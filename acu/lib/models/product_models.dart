class Product {
  String id;
  String name;
  double price;
  String description;
  int stock;
  String imageUrl;
  String category;
  String brand;
  String model;
  double discount;
  double sp;
  double rating; // Placeholder
  int ratingCount; // Placeholder

  Product({
    required this.id,
    required this.name,
    required this.price,
    required this.description,
    required this.stock,
    required this.imageUrl,
    required this.category,
    required this.brand,
    required this.model,
    required this.discount,
    required this.sp,
    this.rating = 0.0, // Default value
    this.ratingCount = 0, // Default value
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['_id'] ?? '',
      name: json['name'] ?? 'Unknown Product',
      price: (json['price'] != null)
          ? double.tryParse(json['price'].toString()) ?? 0.0
          : 0.0,
      description: json['description'] ?? '',
      stock: json['stock'] ?? 0,
      imageUrl: json['featuredImage']?['url'] ?? '',
      category: json['category']?.isNotEmpty == true
          ? json['category'][0]['name']
          : 'Unknown Category',
      brand: json['brand']?.isNotEmpty == true
          ? json['brand'][0]['name']
          : 'Unknown Brand',
      model: json['model']?.isNotEmpty == true
          ? json['model'][0]['name']
          : 'Unknown Model',
      discount: (json['discount'] != null)
          ? double.tryParse(json['discount'].toString()) ?? 0.0
          : 0.0,
      sp: (json['sp'] != null)
          ? double.tryParse(json['sp'].toString()) ?? 0.0
          : 0.0,
      rating: 0.0,
      ratingCount: 0,
    );
  }
}
