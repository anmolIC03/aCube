import 'package:acu/screens/prod_details.dart';
import 'package:flutter/material.dart';
import 'package:acu/services/api_services.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:shimmer/shimmer.dart';

class ViewAllScreen extends StatefulWidget {
  final bool fromDrawer;

  const ViewAllScreen({Key? key, this.fromDrawer = false}) : super(key: key);

  @override
  _ViewAllScreenState createState() => _ViewAllScreenState();
}

class _ViewAllScreenState extends State<ViewAllScreen>
    with SingleTickerProviderStateMixin {
  List<Map<String, dynamic>> categoryList = [];
  List<Map<String, dynamic>> elementList = [];
  List<dynamic> filteredProducts = [];
  List<dynamic> products = [];

  // Cache for all products
  List<dynamic> allProductsCache = [];

  String selectedCategoryId = '';
  String selectedElementId = '';

  bool isLoading = false;
  bool isInitialLoading = false;
  bool isLoadingMore = false;
  bool hasMore = true;
  int page = 1;
  final int limit = 10;

  final ScrollController scrollController = ScrollController();
  final ScrollController _categoryScrollController = ScrollController();
  bool _didAnimateScrollHint = false;
  late PageController pageController;
  final List<GlobalKey> _tabKeys = [];

  final box = GetStorage();

  @override
  void initState() {
    super.initState();
    final args = Get.arguments;
    if (args != null && args is Map<String, dynamic>) {
      selectedCategoryId = args['selectedCategoryId'] ?? '';
    }
    fetchCategories();
    pageController = PageController(initialPage: 0);

    scrollController.addListener(() {
      if (scrollController.position.pixels >=
              scrollController.position.maxScrollExtent - 200 &&
          !isLoadingMore &&
          hasMore) {
        _loadMoreProducts();
      }
    });
  }

  @override
  void dispose() {
    scrollController.dispose();
    _categoryScrollController.dispose();
    pageController.dispose();
    super.dispose();
  }

  Future<void> fetchCategories() async {
    List<Map<String, dynamic>> categories =
        await CategoryApiService.fetchCategories();

    if (!mounted) return;

    setState(() {
      categoryList = categories;
      if (categoryList.isNotEmpty && selectedCategoryId.isEmpty) {
        selectedCategoryId = categoryList.first['id'];
      }
    });

    await fetchAllProductsOnce();
    fetchElements();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_didAnimateScrollHint && categoryList.length > 4) {
        _animateCategoryScrollHint();
        _didAnimateScrollHint = true;
      }
    });
  }

  Future<void> _animateCategoryScrollHint() async {
    try {
      await _categoryScrollController.animateTo(
        40,
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
      await Future.delayed(const Duration(milliseconds: 200));
      await _categoryScrollController.animateTo(
        0,
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    } catch (_) {}
  }

  Future<void> fetchElements() async {
    if (!mounted) return;

    setState(() {
      isLoading = true;
      elementList.clear();
      products.clear();
      filteredProducts.clear();
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

  /// Fetch all products once (from cache or API)
  Future<void> fetchAllProductsOnce() async {
    if (allProductsCache.isNotEmpty) return;

    var cachedData = box.read('allProducts');
    if (cachedData != null && cachedData is List) {
      allProductsCache = cachedData;
      return;
    }

    var response = await CategoryApiService.get('/product/all');
    if (response is Map &&
        response.containsKey('data') &&
        response['data'] is List) {
      allProductsCache = response['data'];
      box.write('allProducts', allProductsCache);
    }
  }

  /// Filter products from cache
  void filterProducts() {
    if (selectedCategoryId.isEmpty || selectedElementId.isEmpty) {
      filteredProducts.clear();
      products.clear();
      setState(() {});
      return;
    }

    filteredProducts = allProductsCache.where((product) {
      bool categoryMatch = product['category'] is List &&
          product['category']
              .any((cat) => cat['_id'].toString().trim() == selectedCategoryId);

      bool elementMatch = product['element'] is List &&
          product['element'].any(
              (elem) => elem['_id'].toString().trim() == selectedElementId);

      return categoryMatch && elementMatch;
    }).toList();

    page = 1;
    hasMore = true;
    products.clear();
    _loadMoreProducts(initial: true);
  }

  void _loadMoreProducts({bool initial = false}) {
    if (!mounted || (!initial && isLoadingMore) || !hasMore) return;

    setState(() {
      if (initial) {
        isInitialLoading = false;
      } else {
        isLoadingMore = true;
      }
    });

    Future.delayed(const Duration(milliseconds: 200), () {
      int start = (page - 1) * limit;
      if (start >= filteredProducts.length) {
        setState(() {
          hasMore = false;
          isLoadingMore = false;
        });
        return;
      }
      int end = start + limit;
      List<dynamic> nextBatch = filteredProducts.sublist(
          start, end > filteredProducts.length ? filteredProducts.length : end);

      setState(() {
        products.addAll(nextBatch);
        hasMore = end < filteredProducts.length;
        page++;
        isLoadingMore = false;
      });
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
                onPressed: () => Get.back(),
              ),
              centerTitle: true,
              title: Text(
                "All Categories",
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
            ),
      body: Column(
        children: [
          _buildCategoryBar(),
          _buildElementsGrid(),
          Expanded(
            child: PageView.builder(
              controller: pageController,
              onPageChanged: (index) {
                if (index < categoryList.length) {
                  setState(() {
                    selectedCategoryId = categoryList[index]['id'];
                  });
                  fetchElements();

                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    final keyContext = _tabKeys[index].currentContext;
                    if (keyContext != null) {
                      final box = keyContext.findRenderObject() as RenderBox;
                      final position = box.localToGlobal(
                        Offset.zero,
                        ancestor: context.findRenderObject(),
                      );
                      final screenWidth = MediaQuery.of(context).size.width;

                      final targetOffset = _categoryScrollController.offset +
                          position.dx -
                          (screenWidth / 2 - box.size.width / 2);

                      _categoryScrollController.animateTo(
                        targetOffset.clamp(
                          _categoryScrollController.position.minScrollExtent,
                          _categoryScrollController.position.maxScrollExtent,
                        ),
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                      );
                    }
                  });
                }
              },
              itemCount: categoryList.length,
              itemBuilder: (context, categoryIndex) {
                return selectedElementId.isEmpty
                    ? Center(
                        child: Text(
                          "Select a sub-category to view products",
                          style: TextStyle(fontSize: 16),
                        ),
                      )
                    : isInitialLoading
                        ? _buildShimmerList()
                        : products.isEmpty
                            ? Center(
                                child: Text(
                                  "No products found",
                                  style: TextStyle(fontSize: 16),
                                ),
                              )
                            : ListView.builder(
                                controller: scrollController,
                                physics: const AlwaysScrollableScrollPhysics(),
                                itemCount:
                                    products.length + (isLoadingMore ? 3 : 0),
                                itemBuilder: (context, index) {
                                  if (index < products.length) {
                                    return _buildItemCard(products[index]);
                                  } else {
                                    return _buildShimmerTile();
                                  }
                                },
                              );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryBar() {
    return Container(
      height: 55,
      color: Colors.grey[100],
      child: categoryList.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : ShaderMask(
              shaderCallback: (Rect bounds) {
                return const LinearGradient(
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                  colors: [
                    Colors.black,
                    Colors.transparent,
                    Colors.transparent,
                    Colors.black
                  ],
                  stops: [0.0, 0.03, 0.97, 1.0],
                ).createShader(bounds);
              },
              blendMode: BlendMode.dstOut,
              child: ListView.builder(
                controller: _categoryScrollController,
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 10),
                itemCount: categoryList.length,
                itemBuilder: (context, index) {
                  if (_tabKeys.length < categoryList.length) {
                    _tabKeys.add(GlobalKey());
                  }

                  final category = categoryList[index];
                  final isSelected = selectedCategoryId == category['id'];

                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        selectedCategoryId = category['id'];
                        products.clear();
                      });
                      fetchElements();
                      pageController.animateToPage(
                        index,
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                      );
                    },
                    child: Container(
                      key: _tabKeys[index],
                      alignment: Alignment.center,
                      padding: const EdgeInsets.symmetric(horizontal: 18),
                      margin: const EdgeInsets.symmetric(horizontal: 6),
                      decoration: BoxDecoration(
                        border: isSelected
                            ? const Border(
                                bottom: BorderSide(
                                    color: Color.fromRGBO(185, 28, 28, 1.0),
                                    width: 3),
                              )
                            : null,
                      ),
                      child: Text(
                        category['name'],
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: isSelected
                              ? const Color.fromRGBO(185, 28, 28, 1.0)
                              : Colors.black,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
    );
  }

  Widget _buildElementsGrid() {
    return Expanded(
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
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 8,
                      mainAxisSpacing: 9,
                      childAspectRatio: 2.8,
                    ),
                    itemBuilder: (context, index) {
                      var element = elementList[index];
                      bool isSelected = selectedElementId == element['id'];
                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            selectedElementId = element['id'];
                            isInitialLoading = true;
                          });
                          filterProducts();
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
                            textAlign: TextAlign.center,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 15,
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
    );
  }

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
            productSp: item['sp']?.toString() ?? '0',
            productId: item['_id']));
      },
      child: Card(
        margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        elevation: 3,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        child: ListTile(
          leading: Image.network(productImages.first, width: 60, height: 80),
          title: Text(item['name']),
          subtitle: Text("₹${item['sp']}"),
        ),
      ),
    );
  }

  Widget _buildShimmerGrid() {
    return GridView.builder(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      itemCount: 6,
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

  Widget _buildShimmerList() {
    return ListView.builder(
      itemCount: 6,
      itemBuilder: (context, index) => _buildShimmerTile(),
    );
  }

  Widget _buildShimmerTile() {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: ListTile(
        leading: Container(width: 60, height: 80, color: Colors.white),
        title: Container(height: 16, color: Colors.white),
        subtitle: Container(
            height: 14, margin: EdgeInsets.only(top: 6), color: Colors.white),
      ),
    );
  }
}
