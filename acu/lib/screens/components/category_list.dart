import 'package:flutter/material.dart';
import 'package:acu/screens/view_all.dart';
import 'package:acu/services/api_services.dart';
import 'package:get/get.dart';

class CategoryListSection extends StatefulWidget {
  @override
  _CategoryListSectionState createState() => _CategoryListSectionState();
}

class _CategoryListSectionState extends State<CategoryListSection> {
  late Future<List<String>> futureCategories;
  String selectedCategory = '';
  String selectedCategoryId = '';
  List<Map<String, String>> categoryList = [];
  late Future<List<dynamic>> futureProducts;

  @override
  void initState() {
    super.initState();
    futureCategories = CategoryApiService.fetchCategories().then((categories) {
      categoryList = categories;
      if (categoryList.isNotEmpty) {
        selectedCategory = categoryList.first['name']!;
        selectedCategoryId = categoryList.first['id']!;
        futureProducts = fetchProducts(selectedCategoryId);
      }
      return categories.map((e) => e["name"]!).toList();
    });
  }

  Future<List<dynamic>> fetchProducts(String categoryId) async {
    print("🔵 Fetching products for category: $categoryId");
    List<dynamic> products =
        await CategoryApiService.fetchProductsByCategoryId(categoryId);
    print("🟢 Received ${products.length} products for category $categoryId:");
    for (var product in products) {
      print("   ➜ Product ID: ${product['_id']}, Name: ${product['name']}");
    }
    return products;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<String>>(
      future: futureCategories,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text("Error: ${snapshot.error}"));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Center(child: Text("No categories found"));
        } else {
          List<String> categories = snapshot.data!;
          if (selectedCategory.isEmpty) {
            selectedCategory = categories[0];
          }
          return buildCategoryList(categories);
        }
      },
    );
  }

  Widget buildCategoryList(List<String> categories) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.black.withOpacity(0.8), Colors.black],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          padding: EdgeInsets.all(16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'REFINED BY MODELS',
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white),
              ),
              TextButton(
                onPressed: () {
                  Get.to(ViewAllScreen());
                },
                child: Text(
                  'View All',
                  style:
                      TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: 16),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: categories.take(5).map((category) {
              return Padding(
                padding: EdgeInsets.symmetric(horizontal: 5),
                child: TextButton(
                  onPressed: () {
                    setState(() {
                      selectedCategory = category;
                      selectedCategoryId = categoryList.firstWhere(
                          (element) => element['name'] == category)['id']!;
                      print(" Selected Category: $selectedCategory");
                      print(" Selected Category ID: $selectedCategoryId");
                      futureProducts = fetchProducts(selectedCategoryId);
                    });
                  },
                  style: TextButton.styleFrom(
                    foregroundColor: selectedCategory == category
                        ? Colors.red
                        : Colors.black,
                  ),
                  child: Text(
                    category,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      decoration: selectedCategory == category
                          ? TextDecoration.underline
                          : null,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
        SizedBox(height: 16),
        SizedBox(
          height: 300,
          child: FutureBuilder<List<dynamic>>(
            key: ValueKey(selectedCategoryId),
            future: futureProducts,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError) {
                return Center(child: Text("Error loading products"));
              } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return Center(child: Text("No products found"));
              }
              List<dynamic> products = snapshot.data!;
              print(
                  "✅ UI is displaying ${products.length} products for category: $selectedCategoryId");

              List<dynamic> limitedProducts = products.take(2).toList();
              return SizedBox(
                height: 250,
                child: ListView.builder(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  scrollDirection: Axis.vertical,
                  itemCount: limitedProducts.length,
                  itemBuilder: (context, index) {
                    var item = limitedProducts[index];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 10.0),
                      child: _buildItemCard(
                        imageUrl:
                            (item['image'] is List && item['image'].isNotEmpty)
                                ? item['image'][0]['url']
                                : 'https://via.placeholder.com/150',
                        name: item['name'] ?? 'Unknown Item',
                        model:
                            (item['model'] is List && item['model'].isNotEmpty)
                                ? item['model'].map((m) => m['name']).join(", ")
                                : (item['model']?['name'] ?? 'Unknown Model'),
                        type: (item['type'] is List && item['type'].isNotEmpty)
                            ? item['type'].map((t) => t['name']).join(", ")
                            : (item['type']?['name'] ?? 'Unknown Type'),
                        rating: item['rating']?.toString() ?? 'N/A',
                      ),
                    );
                  },
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildItemCard({
    required String imageUrl,
    required String name,
    required String model,
    required String type,
    required String rating,
  }) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 10),
      child: Container(
        width: 160,
        height: 150,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(28),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.2),
              blurRadius: 5,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Padding(
              padding: EdgeInsets.all(8.0),
              child: Container(
                height: 80,
                width: 80,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  image: DecorationImage(
                    image: NetworkImage(imageUrl),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: EdgeInsets.only(left: 8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      name,
                      style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black),
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 4),
                    Text(
                      model,
                      style: TextStyle(fontSize: 16, color: Colors.black),
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 4),
                    Text(
                      type,
                      style: TextStyle(fontSize: 16, color: Colors.black54),
                    ),
                    SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(Icons.star, size: 22, color: Colors.yellow),
                        SizedBox(width: 4),
                        Text(
                          rating,
                          style: TextStyle(fontSize: 16, color: Colors.black54),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
