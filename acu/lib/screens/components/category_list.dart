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
              .toList();
          bikeModels = allModels
              .where((model) => model['typeId']['name'] == 'Bike')
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
            Tab(text: "CARS"),
            Tab(text: "BIKES"),
          ],
          labelColor: Color.fromRGBO(185, 28, 28, 1.0),
          unselectedLabelColor: Colors.black,
          labelStyle: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          indicator: UnderlineTabIndicator(
            borderSide: BorderSide(
              color: Color.fromRGBO(185, 28, 28, 1.0),
              width: 3,
            ),
          ),
        ),
        SizedBox(height: 10),
        Container(
          height: 300,
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
    return GridView.builder(
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 0.9,
      ),
      itemCount: models.length,
      itemBuilder: (context, index) {
        var model = models[index];
        return GestureDetector(
          onTap: () => navigateToProducts(model['_id'], model['name']),
          child: AnimatedContainer(
            duration: Duration(milliseconds: 200),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(15),
              boxShadow: [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 6,
                  offset: Offset(0, 3),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  flex: 6,
                  child: ClipRRect(
                    borderRadius:
                        BorderRadius.vertical(top: Radius.circular(15)),
                    child: model['mediaId'] != null
                        ? Image.network(
                            model['mediaId']['url'],
                            fit: BoxFit.cover,
                            width: double.infinity,
                            errorBuilder: (context, error, stackTrace) => Icon(
                                Icons.image_not_supported,
                                size: 60,
                                color: Colors.grey),
                          )
                        : Icon(Icons.image_not_supported,
                            size: 60, color: Colors.grey),
                  ),
                ),
                Expanded(
                  flex: 4,
                  child: Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          model['name'],
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                          textAlign: TextAlign.center,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        SizedBox(height: 4),
                        Text(
                          model['brandId']['name'],
                          style: TextStyle(
                            color: Colors.grey,
                            fontSize: 12,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
