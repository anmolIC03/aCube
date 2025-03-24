import 'package:acu/screens/prod_details.dart';
import 'package:flutter/material.dart';
import 'package:acu/services/api_services.dart';
import 'package:get/get.dart';

class ViewAllScreen extends StatefulWidget {
  @override
  _ViewAllScreenState createState() => _ViewAllScreenState();
}

class _ViewAllScreenState extends State<ViewAllScreen> {
  List<Map<String, String>> categoryList = [];
  String selectedCategoryId = '';
  Future<List<dynamic>>? futureProducts;

  @override
  void initState() {
    super.initState();
    fetchCategories();
  }

  /// 🔹 Fetch all categories
  Future<void> fetchCategories() async {
    List<Map<String, String>> categories =
        await CategoryApiService.fetchCategories();
    setState(() {
      categoryList = categories;
      if (categoryList.isNotEmpty) {
        selectedCategoryId = categoryList.first['id']!; // Default selection
        fetchProducts(selectedCategoryId);
      }
    });
  }

  /// 🔹 Fetch products when a category is clicked
  void fetchProducts(String categoryId) {
    setState(() {
      selectedCategoryId = categoryId;
      futureProducts = CategoryApiService.fetchProductsByCategoryId(categoryId);
    });
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
        centerTitle: true,
        title: Text(
          "All Categories",
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        ),
      ),
      body: Column(
        children: [
          Container(
            height: 50,
            color: Colors.grey[100],
            child: categoryList.isEmpty
                ? Center(child: CircularProgressIndicator())
                : SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: categoryList.map((category) {
                        bool isSelected = selectedCategoryId == category['id'];
                        return GestureDetector(
                          onTap: () => fetchProducts(category['id']!),
                          child: Container(
                            padding: EdgeInsets.symmetric(
                                vertical: 12, horizontal: 18),
                            margin: EdgeInsets.symmetric(horizontal: 5),
                            decoration: BoxDecoration(
                              color: Colors.transparent,
                              border: isSelected
                                  ? Border(
                                      bottom: BorderSide(
                                          color:
                                              Color.fromRGBO(185, 28, 28, 1.0),
                                          width: 3),
                                    )
                                  : null,
                            ),
                            child: Center(
                              child: Text(
                                category['name']!,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: isSelected
                                      ? Color.fromRGBO(185, 28, 28, 1.0)
                                      : Colors.black,
                                ),
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
          ),

          /// 🔹 Display Products Below
          Expanded(
            child: FutureBuilder<List<dynamic>>(
              future: futureProducts,
              builder: (context, snapshot) {
                if (futureProducts == null) {
                  return Center(child: CircularProgressIndicator());
                }

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text("Error loading products"));
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Center(child: Text("No products found"));
                }

                List<dynamic> products = snapshot.data!;
                return SingleChildScrollView(
                  child: Column(
                    children: products.map((item) {
                      return GestureDetector(
                        onTap: () {
                          String productId = item['_id'];

                          /// 🔹 Extract correct data types
                          double productRating = (item['rating'] is num)
                              ? (item['rating'] as num).toDouble()
                              : 0.0;
                          int ratingCount = (item['rating_count'] is num)
                              ? (item['rating_count'] as num).toInt()
                              : 0;

                          /// 🔹 Navigate to `ProductDetails`
                          Get.to(() => ProductDetails(
                                productId: productId,
                                productName: item['name'] ?? 'Unknown',
                                productImage: (item['image'] is List &&
                                        item['image'].isNotEmpty)
                                    ? item['image'][0]['url']
                                    : 'https://via.placeholder.com/150',
                                productPrice: item['sp']?.toString() ?? 'N/A',
                                productBrand: (item['brand'] is Map)
                                    ? item['brand']['name'] ?? 'Unknown'
                                    : 'Unknown',
                                productRating: productRating,
                                ratingCount: ratingCount,
                              ));
                        },
                        child: _buildItemCard(item),
                      );
                    }).toList(),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  /// 🔹 Product Card UI
  Widget _buildItemCard(Map<String, dynamic> item) {
    String imageUrl = (item['image'] is List && item['image'].isNotEmpty)
        ? item['image'][0]['url']
        : 'https://via.placeholder.com/150';

    String model = 'Unknown Model';
    if (item['model'] is List && item['model'].isNotEmpty) {
      model = item['model'][0]['name'] ?? 'Unknown Model';
    }

    String type = 'Unknown Type';
    if (item['type'] is List && item['type'].isNotEmpty) {
      type = item['type'].map((t) => t['name']).join(", ");
    }

    double rating =
        (item['rating'] is num) ? (item['rating'] as num).toDouble() : 0.0;

    return Card(
      margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: ListTile(
        contentPadding: EdgeInsets.all(10),
        leading:
            Image.network(imageUrl, width: 60, height: 60, fit: BoxFit.cover),
        title: Text(item['name'] ?? 'Unknown Item',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        subtitle: Text(
            "Model: $model\nType: $type\nRating: ${rating.toStringAsFixed(1)}"),
      ),
    );
  }
}
