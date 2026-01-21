class CartItem {
  final String id; // Auto-generated Firestore document ID
  final String productId; // Firestore product document ID
  final String name;
  final String imageUrl;
  final double price;
  final String size;
  final String color;
  final int quantity;
  final DateTime timestamp;

  CartItem({
    required this.id,
    required this.productId,
    required this.name,
    required this.imageUrl,
    required this.price,
    required this.size,
    required this.color,
    required this.quantity,
    required this.timestamp,
  });

  // Convert to Map for Firestore
  Map<String, dynamic> toFirestore() {
    return {
      'productId': productId,
      'name': name,
      'imageUrl': imageUrl,
      'price': price,
      'size': size,
      'color': color,
      'quantity': quantity,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  // Create from Firestore document
  factory CartItem.fromFirestore(String id, Map<String, dynamic> data) {
    return CartItem(
      id: id,
      productId: data['productId'] as String,
      name: data['name'] as String,
      imageUrl: data['imageUrl'] as String,
      price: (data['price'] as num).toDouble(),
      size: data['size'] as String,
      color: data['color'] as String,
      quantity: data['quantity'] as int,
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
      'size': size,
      'color': color,
      'quantity': quantity,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  // Create from Map (for local storage)
  factory CartItem.fromMap(Map<String, dynamic> map) {
    return CartItem(
      id: map['id'] as String,
      productId: map['productId'] as String,
      name: map['name'] as String,
      imageUrl: map['imageUrl'] as String,
      price: (map['price'] as num).toDouble(),
      size: map['size'] as String,
      color: map['color'] as String,
      quantity: map['quantity'] as int,
      timestamp: DateTime.parse(map['timestamp'] as String),
    );
  }

  // Create a copy with updated quantity
  CartItem copyWith({
    String? id,
    String? productId,
    String? name,
    String? imageUrl,
    double? price,
    String? size,
    String? color,
    int? quantity,
    DateTime? timestamp,
  }) {
    return CartItem(
      id: id ?? this.id,
      productId: productId ?? this.productId,
      name: name ?? this.name,
      imageUrl: imageUrl ?? this.imageUrl,
      price: price ?? this.price,
      size: size ?? this.size,
      color: color ?? this.color,
      quantity: quantity ?? this.quantity,
      timestamp: timestamp ?? this.timestamp,
    );
  }

  // Check if two items are the same (same product, size, color)
  bool isSameItem(CartItem other) {
    return productId == other.productId &&
        size == other.size &&
        color == other.color;
  }
}
