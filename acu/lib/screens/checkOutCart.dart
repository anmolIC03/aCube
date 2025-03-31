import 'dart:convert';
import 'package:acu/screens/pay_methods.dart';
import 'package:flutter/material.dart';
import 'package:acu/screens/components/cart_components/cart_item.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:get_storage/get_storage.dart';

class CheckOutCart extends StatelessWidget {
  final List<CartItem> cartItems;
  final storage = GetStorage();

  CheckOutCart({Key? key, required this.cartItems}) : super(key: key) {
    fetchCharges();
  }

  /// **Get total price of products in the cart**
  double get totalProductPrice =>
      cartItems.fold(0, (sum, item) => sum + (item.price * item.quantity));

  final RxDouble deliveryCharges = 0.0.obs;
  final RxDouble codCharges = 0.0.obs;

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
          /// **Product List**
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
                          item.images.first,
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

          /// **Bottom Section - Total Price & Proceed Button**
          Obx(() {
            if (deliveryCharges.value == 0.0 && codCharges.value == 0.0) {
              return Padding(
                padding: EdgeInsets.symmetric(vertical: 12),
                child: Center(
                  child: CircularProgressIndicator(),
                ),
              );
            }

            double totalAmount =
                totalProductPrice + deliveryCharges.value + codCharges.value;

            return Container(
              padding: EdgeInsets.symmetric(vertical: 12, horizontal: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(color: Colors.grey.shade300, blurRadius: 5)
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  /// **Total Price + View Details**
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Total: ₹${totalAmount.toStringAsFixed(2)}',
                        style: TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      TextButton(
                        onPressed: () => showDetailsBottomSheet(context),
                        child: Text(
                          "View Details",
                          style: TextStyle(
                              color: Colors.blue,
                              fontSize: 16,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),

                  /// **Proceed Button**
                  ElevatedButton(
                    onPressed: () async {
                      await checkAddressAndProceed(totalAmount);
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
            );
          })
        ],
      ),
    );
  }

  /// **Show Order Summary**
  void showDetailsBottomSheet(BuildContext context) {
    Get.bottomSheet(
      Obx(() {
        double totalAmount =
            totalProductPrice + deliveryCharges.value + codCharges.value;

        return Container(
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                "Order Summary",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              Divider(),
              ListTile(
                title: Text("Subtotal"),
                trailing: Text("₹${totalProductPrice.toStringAsFixed(2)}"),
              ),
              ListTile(
                title: Text("Delivery Charges"),
                trailing: Text("₹${deliveryCharges.value.toStringAsFixed(2)}"),
              ),
              ListTile(
                title: Text("COD Charges"),
                trailing: Text("₹${codCharges.value.toStringAsFixed(2)}"),
              ),
              Divider(),
              ListTile(
                title: Text(
                  "Grand Total",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                trailing: Text(
                  "₹${totalAmount.toStringAsFixed(2)}",
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.green),
                ),
              ),
              SizedBox(height: 10),
              ElevatedButton(
                onPressed: () => Get.back(),
                child: Text("Close"),
              ),
            ],
          ),
        );
      }),
      isScrollControlled: true,
    );
  }

  /// **Fetch Charges from API**
  Future<void> fetchCharges() async {
    try {
      final response = await http.get(
        Uri.parse('https://backend.acubemart.in/api/product/all'),
        headers: {"Content-Type": "application/json"},
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);

        if (data.containsKey('data') && data['data'] is List) {
          final List<dynamic> products = data['data'];

          double maxDeliveryCharges = 0.0;
          double maxCodCharges = 0.0;

          for (var cartItem in cartItems) {
            final product = products.firstWhere(
              (prod) => prod['_id'] == cartItem.productId,
              orElse: () => null,
            );

            if (product != null) {
              double deliveryCharge =
                  (product['deliveryCharges'] as num).toDouble();
              double codCharge = (product['codCharges'] as num).toDouble();
              maxDeliveryCharges = deliveryCharge > maxDeliveryCharges
                  ? deliveryCharge
                  : maxDeliveryCharges;

              maxCodCharges =
                  codCharge > maxCodCharges ? codCharge : maxCodCharges;
            }
          }

          deliveryCharges.value = maxDeliveryCharges;
          codCharges.value = maxCodCharges;
        }
      }
    } catch (e) {
      print("Error fetching charges: $e");
    }
  }

  /// **Check Address and Proceed**
  Future<void> checkAddressAndProceed(double totalAmount) async {
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

      if (response.statusCode == 200) {
        final decodedResponse = json.decode(response.body);
        final user = decodedResponse["data"];

        if (user["address"] is List && user["address"].isNotEmpty) {
          final addressId = user["address"][0]["_id"];
          final phone = user["phone"] ?? "";

          Get.to(() => PaymentMethodsScreen(
                products: cartItems
                    .map((item) => {
                          "productId": item.productId,
                          "quantity": item.quantity
                        })
                    .toList(),
                addressId: addressId,
                phone: phone,
                totalAmount: totalProductPrice.toInt(),
              ));
        } else {
          Get.defaultDialog(
              title: "Address Required",
              middleText: "Enter address details before proceeding.");
        }
      }
    } catch (e) {
      Get.snackbar("Error", "Something went wrong: ${e.toString()}");
    }
  }
}
