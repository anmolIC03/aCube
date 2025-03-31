import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:acu/services/api_services.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:acu/screens/productByType.dart';

class CategoryListSection extends StatefulWidget {
  @override
  _CategoryListSectionState createState() => _CategoryListSectionState();
}

class _CategoryListSectionState extends State<CategoryListSection>
    with SingleTickerProviderStateMixin {
  late Future<List<String>> futureCategories;
  String selectedCategory = '';
  String selectedCategoryId = '';
  List<Map<String, String>> categoryList = [];
  late Future<List<dynamic>> futureProducts;

  // Variables for Model Tabs
  late TabController _tabController;
  List<dynamic> carModels = [];
  List<dynamic> bikeModels = [];
  bool isModelLoading = true;

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

    _tabController = TabController(length: 2, vsync: this);
    fetchModels();
  }

  Future<List<dynamic>> fetchProducts(String categoryId) async {
    return await CategoryApiService.fetchProductsByCategoryId(
        categoryId, 1, 20);
  }

  Future<void> fetchModels() async {
    try {
      final response = await http.get(
        Uri.parse('https://backend.acubemart.in/api/model/all'),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) {
          List<dynamic> allModels = data['data'];

          carModels = allModels
              .where((model) => model['typeId']['name'] == 'Car')
              .take(5)
              .toList();
          bikeModels = allModels
              .where((model) => model['typeId']['name'] == 'Bike')
              .take(5)
              .toList();
        }
      }
    } catch (e) {
      print("Error fetching models: $e");
    }

    if (mounted) {
      setState(() {
        isModelLoading = false;
      });
    }
  }

  void navigateToProducts(String modelId, String modelName) {
    Get.to(() => ProductListScreen(modelId: modelId, modelName: modelName));
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        buildRefinedByModelsHeader(),
        SizedBox(height: 8),
        buildModelTabs(),
      ],
    );
  }

  Widget buildRefinedByModelsHeader() {
    return Container(
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
                fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
          ),
          TextButton(
            onPressed: () {
              Get.to(TypeAndModel());
            },
            child: Text(
              'View All',
              style: TextStyle(
                  color: Color.fromRGBO(185, 28, 28, 1.0),
                  fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildModelTabs() {
    return Column(
      children: [
        TabBar(
          controller: _tabController,
          tabs: [
            Tab(text: "Cars"),
            Tab(text: "Bikes"),
          ],
          labelColor: Colors.black,
          indicatorColor: Color.fromRGBO(185, 28, 28, 1.0),
        ),
        SizedBox(height: 8),
        Container(
          height: 300, // Adjust height for better layout
          child: isModelLoading
              ? Center(child: CircularProgressIndicator())
              : TabBarView(
                  controller: _tabController,
                  children: [
                    buildModelList(carModels),
                    buildModelList(bikeModels),
                  ],
                ),
        ),
      ],
    );
  }

  Widget buildModelList(List<dynamic> models) {
    if (models.isEmpty) {
      return Center(child: Text("No models available"));
    }
    return ListView.builder(
      itemCount: models.length,
      itemBuilder: (context, index) {
        var model = models[index];
        return GestureDetector(
          onTap: () => navigateToProducts(model['_id'], model['name']),
          child: Card(
            elevation: 3,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            margin: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            child: ListTile(
              leading: model['mediaId'] != null
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        model['mediaId']['url'],
                        width: 50,
                        height: 50,
                        fit: BoxFit.scaleDown,
                        errorBuilder: (context, error, stackTrace) =>
                            Icon(Icons.image_not_supported, size: 50),
                      ),
                    )
                  : Icon(Icons.image_not_supported, size: 50),
              title: Text(
                model['name'],
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Text(
                model['brandId']['name'],
                style: TextStyle(color: Colors.grey, fontSize: 12),
              ),
              trailing:
                  Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
            ),
          ),
        );
      },
    );
  }
}
