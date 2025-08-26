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
    final id = json['_id'] ?? json['productId'] ?? '';
    final imagesRaw = json['image'] ?? json['images'] ?? [];
    final brandRaw = json['brand'];

    return CartItem(
      productId: id.toString(),
      name: json['name']?.toString() ?? '',
      images: imagesRaw is List
          ? List<String>.from(imagesRaw.map((e) => e.toString()))
          : [imagesRaw?.toString() ?? ''],
      price: (json['sp'] != null)
          ? (json['sp'] as num).toDouble()
          : (json['price'] != null)
              ? (json['price'] as num).toDouble()
              : 0.0,
      quantity: json['quantity'] is int ? json['quantity'] : 1,
      brand: brandRaw is List
          ? (brandRaw as List).map((b) => b['name']).join(', ')
          : brandRaw?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'productId': productId,
      'name': name,
      'image': images,
      'price': price,
      'quantity': quantity,
      'brand': brand,
    };
  }
}
