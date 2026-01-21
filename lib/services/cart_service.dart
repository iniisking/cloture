import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloture/model/cart_item.dart';
import 'package:cloture/services/storage_service.dart';
import 'package:cloture/services/connectivity_service.dart';

class CartService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final StorageService _storageService = StorageService();
  final ConnectivityService _connectivityService = ConnectivityService();

  // Get cart collection reference for a user
  CollectionReference _getCartCollection(String userId) {
    return _firestore.collection('users').doc(userId).collection('cart');
  }

  // Get cart cache key for local storage
  String _getCartCacheKey(String userId) => 'cart_cache_$userId';

  /// Add item to cart (or increment quantity if exists)
  Future<bool> addToCart(String userId, CartItem item) async {
    try {
      final isConnected = await _connectivityService.isConnected();
      
      if (isConnected) {
        // Check if item with same productId, size, color exists
        final querySnapshot = await _getCartCollection(userId)
            .where('productId', isEqualTo: item.productId)
            .where('size', isEqualTo: item.size)
            .where('color', isEqualTo: item.color)
            .limit(1)
            .get();

        if (querySnapshot.docs.isNotEmpty) {
          // Item exists, update quantity
          final docId = querySnapshot.docs.first.id;
          final existingData = querySnapshot.docs.first.data() as Map<String, dynamic>;
          final existingQuantity = existingData['quantity'] as int;
          
          await _getCartCollection(userId).doc(docId).update({
            'quantity': existingQuantity + item.quantity,
            'timestamp': DateTime.now().toIso8601String(),
          });
        } else {
          // New item, add to cart
          await _getCartCollection(userId).add(item.toFirestore());
        }
      }
      
      // Always update local cache (optimistic update)
      await _updateLocalCache(userId);
      return true;
    } catch (e) {
      print('Error adding to cart: $e');
      // Still update local cache on error
      await _updateLocalCache(userId);
      return false;
    }
  }

  /// Remove item from cart
  Future<bool> removeFromCart(String userId, String cartItemId) async {
    try {
      final isConnected = await _connectivityService.isConnected();
      
      if (isConnected) {
        await _getCartCollection(userId).doc(cartItemId).delete();
      }
      
      // Update local cache
      await _updateLocalCache(userId);
      return true;
    } catch (e) {
      print('Error removing from cart: $e');
      await _updateLocalCache(userId);
      return false;
    }
  }

  /// Update item quantity
  Future<bool> updateQuantity(
    String userId,
    String cartItemId,
    int newQuantity,
  ) async {
    try {
      if (newQuantity <= 0) {
        return await removeFromCart(userId, cartItemId);
      }

      final isConnected = await _connectivityService.isConnected();
      
      if (isConnected) {
        await _getCartCollection(userId).doc(cartItemId).update({
          'quantity': newQuantity,
          'timestamp': DateTime.now().toIso8601String(),
        });
      }
      
      // Update local cache
      await _updateLocalCache(userId);
      return true;
    } catch (e) {
      print('Error updating quantity: $e');
      await _updateLocalCache(userId);
      return false;
    }
  }

  /// Clear entire cart
  Future<bool> clearCart(String userId) async {
    try {
      final isConnected = await _connectivityService.isConnected();
      
      if (isConnected) {
        final batch = _firestore.batch();
        final snapshot = await _getCartCollection(userId).get();
        
        for (var doc in snapshot.docs) {
          batch.delete(doc.reference);
        }
        
        await batch.commit();
      }
      
      // Clear local cache
      await _storageService.saveJsonList(_getCartCacheKey(userId), []);
      return true;
    } catch (e) {
      print('Error clearing cart: $e');
      await _storageService.saveJsonList(_getCartCacheKey(userId), []);
      return false;
    }
  }

  /// Get user's cart as a stream (real-time updates)
  Stream<List<CartItem>> getCartStream(String userId) {
    return _getCartCollection(userId)
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return CartItem.fromFirestore(doc.id, doc.data() as Map<String, dynamic>);
      }).toList();
    });
  }

  /// Get user's cart (one-time fetch)
  Future<List<CartItem>> getCart(String userId) async {
    try {
      final isConnected = await _connectivityService.isConnected();
      
      if (isConnected) {
        final snapshot = await _getCartCollection(userId)
            .orderBy('timestamp', descending: true)
            .get();
        
        final items = snapshot.docs.map((doc) {
          return CartItem.fromFirestore(
            doc.id,
            doc.data() as Map<String, dynamic>,
          );
        }).toList();
        
        // Update local cache
        await _saveLocalCache(userId, items);
        return items;
      } else {
        // Offline: return cached data
        return await getCachedCart(userId);
      }
    } catch (e) {
      print('Error getting cart: $e');
      // Return cached data on error
      return await getCachedCart(userId);
    }
  }

  /// Get cached cart from local storage
  Future<List<CartItem>> getCachedCart(String userId) async {
    try {
      final cacheKey = _getCartCacheKey(userId);
      final cachedData = await _storageService.readJsonList(cacheKey);
      
      if (cachedData == null) return [];
      
      return cachedData.map((map) => CartItem.fromMap(map)).toList();
    } catch (e) {
      print('Error getting cached cart: $e');
      return [];
    }
  }

  /// Get total item count in cart
  Future<int> getCartItemCount(String userId) async {
    try {
      final cart = await getCart(userId);
      return cart.fold<int>(0, (sum, item) => sum + item.quantity);
    } catch (e) {
      print('Error getting cart count: $e');
      return 0;
    }
  }

  /// Update local cache with current cart
  Future<void> _updateLocalCache(String userId) async {
    try {
      final cart = await getCart(userId);
      await _saveLocalCache(userId, cart);
    } catch (e) {
      print('Error updating local cache: $e');
    }
  }

  /// Save cart to local cache
  Future<void> _saveLocalCache(String userId, List<CartItem> items) async {
    try {
      final cacheKey = _getCartCacheKey(userId);
      final itemsMap = items.map((item) => item.toMap()).toList();
      await _storageService.saveJsonList(cacheKey, itemsMap);
    } catch (e) {
      print('Error saving local cache: $e');
    }
  }

  /// Sync local cache to Firestore (when connection is restored)
  Future<void> syncCartToFirestore(String userId) async {
    try {
      final isConnected = await _connectivityService.isConnected();
      if (!isConnected) return;

      final cachedItems = await getCachedCart(userId);
      if (cachedItems.isEmpty) return;

      final batch = _firestore.batch();
      final cartRef = _getCartCollection(userId);

      // Clear existing cart in Firestore
      final existingSnapshot = await cartRef.get();
      for (var doc in existingSnapshot.docs) {
        batch.delete(doc.reference);
      }

      // Add cached items to Firestore
      for (var item in cachedItems) {
        final docRef = cartRef.doc();
        batch.set(docRef, item.toFirestore());
      }

      await batch.commit();
    } catch (e) {
      print('Error syncing cart to Firestore: $e');
    }
  }
}
