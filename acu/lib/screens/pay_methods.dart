import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;
import 'package:acu/screens/payment_success.dart';

class PaymentMethodsScreen extends StatefulWidget {
  final Map<String, dynamic> product;
  final String addressId;
  final String phone;
  final int totalAmount;

  const PaymentMethodsScreen({
    Key? key,
    required this.product,
    required this.addressId,
    required this.phone,
    required this.totalAmount,
  }) : super(key: key);

  @override
  _PaymentMethodsScreenState createState() => _PaymentMethodsScreenState();
}

class _PaymentMethodsScreenState extends State<PaymentMethodsScreen> {
  String selectedMethod = "Cash On Delivery";
  bool isLoading = false;

  Future<void> placeOrder() async {
    if (isLoading) return;

    setState(() {
      isLoading = true;
    });

    final userId = GetStorage().read("userId");
    final productId = widget.product["_id"];
    final totalAmount = widget.totalAmount;
    final phone = widget.phone;
    final addressId = widget.addressId; // This is already an ObjectId

    if (userId == null ||
        productId == null ||
        totalAmount == 0 ||
        phone.isEmpty ||
        addressId.isEmpty) {
      Get.snackbar("Error", "Missing required fields!",
          snackPosition: SnackPosition.BOTTOM);
      setState(() {
        isLoading = false;
      });
      return;
    }

    final orderData = {
      "userId": userId,
      "products": [
        {
          "productId": productId,
          "quantity": 1,
        }
      ],
      "total": totalAmount,
      "address": addressId, // Send only the address ID
      "phone": phone,
      "status": "pending",
      "transactionId": selectedMethod == "Cash On Delivery"
          ? []
          : [
              {
                "amount": totalAmount,
                "paymentMode": selectedMethod,
                "status": "SUCCESS",
              }
            ],
      "statusUpdateTime": [],
    };

    print("Order Data: ${jsonEncode(orderData)}");

    try {
      final response = await http.post(
        Uri.parse("https://backend.acubemart.in/api/order/add"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(orderData),
      );

      print("Response Status: ${response.statusCode}");
      print("Response Body: ${response.body}");

      if (response.statusCode == 201) {
        Get.to(() => const PaymentSuccessWidget());
      } else {
        Get.snackbar("Error", "Failed to place order: ${response.body}",
            snackPosition: SnackPosition.BOTTOM);
      }
    } catch (e) {
      Get.snackbar("Error", "Something went wrong: ${e.toString()}",
          snackPosition: SnackPosition.BOTTOM);
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade200,
      appBar: AppBar(
        elevation: 0,
        title: const Text("Select Payment Method",
            style: TextStyle(fontWeight: FontWeight.w900, fontSize: 20)),
        centerTitle: true,
        backgroundColor: Colors.white,
        leading: IconButton(
          onPressed: () => Get.back(),
          icon: const Icon(Icons.arrow_back_ios_new, size: 26),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            Card(
              elevation: 5,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              child: ListTile(
                contentPadding: const EdgeInsets.all(16),
                leading: Icon(Icons.local_shipping,
                    color: Colors.orange.shade700, size: 40),
                title: const Text("Cash On Delivery",
                    style:
                        TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                subtitle: const Text("Pay when you receive the order",
                    style: TextStyle(fontSize: 14, color: Colors.grey)),
                trailing: Icon(Icons.check_circle,
                    color: selectedMethod == "Cash On Delivery"
                        ? Colors.green
                        : Colors.grey,
                    size: 28),
                onTap: () =>
                    setState(() => selectedMethod = "Cash On Delivery"),
              ),
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: isLoading ? null : placeOrder,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color.fromRGBO(185, 28, 28, 1.0),
                foregroundColor: Colors.white,
                padding:
                    const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
              child: isLoading
                  ? const SizedBox(
                      height: 24,
                      width: 24,
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        strokeWidth: 3,
                      ),
                    )
                  : Text("CONTINUE",
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }
}
