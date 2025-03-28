import 'package:acu/screens/prod_details.dart';
import 'package:flutter/material.dart';
import 'package:acu/services/api_services.dart';
import 'package:get/get.dart';

class ViewAllScreen extends StatefulWidget {
  final bool fromDrawer;

  const ViewAllScreen({Key? key, this.fromDrawer = false}) : super(key: key);

  @override
  _ViewAllScreenState createState() => _ViewAllScreenState();
}

class _ViewAllScreenState extends State<ViewAllScreen> {
  List<Map<String, String>> categoryList = [];
  String selectedCategoryId = '';

  List<dynamic> products = [];
  bool isLoading = false;
  bool hasMore = true;
  int page = 1;
  final int limit = 10; // Load 10 products per request
  ScrollController scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    fetchCategories();

    // 🔹 Add Scroll Listener for Lazy Loading
    scrollController.addListener(() {
      if (scrollController.position.pixels ==
              scrollController.position.maxScrollExtent &&
          !isLoading &&
          hasMore) {
        fetchProducts();
      }
    });
  }

  /// 🔹 Fetch categories from the backend
  Future<void> fetchCategories() async {
    List<Map<String, String>> categories =
        await CategoryApiService.fetchCategories();

    setState(() {
      categoryList = categories;
      if (categoryList.isNotEmpty) {
        selectedCategoryId = categoryList.first['id']!;
        fetchProducts(); // Load initial products
      }
    });
  }

  /// 🔹 Fetch products with pagination (Lazy Loading)
  Future<void> fetchProducts() async {
    if (isLoading || !hasMore) return;

    setState(() {
      isLoading = true;
    });

    List<dynamic> newProducts =
        await CategoryApiService.fetchProductsByCategoryId(
            selectedCategoryId, page, limit);

    setState(() {
      if (newProducts.length < limit) {
        hasMore = false;
      }
      products.addAll(newProducts);
      page++;
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: widget.fromDrawer
          ? null
          : AppBar(
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
          /// 🔹 Category Selection Bar
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
                          onTap: () {
                            setState(() {
                              selectedCategoryId = category['id']!;
                              products.clear();
                              page = 1;
                              hasMore = true;
                            });
                            fetchProducts();
                          },
                          child: Container(
                            padding: EdgeInsets.symmetric(
                                vertical: 12, horizontal: 18),
                            margin: EdgeInsets.symmetric(horizontal: 5),
                            decoration: BoxDecoration(
                              border: isSelected
                                  ? Border(
                                      bottom: BorderSide(
                                          color:
                                              Color.fromRGBO(185, 28, 28, 1.0),
                                          width: 3),
                                    )
                                  : null,
                            ),
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
                        );
                      }).toList(),
                    ),
                  ),
          ),

          /// 🔹 Products List (Lazy Loading Enabled)
          Expanded(
            child: products.isEmpty && !isLoading
                ? Center(child: Text("No products found"))
                : ListView.builder(
                    controller: scrollController,
                    itemCount: products.length + 1,
                    itemBuilder: (context, index) {
                      if (index < products.length) {
                        return _buildItemCard(products[index]);
                      } else {
                        return isLoading
                            ? Center(child: CircularProgressIndicator())
                            : SizedBox(); // Hide when no more products
                      }
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

    return GestureDetector(
      onTap: () {
        Get.to(() => ProductDetails(
              productId: item['_id'],
              productName: item['name'] ?? 'Unknown',
              productImage: imageUrl,
              productPrice: item['sp']?.toString() ?? 'N/A',
              productBrand: (item['brand'] is Map)
                  ? item['brand']['name'] ?? 'Unknown'
                  : 'Unknown',
              productRating: rating,
              ratingCount: (item['rating_count'] is num)
                  ? (item['rating_count'] as num).toInt()
                  : 0,
            ));
      },
      child: Card(
        margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        elevation: 3,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        child: ListTile(
          contentPadding: EdgeInsets.all(10),
          leading: Image.network(imageUrl, width: 60, height: 60),
          title: Text(item['name'] ?? 'Unknown Item',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          subtitle: Text(
              "Model: $model\nType: $type\nRating: ${rating.toStringAsFixed(1)}"),
        ),
      ),
    );
  }
}
