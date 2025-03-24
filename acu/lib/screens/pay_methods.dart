import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;
import 'package:acu/screens/payment_success.dart';

class PaymentMethodsScreen extends StatefulWidget {
  final Map<String, dynamic> product;
  final Map<String, dynamic> address;
  final String phone;
  final int totalAmount;

  const PaymentMethodsScreen({
    Key? key,
    required this.product,
    required this.address,
    required this.phone,
    required this.totalAmount,
  }) : super(key: key);

  @override
  _PaymentMethodsScreenState createState() => _PaymentMethodsScreenState();
}

class _PaymentMethodsScreenState extends State<PaymentMethodsScreen> {
  String selectedMethod = "Cash On Delivery";

  Future<void> placeOrder() async {
    final userId = GetStorage().read("userId");

    if (userId == null ||
        widget.product["_id"] == null ||
        widget.totalAmount == 0 ||
        widget.phone.isEmpty) {
      Get.snackbar("Error", "Some required fields are missing. Please check.");
      return;
    }

    final orderData = {
      "userId": userId,
      "products": [
        {
          "productId": widget.product["_id"], // Ensure _id is used correctly
          "quantity": 1,
        }
      ],
      "total": widget.totalAmount,
      "address": {
        "street": widget.address["street"] ?? "",
        "city": widget.address["city"] ?? "",
        "state": widget.address["state"] ?? "",
        "country": widget.address["country"] ?? "",
        "pincode": widget.address["pincode"] ?? "",
      },
      "phone": widget.phone,
      "status": "pending",
      "transactionId": [
        {
          "amount": widget.totalAmount,
          "paymentMode": selectedMethod,
          "status": "SUCCESS",
        }
      ],
      "statusUpdateTime": [], // Include empty statusUpdateTime array
    };

    print("Order Data: ${jsonEncode(orderData)}"); // Debugging

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
              onPressed: placeOrder,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color.fromRGBO(185, 28, 28, 1.0),
                foregroundColor: Colors.white,
                padding:
                    const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text("CONTINUE",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }
}
