class CartItem {
  final String productId;
  final String name;
  final List<String> images;
  final String brand;
  final double price;
  final int quantity;

  CartItem({
    required this.productId,
    required this.name,
    required this.images,
    required this.price,
    required this.quantity,
    required this.brand,
  });

  /// ✅ Properly handles list fields
  CartItem copyWith({
    String? productId,
    String? name,
    List<String>? images,
    String? brand,
    double? price,
    int? quantity,
  }) {
    return CartItem(
      productId: productId ?? this.productId,
      name: name ?? this.name,
      images: images ?? this.images,
      brand: brand ?? this.brand,
      price: price ?? this.price,
      quantity: quantity ?? this.quantity,
    );
  }

  factory CartItem.fromJson(Map<String, dynamic> json) {
    return CartItem(
      productId: json['_id'] as String,
      name: json['name'] as String,
      images: json['image'] is List
          ? List<String>.from(json['image'])
          : [json['image'].toString()],
      price: (json['sp'] as num).toDouble(),
      quantity: json['quantity'] as int,
      brand: json['brand'] is List
          ? (json['brand'] as List).map((b) => b['name']).join(', ')
          : json['brand'].toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'product_id': productId,
      'name': name,
      'image': images,
      'price': price,
      'quantity': quantity,
      'brand': brand,
    };
  }
}
