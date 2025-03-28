import 'package:acu/screens/prodByCategory.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:acu/services/api_services.dart';

class ViewAllCategoriesScreen extends StatefulWidget {
  @override
  _ViewAllCategoriesScreenState createState() =>
      _ViewAllCategoriesScreenState();
}

class _ViewAllCategoriesScreenState extends State<ViewAllCategoriesScreen> {
  List<Map<String, String>> elements = [];
  bool isLoadingElements = true;
  bool isLoadingProducts = true;
  List<dynamic> allProducts = [];

  @override
  void initState() {
    super.initState();
    fetchElements();
    fetchAllProducts();
  }

  Future<void> fetchElements() async {
    var response = await CategoryApiService.get('/element/all');
    if (!mounted) return;

    if (response is Map<String, dynamic> && response.containsKey('data')) {
      List<dynamic> elementList = response['data'];
      if (elementList.isNotEmpty) {
        setState(() {
          elements = elementList
              .map((element) => {
                    'id': element['_id'].toString(),
                    'name': element['name'].toString()
                  })
              .toList();
        });
      }
    }
    setState(() {
      isLoadingElements = false;
    });
  }

  Future<void> fetchAllProducts() async {
    var response = await CategoryApiService.get('/product/all');
    if (!mounted) return;

    if (response is Map<String, dynamic> && response.containsKey('data')) {
      setState(() {
        allProducts = response['data'];
      });
    }
    setState(() {
      isLoadingProducts = false;
    });
  }

  void navigateToProductsScreen(String id, String name) {
    List<dynamic> filtered = allProducts.where((product) {
      if (product['element'] is List) {
        return product['element'].any((e) => e['_id'] == id);
      }
      return false;
    }).toList();

    Get.to(
        () => ProductsScreen(
              title: name,
              id: id,
              isType: false,
            ),
        arguments: filtered);
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
          'ELEMENTS',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900),
        ),
        backgroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: isLoadingElements
            ? Center(child: CircularProgressIndicator())
            : GridView.builder(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 2.3,
                ),
                itemCount: elements.length,
                itemBuilder: (context, index) {
                  final item = elements[index];

                  return GestureDetector(
                    onTap: () =>
                        navigateToProductsScreen(item['id']!, item['name']!),
                    child: Container(
                      padding:
                          EdgeInsets.symmetric(vertical: 12, horizontal: 20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border(
                          bottom: BorderSide(
                            color: Colors.grey.shade300,
                            width: 3,
                          ),
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
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            item['name']!,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
      ),
    );
  }
}
