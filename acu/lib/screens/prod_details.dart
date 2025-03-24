import 'dart:convert';
import 'package:http/http.dart' as http;

import 'package:acu/screens/check_out.dart';
import 'package:acu/screens/components/avail_card.dart';
import 'package:acu/screens/components/cart_components/cart_controller.dart';
import 'package:acu/screens/components/cart_components/cart_item.dart';
import 'package:acu/screens/components/products/rating_list.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ProductDetails extends StatefulWidget {
  final String productName;
  final String productImage;
  final String productPrice;
  final String productBrand;
  final double productRating;
  final int ratingCount;

  const ProductDetails({
    Key? key,
    required this.productName,
    required this.productImage,
    required this.productPrice,
    required this.productBrand,
    required this.productRating,
    required this.ratingCount,
  }) : super(key: key);

  @override
  _ProductDetailsState createState() => _ProductDetailsState();
}

class _ProductDetailsState extends State<ProductDetails> {
  final List<String> sizes = ['38', '40', '42', '44', '46'];
  String selectedSize = '';
  bool isAddressSame = false;
  bool ageConsent = false;
  bool wantDetails = false;
  bool isLoading = false;

  final TextEditingController _emailController = TextEditingController();

  Future<void> navigateToCheckout() async {
    setState(() {
      isLoading = true;
    });
    try {
      final response = await http
          .get(Uri.parse("https://backend.acubemart.in/api/product/all"));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        double deliveryCharges =
            double.tryParse(data['deliveryCharges'].toString()) ?? 0.0;
        double codCharges =
            double.tryParse(data['codCharges'].toString()) ?? 0.0;
        print("Navigating to CheckoutScreen...");
        Get.to(() => CheckoutScreen(
              productName: widget.productName,
              productImage: widget.productImage,
              productPrice: double.tryParse(widget.productPrice) ?? 0.0,
              productRating: widget.productRating,
              deliveryCharges: deliveryCharges,
              codCharges: codCharges,
            ));
        print("Navigation command executed.");
      } else {
        throw Exception("Failed to fetch charges");
      }
    } catch (e) {
      print("Error fetching delivery/cod charges: $e");
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final CartController cartController = Get.find<CartController>();

    return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          toolbarHeight: 60,
          backgroundColor: Colors.white,
          centerTitle: true,
          title: Text(
            "Product Details",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
          ),
          leading: IconButton(
            onPressed: () {
              Get.back();
            },
            icon: Icon(
              Icons.arrow_back_ios_new,
              size: 26,
            ),
          ),
          actions: [
            Padding(
              padding: const EdgeInsets.only(right: 12),
              child: Icon(
                Icons.favorite_border_outlined,
                size: 26,
              ),
            )
          ],
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Product Image
                    Image.network(
                      widget.productImage,
                      width: double.infinity,
                      height: 300,
                      fit: BoxFit.cover,
                    ),
                    SizedBox(height: 16),

                    Text(
                      widget.productName,
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 8),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Brand: ${widget.productBrand}',
                          style: TextStyle(fontSize: 16, color: Colors.grey),
                        ),
                        StarRating(
                            rating: widget.productRating,
                            ratingCount: widget.ratingCount),
                      ],
                    ),

                    SizedBox(height: 10),

                    // Price
                    Text(
                      'Price: \₹${widget.productPrice}',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                      ),
                    ),
                    SizedBox(height: 16),

                    Divider(
                      color: Colors.grey,
                      thickness: 1,
                    ),
                    SizedBox(height: 8),

                    // Size Section
                    Text(
                      'SIZE',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 5),

                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: sizes.map((size) {
                        final isSelected = size == selectedSize;
                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              selectedSize = size; // Update the selected size
                            });
                          },
                          child: Container(
                            width: 50,
                            height: 50,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? Colors.black
                                  : Colors.grey.shade200, // Black if selected
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: isSelected
                                    ? Colors.black
                                    : Colors.grey.shade400,
                              ),
                            ),
                            child: Text(
                              size,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: isSelected ? Colors.white : Colors.black,
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                    SizedBox(height: 30),

                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        BrandInfoContainer(
                            brandLogoUrl:
                                'https://www.acubemart.in/_next/static/media/hero-image-1.a2f50314.jpeg',
                            brandName: widget.productBrand,
                            isAvailable: true)
                      ],
                    ),
                    SizedBox(height: 16),

                    Text(
                      'Product Details',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text('Shadow Navy/Army Green',
                        style: TextStyle(fontSize: 18)),
                    SizedBox(height: 16),
                    Text(
                      'This product is made with premium quality materials to ensure '
                      'long-lasting performance and durability. Perfect for anyone '
                      'looking for style, comfort, and reliability.',
                      style: TextStyle(fontSize: 16, color: Colors.black),
                    ),
                    SizedBox(height: 24),

                    Row(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        OutlinedButton(
                          onPressed: () {},
                          style: OutlinedButton.styleFrom(
                            backgroundColor: Color.fromRGBO(90, 97, 255, 0.06),
                            side: BorderSide(
                              color: Color.fromRGBO(90, 97, 255, 0.25),
                              width: 1.0,
                            ),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8)),
                            padding: EdgeInsets.symmetric(
                                vertical: 6, horizontal: 4),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.location_pin,
                                size: 18,
                                color: const Color.fromRGBO(90, 97, 255, 1),
                              ),
                              SizedBox(width: 4),
                              Text(
                                'Nearest Store',
                                style: TextStyle(
                                    fontSize: 14,
                                    color:
                                        const Color.fromRGBO(90, 97, 255, 1)),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(width: 10),
                        OutlinedButton(
                          onPressed: () {},
                          style: OutlinedButton.styleFrom(
                            backgroundColor: Color.fromRGBO(
                                251, 137, 4, 0.22), // RGBA background color
                            side: BorderSide(
                              color: Color.fromRGBO(251, 137, 4, 0.22),
                              width: 1.0,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            padding: EdgeInsets.symmetric(
                              vertical: 6,
                              horizontal: 4,
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.lock_outline_rounded,
                                color: Color.fromRGBO(251, 137, 4, 1),
                              ),
                              SizedBox(width: 4),
                              Text(
                                'VIP',
                                style: TextStyle(
                                    color: Color.fromRGBO(251, 137, 4, 1)),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(width: 10),
                        ElevatedButton(
                          onPressed: () {},
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(
                              color: Color.fromRGBO(197, 84, 146, 0.4),
                              width: 1.0,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            padding: EdgeInsets.symmetric(
                                vertical: 6, horizontal: 4),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.history_rounded,
                                color: Color.fromRGBO(197, 84, 146, 1),
                              ),
                              SizedBox(width: 4),
                              Text(
                                'Return Policy',
                                style: TextStyle(
                                    color: Color.fromRGBO(197, 84, 146, 1)),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 16),

                    SizedBox(height: 20),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Contact Details',
                          style: TextStyle(
                              fontSize: 26, fontWeight: FontWeight.w900),
                        ),
                        Text(
                          'We will use these details to keep you informed about \nthis delivery.',
                          style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey.shade700,
                              fontWeight: FontWeight.w700),
                        ),
                        SizedBox(height: 25),
                        TextField(
                          controller: _emailController,
                          decoration: InputDecoration(
                            labelText: 'Email Address',
                            hintText: 'Enter your email',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                        ),
                        SizedBox(height: 20),
                        Text(
                          'Shipping Address',
                          style: TextStyle(
                              fontSize: 22, fontWeight: FontWeight.w900),
                        ),
                        SizedBox(height: 16),
                        Container(
                          padding: EdgeInsets.all(16),
                          margin: EdgeInsets.only(bottom: 8),
                          decoration: BoxDecoration(
                            color: Color.fromRGBO(90, 97, 255, 0.06),
                            border: Border.all(
                                color: Color.fromRGBO(90, 97, 255, 0.25)),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Standard Delivery',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black,
                                      ),
                                    ),
                                    SizedBox(height: 4),
                                    Text(
                                      'Enter your address to see when you’ll get your order',
                                      style: TextStyle(
                                          fontSize: 14, color: Colors.black),
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(width: 10),
                              Text(
                                '\$6.00',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF5A61FF),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Color.fromRGBO(251, 137, 4, 0.22),
                            border: Border.all(
                                color: Color.fromRGBO(251, 137, 4, 0.4)),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Collect in store',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black,
                                    ),
                                  ),
                                  SizedBox(height: 4),
                                  Text(
                                    'Pay now, collect in store',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.black,
                                    ),
                                  ),
                                ],
                              ),
                              Text(
                                'Free',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.orange,
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: 16),
                        // Checkboxes
                        Row(
                          children: [
                            Checkbox(
                              value: isAddressSame,
                              onChanged: (value) {
                                setState(() {
                                  isAddressSame = value ?? false;
                                });
                              },
                              activeColor: Colors.red,
                            ),
                            Text(
                              'My billing and delivery information are the \nsame',
                              style:
                                  TextStyle(fontSize: 16, color: Colors.black),
                            ),
                          ],
                        ),
                        Row(children: [
                          Checkbox(
                            value: ageConsent,
                            onChanged: (value) {
                              setState(() {
                                ageConsent = value ?? false;
                              });
                            },
                            activeColor: Colors.red,
                          ),
                          Text(
                            'I’m 13+ years old',
                            style: TextStyle(fontSize: 16, color: Colors.black),
                          ),
                        ]),
                        Row(
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(left: 12),
                              child: Text(
                                'Also want product updates with our newsletter',
                                style: TextStyle(
                                    fontSize: 16, color: Colors.black),
                              ),
                            )
                          ],
                        ),
                        SizedBox(height: 16),
                        Row(children: [
                          Checkbox(
                            value: wantDetails,
                            onChanged: (value) {
                              setState(() {
                                wantDetails = value ?? false;
                              });
                            },
                            activeColor: Colors.red,
                          ),
                          Text(
                            'Yes, I’d like to receive emails about \nexclusive sales and more.',
                            style: TextStyle(fontSize: 16, color: Colors.black),
                          ),
                        ]),
                        SizedBox(height: 20),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            ElevatedButton(
                              onPressed: () {
                                CartItem cartItem = CartItem(
                                  name: widget.productName,
                                  price: double.parse(widget.productPrice),
                                  quantity: 1,
                                  image: widget.productImage,
                                  brand: widget.productBrand,
                                  rating: widget.productRating,
                                );
                                // String rating = double.parse(productRating).toString();
                                String price = double.parse(widget.productPrice)
                                    .toString();
                                int quantity = 1;
                                cartController.addItem(cartItem);
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor:
                                    Colors.grey.shade900, // Button color
                                padding: EdgeInsets.symmetric(
                                    horizontal: 18, vertical: 18),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: Text(
                                "ADD TO CART",
                                style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white),
                              ),
                            ),
                            SizedBox(height: 10),
                            ElevatedButton(
                              onPressed: () {
                                isLoading ? null : navigateToCheckout();
                                // ScaffoldMessenger.of(context).showSnackBar(
                                //   SnackBar(
                                //       content: Text("Proceeding to Payment")),
                                // );
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Color.fromRGBO(
                                    185, 28, 28, 1.0), // Button color
                                padding: EdgeInsets.symmetric(
                                    horizontal: 20, vertical: 18),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: isLoading
                                  ? const SizedBox(
                                      width: 24,
                                      height: 24,
                                      child: CircularProgressIndicator(
                                        valueColor:
                                            AlwaysStoppedAnimation<Color>(
                                                Colors.white),
                                        strokeWidth: 2,
                                      ),
                                    )
                                  : Text(
                                      "PROCEED TO PAYMENT",
                                      style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white),
                                    ),
                            ),
                            SizedBox(height: 30),
                          ],
                        ),
                      ],
                    ),
                  ]),
            ),
          ),
        ));
  }
}
