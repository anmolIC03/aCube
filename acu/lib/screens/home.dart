import 'package:acu/models/product_models.dart';
import 'package:acu/screens/productByType.dart';
import 'package:acu/screens/cart_page.dart';
import 'package:acu/screens/components/cart_components/cart_controller.dart';
import 'package:acu/screens/components/cart_components/cart_item.dart';
import 'package:acu/screens/components/category_card.dart';
import 'package:acu/screens/components/category_list.dart';
import 'package:acu/screens/components/home_controller.dart';
import 'package:acu/screens/components/products/rating_list.dart';
import 'package:acu/screens/components/wishlist_controller.dart';
import 'package:acu/screens/prodByCategory.dart';
import 'package:acu/screens/prod_details.dart';
import 'package:acu/screens/search.dart';
import 'package:acu/screens/view_all.dart';
import 'package:acu/screens/wishlist.dart';
import 'package:acu/services/api_services.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_nav_bar/google_nav_bar.dart';

import 'components/cart_components/product_components/prodList.dart';

class HomeScreen extends StatefulWidget {
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final PageController _pageController = PageController(viewportFraction: 0.8);
  final TextEditingController _emailController = TextEditingController();
  final HomeController homeController = Get.put(HomeController());

  int selectedIndex = 0;
  var elements = <Map<String, String>>[].obs;
  var isLoading = false.obs;
  var searchQuery = ''.obs;
  var filteredProducts = <dynamic>[].obs;
  final RxInt selectIndex = 0.obs; // Default selected tab (Home)

  @override
  void initState() {
    super.initState();
    fetchElements();
    Get.find<CartController>().fetchCart();

    ever(homeController.productList, (_) {
      filteredProducts.assignAll(homeController.productList);
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      filteredProducts.assignAll(homeController.productList);
    });
  }

  void filterProducts() {
    if (searchQuery.value.isEmpty) {
      filteredProducts.assignAll(homeController.productList);
    } else {
      filteredProducts.assignAll(homeController.productList.where((product) {
        return product.name
            .toLowerCase()
            .contains(searchQuery.value.toLowerCase());
      }).toList());
    }
  }

