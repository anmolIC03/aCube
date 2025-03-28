import 'package:acu/screens/prod_details.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class Exhausts extends StatefulWidget {
  const Exhausts({super.key});

  @override
  State<Exhausts> createState() => _ExhaustsState();
}

class _ExhaustsState extends State<Exhausts> {
  var isLoading = false.obs;
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

  void fetchAllProducts() async {
    isLoading.value = true;

    try {
      final response = await GetConnect().get(
        "https://backend.acubemart.in/api/product/all",
      );

      if (response.statusCode == 200) {
        allProducts.assignAll(response.body['data'] ?? []);
        filteredProducts.assignAll(allProducts); // Show all products initially
      }
    } catch (e) {
      print("Error fetching products: $e");
    } finally {
      isLoading.value = false;
    }
  }

  void filterProducts(String exhaustName) {
    print("Filtering for: $exhaustName");

    filteredProducts.assignAll(
      allProducts.where((product) {
        print("Checking Product: ${product['name']}");
        print("Product Elements: ${product['element']}");

        if (product['element'] != null && product['element'] is List<dynamic>) {
          return product['element'].any((el) {
            print("Checking Element: ${el['name']}");
            return el['name'].toString().toLowerCase() ==
                exhaustName.toLowerCase();
          });
        }

        return false;
      }).toList(),
    );

    print("Filtered Products: ${filteredProducts.length}");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          _buildExhaustTypeSelector(),

          // Product List
          Expanded(
            child: Obx(() {
              if (isLoading.value) {
                return const Center(child: CircularProgressIndicator());
              } else if (filteredProducts.isEmpty) {
                return const Center(child: Text("No products found"));
              } else {
                return ListView.builder(
                  padding: const EdgeInsets.all(8),
                  itemCount: filteredProducts.length,
                  itemBuilder: (context, index) {
                    final product = filteredProducts[index];

                    final imageUrl =
                        (product['image'] as List<dynamic>?)?.firstWhere(
                              (img) => img['isFeatured'] == true,
                              orElse: () => product['image'].isNotEmpty
                                  ? product['image'][0]
                                  : null,
                            )?['url'] ??
                            'https://via.placeholder.com/150';

                    return GestureDetector(
                      onTap: () {
                        Get.to(() => ProductDetails(
                              productName: product['name'] ?? 'Unknown Product',
                              productBrand: (product['brand'] is List &&
                                      product['brand'].isNotEmpty)
                                  ? product['brand'][0]['name'].toString()
                                  : 'Unknown Brand',
                              productId: product['_id'] ?? '',
                              productImage: imageUrl,
                              productPrice:
                                  product['price']?.toString() ?? 'N/A',
                              productRating: product['rating'] ?? 0.0,
                              ratingCount: product['ratingCount'] ?? 0,
                            ));
                        print("Product clicked: ${product['name']}");
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
      scrollDirection: Axis.horizontal, // Prevents RenderFlex error
      child: Obx(() {
        return Row(
          children: exhaustTypes.map((exhaust) {
            bool isSelected = selectedExhaust.value == exhaust;

            return GestureDetector(
              onTap: () {
                selectedExhaust.value = exhaust; // Update selection
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
}
