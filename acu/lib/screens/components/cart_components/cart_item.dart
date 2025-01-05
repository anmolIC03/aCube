class CartItem {
  final String name;
  final String image;
  final String brand;
  final double price;
  int quantity;

  CartItem({
    required this.name,
    required this.image,
    required this.brand,
    required this.price,
    this.quantity = 1,
  });

  // Increment item quantity
  void incrementQuantity() {
    quantity += 1;
  }

  // Decrement item quantity
  void decrementQuantity() {
    if (quantity > 1) {
      quantity -= 1;
    }
  }
}
