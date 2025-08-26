import 'package:flutter/material.dart';
import 'package:acu/screens/components/cart_components/cart_item.dart';
import 'package:acu/screens/components/cart_components/cart_controller.dart';
import 'package:acu/screens/components/cart_components/guestCartController.dart';
import 'package:get_storage/get_storage.dart';

class CartCard extends StatelessWidget {
  final CartItem item;
  final dynamic
      cartController; // <-- allows CartController or GuestCartController
  final VoidCallback updateItemCount;

  const CartCard({
    super.key,
    required this.item,
    required this.cartController,
    required this.updateItemCount,
  });

  @override
  Widget build(BuildContext context) {
    final String? userId = GetStorage().read("userId");

    return Card(
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      child: Container(
        height: 200,
        padding: EdgeInsets.all(8),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 4, top: 10, bottom: 10),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  item.images.isNotEmpty && item.images.first.isNotEmpty
                      ? item.images.first
                      : 'https://via.placeholder.com/150', // fallback URL
                  width: 150,
                  height: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      width: 150,
                      color: Colors.grey[300],
                      child: Icon(Icons.broken_image,
                          size: 40, color: Colors.grey[700]),
                    );
                  },
                ),
              ),
            ),
            SizedBox(width: 12),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(top: 14, left: 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      item.name,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      'Price: ₹${item.price}',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey.shade700,
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        IconButton(
                          icon: Icon(Icons.remove_circle),
                          onPressed: () async {
                            if (item.quantity > 1) {
                              if (userId == null) {
                                cartController.decrement(item.productId);
                              } else {
                                await cartController.updateQuantity(
                                    item.productId, item.quantity - 1);
                              }
                            } else {
                              if (userId == null) {
                                cartController.removeFromCart(item.productId);
                              } else {
                                await cartController.removeItem(item.productId);
                              }
                            }
                            updateItemCount();
                          },
                        ),
                        Text(
                          '${item.quantity}',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        IconButton(
                          icon: Icon(Icons.add_circle),
                          onPressed: () async {
                            if (userId == null) {
                              cartController.increment(item.productId);
                            } else {
                              await cartController.updateQuantity(
                                  item.productId, item.quantity + 1);
                            }
                            updateItemCount();
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
