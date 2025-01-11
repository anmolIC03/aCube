import 'package:acu/screens/all_categories.dart';
import 'package:acu/screens/cart_page.dart';
import 'package:acu/screens/components/cart_components/cart_controller.dart';
import 'package:acu/screens/components/cart_components/cart_item.dart';
import 'package:acu/screens/components/cart_components/product_components/prodList.dart';
import 'package:acu/screens/components/category_card.dart';
import 'package:acu/screens/components/category_list.dart';
import 'package:acu/screens/components/products/rating_list.dart';
import 'package:acu/screens/components/wishlist_controller.dart';
import 'package:acu/screens/prod_details.dart';
import 'package:acu/screens/wishlist.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_nav_bar/google_nav_bar.dart';

class HomeScreen extends StatefulWidget {
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final PageController _pageController = PageController(viewportFraction: 0.8);
  final TextEditingController _emailController = TextEditingController();
  int selectedIndex = 0;

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
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: 'Search any Product...',
                      prefixIcon: Icon(Icons.search),
                      suffixIcon: Icon(Icons.filter_list),
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                        borderSide: BorderSide.none,
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
                          Get.to(() => ViewAllCategoriesScreen());
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
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    children: [
                      CategoryCard(
                        icon: Icons.pedal_bike,
                        label: 'Bikes',
                        onTap: () {},
                      ),
                      CategoryCard(
                        icon: Icons.car_rental,
                        label: 'Cars',
                        onTap: () {},
                      ),
                      CategoryCard(
                        icon: Icons.chair,
                        label: 'Riding Gears',
                        onTap: () {},
                      ),
                      CategoryCard(
                        icon: Icons.electrical_services,
                        label: 'Goggles',
                        onTap: () {},
                      ),
                      CategoryCard(
                        icon: Icons.kitchen,
                        label: 'Accessories',
                        onTap: () {},
                      ),
                    ],
                  ),
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
                  child: SizedBox(
                    height: 390,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: productList.length,
                      itemBuilder: (context, index) {
                        final product = productList[index];
                        return Padding(
                          padding: const EdgeInsets.only(right: 22.0),
                          child: GestureDetector(
                            onTap: () {
                              Get.to(() => ProductDetails(
                                    productName:
                                        product['name'] ?? 'Unknown Product',
                                    productImage: product['image'] ?? '',
                                    productPrice: product['price'] ?? "",
                                    productBrand:
                                        product['brand'] ?? 'Unknown Brand',
                                    productRating: double.tryParse(
                                            product['rating'] ?? '0') ??
                                        0.0,
                                    ratingCount: int.tryParse(
                                            product['ratingCount'] ?? '0') ??
                                        0,
                                  ));
                            },
                            child: _buildProductCard(
                                productName:
                                    product['name'] ?? 'Unknown Product',
                                productImage: product['image'] ?? '',
                                productPrice: product['price'] ?? "",
                                productBrand:
                                    product['brand'] ?? 'Unknown Brand',
                                productRating: product['rating'] ?? '',
                                ratingCount: int.tryParse(
                                        product['ratingCount'] ?? '0') ??
                                    0),
                          ),
                        );
                      },
                    ),
                  ),
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
                              text: 'GET 15% OFF*', // Custom text
                              style: TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                                color: Color.fromRGBO(
                                    185, 28, 28, 1.0), // Your custom color
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
      bottomNavigationBar: Container(
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
            onTabChange: (index) {
              print(index);
            },
            tabs: [
              GButton(
                icon: Icons.home,
                text: 'Home',
              ),
              GButton(
                icon: Icons.favorite,
                text: 'Wishlist',
                onPressed: () {
                  Get.to(() => WishlistScreen());
                },
              ),
              GButton(
                icon: Icons.shopping_cart,
                text: 'Cart',
                onPressed: () {
                  Get.to(() => CartPage());
                },
              ),
              GButton(
                icon: Icons.search,
                text: 'Search',
              ),
            ],
          ),
        ),
      ),
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

  Widget _buildProductCard({
    required String productName,
    required String productImage,
    required String productPrice,
    required String productBrand,
    required String productRating,
    required int ratingCount,
  }) {
    final CartController cartController = Get.find<CartController>();
    final wishlistController = Get.find<WishlistController>();

    // Wishlist controller or list
    final wishlist = <CartItem>[].obs;

    return Container(
      width: 240,
      height: 310,
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
                    image: NetworkImage(productImage),
                    fit: BoxFit.fill,
                  ),
                ),
              ),
              Positioned(
                top: 10,
                right: 10,
                child: Obx(() {
                  final isInWishlist = wishlistController.wishlist
                      .any((item) => item.name == productName);
                  return IconButton(
                    icon: Icon(
                      isInWishlist ? Icons.favorite : Icons.favorite_border,
                      color: isInWishlist ? Colors.red : Colors.grey,
                    ),
                    onPressed: () {
                      if (isInWishlist) {
                        wishlistController.removeFromWishlist(productName);
                        Get.snackbar('Removed from Wishlist', productName);
                      } else {
                        // Add to wishlist
                        wishlistController.addToWishlist(
                          CartItem(
                            name: productName,
                            price: double.parse(productPrice),
                            quantity: 1,
                            image: productImage,
                            brand: productBrand,
                            rating: double.parse(productRating),
                          ),
                        );
                        Get.snackbar('Added to Wishlist', productName);
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
                  productName,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 4),
                StarRating(
                  rating: double.parse(productRating),
                  ratingCount: ratingCount,
                ),
                Text(
                  productBrand,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey,
                  ),
                ),
                SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '\$${productPrice.toString()}',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: Colors.black,
                      ),
                    ),
                    IconButton(
                      icon: Icon(
                        Icons.add_circle,
                        size: 34,
                        color: Color.fromRGBO(251, 137, 4, 1),
                      ),
                      onPressed: () {
                        CartItem cartItem = CartItem(
                          name: productName,
                          price: double.parse(productPrice),
                          quantity: 1,
                          image: productImage,
                          brand: productBrand,
                          rating: double.parse(productRating),
                        );
                        cartController.addItem(cartItem);
                        Get.snackbar('Added to Cart', productName);
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
}
