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
      backgroundColor: Colors.grey[100],
      body: Column(
        children: [
          _buildExhaustTypeSelector(),
          Expanded(
            child: Obx(() {
              if (isLoading.value) {
                return _buildShimmerList();
              }
              if (filteredProducts.isEmpty) {
                return const Center(
                  child: Text(
                    "No products found",
                    style: TextStyle(fontSize: 16, color: Colors.black54),
                  ),
                );
              }
              return _buildProductList();
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildExhaustTypeSelector() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10),
      color: Colors.white,
      child: SingleChildScrollView(
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
                  margin: const EdgeInsets.symmetric(horizontal: 8),
                  padding:
                      const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? const Color.fromRGBO(185, 28, 28, 1.0)
                        : Colors.grey[200],
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: isSelected
                        ? [
                            BoxShadow(
                              color: Colors.red.withOpacity(0.2),
                              blurRadius: 5,
                              offset: const Offset(0, 3),
                            )
                          ]
                        : [],
                  ),
                  child: Text(
                    exhaust,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: isSelected ? Colors.white : Colors.black87,
                    ),
                  ),
                ),
              );
            }).toList(),
          );
        }),
      ),
    );
  }

  Widget _buildProductList() {
    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: filteredProducts.length,
      itemBuilder: (context, index) {
        final product = filteredProducts[index];
        List<String> productImages =
            (product['image'] is List && product['image'].isNotEmpty)
                ? product['image']
                    .map<String>((img) => img['url'].toString())
                    .toList()
                : ['https://via.placeholder.com/150'];

        String imageUrl = productImages.first;

        return GestureDetector(
          onTap: () {
            Get.to(() => ProductDetails(
                  productName: product['name'] ?? 'Unknown Product',
                  productBrand:
                      (product['brand'] is List && product['brand'].isNotEmpty)
                          ? product['brand'][0]['name'].toString()
                          : 'Unknown Brand',
                  productId: product['_id'] ?? '',
                  productImages: productImages,
                  productPrice: product['price']?.toString() ?? 'N/A',
                  productSp: product['sp']?.toString() ?? 'N/A',
                ));
          },
          child: Card(
            elevation: 2,
            margin: const EdgeInsets.only(bottom: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(14),
                      bottomLeft: Radius.circular(14)),
                  child: Image.network(
                    imageUrl,
                    width: 90,
                    height: 90,
                    fit: BoxFit.scaleDown,
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          product['name'] ?? "Unknown Product",
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          "₹${product['sp'] ?? "N/A"}",
                          style: const TextStyle(
                            fontSize: 15,
                            color: Color.fromRGBO(185, 28, 28, 1.0),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildShimmerList() {
    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: 6,
      itemBuilder: (context, index) {
        return Card(
          elevation: 2,
          margin: const EdgeInsets.only(bottom: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          child: Row(
            children: [
              Shimmer.fromColors(
                baseColor: Colors.grey[300]!,
                highlightColor: Colors.grey[100]!,
                child: Container(
                  width: 90,
                  height: 90,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(14),
                      bottomLeft: Radius.circular(14),
                    ),
                  ),
                ),
              ),
              Expanded(
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Shimmer.fromColors(
                        baseColor: Colors.grey[300]!,
                        highlightColor: Colors.grey[100]!,
                        child: Container(
                          height: 16,
                          width: 140,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Shimmer.fromColors(
                        baseColor: Colors.grey[300]!,
                        highlightColor: Colors.grey[100]!,
                        child: Container(
                          height: 14,
                          width: 100,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
