import 'package:acu/screens/prod_details.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:acu/services/api_services.dart';

class ViewAllCategoriesScreen extends StatefulWidget {
  @override
  _ViewAllCategoriesScreenState createState() =>
      _ViewAllCategoriesScreenState();
}

class _ViewAllCategoriesScreenState extends State<ViewAllCategoriesScreen> {
  List<Map<String, String>> types = [];
  String selectedTypeId = '';
  List<dynamic> allProducts = [];
  List<dynamic> filteredProducts = [];
  bool isLoadingProducts = false;
  bool isLoadingCategories = true;

  @override
  void initState() {
    super.initState();
    fetchTypes();
    fetchAllProducts();
  }

  Future<void> fetchTypes() async {
    var response = await CategoryApiService.get('/type/all');

    if (response is Map<String, dynamic> && response.containsKey('data')) {
      List<dynamic> typeList = response['data'];

      if (typeList.isNotEmpty) {
        setState(() {
          types = typeList
              .map((type) => {
                    'id': type['_id'].toString(),
                    'name': type['name'].toString()
                  })
              .toList();
        });
      }
    }
    setState(() {
      isLoadingCategories = false;
    });
  }

  Future<void> fetchAllProducts() async {
    setState(() {
      isLoadingProducts = true;
    });

    try {
      var response = await CategoryApiService.get('/product/all');

      if (response is Map<String, dynamic> && response.containsKey('data')) {
        setState(() {
          allProducts = response['data'];
          filteredProducts = allProducts;
        });
      }
    } finally {
      setState(() {
        isLoadingProducts = false;
      });
    }
  }

  void filterProductsByType(String typeId) {
    setState(() {
      selectedTypeId = typeId;
      filteredProducts = allProducts.where((product) {
        if (product['type'] is List) {
          return product['type'].any((t) => t['_id'] == typeId);
        }
        return false;
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade200,
      appBar: AppBar(
        elevation: 4,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new),
          onPressed: () {
            Get.back();
          },
        ),
        centerTitle: true,
        title: Text(
          'CATEGORIES',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900),
        ),
        backgroundColor: Colors.white,
      ),
      body: Column(
        children: [
          Expanded(
            flex: 1,
            child: isLoadingCategories
                ? Center(child: CircularProgressIndicator())
                : types.isEmpty
                    ? Center(child: Text("No categories available"))
                    : Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: GridView.builder(
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: 16,
                            mainAxisSpacing: 16,
                            childAspectRatio: 3,
                          ),
                          itemCount: types.length,
                          itemBuilder: (context, index) {
                            final type = types[index];

                            return GestureDetector(
                              onTap: () {
                                filterProductsByType(type['id']!);
                              },
                              child: Container(
                                padding: EdgeInsets.symmetric(
                                    vertical: 12, horizontal: 20),
                                decoration: BoxDecoration(
                                  color: selectedTypeId == type['id']
                                      ? Colors.orange
                                      : Colors.white,
                                  borderRadius: BorderRadius.circular(50),
                                  border: Border.all(
                                    color: selectedTypeId == type['id']
                                        ? Colors.orange
                                        : Colors.grey.shade300,
                                    width: 2,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black12,
                                      blurRadius: 4,
                                      spreadRadius: 1,
                                      offset: Offset(2, 2),
                                    )
                                  ],
                                ),
                                child: Center(
                                  child: Text(
                                    type['name']!,
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                      color: selectedTypeId == type['id']
                                          ? Colors.white
                                          : Colors.black,
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
          ),

          // Product List
          Expanded(
            flex: 2,
            child: isLoadingProducts
                ? Center(child: CircularProgressIndicator())
                : filteredProducts.isEmpty
                    ? Center(
                        child: Text("No products available for this category"))
                    : Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: ListView.builder(
                          itemCount: filteredProducts.length,
                          itemBuilder: (context, index) {
                            return ProductCard(
                                product: filteredProducts[index]);
                          },
                        ),
                      ),
          ),
        ],
      ),
    );
  }
}

// Product Card Widget
class ProductCard extends StatelessWidget {
  final dynamic product;

  const ProductCard({Key? key, required this.product}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Extract product details safely
    final String productName = product['name'] ?? 'Unknown Product';
    final String productImage =
        (product['image'] != null && product['image'].isNotEmpty)
            ? product['image'][0]['url']
            : 'https://via.placeholder.com/150';
    final double productPrice = product['price'] != null
        ? double.tryParse(product['price'].toString()) ?? 0.0
        : 0.0;

    // FIXED: Handling product['brand'] as a list
    final String productBrand =
        (product['brand'] is List && product['brand'].isNotEmpty)
            ? product['brand'][0]['name'].toString()
            : 'Unknown Brand';

    final double productRating = product['rating'] != null
        ? double.tryParse(product['rating'].toString()) ?? 0.0
        : 0.0;
    final int ratingCount = product['ratingCount'] != null
        ? int.tryParse(product['ratingCount'].toString()) ?? 0
        : 0;

    return GestureDetector(
      onTap: () {
        Get.to(() => ProductDetails(
              productName: productName,
              productImage: productImage,
              productPrice: productPrice.toString(),
              productBrand: productBrand,
              productRating: productRating,
              ratingCount: ratingCount,
            ));
      },
      child: Card(
        color: Colors.white,
        margin: EdgeInsets.symmetric(vertical: 8, horizontal: 12),
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(22),
        ),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  productImage,
                  width: 80,
                  height: 80,
                  fit: BoxFit.cover,
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      productName,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 4),
                    Text(
                      "₹${productPrice.toStringAsFixed(2)}",
                      style: TextStyle(
                        color: Colors.orange,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      productBrand,
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 14,
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
  }
}
