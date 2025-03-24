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

  @override
  void initState() {
    super.initState();
    fetchProducts();
  }

  Future<void> fetchProducts() async {
    await Future.delayed(Duration(milliseconds: 500));

    List<dynamic> allProducts = Get.arguments ?? [];

    List<dynamic> filtered = allProducts.where((product) {
      if (widget.isType && product['type'] is List) {
        return product['type'].any((t) => t['_id'] == widget.id);
      }
      if (!widget.isType && product['element'] is List) {
        return product['element'].any((e) => e['_id'] == widget.id);
      }
      return false;
    }).toList();

    products.assignAll(filtered);
    isLoading.value = false;
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
          return ListView.builder(
            padding: EdgeInsets.all(16),
            itemCount: products.length,
            itemBuilder: (context, index) {
              return ProductCard(product: products[index]);
            },
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
    final String productImage =
        (product['image'] != null && product['image'].isNotEmpty)
            ? product['image'][0]['url']
            : 'https://via.placeholder.com/150';
    final double productPrice =
        double.tryParse(product['sp'].toString()) ?? 0.0;
    final String productBrand =
        (product['brand'] is List && product['brand'].isNotEmpty)
            ? product['brand'][0]['name'].toString()
            : 'Unknown Brand';

    return GestureDetector(
      onTap: () {
        Get.to(() => ProductDetails(
              productId: productId,
              productName: productName,
              productImage: productImage,
              productPrice: productPrice.toString(),
              productBrand: productBrand,
              productRating: 0.0,
              ratingCount: 0,
            ));
      },
      child: Card(
        margin: EdgeInsets.all(6),
        child: ListTile(
          leading: Image.network(productImage, width: 80, height: 100),
          title:
              Text(productName, maxLines: 2, overflow: TextOverflow.ellipsis),
          subtitle: Text("₹${productPrice.toStringAsFixed(2)}"),
        ),
      ),
    );
  }
}
