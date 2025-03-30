import 'dart:convert';
import 'package:acu/screens/prod_details.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:shimmer/shimmer.dart';

class Exhausts extends StatefulWidget {
  const Exhausts({super.key});

  @override
  State<Exhausts> createState() => _ExhaustsState();
}

class _ExhaustsState extends State<Exhausts> {
  var isLoading = true.obs;
  var selectedExhaust = ''.obs;
  var allProducts = <dynamic>[].obs;
  var filteredProducts = <dynamic>[].obs;

  final List<String> exhaustTypes = [
    "Exhaust",
    "Bend Pipe",
    "Performance Parts",
    "Airfilter"
  ];

  @override
  void initState() {
    super.initState();
    fetchAllProducts();
  }

  Future<void> fetchAllProducts({int page = 1, int limit = 20}) async {
    isLoading.value = true;
    try {
      var url = Uri.parse(
          "https://backend.acubemart.in/api/product/all?page=$page&limit=$limit");
      var response = await http.get(url);

      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);
        if (data['data'] is List) {
          if (page == 1) {
            allProducts.assignAll(data['data']);
          } else {
            allProducts.addAll(data['data']);
          }
          filteredProducts.assignAll(allProducts);
        }
      }
    } catch (e) {
      print("❌ Exception: $e");
    } finally {
      isLoading.value = false;
    }
  }

  void filterProducts(String exhaustName) {
    filteredProducts.assignAll(
      allProducts.where((product) {
        if (product['element'] is List) {
          return product['element'].any((el) =>
              el is Map &&
              el.containsKey('name') &&
              el['name'].toString().toLowerCase() == exhaustName.toLowerCase());
        }
        return false;
      }).toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          _buildExhaustTypeSelector(),
          Expanded(
            child: Obx(() {
              if (isLoading.value) {
                return _buildShimmerList(); // ✅ Shimmer loading effect
              } else if (filteredProducts.isEmpty) {
                return const Center(child: Text("No products found"));
              } else {
                return ListView.builder(
                  padding: const EdgeInsets.all(8),
                  itemCount: filteredProducts.length,
                  itemBuilder: (context, index) {
                    final product = filteredProducts[index];
                    List<String> productImages = (product['image'] is List &&
                            product['image'].isNotEmpty)
                        ? product['image']
                            .map<String>((img) => img['url'].toString())
                            .toList()
                        : ['https://via.placeholder.com/150'];

                    String imageUrl = productImages.first;
                    return GestureDetector(
                      onTap: () {
                        Get.to(() => ProductDetails(
                              productName: product['name'] ?? 'Unknown Product',
                              productBrand: (product['brand'] is List &&
                                      product['brand'].isNotEmpty)
                                  ? product['brand'][0]['name'].toString()
                                  : 'Unknown Brand',
                              productId: product['_id'] ?? '',
                              productImages: productImages,
                              productPrice:
                                  product['price']?.toString() ?? 'N/A',
                              productRating: product['rating'] ?? 0.0,
                              ratingCount: product['ratingCount'] ?? 0,
                            ));
                      },
                      child: Card(
                        elevation: 4,
                        margin: const EdgeInsets.symmetric(vertical: 8),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Row(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.network(
                                  imageUrl,
                                  width: 80,
                                  height: 80,
                                  fit: BoxFit.cover,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      product['name'] ?? "Unknown Product",
                                      style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 5),
                                    Text(
                                      "₹${product['price'] ?? "N/A"}",
                                      style: const TextStyle(
                                        fontSize: 16,
                                        color: Color.fromRGBO(185, 28, 28, 1.0),
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                );
              }
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildExhaustTypeSelector() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Obx(() {
        return Row(
          children: exhaustTypes.map((exhaust) {
            bool isSelected = selectedExhaust.value == exhaust;

            return GestureDetector(
              onTap: () {
                selectedExhaust.value = exhaust;
                filterProducts(exhaust);
              },
              child: Container(
                padding:
                    const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                decoration: BoxDecoration(
                  color: Colors.transparent,
                  border: Border(
                    bottom: BorderSide(
                      color: isSelected
                          ? Color.fromRGBO(185, 28, 28, 1.0)
                          : Colors.transparent,
                      width: 3,
                    ),
                  ),
                ),
                child: Text(
                  exhaust,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: isSelected
                        ? Color.fromRGBO(185, 28, 28, 1.0)
                        : Colors.black,
                  ),
                ),
              ),
            );
          }).toList(),
        );
      }),
    );
  }

  /// Shimmer loading effect for skeleton UI
  Widget _buildShimmerList() {
    return ListView.builder(
      padding: const EdgeInsets.all(8),
      itemCount: 5, // Show 5 shimmer placeholders
      itemBuilder: (context, index) {
        return Card(
          elevation: 4,
          margin: const EdgeInsets.symmetric(vertical: 8),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Shimmer.fromColors(
                  baseColor: Colors.grey[300]!,
                  highlightColor: Colors.grey[100]!,
                  child: Container(
                    width: 80,
                    height: 80,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Shimmer.fromColors(
                        baseColor: Colors.grey[300]!,
                        highlightColor: Colors.grey[100]!,
                        child: Container(
                          height: 20,
                          width: 150,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Shimmer.fromColors(
                        baseColor: Colors.grey[300]!,
                        highlightColor: Colors.grey[100]!,
                        child: Container(
                          height: 16,
                          width: 100,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
