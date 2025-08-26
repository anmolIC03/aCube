import 'dart:convert';
import 'package:acu/screens/components/home_controller.dart';
import 'package:acu/screens/prod_details.dart';
import 'package:acu/screens/productByType.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

class SearchScreen extends StatefulWidget {
  @override
  _SearchScreenState createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController searchController = TextEditingController();
  final HomeController homeController = Get.find<HomeController>();
  RxList<dynamic> filteredProducts = <dynamic>[].obs;

  List<dynamic> allModels = [];

  @override
  void initState() {
    super.initState();
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
          allModels = data['data'];
        }
      }
    } catch (e) {
      print("Error fetching models: $e");
    }
  }

  void searchProducts(String query) {
    if (query.isEmpty) {
      filteredProducts.clear();
      return;
    }

    final searchLower = query.toLowerCase();

    final productResults = homeController.productList.where((product) {
      return product.name.toLowerCase().contains(searchLower);
    });

    final modelResults = allModels.where((model) {
      final name = model['name']?.toString().toLowerCase() ?? '';
      final brand = model['brandId']['name']?.toString().toLowerCase() ?? '';
      return name.contains(searchLower) || brand.contains(searchLower);
    });

    filteredProducts.assignAll([...productResults, ...modelResults]);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new),
          onPressed: () {
            Get.back();
          },
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        title: TextField(
          controller: searchController,
          autofocus: true,
          onChanged: searchProducts,
          decoration: InputDecoration(
            hintText: "Search products & models...",
            border: InputBorder.none,
          ),
        ),
      ),
      body: Obx(() {
        if (filteredProducts.isEmpty) {
          return Center(
            child: Text("Search product or model..."),
          );
        }

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10),
          child: GridView.builder(
            itemCount: filteredProducts.length,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              childAspectRatio: 0.75,
            ),
            itemBuilder: (context, index) {
              final item = filteredProducts[index];

              // Check if it's a Product (has .id) or a Model (Map with _id)
              if (item.runtimeType.toString().contains('Product')) {
                return GestureDetector(
                  onTap: () {
                    Get.to(() => ProductDetails(
                          productId: item.id,
                          productName: item.name,
                          productImages: item.images,
                          productPrice: item.price.toString(),
                          productBrand: item.brand,
                          productSp: item.sp.toString(),
                        ));
                  },
                  child: _buildProductCard(item),
                );
              } else {
                return GestureDetector(
                  onTap: () {
                    Get.to(() => ProductListScreen(
                          modelId: item['_id'],
                          modelName: item['name'],
                        ));
                  },
                  child: _buildModelCard(item),
                );
              }
            },
          ),
        );
      }),
    );
  }

  Widget _buildProductCard(dynamic product) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 5,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.vertical(top: Radius.circular(10)),
              child: Image.network(
                product.images[0],
                width: double.infinity,
                fit: BoxFit.scaleDown,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              product.name,
              style: TextStyle(fontWeight: FontWeight.bold),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Text(
              "₹${product.sp}",
              style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModelCard(dynamic model) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 5,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.vertical(top: Radius.circular(10)),
              child: model['mediaId'] != null
                  ? Image.network(
                      model['mediaId']['url'],
                      width: double.infinity,
                      fit: BoxFit.scaleDown,
                      errorBuilder: (_, __, ___) =>
                          const Icon(Icons.image_not_supported),
                    )
                  : Icon(Icons.image_not_supported),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              model['name'],
              style: TextStyle(fontWeight: FontWeight.bold),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Text(
              model['brandId']['name'],
              style: TextStyle(color: Colors.grey),
            ),
          ),
        ],
      ),
    );
  }
}
