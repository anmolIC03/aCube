import 'package:acu/screens/components/cart_components/cart_card.dart';
import 'package:acu/screens/components/cart_components/cart_controller.dart';
import 'package:acu/screens/components/cart_components/cart_item.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CartPage extends StatefulWidget {
  const CartPage({super.key});

  @override
  _CartPageState createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  int itemCount = 0;

  @override
  void initState() {
    super.initState();
    updateItemCount();
  }

  // Update the total item count
  void updateItemCount() {
    setState(() {
      itemCount = Get.find<CartController>().calculateItemCount();
    });
  }

  @override
  Widget build(BuildContext context) {
    final CartController cartController = Get.find<CartController>();

    return Scaffold(
      backgroundColor: Colors.grey.shade300,
      appBar: AppBar(
        elevation: 2,
        backgroundColor: Colors.white,
        title: Text(
          'CART',
          style: TextStyle(fontSize: 30, fontWeight: FontWeight.w900),
        ),
        leading: IconButton(
          onPressed: () => Get.back(),
          icon: Icon(Icons.arrow_back_ios_new, size: 28),
        ),
      ),
      body: Obx(() {
        print("Cart Items: ${cartController.cartItems}");
        return cartController.cartItems.isEmpty
            ? Center(
                child: Text(
                  'Your cart is empty!',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
                ),
              )
            : ListView.builder(
                itemCount: cartController.cartItems.length,
                itemBuilder: (context, index) {
                  final item = cartController.cartItems.values.toList()[index];
                  return CartCard(
                    item: item,
                    cartController: cartController,
                    updateItemCount: updateItemCount,
                  );
                },
              );
      }),
    );
  }
}
