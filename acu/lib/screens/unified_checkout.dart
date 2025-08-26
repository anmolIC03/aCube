import 'dart:convert';

import 'package:acu/screens/order.dart';
import 'package:acu/screens/order_screen.dart';
import 'package:acu/screens/otpSheet.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;

import 'components/cart_components/cart_item.dart';

class UnifiedCheckoutScreen extends StatefulWidget {
  final bool isSingleProduct;
  final CartItem? singleItem;
  final List<CartItem>? cartItems;
  final double? deliveryChargeOverride;
  final double? codChargeOverride;

  const UnifiedCheckoutScreen({
    Key? key,
    required this.isSingleProduct,
    this.singleItem,
    this.cartItems,
    this.deliveryChargeOverride,
    this.codChargeOverride,
  }) : super(key: key);

  @override
  State<UnifiedCheckoutScreen> createState() => _UnifiedCheckoutScreenState();
}

class _UnifiedCheckoutScreenState extends State<UnifiedCheckoutScreen> {
  final storage = GetStorage();
  final RxDouble deliveryCharges = 0.0.obs;
  final RxDouble codCharges = 0.0.obs;

  List<CartItem> get items {
    if (widget.isSingleProduct) {
      return widget.singleItem != null ? [widget.singleItem!] : [];
    } else {
      return widget.cartItems ?? [];
    }
  }

  double get totalProductPrice =>
      items.fold(0, (sum, item) => sum + (item.price * item.quantity));

  @override
  void initState() {
    super.initState();
    fetchCharges();
  }

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
              itemCount: items.length,
              itemBuilder: (context, index) {
                final item = items[index];
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
                      ),
                    ),
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

          /// Total + Proceed
          Obx(() {
            if (deliveryCharges.value == 0.0 && codCharges.value == 0.0) {
              return Padding(
                padding: EdgeInsets.symmetric(vertical: 12),
                child: Center(child: CircularProgressIndicator()),
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
                  /// Total and Details
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

                  /// Proceed
                  ElevatedButton(
                    onPressed: () => checkAddressAndProceed(totalAmount),
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
          }),
        ],
      ),
    );
  }

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
              Text("Order Summary",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
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

  Future<void> fetchCharges() async {
    try {
      if (widget.deliveryChargeOverride != null &&
          widget.codChargeOverride != null) {
        deliveryCharges.value = widget.deliveryChargeOverride!;
        codCharges.value = widget.codChargeOverride!;
        return;
      }

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

          for (var cartItem in items) {
            final product = products.firstWhere(
              (prod) => prod['_id'] == cartItem.productId,
              orElse: () => null,
            );

            if (product != null) {
              double deliveryCharge =
                  (product['deliveryCharges'] as num?)?.toDouble() ?? 0.0;
              double codCharge =
                  (product['codCharges'] as num?)?.toDouble() ?? 0.0;

              if (deliveryCharge > maxDeliveryCharges) {
                maxDeliveryCharges = deliveryCharge;
              }
              if (codCharge > maxCodCharges) {
                maxCodCharges = codCharge;
              }
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

  Future<void> checkAddressAndProceed(double totalAmount) async {
    final userId = storage.read("userId");

    if (userId == null) {
      // Navigate to OTP login and pass custom onSuccess for checkout
      Get.to(() => OtpLoginScreen(
            onSuccess: (userData) {
              storage.write("userId", userData["_id"]);

              Get.to(() => OrderConfirmScreenAlt(
                    orderedItems: items.map((item) => item.toJson()).toList(),
                    userData: userData,
                    deliveryCharges: deliveryCharges.value,
                    codCharges: codCharges.value,
                  ));
            },
          ));
      return;
    }

    try {
      final response = await http.get(
        Uri.parse('https://backend.acubemart.in/api/user/$userId'),
        headers: {"Content-Type": "application/json"},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true && data['data'] != null) {
          final userData = data['data'];

          Get.to(() => OrderConfirmScreenAlt(
                orderedItems: items.map((item) => item.toJson()).toList(),
                userData: userData,
                deliveryCharges: deliveryCharges.value,
                codCharges: codCharges.value,
              ));
        } else {
          Get.snackbar("Error", "Failed to fetch user details");
        }
      } else {
        Get.snackbar("Error", "User fetch failed (${response.statusCode})");
      }
    } catch (e) {
      Get.snackbar("Error", "Exception while fetching user: $e");
    }
  }
}
