class Product {
  String id;
  String name;
  double price;
  String description;
  int stock;
  List<String> images;
  String category;
  String brand;
  String model;
  double discount;
  double sp;
  double codCharges;
  double deliveryCharges;
  double rating;
  int ratingCount;

  Product({
    required this.id,
    required this.name,
    required this.price,
    required this.description,
    required this.stock,
    required this.images,
    required this.category,
    required this.brand,
    required this.model,
    required this.discount,
    required this.sp,
    required this.codCharges,
    required this.deliveryCharges,
    this.rating = 0.0,
    this.ratingCount = 0,
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
      images: (json['image'] != null && json['image'] is List)
          ? List<String>.from(
              json['image'].map((img) => img['url']).whereType<String>())
          : [],
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
      codCharges: (json['codCharges'] != null)
          ? double.tryParse(json['codCharges'].toString()) ?? 0.0
          : 0.0,
      deliveryCharges: (json['deliveryCharges'] != null)
          ? double.tryParse(json['deliveryCharges'].toString()) ?? 0.0
          : 0.0,
      rating: 0.0,
      ratingCount: 0,
    );
  }
}
