// lib/models/ordermodel.dart

class Order {
  final String id;
  final double total;
  final String status;
  final DateTime createdAt;

  final List<OrderProduct> products;

  Order({
    required this.id,
    required this.total,
    required this.status,
    required this.createdAt,
    required this.products,
  });

  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      id: json['_id'] ?? '',
      total: (json['total'] ?? 0).toDouble(),
      status: json['status'] ?? 'Pending',
      createdAt:
          DateTime.parse(json['createdAt']), // assuming `createdAt` exists

      products: (json['products'] as List<dynamic>)
          .map((item) => OrderProduct.fromJson(item))
          .toList(),
    );
  }
}

class OrderProduct {
  final String name;
  final String image;
  final int quantity;
  final double price;

  OrderProduct({
    required this.name,
    required this.image,
    required this.quantity,
    required this.price,
  });

  factory OrderProduct.fromJson(Map<String, dynamic> json) {
    final productJson = json['productId'] ?? {};

    return OrderProduct(
      name: productJson['name'] ?? 'No Name',
      image: productJson['featuredImage']?['url'] ?? '',
      quantity: json['quantity'] ?? 0,
      price: (productJson['sp'] ?? 0).toDouble(),
    );
  }
}
