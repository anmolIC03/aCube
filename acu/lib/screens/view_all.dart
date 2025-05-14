import 'package:acu/screens/prod_details.dart';
import 'package:flutter/material.dart';
import 'package:acu/services/api_services.dart';
import 'package:get/get.dart';
import 'package:shimmer/shimmer.dart';

class ViewAllScreen extends StatefulWidget {
  final bool fromDrawer;

  const ViewAllScreen({Key? key, this.fromDrawer = false}) : super(key: key);

  @override
  _ViewAllScreenState createState() => _ViewAllScreenState();
}

class _ViewAllScreenState extends State<ViewAllScreen> {
  List<Map<String, dynamic>> categoryList = [];
  List<Map<String, dynamic>> elementList = [];
  List<dynamic> products = [];

  String selectedCategoryId = '';
  String selectedElementId = '';

  bool isLoading = false;
  bool hasMore = true;
  int page = 1;
  final int limit = 10;
  ScrollController scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    final args = Get.arguments;
    if (args != null && args is Map<String, dynamic>) {
      selectedCategoryId = args['selectedCategoryId'] ?? '';
    }
    fetchCategories();

    scrollController.addListener(() {
      if (scrollController.position.pixels ==
              scrollController.position.maxScrollExtent &&
          !isLoading &&
          hasMore) {
        fetchProducts();
      }
    });
  }

  @override
  void dispose() {
    scrollController.dispose();
    super.dispose();
  }

  Future<void> fetchCategories() async {
    List<Map<String, dynamic>> categories =
        await CategoryApiService.fetchCategories();

    if (!mounted) {
      return;
    }

    setState(() {
      categoryList = categories;
      if (categoryList.isNotEmpty) {
        selectedCategoryId = categoryList.first['id'];
        fetchElements();
      }
    });
  }

  Future<void> fetchElements() async {
    if (!mounted) return;

    setState(() {
      isLoading = true;
      elementList.clear();
      products.clear();
      page = 1;
      hasMore = true;
      selectedElementId = '';
    });

    List<Map<String, dynamic>> elements =
        await CategoryApiService.fetchElementsByCategoryId(selectedCategoryId);

    if (!mounted) return;

    setState(() {
      elementList = elements;
      isLoading = false;
    });
  }

  Future<void> fetchProducts() async {
    if (!mounted || isLoading || !hasMore || selectedElementId.isEmpty) return;

    setState(() {
      isLoading = true;
    });

    var response = await CategoryApiService.get('/product/all');

    List<dynamic> allProducts = [];

    if (response is Map &&
        response.containsKey('data') &&
        response['data'] is List) {
      allProducts = response['data'];
    } else {
      setState(() {
        isLoading = false;
      });
      return;
    }

    List<dynamic> filteredProducts = allProducts.where((product) {
      bool categoryMatch = product['category'] is List &&
          product['category']
              .any((cat) => cat['_id'].toString().trim() == selectedCategoryId);

      bool elementMatch = product['element'] is List &&
          product['element'].any(
              (elem) => elem['_id'].toString().trim() == selectedElementId);

      return categoryMatch && elementMatch;
    }).toList();

    if (!mounted) return;

    setState(() {
      products = filteredProducts;
      hasMore = filteredProducts.length >= limit;
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
          /// Categories
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
                              selectedCategoryId = category['id'];
                              products.clear();
                            });
                            fetchElements();
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
                              category['name'],
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

          /// Elements
          Expanded(
            flex: 0,
            child: Container(
              padding: EdgeInsets.all(6),
              color: Colors.grey[200],
              child: isLoading
                  ? _buildShimmerGrid()
                  : elementList.isEmpty
                      ? Center(child: Text("No elements found"))
                      : GridView.builder(
                          shrinkWrap: true,
                          physics: NeverScrollableScrollPhysics(),
                          itemCount: elementList.length,
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: 8,
                            mainAxisSpacing: 9,
                            childAspectRatio: 2.8,
                          ),
                          itemBuilder: (context, index) {
                            var element = elementList[index];
                            bool isSelected =
                                selectedElementId == element['id'];
                            return GestureDetector(
                              onTap: () {
                                setState(() {
                                  selectedElementId = element['id'];
                                  products.clear();
                                  page = 1;
                                  hasMore = true;
                                });
                                fetchProducts();
                              },
                              child: Container(
                                alignment: Alignment.center,
                                padding: EdgeInsets.symmetric(vertical: 12),
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? Color.fromRGBO(185, 28, 28, 1.0)
                                      : Colors.white,
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                      color: Color.fromRGBO(185, 28, 28, 1.0)),
                                ),
                                child: Text(
                                  element['name'].toString().capitalize!,
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: isSelected
                                        ? Colors.white
                                        : Color.fromRGBO(185, 28, 28, 1.0),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
            ),
          ),

          /// Products
          Expanded(
            child: selectedElementId.isEmpty
                ? Center(
                    child: Text("Select a sub-category to view products"),
                  )
                : products.isEmpty && !isLoading
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
                                : SizedBox();
                          }
                        },
                      ),
          ),
        ],
      ),
    );
  }

  /// Product Card
  Widget _buildItemCard(Map<String, dynamic> item) {
    List<String> productImages =
        (item['image'] is List && item['image'].isNotEmpty)
            ? item['image'].map<String>((img) => img['url'].toString()).toList()
            : ['https://via.placeholder.com/150'];

    String productBrand = (item['brand'] is List && item['brand'].isNotEmpty)
        ? item['brand'].first['name'] ?? 'Unknown'
        : 'Unknown';

    return GestureDetector(
      onTap: () {
        Get.to(() => ProductDetails(
            productName: item['name'],
            productImages: productImages,
            productPrice: item['price']?.toString() ?? '0',
            productBrand: productBrand,
            productRating: item['rating']?.toDouble() ?? 0.0,
            ratingCount: item['ratingCount'] ?? 0,
            productSp: item['sp']?.toString() ?? '0',
            productId: item['_id']));
      },
      child: Card(
        margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        elevation: 3,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        child: ListTile(
          leading:
              Image.network(item['image'][0]['url'], width: 60, height: 80),
          title: Text(item['name']),
          subtitle: Text("₹${item['sp']}"),
        ),
      ),
    );
  }

  /// Shimmer Loading
  Widget _buildShimmerGrid() {
    return GridView.builder(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      itemCount: 6, // Show 6 placeholders
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 8,
        mainAxisSpacing: 9,
        childAspectRatio: 2.8,
      ),
      itemBuilder: (context, index) {
        return Shimmer.fromColors(
          baseColor: Colors.grey[300]!,
          highlightColor: Colors.grey[100]!,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
            ),
          ),
        );
      },
    );
  }
}
