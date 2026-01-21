import 'package:cloture/utils/logger.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloture/model/favorite_item.dart';
import 'package:cloture/services/storage_service.dart';
import 'package:cloture/services/connectivity_service.dart';

class FavoritesService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final StorageService _storageService = StorageService();
  final ConnectivityService _connectivityService = ConnectivityService();

  // Get favorites collection reference for a user
  CollectionReference _getFavoritesCollection(String userId) {
    return _firestore.collection('users').doc(userId).collection('favorites');
  }

  // Get favorites cache key for local storage
  String _getFavoritesCacheKey(String userId) => 'favorites_cache_$userId';

  /// Add product to favorites
  Future<bool> addToFavorites(String userId, FavoriteItem item) async {
    try {
      final isConnected = await _connectivityService.isConnected();
      
      if (isConnected) {
        // Check if product is already in favorites
        final querySnapshot = await _getFavoritesCollection(userId)
            .where('productId', isEqualTo: item.productId)
            .limit(1)
            .get();

        if (querySnapshot.docs.isEmpty) {
          // Not in favorites, add it
          await _getFavoritesCollection(userId).add(item.toFirestore());
        }
        // If already exists, do nothing (idempotent)
      }
      
      // Always update local cache (optimistic update)
      await _updateLocalCache(userId);
      return true;
    } catch (e) {
      AppLogger.error('Error adding to favorites', e);
      // Still update local cache on error
      await _updateLocalCache(userId);
      return false;
    }
  }

  /// Remove product from favorites
  Future<bool> removeFromFavorites(String userId, String favoriteItemId) async {
    try {
      final isConnected = await _connectivityService.isConnected();
      
      if (isConnected) {
        await _getFavoritesCollection(userId).doc(favoriteItemId).delete();
      }
      
      // Update local cache
      await _updateLocalCache(userId);
      return true;
    } catch (e) {
      AppLogger.error('Error removing from favorites', e);
      await _updateLocalCache(userId);
      return false;
    }
  }

  /// Remove product from favorites by productId
  Future<bool> removeByProductId(String userId, String productId) async {
    try {
      final isConnected = await _connectivityService.isConnected();
      
      if (isConnected) {
        final querySnapshot = await _getFavoritesCollection(userId)
            .where('productId', isEqualTo: productId)
            .limit(1)
            .get();

        if (querySnapshot.docs.isNotEmpty) {
          await querySnapshot.docs.first.reference.delete();
        }
      }
      
      // Update local cache
      await _updateLocalCache(userId);
      return true;
    } catch (e) {
      AppLogger.error('Error removing from favorites by productId', e);
      await _updateLocalCache(userId);
      return false;
    }
  }

  /// Check if product is in favorites
  Future<bool> isFavorite(String userId, String productId) async {
    try {
      final isConnected = await _connectivityService.isConnected();
      
      if (isConnected) {
        final querySnapshot = await _getFavoritesCollection(userId)
            .where('productId', isEqualTo: productId)
            .limit(1)
            .get();
        
        return querySnapshot.docs.isNotEmpty;
      } else {
        // Check cache if offline
        final cachedFavorites = await getCachedFavorites(userId);
        return cachedFavorites.any((item) => item.productId == productId);
      }
    } catch (e) {
      AppLogger.error('Error checking if favorite', e);
      return false;
    }
  }

  /// Clear all favorites
  Future<bool> clearFavorites(String userId) async {
    try {
      final isConnected = await _connectivityService.isConnected();
      
      if (isConnected) {
        final batch = _firestore.batch();
        final snapshot = await _getFavoritesCollection(userId).get();
        
        for (var doc in snapshot.docs) {
          batch.delete(doc.reference);
        }
        
        await batch.commit();
      }
      
      // Clear local cache
      await _storageService.saveJsonList(_getFavoritesCacheKey(userId), []);
      return true;
    } catch (e) {
      AppLogger.error('Error clearing favorites', e);
      await _storageService.saveJsonList(_getFavoritesCacheKey(userId), []);
      return false;
    }
  }

  /// Get user's favorites as a stream (real-time updates)
  Stream<List<FavoriteItem>> getFavoritesStream(String userId) {
    return _getFavoritesCollection(userId)
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return FavoriteItem.fromFirestore(
          doc.id,
          doc.data() as Map<String, dynamic>,
        );
      }).toList();
    });
  }

  /// Get user's favorites (one-time fetch)
  Future<List<FavoriteItem>> getFavorites(String userId) async {
    try {
      final isConnected = await _connectivityService.isConnected();
      
      if (isConnected) {
        final snapshot = await _getFavoritesCollection(userId)
            .orderBy('timestamp', descending: true)
            .get();
        
        final items = snapshot.docs.map((doc) {
          return FavoriteItem.fromFirestore(
            doc.id,
            doc.data() as Map<String, dynamic>,
          );
        }).toList();
        
        // Update local cache
        await _saveLocalCache(userId, items);
        return items;
      } else {
        // Offline: return cached data
        return await getCachedFavorites(userId);
      }
    } catch (e) {
      AppLogger.error('Error getting favorites', e);
      // Return cached data on error
      return await getCachedFavorites(userId);
    }
  }

  /// Get cached favorites from local storage
  Future<List<FavoriteItem>> getCachedFavorites(String userId) async {
    try {
      final cacheKey = _getFavoritesCacheKey(userId);
      final cachedData = await _storageService.readJsonList(cacheKey);
      
      if (cachedData == null) return [];
      
      return cachedData.map((map) => FavoriteItem.fromMap(map)).toList();
    } catch (e) {
      AppLogger.error('Error getting cached favorites', e);
      return [];
    }
  }

  /// Update local cache with current favorites
  Future<void> _updateLocalCache(String userId) async {
    try {
      final favorites = await getFavorites(userId);
      await _saveLocalCache(userId, favorites);
    } catch (e) {
      AppLogger.error('Error updating local cache', e);
    }
  }

  /// Save favorites to local cache
  Future<void> _saveLocalCache(String userId, List<FavoriteItem> items) async {
    try {
      final cacheKey = _getFavoritesCacheKey(userId);
      final itemsMap = items.map((item) => item.toMap()).toList();
      await _storageService.saveJsonList(cacheKey, itemsMap);
    } catch (e) {
      AppLogger.error('Error saving local cache', e);
    }
  }

  /// Sync local cache to Firestore (when connection is restored)
  Future<void> syncFavoritesToFirestore(String userId) async {
    try {
      final isConnected = await _connectivityService.isConnected();
      if (!isConnected) return;

      final cachedItems = await getCachedFavorites(userId);
      if (cachedItems.isEmpty) return;

      final batch = _firestore.batch();
      final favoritesRef = _getFavoritesCollection(userId);

      // Clear existing favorites in Firestore
      final existingSnapshot = await favoritesRef.get();
      for (var doc in existingSnapshot.docs) {
        batch.delete(doc.reference);
      }

      // Add cached items to Firestore
      for (var item in cachedItems) {
        final docRef = favoritesRef.doc();
        batch.set(docRef, item.toFirestore());
      }

      await batch.commit();
    } catch (e) {
      AppLogger.error('Error syncing favorites to Firestore', e);
    }
  }
}
