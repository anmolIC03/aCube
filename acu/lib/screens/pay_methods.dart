import 'dart:convert';
import 'package:acu/screens/components/cart_components/cart_controller.dart';
import 'package:acu/screens/payment_success.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;

final cartController = Get.put(CartController());

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
  State<PaymentMethodsScreen> createState() => _PaymentMethodsScreenState();
}

class _PaymentMethodsScreenState extends State<PaymentMethodsScreen> {
  int _selectedPaymentOption = 0;
  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    double advance = widget.totalAmount * 0.10;
    double pending = widget.totalAmount - advance;

    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        elevation: 0,
        title: const Text("Payment Options",
            style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Order Summary",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            _buildPriceRow("Order Total:", widget.totalAmount.toDouble(),
                isBold: true),
            const Divider(height: 30),
            const Text("Select Payment Method",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            _buildPaymentOption(
              index: 0,
              isSelected: _selectedPaymentOption == 0,
              title: "Cash On Delivery",
              subtitle: "COD Charges Apply. Pay full amount on delivery.",
              onSelect: () => setState(() => _selectedPaymentOption = 0),
            ),
            const SizedBox(height: 10),
            _buildDisabledOption(
              title: "Pay Now (Online Payment)",
              subtitle: "Get free shipping and 0 extra charge.",
            ),
            const SizedBox(height: 10),
            _buildDisabledOption(
              title: "10% Advance, Rest on Delivery",
              subtitle:
                  "Advance: ₹${advance.toStringAsFixed(2)}\nPending: ₹${pending.toStringAsFixed(2)}",
            ),
            const Spacer(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                GestureDetector(
                  onTap: _showOrderDetails,
                  child: Column(
                    children: [
                      Text("₹${widget.totalAmount.toStringAsFixed(2)}",
                          style: const TextStyle(
                              fontSize: 22, fontWeight: FontWeight.bold)),
                      const Text('View Details',
                          style: TextStyle(
                              color: Color.fromRGBO(185, 28, 28, 1.0),
                              fontSize: 16)),
                    ],
                  ),
                ),
                ElevatedButton(
                  onPressed: isLoading ? null : placeOrder,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromRGBO(185, 28, 28, 1.0),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text("PROCEED TO PAYMENT",
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showOrderDetails() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) {
        return Padding(
          padding: const EdgeInsets.all(16),
          child: ListView(
            shrinkWrap: true,
            children: [
              const Text("Order Details",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              ...widget.products.map((product) {
                return ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(product["name"] ?? "Unnamed Product",
                      style: const TextStyle(fontWeight: FontWeight.w600)),
                  subtitle: Text("Quantity: ${product["quantity"] ?? 1}"),
                  trailing: Text("₹${product["price"] ?? 0}"),
                );
              }).toList(),
              const Divider(),
              _buildPriceRow("Total:", widget.totalAmount.toDouble(),
                  isBold: true),
            ],
          ),
        );
      },
    );
  }

  Widget _buildPriceRow(String label, double value, {bool isBold = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(fontSize: 18)),
        Text("₹${value.toStringAsFixed(2)}",
            style: TextStyle(
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
              fontSize: 18,
            )),
      ],
    );
  }

  Widget _buildPaymentOption({
    required int index,
    required bool isSelected,
    required String title,
    required String subtitle,
    required VoidCallback onSelect,
  }) {
    return ElevatedButton(
      onPressed: onSelect,
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.red.shade100,
        foregroundColor: Colors.black,
        padding: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: isSelected
              ? const BorderSide(
                  color: Color.fromRGBO(185, 28, 28, 1.0), width: 2)
              : BorderSide.none,
        ),
      ),
      child: Column(
        children: [
          Text(title,
              style:
                  const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text(subtitle,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 14)),
        ],
      ),
    );
  }

  Widget _buildDisabledOption({
    required String title,
    required String subtitle,
  }) {
    return ElevatedButton(
      onPressed: null,
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.grey.shade300,
        foregroundColor: Colors.grey.shade600,
        padding: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      child: Column(
        children: [
          Text(title,
              style:
                  const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text(subtitle,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 14)),
        ],
      ),
    );
  }

  // ========== BACKEND METHODS ========== //

  Future<String?> createTransaction(String userId, double amount) async {
    try {
      final response = await http.post(
        Uri.parse("https://backend.acubemart.in/api/transaction/add"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "userId": userId,
          "amount": amount,
          "paymentMode": "COD",
          "status": "SUCCESS",
        }),
      );

      if (response.statusCode == 201) {
        final data = jsonDecode(response.body);
        return data["data"]["_id"];
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
        {"_id": orderId, "total": total, "orderNumber": orderNumber}
      ]
    };

    try {
      final response = await http.patch(
        Uri.parse("https://backend.acubemart.in/api/user/update/$userId"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(updateData),
      );

      if (response.statusCode != 200) {
        Get.snackbar("Error", "Failed to update user orders");
      }
    } catch (e) {
      Get.snackbar("Error", "Update Error: ${e.toString()}");
    }
  }

  Future<void> placeOrder() async {
    setState(() => isLoading = true);

    final userId = GetStorage().read("userId");
    final totalAmount = widget.totalAmount;
    final phone = widget.phone;
    final addressId = widget.addressId;

    if (userId == null || phone.isEmpty || addressId.isEmpty) {
      Get.snackbar("Error", "Missing required fields");
      setState(() => isLoading = false);
      return;
    }

    final transactionId =
        await createTransaction(userId, totalAmount.toDouble());
    if (transactionId == null) {
      Get.snackbar("Error", "Transaction creation failed");
      setState(() => isLoading = false);
      return;
    }

    final productList = widget.products.map((product) {
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

    try {
      final response = await http.post(
        Uri.parse("https://backend.acubemart.in/api/order/add"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(orderData),
      );

      if (response.statusCode == 201) {
        final body = jsonDecode(response.body);
        await _updateUserOrders(
          userId,
          body["data"]["_id"],
          totalAmount,
          body["data"]["orderNumber"],
        );

        await cartController.clearCart();
        Get.to(() => const PaymentSuccessWidget());
      } else {
        Get.snackbar("Error", "Order failed: ${response.body}");
        print(response.body);
      }
    } catch (e) {
      print(e.toString());
      Get.snackbar("Error", "Something went wrong: ${e.toString()}");
    } finally {
      setState(() => isLoading = false);
    }
  }
}
