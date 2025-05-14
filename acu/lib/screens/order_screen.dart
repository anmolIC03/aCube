import 'package:acu/screens/pay_methods.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

class OrderConfirmScreen extends StatefulWidget {
  final String productId;
  final String productName;
  final String productImage;
  final double productPrice;
  final double productRating;
  final double deliveryCharges;
  final double codCharges;
  final String addressId;
  final String phone;

  const OrderConfirmScreen({
    Key? key,
    required this.productId,
    required this.productName,
    required this.productImage,
    required this.productPrice,
    required this.productRating,
    required this.deliveryCharges,
    required this.codCharges,
    required this.addressId,
    required this.phone,
  }) : super(key: key);

  @override
  State<OrderConfirmScreen> createState() => _OrderConfirmScreenState();
}

class _OrderConfirmScreenState extends State<OrderConfirmScreen> {
  int _selectedDeliveryOption = 0; // Standard Delivery selected by default
  int _selectedPaymentOption = 0; // Cash on Delivery selected by default
  Future<bool> checkAPI() async {
    try {
      final response = await http
          .get(Uri.parse("https://www.backend.acubemart.in/api/product/all"));
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    double totalAmount =
        widget.productPrice + widget.deliveryCharges + widget.codCharges;
    double advancePayment = totalAmount * 0.10;
    double pendingAmount = totalAmount - advancePayment;

    return Scaffold(
      backgroundColor: Colors.grey.shade300,
      appBar: AppBar(
        elevation: 0,
        title: const Text(
          "Shipping Bag",
          style: TextStyle(fontWeight: FontWeight.w900),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: const Icon(Icons.arrow_back_ios_new, size: 26),
        ),
      ),
      body: SingleChildScrollView(
        child: ConstrainedBox(
          constraints:
              BoxConstraints(minHeight: MediaQuery.of(context).size.height),
          child: IntrinsicHeight(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Product Card
                  Card(
                    elevation: 1,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: SizedBox(
                        height: 180,
                        child: Row(
                          children: [
                            Image.network(
                              widget.productImage,
                              width: 150,
                              height: double.infinity,
                              fit: BoxFit.cover,
                            ),
                            const SizedBox(width: 16),
                            Flexible(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    widget.productName,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  const SizedBox(height: 20),
                                  Text(
                                    '\₹${widget.productPrice}',
                                    style: const TextStyle(
                                        fontSize: 18,
                                        color: Colors.black,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  const SizedBox(height: 4),
                                  Row(
                                    children: [
                                      const Icon(Icons.star,
                                          color: Colors.orange, size: 18),
                                      const SizedBox(width: 4),
                                      Text("${widget.productRating}",
                                          style: const TextStyle(fontSize: 16)),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Divider(),
                  const SizedBox(height: 20),

                  // Order Payment Details
                  const Text("Order Payment Details",
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  buildPriceRow("Order Amount:", widget.productPrice),
                  buildPriceRow("COD Charges:", widget.codCharges),
                  buildPriceRow("Delivery Fee:", widget.deliveryCharges),
                  const SizedBox(height: 10),
                  const Divider(),
                  buildPriceRow("Order Total:", totalAmount, isBold: true),
                  const SizedBox(height: 16),

                  // Delivery Options
                  const Text("Delivery Options",
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  buildDeliveryOptions(),

                  const SizedBox(height: 16),

                  // Payment Options
                  const Text("Payment Options",
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  buildPaymentOptions(
                      totalAmount, advancePayment, pendingAmount),

                  const SizedBox(height: 20),
                  // Bottom Navigation
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        children: [
                          Text("\₹${totalAmount.toStringAsFixed(2)}",
                              style: const TextStyle(
                                  fontSize: 22, fontWeight: FontWeight.bold)),
                          const Padding(
                            padding: EdgeInsets.only(left: 6),
                            child: Text('View Details',
                                style: TextStyle(
                                    color: Color.fromRGBO(185, 28, 28, 1.0),
                                    fontSize: 16)),
                          ),
                        ],
                      ),
                      ElevatedButton(
                        onPressed: () async {
                          bool isAPIAccesible = await checkAPI();
                          Get.to(() => PaymentMethodsScreen(
                                products: [
                                  {
                                    "_id": widget.productId,
                                    "name": widget.productName,
                                    "image": widget.productImage,
                                    "price": widget.productPrice,
                                  }
                                ],
                                addressId: widget.addressId,
                                phone: widget.phone,
                                totalAmount: totalAmount.toInt(),
                              ));
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              const Color.fromRGBO(185, 28, 28, 1.0),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text("PLACE ORDER",
                            style: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget buildPriceRow(String label, double value, {bool isBold = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: TextStyle(fontSize: 20)),
        Text(
          "\₹${value.toStringAsFixed(2)}",
          style: TextStyle(
            color: Colors.black,
            fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            fontSize: 20,
          ),
        ),
      ],
    );
  }

  Widget buildDeliveryOptions() {
    return Column(
      children: [
        buildSelectionButton(
          index: 0,
          isSelected: _selectedDeliveryOption == 0,
          title: "Standard Delivery",
          onSelect: () {
            setState(() {
              _selectedDeliveryOption = 0; // Always select Standard Delivery
            });
          },
        ),
      ],
    );
  }

  Widget buildPaymentOptions(
      double totalAmount, double advancePayment, double pendingAmount) {
    return Column(
      children: [
        buildSelectionButton(
          index: 0,
          isSelected: _selectedPaymentOption == 0,
          title: "Cash On Delivery",
          subtitle:
              "COD charges: ₹${widget.codCharges.toStringAsFixed(2)} \nAn extra charge applies on COD to cover shipping costs and taxes",
          onSelect: () {
            setState(() {
              _selectedPaymentOption = 0;
            });
          },
        ),
        const SizedBox(height: 10),
        buildDisabledSelectionButton(
          title: "Pay Now",
          subtitle: "Enjoy 0 extra charge and free shipping on prepaid payment",
        ),
        const SizedBox(height: 10),
        buildDisabledSelectionButton(
          title: "10% advance, rest on delivery",
          subtitle:
              "Advance: ₹${advancePayment.toStringAsFixed(2)}\nPending: ₹${pendingAmount.toStringAsFixed(2)}",
        ),
      ],
    );
  }

  Widget buildSelectionButton({
    required int index,
    required bool isSelected,
    required String title,
    String? subtitle,
    required VoidCallback onSelect,
  }) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
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
                    const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            if (subtitle != null) ...[
              const SizedBox(height: 4),
              RichText(
                textAlign: TextAlign.center,
                text: TextSpan(
                  style: const TextStyle(fontSize: 15, color: Colors.black),
                  children: _formatAmountWithColor(
                      subtitle), // ✅ Apply color formatting
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget buildDisabledSelectionButton(
      {required String title, String? subtitle}) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: null, // Disabled button
        style: ElevatedButton.styleFrom(
          backgroundColor:
              Colors.grey.shade300, // Greyed out to indicate disabled
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
                    const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            if (subtitle != null) ...[
              const SizedBox(height: 4),
              RichText(
                textAlign: TextAlign.center,
                text: TextSpan(
                  style: const TextStyle(fontSize: 14, color: Colors.black),
                  children: _formatAmountWithColor(subtitle),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  List<TextSpan> _formatAmountWithColor(String text) {
    final RegExp amountPattern = RegExp(r'₹\d+(\.\d+)?');
    List<TextSpan> spans = [];
    int lastIndex = 0;

    for (RegExpMatch match in amountPattern.allMatches(text)) {
      // Get the matched amount
      String amount = match.group(0) ?? "";

      // Add normal text before the amount
      if (match.start > lastIndex) {
        spans.add(TextSpan(text: text.substring(lastIndex, match.start)));
      }

      spans.add(TextSpan(
        text: amount,
        style: const TextStyle(
          color: Colors.red,
          fontWeight: FontWeight.bold,
        ),
      ));

      lastIndex = match.end;
    }

    // Add remaining text
    if (lastIndex < text.length) {
      spans.add(TextSpan(text: text.substring(lastIndex)));
    }

    return spans;
  }
}
