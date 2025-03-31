import 'dart:convert';
import 'package:acu/screens/components/cart_components/cart_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;
import 'package:acu/screens/payment_success.dart';

class PaymentMethodsScreen extends StatefulWidget {
  final List<Map<String, dynamic>> products;
  final String addressId;
  final String phone;
  final int totalAmount;

  const PaymentMethodsScreen({
    Key? key,
    required this.products,
    required this.addressId,
    required this.phone,
    required this.totalAmount,
  }) : super(key: key);

  @override
  _PaymentMethodsScreenState createState() => _PaymentMethodsScreenState();
}

class _PaymentMethodsScreenState extends State<PaymentMethodsScreen> {
  String selectedMethod = "COD";
  bool isLoading = false;
  final CartController cartController = Get.find<CartController>();

  Future<String?> createTransaction(String userId, double amount) async {
    try {
      String paymentMode = "COD";
      final transactionData = {
        "userId": userId,
        "amount": amount,
        "paymentMode": paymentMode,
        "status": "SUCCESS",
      };

      final response = await http.post(
        Uri.parse("https://backend.acubemart.in/api/transaction/add"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(transactionData),
      );

      if (response.statusCode == 201) {
        final responseData = jsonDecode(response.body);
        return responseData["data"]["_id"];
      } else {
        print("Transaction Error: ${response.body}");
        return null;
      }
    } catch (e) {
      print("Transaction Exception: $e");
      return null;
    }
  }

  Future<void> _updateUserOrders(
      String userId, String orderId, int total, int orderNumber) async {
    final updateData = {
      "orders": [
        {
          "_id": orderId,
          "total": total,
          "orderNumber": orderNumber,
        }
      ]
    };

    try {
      final response = await http.patch(
        Uri.parse("https://backend.acubemart.in/api/user/update/$userId"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(updateData),
      );

      print("User Update Response: ${response.statusCode}");
      print("User Update Response Body: ${response.body}");

      if (response.statusCode != 200) {
        Get.snackbar("Error", "Failed to update user orders",
            snackPosition: SnackPosition.BOTTOM);
      }
    } catch (e) {
      Get.snackbar("Error", "Error updating user orders: ${e.toString()}",
          snackPosition: SnackPosition.BOTTOM);
    }
  }

  Future<void> placeOrder() async {
    if (isLoading) return;

    setState(() {
      isLoading = true;
    });

    final userId = GetStorage().read("userId");
    //final productId = widget.product["_id"];
    final totalAmount = widget.totalAmount;
    final phone = widget.phone;
    final addressId = widget.addressId;

    List<String> missingFields = [];

    if (userId == null) missingFields.add("User ID");
    //if (productId == null) missingFields.add("Product ID");
    if (totalAmount == 0) missingFields.add("Total Amount");
    if (phone.isEmpty) missingFields.add("Phone Number");
    if (addressId.isEmpty) missingFields.add("Address ID");

    if (missingFields.isNotEmpty) {
      Get.snackbar(
        "Error",
        "Missing required fields: ${missingFields.join(', ')}",
        snackPosition: SnackPosition.BOTTOM,
      );
      setState(() {
        isLoading = false;
      });
      return;
    }

    String? transactionId =
        await createTransaction(userId, totalAmount.toDouble());
    if (transactionId == null) {
      Get.snackbar(
        "Error",
        "Failed to create transaction",
        snackPosition: SnackPosition.BOTTOM,
      );
      setState(() {
        isLoading = false;
      });
      return;
    }

    final List<Map<String, dynamic>> productList =
        widget.products.map((product) {
      if (!product.containsKey("_id") || product["_id"] == null) {
        print("🚨 Missing productId for product: ${jsonEncode(product)}");
      }

      return {
        "productId": product["_id"] ?? product["productId"],
        "quantity": product["quantity"] ?? 1,
      };
    }).toList();

    final orderData = {
      "userId": userId,
      "products": productList,
      "total": totalAmount,
      "address": addressId,
      "phone": phone,
      "status": "pending",
      "transactionId": [transactionId],
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
        final responseBody = jsonDecode(response.body);
        final orderId = responseBody["data"]["_id"];
        final orderNumber = responseBody["data"]["orderNumber"];

        await _updateUserOrders(userId, orderId, totalAmount, orderNumber);

        await cartController.clearCart();

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
