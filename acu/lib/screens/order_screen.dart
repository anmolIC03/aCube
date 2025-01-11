import 'package:acu/screens/payment_success.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class OrderConfirmScreen extends StatelessWidget {
  final String productName;
  final String productImage;
  final double productPrice;
  final double productRating;

  const OrderConfirmScreen({
    Key? key,
    required this.productName,
    required this.productImage,
    required this.productPrice,
    required this.productRating,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade300,
      appBar: AppBar(
        elevation: 0,
        title: Text(
          "Shipping Bag",
          style: TextStyle(fontWeight: FontWeight.w900),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context); // Go back to the previous screen
          },
          icon: Icon(
            Icons.arrow_back_ios_new,
            size: 26,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Product Card (Same as CheckoutScreen)
            GestureDetector(
              onTap: () {},
              child: Card(
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
                          productImage,
                          width: 150,
                          height: double.infinity,
                          fit: BoxFit.cover,
                        ),
                        SizedBox(width: 16),
                        Flexible(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                productName,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                    fontSize: 16, fontWeight: FontWeight.bold),
                              ),
                              SizedBox(height: 20),
                              Text(
                                '\$${productPrice}',
                                style: TextStyle(
                                    fontSize: 18,
                                    color: Colors.black,
                                    fontWeight: FontWeight.bold),
                              ),
                              SizedBox(height: 4),
                              Row(
                                children: [
                                  Icon(
                                    Icons.star,
                                    color: Colors.orange,
                                    size: 18,
                                  ),
                                  SizedBox(width: 4),
                                  Text(
                                    "$productRating",
                                    style: TextStyle(fontSize: 16),
                                  ),
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
            ),

            SizedBox(height: 16),

            SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.money,
                      color: Colors.black,
                      size: 26,
                    ),
                    SizedBox(width: 8),
                    Text(
                      "Select Coupon",
                      style: TextStyle(fontSize: 18, color: Colors.black),
                    ),
                  ],
                ),
                TextButton(
                  onPressed: () {
                    // Navigate to a screen where user can select coupons
                    // Example: Navigator.push(...);
                  },
                  style: TextButton.styleFrom(
                    foregroundColor: Color.fromRGBO(185, 28, 28, 1.0),
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    "Select",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            Divider(),
            SizedBox(height: 20),

            // Order Payment Details (Price on the right)
            Text(
              "Order Payment Details",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Order Amount:",
                  style: TextStyle(fontSize: 20),
                ),
                Text("\$${productPrice}",
                    style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                        fontSize: 20)),
              ],
            ),
            SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Convenience Fee:",
                  style: TextStyle(color: Colors.black, fontSize: 20),
                ),
                Text("\$5.00",
                    style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                        fontSize: 20)),
              ],
            ),
            SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Delivery Fee:",
                  style: TextStyle(color: Colors.black, fontSize: 20),
                ),
                Text("\$3.00",
                    style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                        fontSize: 20)),
              ],
            ),
            SizedBox(height: 10),
            Divider(),
            SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Order Total:",
                  style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                      fontSize: 20),
                ),
                Text(
                  "\$${productPrice + 5 + 3}",
                  style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                      fontSize: 20),
                ),
              ],
            ),
            SizedBox(height: 10),
            Text(
              "EMI Available",
              style: TextStyle(
                  fontSize: 16, color: Color.fromRGBO(185, 28, 28, 1.0)),
            ),
            SizedBox(height: 16),

            Spacer(),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  children: [
                    Text(
                      "\$${productPrice + 5 + 3}",
                      style:
                          TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 6),
                      child: Text(
                        'View Details',
                        style: TextStyle(
                            color: Color.fromRGBO(185, 28, 28, 1.0),
                            fontSize: 16),
                      ),
                    )
                  ],
                ),
                ElevatedButton(
                  onPressed: () {
                    Get.to(() => PaymentSuccessWidget());
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color.fromRGBO(185, 28, 28, 1.0),
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    "PROCEED TO PAYMENT",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
