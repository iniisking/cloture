import 'package:cloture/utils/logger.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Fetch categories from Firestore
  Future<List<Map<String, String>>> fetchCategories() async {
    try {
      QuerySnapshot querySnapshot = await _firestore
          .collection('categories')
          .get();
      List<Map<String, String>> fetchedCategories = querySnapshot.docs.map((
        doc,
      ) {
        return {
          'name': doc['name'] as String,
          'imageUrl': doc['imageUrl'] as String,
        };
      }).toList();
      return fetchedCategories;
    } catch (e) {
      AppLogger.error('Error fetching categories', e);
      return [];
    }
  }

  // Fetch top-selling products from Firestore
  Future<List<Map<String, String>>> fetchTopSellingProducts() async {
    try {
      QuerySnapshot querySnapshot = await _firestore
          .collection('products')
          .where('topSelling', isEqualTo: true)
          .get();
      List<Map<String, String>> fetchedTopSellingProducts = querySnapshot.docs
          .map((doc) {
            return {
              'id': doc.id, // Include document ID
              'name': doc['name'] as String,
              'price': doc['price'] as String,
              'imageUrl': doc['imageUrl'] as String,
            };
          })
          .toList();
      return fetchedTopSellingProducts;
    } catch (e) {
      AppLogger.error('Error fetching top-selling products', e);
      return [];
    }
  }

  // Fetch new-in products from Firestore
  Future<List<Map<String, String>>> fetchNewInProducts() async {
    try {
      QuerySnapshot querySnapshot = await _firestore
          .collection('products')
          .where('newIn', isEqualTo: true)
          .get();
      List<Map<String, String>> fetchedNewInProducts = querySnapshot.docs.map((
        doc,
      ) {
        return {
          'id': doc.id, // Include document ID
          'name': doc['name'] as String,
          'price': doc['price'] as String,
          'imageUrl': doc['imageUrl'] as String,
        };
      }).toList();
      return fetchedNewInProducts;
    } catch (e) {
      AppLogger.error('Error fetching new-in products', e);
      return [];
    }
  }
}
