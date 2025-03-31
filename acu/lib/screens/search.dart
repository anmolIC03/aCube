import 'dart:convert';
import 'package:acu/screens/components/home_controller.dart';
import 'package:acu/screens/prod_details.dart';
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

  void searchProducts(String query) {
    if (query.isEmpty) {
      filteredProducts.clear();
      return;
    }

    final results = homeController.productList.where((product) {
      final name = product.name.toLowerCase();
      final searchLower = query.toLowerCase();
      return name.contains(searchLower);
    }).toList();

    filteredProducts.assignAll(results);
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
            hintText: "Search products...",
            border: InputBorder.none,
          ),
        ),
      ),
      body: Obx(() {
        if (filteredProducts.isEmpty) {
          return Center(
            child: Text("No products found"),
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
              final product = filteredProducts[index];

              return GestureDetector(
                onTap: () {
                  Get.to(() => ProductDetails(
                        productId: product.id,
                        productName: product.name,
                        productImages: product.images,
                        productPrice: product.price.toString(),
                        productBrand: product.brand,
                        productRating: product.rating,
                        ratingCount: product.ratingCount,
                        productSp: product.sp.toString(),
                      ));
                },
                child: _buildProductCard(product),
              );
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
}