  void navigateToProductsScreen(String? id, String? name) async {
    if (id == null || name == null) {
      print("Error: Category ID or Name is null");
      return;
    }

    // Fetch all products from API
    var response = await CategoryApiService.get('/product/all');

    if (response is Map<String, dynamic> && response.containsKey('data')) {
      List<dynamic> allProducts = response['data'];

      // Filter products that belong to the selected element
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
        arguments: filtered,
      );
    }
  }

  Future<void> fetchElements() async {
    var response = await CategoryApiService.get('/category/all');
    if (!mounted) return;

    if (response is Map<String, dynamic> && response.containsKey('data')) {
      List<dynamic> elementList = response['data'];
      if (elementList.isNotEmpty) {
        elements.value = elementList
            .map((element) => {
                  'id': element['_id'].toString(),
                  'name': element['name'].toString(),
                })
            .toList();
      }
    }
    isLoading.value = false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.grey.shade100, // Top grey shade
                Color(0xFFFFF6E5), // Beige shade
              ],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Search Bar
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: GestureDetector(
                    onTap: () {
                      Get.to(() => SearchScreen());
                    },
                    child: Container(
                      height: 50,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(30),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 5,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          SizedBox(width: 15),
                          Icon(Icons.search, color: Colors.grey),
                          SizedBox(width: 10),
                          Text(
                            "Search any Product...",
                            style: TextStyle(color: Colors.grey),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 20),

                // Carousel Section
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: SizedBox(
                    height: 200,
                    child: PageView.builder(
                      controller: _pageController,
                      itemCount: 2,
                      itemBuilder: (context, index) {
                        return _buildCarouselItem(
                          imageUrl: index == 0
                              ? 'https://www.acubemart.in/_next/static/media/hero-image-1.a2f50314.jpeg'
                              : 'https://www.acubemart.in/_next/static/media/hero-image-1.a2f50314.jpeg',
                          title: index == 0
                              ? '100% Genuine'
                              : 'Super Sale 35% OFF',
                          subtitle: index == 0
                              ? 'SMK introducing the new helmet for everyone’s comfort'
                              : 'Limited time offer on all products!',
                        );
                      },
                    ),
                  ),
                ),

                SizedBox(height: 20),

                // Categories Section
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'CATEGORIES',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          Get.to(() => ViewAllScreen());
                        },
                        child: Text(
                          'VIEW ALL',
                          style: TextStyle(color: Colors.red),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  height: 50,
                  child: Obx(() {
                    if (isLoading.value) {
                      return const Center(
                        child: CircularProgressIndicator(),
                      );
                    }
                    if (elements.isEmpty) {
                      return Center(child: const Text("No Categories Found"));
                    }

                    return ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: elements.length > 6
                          ? 7
                          : elements.length, // Show up to 6 + 'View All'
                      itemBuilder: (context, index) {
                        if (index == 6) {
                          // Show 'View All' button
                          return GestureDetector(
                            onTap: () {
                              Get.to(() => ViewAllScreen());
                            },
                            child: Container(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 8),
                              margin: EdgeInsets.only(left: 8),
                              decoration: BoxDecoration(
                                color: Colors.red, // Customize color
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Center(
                                child: Text(
                                  "View All",
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold),
                                ),
                              ),
                            ),
                          );
                        }

                        final category = elements[index];

                        return CategoryCard(
                          icon: Icons.category,
                          label: category['name'] ?? 'Unknown',
                          onTap: () {
                            String? id = category['id'];
                            String? name = category['name'];

                            Get.to(() => ViewAllScreen(), arguments: {
                              'selectedCategoryId': id,
                              'selectedCategoryName': name,
                            });

                            print(
                                "Navigating to ViewAllScreen with Category: ${category['name']}");
                          },
                        );
                      },
                    );
                  }),
                ),

                SizedBox(height: 20),

                // Super Sale Section
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Text(
                    "DON'T MISS OUT SUPER SALE 35% OFF",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.red,
                    ),
                  ),
                ),

                SizedBox(height: 20),

                // Product Grid Section
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Obx(() {
                    if (homeController.isLoading.value) {
                      return Center(child: CircularProgressIndicator());
                    } else if (homeController.productList.isEmpty) {
                      return Center(child: Text('No products found'));
                    } else {
                      return SizedBox(
                        height: 410,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: filteredProducts.length,
                          itemBuilder: (context, index) {
                            final product = filteredProducts[index];
                            return Padding(
                              padding: const EdgeInsets.only(right: 22.0),
                              child: GestureDetector(
                                onTap: () {
                                  Get.to(() => ProductDetails(
                                        productId: product.id,
                                        productName: product.name,
                                        productImages: product.images,
                                        productPrice: product.price.toString(),
                                        productBrand: product.brand,
                                        productRating: product.rating,
                                        ratingCount: product.ratingCount,
                                        productSp: product.sp.toString(),
                                      ));
                                },
                                child: _buildProductCard(product),
                              ),
                            );
                          },
                        ),
                      );
                    }
                  }),
                ),

                SizedBox(height: 20),
                // Join Our ACUBE Plus Section
                Container(
                  padding: EdgeInsets.all(16),
                  margin: EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.3),
                        blurRadius: 6,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Stack(
                    children: [
                      Positioned.fill(
                        child: Opacity(
                          opacity: 0.1, // Adjust opacity to make it light
                          child: Center(
                            child: Icon(
                              Icons.settings,
                              size: 150,
                              color: Colors.grey,
                            ),
                          ),
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Join Our ACUBE Plus & ',
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                          RichText(
                            text: const TextSpan(
                              text: 'GET 15% OFF*',
                              style: TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                                color: Color.fromRGBO(185, 28, 28, 1.0),
                              ),
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            'Sign up for free! Join the community.',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              color: Colors.black,
                            ),
                          ),
                          SizedBox(height: 12),
                          TextField(
                            controller: _emailController,
                            decoration: InputDecoration(
                              hintText: 'Enter your email address',
                              prefixIcon: Icon(Icons.email),
                              filled: true,
                              fillColor: Colors.white,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide:
                                    BorderSide(color: Colors.black, width: 1),
                              ),
                            ),
                          ),
                          SizedBox(height: 12),
                          Center(
                            child: SizedBox(
                              width: 350,
                              child: ElevatedButton(
                                onPressed: () {},
                                style: ElevatedButton.styleFrom(
                                  backgroundColor:
                                      Color.fromRGBO(185, 28, 28, 1.0),
                                  padding: EdgeInsets.symmetric(
                                      vertical: 18, horizontal: 20),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                child: Text(
                                  'SUBMIT',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 18,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  height: 20,
                ),
                CategoryListSection(),
                SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: Obx(() => Container(
            color: Colors.white,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
              child: GNav(
                haptic: true,
                backgroundColor: Colors.white,
                activeColor: Color.fromRGBO(185, 28, 28, 1.0),
                tabBackgroundColor: Colors.grey.shade100,
                padding: EdgeInsets.all(20),
                gap: 8,
                selectedIndex: selectIndex.value, // Bind selected index
                onTabChange: (index) {
                  selectIndex.value = index; // Update selected tab
                  print("Tab Changed: $index");

                  if (index == 1) {
                    Get.to(() => WishlistScreen())!.then((_) {
                      selectIndex.value = 0; // Set back to Home when returning
                    });
                  } else if (index == 2) {
                    Get.to(() => CartPage())!.then((_) {
                      selectIndex.value = 0;
                    });
                  } else if (index == 3) {
                    Get.to(() => SearchScreen())!.then((_) {
                      selectIndex.value = 0;
                    });
                  }
                },
                tabs: [
                  GButton(
                    icon: Icons.home,
                    text: 'Home',
                  ),
                  GButton(
                    icon: Icons.favorite,
                    text: 'Wishlist',
                  ),
                  GButton(
                    icon: Icons.shopping_cart,
                    text: 'Cart',
                  ),
                  GButton(
                    icon: Icons.search,
                    text: 'Search',
                  ),
                ],
              ),
            ),
          )),
    );
  }

  Widget _buildCarouselItem({
    required String imageUrl,
    required String title,
    required String subtitle,
  }) {
    return Padding(
      padding: const EdgeInsets.only(right: 8.0),
      child: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              image: DecorationImage(
                image: NetworkImage(imageUrl),
                fit: BoxFit.cover,
              ),
            ),
          ),
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              gradient: LinearGradient(
                colors: [
                  Colors.black.withOpacity(0.6),
                  Colors.transparent,
                ],
                begin: Alignment.bottomCenter,
                end: Alignment.topCenter,
              ),
            ),
          ),
          Positioned(
            bottom: 16,
            left: 16,
            right: 16,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: Colors.orange,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  subtitle,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductCard(Product product) {
    final CartController cartController = Get.find<CartController>();
    final wishlistController = Get.find<WishlistController>();

    // Wishlist controller or list
    final wishlist = <CartItem>[].obs;

    return Container(
      width: 300,
      height: 320,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            blurRadius: 10,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              Container(
                height: 210,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                  image: DecorationImage(
                    image: NetworkImage(product.images.isNotEmpty
                        ? product.images.first
                        : 'https://via.placeholder.com/150'),
                    fit: BoxFit.fill,
                  ),
                ),
              ),
              Positioned(
                top: 10,
                right: 10,
                child: Obx(() {
                  final isInWishlist = wishlistController.wishlist
                      .any((item) => item.name == product.name);
                  return IconButton(
                    icon: Icon(
                      isInWishlist ? Icons.favorite : Icons.favorite_border,
                      color: isInWishlist ? Colors.red : Colors.grey,
                    ),
                    onPressed: () {
                      if (isInWishlist) {
                        wishlistController.removeFromWishlist(product.name);
                        Get.snackbar('Removed from Wishlist', product.name);
                      } else {
                        // Add to wishlist
                        wishlistController.addToWishlist(
                          CartItem(
                            productId: product.id,
                            name: product.name,
                            price: product.sp,
                            quantity: 1,
                            images: product.images.isNotEmpty
                                ? product.images
                                : ['https://via.placeholder.com/150'],
                            brand: product.brand,
                          ),
                        );
                        Get.snackbar('Added to Wishlist', product.name);
                      }
                    },
                  );
                }),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product.name,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 4),
                StarRating(
                  rating: product.rating,
                  ratingCount: product.ratingCount,
                ),
                Text(
                  product.brand,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey,
                  ),
                ),
                SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '\₹${product.price.toStringAsFixed(2)}',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: Colors.black,
                            decoration: TextDecoration.lineThrough,
                          ),
                        ),
                        SizedBox(height: 2),
                        // Selling Price and Discount %
                        Row(
                          children: [
                            Text(
                              '₹${product.sp.toStringAsFixed(2)}',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                            ),
                            SizedBox(width: 8),
                            // Discount Percentage
                            Container(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: Colors.red,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                '${_calculateDiscount(product.price, product.sp)}% OFF',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    IconButton(
                      icon: Obx(() {
                        int quantity = cartController.cartItems
                                .firstWhereOrNull(
                                    (item) => item.productId == product.id)
                                ?.quantity ??
                            0;

                        return quantity > 0
                            ? Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  IconButton(
                                    icon: Icon(Icons.remove_circle,
                                        size: 24, color: Colors.red),
                                    onPressed: () {
                                      if (quantity > 1) {
                                        cartController.updateQuantity(
                                            product.id, quantity - 1);
                                      } else {
                                        cartController.removeItem(product.id);
                                      }
                                    },
                                  ),
                                  Text(
                                    quantity.toString(),
                                    style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  IconButton(
                                    icon: Icon(Icons.add_circle,
                                        size: 24, color: Colors.green),
                                    onPressed: () {
                                      cartController.updateQuantity(
                                          product.id, quantity + 1);
                                    },
                                  ),
                                ],
                              )
                            : Center(
                                child: IconButton(
                                  icon: cartController.isLoading.value
                                      ? CircularProgressIndicator()
                                      : Icon(Icons.add_circle,
                                          size: 34,
                                          color:
                                              Color.fromRGBO(251, 137, 4, 1)),
                                  onPressed: () {
                                    cartController.addItem(product.id);
                                  },
                                ),
                              );
                      }),
                      onPressed: () {
                        cartController.addItem(product.id);
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  int _calculateDiscount(double mrp, double sp) {
    if (mrp <= sp) return 0; // No discount if selling price >= MRP
    return ((1 - (sp / mrp)) * 100).round();
  }
}
