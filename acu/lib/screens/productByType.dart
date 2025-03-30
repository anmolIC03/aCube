import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:acu/screens/prod_details.dart';

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

          // Separate models into Car and Bike lists
          carModels = allModels
              .where((model) => model['typeId']['name'] == 'Car')
              .toList();
          bikeModels = allModels
              .where((model) => model['typeId']['name'] == 'Bike')
              .toList();
        }
      } else {
        print("Failed to fetch models. Status Code: ${response.statusCode}");
      }
    } catch (e) {
      print("Error fetching models: $e");
    }

    if (mounted) {
      setState(() {
        isLoading = false;
      });
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
        appBar: AppBar(
          title: const Text("Select Model"),
          bottom: TabBar(
            controller: _tabController,
            tabs: const [
              Tab(text: "Cars"),
              Tab(text: "Bikes"),
            ],
          ),
        ),
        body: isLoading
            ? const Center(child: CircularProgressIndicator())
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

  Widget buildModelGrid(List<dynamic> models) {
    if (models.isEmpty) {
      return const Center(child: Text("No models available"));
    }
    return GridView.builder(
      padding: const EdgeInsets.all(8),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2, // 2 items per row
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        childAspectRatio: 0.9, // Adjust the height of each grid item
      ),
      itemCount: models.length,
      itemBuilder: (context, index) {
        var model = models[index];
        return GestureDetector(
          onTap: () => navigateToProducts(model['_id'], model['name']),
          child: Card(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            elevation: 3,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: model['mediaId'] != null
                      ? Image.network(
                          model['mediaId']['url'],
                          width: double.infinity,
                          fit: BoxFit.scaleDown,
                          errorBuilder: (context, error, stackTrace) =>
                              const Icon(Icons.image_not_supported, size: 50),
                        )
                      : const Icon(Icons.image_not_supported, size: 50),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
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
                        style: const TextStyle(color: Colors.grey),
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

class ProductListScreen extends StatefulWidget {
  final String modelId;
  final String modelName;

  const ProductListScreen(
      {super.key, required this.modelId, required this.modelName});

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

          // Filter products by selected model
          products = allProducts.where((product) {
            return product['model'].any((m) => m['_id'] == widget.modelId);
          }).toList();
        }
      } else {
        print("Failed to fetch products. Status Code: ${response.statusCode}");
      }
    } catch (e) {
      print("Error fetching products: $e");
    }

    if (mounted) {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Products for ${widget.modelName}")),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : products.isEmpty
              ? const Center(child: Text("No products available"))
              : ListView.builder(
                  itemCount: products.length,
                  padding: const EdgeInsets.all(8),
                  itemBuilder: (context, index) {
                    var product = products[index];
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
                        double.tryParse(product['sp'].toString()) ?? 0.0;
                    final String productBrand = (product['brand'] is List &&
                            product['brand'].isNotEmpty)
                        ? product['brand'][0]['name'].toString()
                        : 'Unknown Brand';

                    return Card(
                      elevation: 3,
                      margin: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 6),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                      child: InkWell(
                        onTap: () => Get.to(
                          () => ProductDetails(
                            productId: productId,
                            productName: productName,
                            productImages: productImages,
                            productPrice: productPrice.toString(),
                            productBrand: productBrand,
                            productRating: 0.0,
                            ratingCount: 0,
                          ),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.network(
                                  productImages.first,
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
                                    Text(productName,
                                        style: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold)),
                                    Text("Brand: $productBrand",
                                        style: const TextStyle(
                                            color: Colors.grey)),
                                    Text("₹${productPrice.toStringAsFixed(2)}",
                                        style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: Colors.blue)),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}
