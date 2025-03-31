import 'package:acu/screens/components/cart_components/cart_card.dart';
import 'package:acu/screens/components/cart_components/cart_controller.dart';
import 'package:acu/screens/components/cart_components/cart_item.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:acu/screens/checkOutCart.dart';

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
    Get.find<CartController>().fetchCart();
  }

  void updateItemCount() {
    setState(() {
      itemCount = Get.find<CartController>().itemCount;
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
      body: Column(
        children: [
          Expanded(
            child: Obx(() {
              return cartController.cartItems.isEmpty
                  ? Center(
                      child: Text(
                        'Your cart is empty!',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.w500),
                      ),
                    )
                  : ListView.builder(
                      itemCount: cartController.cartItems.length,
                      itemBuilder: (context, index) {
                        final item = cartController.cartItems[index];
                        return CartCard(
                          item: item,
                          cartController: cartController,
                          updateItemCount: updateItemCount,
                        );
                      },
                    );
            }),
          ),
          Obx(() {
            double totalAmount = cartController.cartItems
                .fold(0, (sum, item) => sum + (item.price * item.quantity));

            return cartController.cartItems.isEmpty
                ? SizedBox.shrink()
                : Container(
                    padding: EdgeInsets.symmetric(vertical: 25, horizontal: 16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius:
                          BorderRadius.vertical(top: Radius.circular(12)),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black12,
                          blurRadius: 6,
                          spreadRadius: 1,
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Total: ₹${totalAmount.toStringAsFixed(2)}',
                              style: TextStyle(
                                  fontSize: 20, fontWeight: FontWeight.bold),
                            ),
                            Text(
                              '${cartController.itemCount} items',
                              style:
                                  TextStyle(fontSize: 14, color: Colors.grey),
                            ),
                          ],
                        ),
                        ElevatedButton(
                          onPressed: () {
                            List<CartItem> cartItems =
                                cartController.cartItems.toList();
                            Get.to(() => CheckOutCart(cartItems: cartItems));
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Color.fromRGBO(185, 28, 28, 1.0),
                            padding: EdgeInsets.symmetric(
                                horizontal: 20, vertical: 12),
                          ),
                          child: Text(
                            'Place Order',
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                  );
          }),
        ],
      ),
    );
  }
}
