import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'prod_details.dart';

class ProductsScreen extends StatefulWidget {
  final String title;
  final String id;
  final bool isType;

  const ProductsScreen({
    Key? key,
    required this.title,
    required this.id,
    required this.isType,
  }) : super(key: key);

  @override
  _ProductsScreenState createState() => _ProductsScreenState();
}

class _ProductsScreenState extends State<ProductsScreen> {
  var isLoading = true.obs;
  var products = <dynamic>[].obs;

  int page = 0;
  int batchSize = 10; // Load products in batches of 10
  var isFetchingMore = false.obs;

  @override
  void initState() {
    super.initState();
    fetchProducts();
  }

  Future<void> fetchProducts({bool isPagination = false}) async {
    if (isPagination && isFetchingMore.value) return;

    if (!isPagination) isLoading.value = true;
    isFetchingMore.value = true;

    await Future.delayed(Duration(milliseconds: 500));

    List<dynamic> allProducts = Get.arguments ?? [];

    int startIndex = page * batchSize;
    int endIndex = startIndex + batchSize;

    if (startIndex >= allProducts.length) {
      isFetchingMore.value = false;
      return; // No more products to fetch
    }

    List<dynamic> newProducts = allProducts.sublist(startIndex,
        endIndex > allProducts.length ? allProducts.length : endIndex);

    if (mounted) {
      if (isPagination) {
        products.addAll(newProducts);
      } else {
        products.assignAll(newProducts);
      }
      page++;
      isLoading.value = false;
      isFetchingMore.value = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade200,
      appBar: AppBar(
        elevation: 4,
        title: Text(
          widget.title,
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900),
        ),
        backgroundColor: Colors.white,
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new),
          onPressed: () {
            Get.back();
          },
        ),
      ),
      body: Obx(() {
        if (isLoading.value) {
          return Center(child: CircularProgressIndicator());
        } else if (products.isEmpty) {
          return Center(child: Text("No products available"));
        } else {
          return NotificationListener<ScrollNotification>(
            onNotification: (ScrollNotification scrollInfo) {
              if (scrollInfo.metrics.pixels >=
                      scrollInfo.metrics.maxScrollExtent - 50 &&
                  !isFetchingMore.value) {
                fetchProducts(isPagination: true);
              }
              return true;
            },
            child: ListView.builder(
              padding: EdgeInsets.all(16),
              itemCount: products.length + 1,
              itemBuilder: (context, index) {
                if (index == products.length) {
                  return isFetchingMore.value
                      ? Center(child: CircularProgressIndicator())
                      : SizedBox();
                }
                return ProductCard(product: products[index]);
              },
            ),
          );
        }
      }),
    );
  }
}

class ProductCard extends StatelessWidget {
  final dynamic product;

  const ProductCard({Key? key, required this.product}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final String productId = product['_id'];
    final String productName = product['name'] ?? 'Unknown Product';
    final List<String> productImages = (product['image'] != null &&
            product['image'] is List)
        ? product['image'].map<String>((img) => img['url'].toString()).toList()
        : ['https://via.placeholder.com/150'];
    final double productPrice =
        double.tryParse(product['price'].toString()) ?? 0.0;
    final String productBrand =
        (product['brand'] is List && product['brand'].isNotEmpty)
            ? product['brand'][0]['name'].toString()
            : 'Unknown Brand';
    final double productSp = double.tryParse(product['sp'].toString()) ?? 0.0;

    return GestureDetector(
      onTap: () {
        Get.to(() => ProductDetails(
              productId: productId,
              productName: productName,
              productImages: productImages,
              productPrice: productPrice.toString(),
              productBrand: productBrand,
              productSp: productSp.toString(),
            ));
      },
      child: Card(
        margin: EdgeInsets.all(6),
        child: ListTile(
          leading: Image.network(productImages.first, width: 80, height: 100),
          title:
              Text(productName, maxLines: 2, overflow: TextOverflow.ellipsis),
          subtitle: Text("₹${productPrice.toStringAsFixed(2)}"),
        ),
      ),
    );
  }
}
