class FavoriteItem {
  final String id; // Auto-generated Firestore document ID
  final String productId; // Firestore product document ID
  final String name;
  final String imageUrl;
  final double price;
  final DateTime timestamp;

  FavoriteItem({
    required this.id,
    required this.productId,
    required this.name,
    required this.imageUrl,
    required this.price,
    required this.timestamp,
  });

  // Convert to Map for Firestore
  Map<String, dynamic> toFirestore() {
    return {
      'productId': productId,
      'name': name,
      'imageUrl': imageUrl,
      'price': price,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  // Create from Firestore document
  factory FavoriteItem.fromFirestore(String id, Map<String, dynamic> data) {
    return FavoriteItem(
      id: id,
      productId: data['productId'] as String,
      name: data['name'] as String,
      imageUrl: data['imageUrl'] as String,
      price: (data['price'] as num).toDouble(),
      timestamp: DateTime.parse(data['timestamp'] as String),
    );
  }

  // Convert to Map for local storage (SharedPreferences)
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'productId': productId,
      'name': name,
      'imageUrl': imageUrl,
      'price': price,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  // Create from Map (for local storage)
  factory FavoriteItem.fromMap(Map<String, dynamic> map) {
    return FavoriteItem(
      id: map['id'] as String,
      productId: map['productId'] as String,
      name: map['name'] as String,
      imageUrl: map['imageUrl'] as String,
      price: (map['price'] as num).toDouble(),
      timestamp: DateTime.parse(map['timestamp'] as String),
    );
  }
}
