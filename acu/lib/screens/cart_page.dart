import 'package:acu/screens/components/cart_components/cart_card.dart';
import 'package:acu/screens/components/cart_components/cart_controller.dart';
import 'package:acu/screens/components/cart_components/cart_item.dart';
import 'package:acu/screens/components/cart_components/guestCartController.dart';
import 'package:acu/screens/unified_checkout.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:acu/screens/checkOutCart.dart';
import 'package:get_storage/get_storage.dart';

class CartPage extends StatefulWidget {
  const CartPage({super.key});

  @override
  _CartPageState createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  int itemCount = 0;
  late final CartController cartController;
  late final GuestCartController guestCartController;
  final String? userId = GetStorage().read("userId");

  @override
  void initState() {
    super.initState();
    cartController = Get.put(CartController());
    guestCartController = Get.put(GuestCartController());

    if (userId != null) {
      cartController.fetchCart();
    }

    updateItemCount();
  }

  void updateItemCount() {
    setState(() {
      itemCount = userId == null
          ? guestCartController.itemCount
          : cartController.itemCount;
    });
  }

  @override
  Widget build(BuildContext context) {
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
              final items = userId == null
                  ? guestCartController.cartItems
                  : cartController.cartItems;

              return items.isEmpty
                  ? Center(
                      child: Text(
                        'Your cart is empty!',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.w500),
                      ),
                    )
                  : ListView.builder(
                      itemCount: items.length,
                      itemBuilder: (context, index) {
                        final item = items[index];

                        return CartCard(
                          item: item,
                          cartController: userId == null
                              ? guestCartController
                              : cartController,
                          updateItemCount: updateItemCount,
                        );
                      },
                    );
            }),
          ),
          Obx(() {
            final items = userId == null
                ? guestCartController.cartItems
                : cartController.cartItems;

            double totalAmount = items.fold(
                0, (sum, item) => sum + (item.price * item.quantity));

            return items.isEmpty
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
                              '${items.length} items',
                              style:
                                  TextStyle(fontSize: 14, color: Colors.grey),
                            ),
                          ],
                        ),
                        ElevatedButton(
                          onPressed: () async {
                            print(userId);

                            if (userId != null) {
                              // Refresh cart to make sure latest items are loaded
                              await cartController.fetchCart();
                            }
                            final itemsToSend = userId == null
                                ? guestCartController.cartItems.toList()
                                : cartController.cartItems.toList();

                            Get.to(() => UnifiedCheckoutScreen(
                                  isSingleProduct: false,
                                  cartItems: itemsToSend,
                                ));
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
                        )
                      ],
                    ),
                  );
          }),
        ],
      ),
    );
  }
}
