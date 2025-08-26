import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:acu/screens/prod_details.dart';
import 'package:shimmer/shimmer.dart';

class TypeAndModel extends StatefulWidget {
  const TypeAndModel({super.key});

  @override
  State<TypeAndModel> createState() => _TypeAndModelState();
}

class _TypeAndModelState extends State<TypeAndModel>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<dynamic> carModels = [];
  List<dynamic> bikeModels = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    fetchModels();
  }

  Future<void> fetchModels() async {
    try {
      final response = await http.get(
        Uri.parse('https://backend.acubemart.in/api/model/all'),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) {
          List<dynamic> allModels = data['data'];

          carModels = allModels
              .where((model) => model['typeId']['name'] == 'Car')
              .toList();
          bikeModels = allModels
              .where((model) => model['typeId']['name'] == 'Bike')
              .toList();
        }
      }
    } catch (e) {
      print("Error fetching models: $e");
    }

    if (mounted) {
      setState(() => isLoading = false);
    }
  }

  void navigateToProducts(String modelId, String modelName) {
    Get.to(() => ProductListScreen(modelId: modelId, modelName: modelName));
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: Colors.grey[100],
        appBar: AppBar(
          backgroundColor: const Color.fromRGBO(185, 28, 28, 1),
          elevation: 3,
          title: const Text("Select Your Model",
              style:
                  TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
          leading: IconButton(
              color: Colors.white,
              icon: const Icon(Icons.arrow_back_ios_new),
              onPressed: () => Get.back()),
          bottom: TabBar(
            indicatorColor: Colors.white,
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white70,
            controller: _tabController,
            tabs: const [
              Tab(icon: Icon(Icons.directions_car), text: "Cars"),
              Tab(icon: Icon(Icons.motorcycle), text: "Bikes"),
            ],
          ),
        ),
        body: isLoading
            ? buildShimmer()
            : TabBarView(
                controller: _tabController,
                children: [
                  buildModelGrid(carModels),
                  buildModelGrid(bikeModels),
                ],
              ),
      ),
    );
  }

  Widget buildShimmer() {
    return GridView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: 6,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2, crossAxisSpacing: 12, mainAxisSpacing: 12),
      itemBuilder: (_, __) {
        return Shimmer.fromColors(
          baseColor: Colors.grey[300]!,
          highlightColor: Colors.grey[100]!,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
      },
    );
  }

  Widget buildModelGrid(List<dynamic> models) {
    if (models.isEmpty) {
      return const Center(child: Text("No models available"));
    }
    return GridView.builder(
      padding: const EdgeInsets.all(12),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2, crossAxisSpacing: 12, mainAxisSpacing: 12),
      itemCount: models.length,
      itemBuilder: (context, index) {
        var model = models[index];
        return GestureDetector(
          onTap: () => navigateToProducts(model['_id'], model['name']),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              boxShadow: [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 6,
                  offset: const Offset(0, 3),
                )
              ],
            ),
            child: Column(
              children: [
                Expanded(
                  child: ClipRRect(
                    borderRadius:
                        const BorderRadius.vertical(top: Radius.circular(14)),
                    child: model['mediaId'] != null
                        ? Image.network(
                            model['mediaId']['url'],
                            width: double.infinity,
                            fit: BoxFit.contain,
                          )
                        : const Icon(Icons.image_not_supported, size: 50),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(10),
                  child: Column(
                    children: [
                      Text(
                        model['name'],
                        style: const TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        model['brandId']['name'],
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                    ],
                  ),
                )
              ],
            ),
          ),
        );
      },
    );
  }
}

class ProductListScreen extends StatefulWidget {
  final String modelId;
  final String modelName;

  const ProductListScreen({
    super.key,
    required this.modelId,
    required this.modelName,
  });

  @override
  State<ProductListScreen> createState() => _ProductListScreenState();
}

class _ProductListScreenState extends State<ProductListScreen> {
  List<dynamic> products = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchProductsByModel();
  }

  Future<void> fetchProductsByModel() async {
    try {
      final response = await http.get(
        Uri.parse('https://backend.acubemart.in/api/product/all'),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) {
          List<dynamic> allProducts = data['data'];

          products = allProducts.where((product) {
            return product['model'].any((m) => m['_id'] == widget.modelId);
          }).toList();
        }
      }
    } catch (e) {
      debugPrint("Error fetching products: $e");
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.modelName,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new),
          onPressed: () => Get.back(),
        ),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : products.isEmpty
              ? const Center(child: Text("No products available"))
              : GridView.builder(
                  padding: const EdgeInsets.all(10),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2, // Two cards per row
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 0.72,
                  ),
                  itemCount: products.length,
                  itemBuilder: (context, index) {
                    final product = products[index];
                    final String productId = product['_id'];
                    final String productName =
                        product['name'] ?? 'Unknown Product';
                    final List<String> productImages =
                        (product['image'] != null && product['image'] is List)
                            ? product['image']
                                .map<String>((img) => img['url'].toString())
                                .toList()
                            : ['https://via.placeholder.com/150'];
                    final double productPrice =
                        double.tryParse(product['price'].toString()) ?? 0.0;
                    final String productBrand = (product['brand'] is List &&
                            product['brand'].isNotEmpty)
                        ? product['brand'][0]['name'].toString()
                        : 'Unknown Brand';
                    final double productSp =
                        double.tryParse(product['sp'].toString()) ?? 0.0;

                    return GestureDetector(
                      onTap: () => Get.to(
                        () => ProductDetails(
                          productId: productId,
                          productName: productName,
                          productImages: productImages,
                          productPrice: productPrice.toString(),
                          productBrand: productBrand,
                          productSp: productSp.toString(),
                        ),
                      ),
                      child: Card(
                        elevation: 4,
                        shadowColor: Colors.grey.withOpacity(0.3),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        clipBehavior: Clip.antiAlias,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Product Image
                            Expanded(
                              child: ClipRRect(
                                borderRadius: const BorderRadius.only(
                                  topLeft: Radius.circular(15),
                                  topRight: Radius.circular(15),
                                ),
                                child: Image.network(
                                  productImages.first,
                                  fit: BoxFit.cover,
                                  width: double.infinity,
                                ),
                              ),
                            ),

                            // Details Section
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    productName,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    productBrand,
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey.shade600,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    "₹${productSp.toStringAsFixed(2)}",
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                      color: Color.fromRGBO(185, 28, 28, 1),
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
                ),
    );
  }
}
