import 'package:acu/screens/components/cart_components/cart_controller.dart';
import 'package:acu/screens/components/cart_components/cart_item.dart';
import 'package:flutter/material.dart';

class CartCard extends StatelessWidget {
  final CartItem item;
  final CartController cartController;
  final VoidCallback updateItemCount;

  const CartCard({
    super.key,
    required this.item,
    required this.cartController,
    required this.updateItemCount,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      child: Container(
        height: 280,
        child: ListTile(
          contentPadding: EdgeInsets.all(8),
          leading: Image.network(item.image,
              width: 100, height: 120, fit: BoxFit.fill),
          title: Text(item.name),
          subtitle: Text('Quantity: ${item.quantity}\nPrice: \$${item.price}'),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: Icon(Icons.remove_circle),
                onPressed: () {
                  cartController.removeItem(item.name);
                  updateItemCount();
                },
              ),
              IconButton(
                icon: Icon(Icons.add_circle),
                onPressed: () {
                  cartController.addItem(item);
                  updateItemCount();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
