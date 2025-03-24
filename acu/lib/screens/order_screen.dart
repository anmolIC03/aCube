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
      body: Padding(
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
                                  fontSize: 16, fontWeight: FontWeight.bold),
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
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            buildPriceRow("Order Amount:", widget.productPrice),
            buildPriceRow("Convenience Fee:", widget.codCharges),
            buildPriceRow("Delivery Fee:", widget.deliveryCharges),
            const SizedBox(height: 10),
            const Divider(),
            buildPriceRow("Order Total:", totalAmount, isBold: true),
            const SizedBox(height: 16),
            const Spacer(),

            // Bottom Navigation
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  children: [
                    Text("\₹${totalAmount}",
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
                    // if (!isAPIAccesible) {
                    //   Get.snackbar("Warning", "Server is not reachable!",
                    //       snackPosition: SnackPosition.BOTTOM);
                    // }
                    // Navigate to PaymentMethodsScreen with correct product details
                    Get.to(() => PaymentMethodsScreen(
                          product: {
                            "_id": widget.productId,
                            "name": widget.productName,
                            "image": widget.productImage,
                            "price": widget.productPrice,
                          },
                          addressId: widget.addressId,
                          phone: widget.phone,
                          totalAmount: totalAmount.toInt(),
                        ));
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromRGBO(185, 28, 28, 1.0),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text("PROCEED TO PAYMENT",
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// Helper widget to build price rows
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
}
