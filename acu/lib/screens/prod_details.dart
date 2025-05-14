import 'dart:convert';
import 'package:carousel_slider/carousel_options.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:http/http.dart' as http;

import 'package:acu/screens/check_out.dart';
import 'package:acu/screens/components/avail_card.dart';
import 'package:acu/screens/components/cart_components/cart_controller.dart';
import 'package:acu/screens/components/cart_components/cart_item.dart';
import 'package:acu/screens/components/products/rating_list.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ProductDetails extends StatefulWidget {
  final String productId;
  final String productName;
  final List<String> productImages;
  final String productPrice;
  final String productBrand;
  final double productRating;
  final int ratingCount;
  final String productSp;

  const ProductDetails({
    Key? key,
    required this.productName,
    required this.productImages,
    required this.productPrice,
    required this.productBrand,
    required this.productRating,
    required this.ratingCount,
    required this.productId,
    required this.productSp,
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

  int _currentImageIndex = 0;
  String productDescription = "";

  Future<void> fetchProductDetails() async {
    setState(() {
      isLoading = true;
    });

    try {
      final response = await http
          .get(Uri.parse("https://backend.acubemart.in/api/product/all"));

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);

        if (data.containsKey('data') && data['data'] is List) {
          final product = data['data'].firstWhere(
            (prod) => prod['_id'] == widget.productId,
            orElse: () => null,
          );

          if (product != null) {
            setState(() {
              productDescription =
                  product['description'] ?? "No description available.";
              print(productDescription);
            });
          }
        }
      }
    } catch (e) {
      print("Error fetching product description: $e");
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> navigateToCheckout() async {
    setState(() {
      isLoading = true;
    });

    try {
      final response = await http
          .get(Uri.parse("https://backend.acubemart.in/api/product/all"));

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);

        print("Full API Response: $data");

        // Extract products list
        if (data.containsKey('data') && data['data'] is List) {
          // Find the specific product matching widget.productId
          final product = data['data'].firstWhere(
            (prod) => prod['_id'] == widget.productId,
            orElse: () => null,
          );

          if (product != null) {
            double deliveryCharges =
                double.tryParse(product['deliveryCharges'].toString()) ?? 0.0;
            double codCharges =
                double.tryParse(product['codCharges'].toString()) ?? 0.0;

            print("Extracted deliveryCharges: $deliveryCharges");
            print("Extracted codCharges: $codCharges");

            Get.to(() => CheckoutScreen(
                  productId: widget.productId,
                  productName: widget.productName,
                  productImage: widget.productImages.isNotEmpty
                      ? widget.productImages.first
                      : 'https://via.placeholder.com/150',
                  productPrice: double.tryParse(widget.productSp) ?? 0.0,
                  productRating: widget.productRating,
                  deliveryCharges: deliveryCharges,
                  codCharges: codCharges,
                ));
          } else {
            print(
                "Error: Product with ID ${widget.productId} not found in response.");
          }
        } else {
          print("Error: 'data' array is missing or empty in response.");
        }
      } else {
        print("Error: API returned status code ${response.statusCode}");
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
  void initState() {
    super.initState();
    fetchProductDetails();
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
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Product Image
                    CarouselSlider(
                      items: widget.productImages.map((imageUrl) {
                        return ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.network(
                            imageUrl,
                            width: double.infinity,
                            height: 300,
                            fit: BoxFit.scaleDown,
                          ),
                        );
                      }).toList(),
                      options: CarouselOptions(
                        height: 300,
                        autoPlay: true,
                        enlargeCenterPage: true,
                        onPageChanged: (index, reason) {
                          setState(() {
                            _currentImageIndex = index;
                          });
                        },
                      ),
                    ),
                    const SizedBox(height: 10),

                    // Indicator Dots
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children:
                          widget.productImages.asMap().entries.map((entry) {
                        return GestureDetector(
                          onTap: () => setState(() {
                            _currentImageIndex = entry.key;
                          }),
                          child: Container(
                            width: 8,
                            height: 8,
                            margin: const EdgeInsets.symmetric(horizontal: 4),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: _currentImageIndex == entry.key
                                  ? Colors.redAccent
                                  : Colors.grey,
                            ),
                          ),
                        );
                      }).toList(),
                    ),

                    SizedBox(height: 16),

                    //Product Details
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
                      ],
                    ),

                    SizedBox(height: 10),

                    Text(
                      '₹${widget.productPrice}', // MRP
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey,
                        decoration: TextDecoration.lineThrough,
                      ),
                    ),
                    SizedBox(width: 6),

                    // Price
                    Text(
                      'Price: \₹${widget.productSp}',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                      ),
                    ),
                    // Discount Percentage (Red Box)
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        '${_calculateDiscount(widget.productPrice, widget.productSp)}% OFF',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),

                    SizedBox(height: 16),

                    // Size Section

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
                    isLoading
                        ? Center(child: CircularProgressIndicator())
                        : productDescription.isNotEmpty
                            ? Html(
                                data: productDescription,
                                style: {
                                  "p": Style(fontSize: FontSize(16)),
                                  "b": Style(fontWeight: FontWeight.bold),
                                  "i": Style(fontStyle: FontStyle.italic),
                                },
                              )
                            : Text(
                                "No description available.",
                                style:
                                    TextStyle(fontSize: 16, color: Colors.grey),
                              ),

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
                            backgroundColor: Color.fromRGBO(251, 137, 4, 0.22),
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
                        // Checkboxes

                        Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            ElevatedButton(
                              onPressed: () {
                                // CartItem cartItem = CartItem(
                                //   productId: widget.,
                                //   name: widget.productName,
                                //   price: double.parse(widget.productPrice),
                                //   quantity: 1,
                                //   image: widget.productImages.isNotEmpty
                                //       ? widget.productImages.first
                                //       : 'https://via.placeholder.com/150',
                                //   brand: widget.productBrand,
                                //   rating: widget.productRating,
                                // );
                                // // String rating = double.parse(productRating).toString();
                                // String price = double.parse(widget.productPrice)
                                //     .toString();
                                // int quantity = 1;
                                cartController.addItem(widget.productId);
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
                                navigateToCheckout();
                              }, // Disable button if conditions aren't met
                              style: ElevatedButton.styleFrom(
                                backgroundColor:
                                    Color.fromRGBO(185, 28, 28, 1.0),
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

  int _calculateDiscount(String mrp, String sp) {
    double mrpValue = double.tryParse(mrp) ?? 0;
    double spValue = double.tryParse(sp) ?? 0;
    if (mrpValue <= 0 || spValue <= 0 || spValue >= mrpValue) return 0;
    return ((1 - (spValue / mrpValue)) * 100).round();
  }
}
