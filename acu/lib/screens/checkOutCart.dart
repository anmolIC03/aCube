import 'dart:convert';
import 'package:acu/screens/pay_methods.dart';
import 'package:flutter/material.dart';
import 'package:acu/screens/components/cart_components/cart_item.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:get_storage/get_storage.dart';

class CheckOutCart extends StatelessWidget {
  final List<CartItem> cartItems;
  final storage = GetStorage(); // Local storage for user ID

  CheckOutCart({Key? key, required this.cartItems}) : super(key: key);

  double get totalProductPrice =>
      cartItems.fold(0, (sum, item) => sum + (item.price * item.quantity));

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 3,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new),
          onPressed: () => Get.back(),
        ),
        title: Text(
          'Checkout',
          style: TextStyle(fontSize: 26, fontWeight: FontWeight.w700),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: cartItems.length,
              itemBuilder: (context, index) {
                final item = cartItems[index];
                return Card(
                  margin: EdgeInsets.only(bottom: 10),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: ListTile(
                    leading: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.network(
                          item.image,
                          width: 60,
                          height: 60,
                          fit: BoxFit.cover,
                        )),
                    title: Text(
                      item.name,
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(
                      "₹${item.price} x ${item.quantity}",
                      style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                    ),
                    trailing: Text(
                      "₹${(item.price * item.quantity).toStringAsFixed(2)}",
                      style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.black),
                    ),
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Total: ₹${totalProductPrice.toStringAsFixed(2)}',
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () async {
                        await checkAddressAndProceed();
                      },
                      style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                        backgroundColor: Color.fromRGBO(185, 28, 28, 1.0),
                        padding:
                            EdgeInsets.symmetric(horizontal: 30, vertical: 12),
                      ),
                      child: Text(
                        'Proceed',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> checkAddressAndProceed() async {
    try {
      final userId = storage.read("userId");
      if (userId == null) {
        Get.snackbar("Error", "No logged-in user found!");
        return;
      }

      final response = await http.get(
        Uri.parse('https://backend.acubemart.in/api/user/$userId'),
        headers: {"Content-Type": "application/json"},
      );

      print("Fetch Address Response Status: ${response.statusCode}");
      print("Raw Response Body: ${response.body}");

      if (response.statusCode == 200) {
        final decodedResponse = json.decode(response.body);

        if (decodedResponse is Map && decodedResponse.containsKey("data")) {
          final user = decodedResponse["data"];

          if (user != null &&
              user.containsKey("address") &&
              user["address"] is List &&
              user["address"].isNotEmpty) {
            // ✅ Address exists, extract details
            final address = user["address"][0];
            final String addressId = address["_id"];
            final String phone = user["phone"] ?? "";

            for (var item in cartItems) {
              print(
                  "CartItem -> id: ${item.productId}, name: ${item.name}, quantity: ${item.quantity}");
            }

            // Prepare list of products with their IDs
            List<Map<String, dynamic>> products = cartItems
                .map((item) => {
                      "productId": item.productId,
                      "quantity": item.quantity,
                    })
                .toList();

            Get.to(() => PaymentMethodsScreen(
                  products: products,
                  addressId: addressId,
                  phone: phone,
                  totalAmount: totalProductPrice.toInt(),
                ));
          } else {
            // ❌ No address found, show popup
            Get.defaultDialog(
              title: "Address Required",
              middleText: "Enter address details before proceeding.",
              textConfirm: "OK",
              confirmTextColor: Colors.white,
              onConfirm: () => Get.back(),
            );
          }
        } else {
          Get.snackbar("Error", "Invalid API response: 'data' key missing.");
        }
      } else {
        Get.snackbar("Error", "Failed to load user details");
      }
    } catch (e, stacktrace) {
      print("Error: $e\nStacktrace: $stacktrace");
      Get.snackbar("Error", "Something went wrong: ${e.toString()}");
    }
  }
}
