import 'package:cloture/gen/assets.gen.dart';
import 'package:cloture/view/screens/home/categories_men.dart';
import 'package:cloture/view/screens/home/new_in.dart';
import 'package:cloture/view/screens/home/top_selling.dart';
import 'package:cloture/view/screens/product/product_details_screen.dart';
import 'package:cloture/services/firestore_service.dart';
import 'package:cloture/view/widgets/shimmer_widget.dart';
import 'package:cloture/view/constants/colors.dart';
import 'package:cloture/view/constants/text.dart';
import 'package:cloture/view/constants/theme_colors.dart';
import 'package:cloture/controller/theme_controller.dart';
import 'package:cloture/controller/cart_controller.dart';
import 'package:cloture/controller/favorites_controller.dart';
import 'package:cloture/view/widgets/toast_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:liquid_pull_to_refresh/liquid_pull_to_refresh.dart';
import 'package:provider/provider.dart';

// Custom scroll physics that only bounces at the bottom
class BottomBouncingScrollPhysics extends BouncingScrollPhysics {
  const BottomBouncingScrollPhysics({super.parent});

  @override
  BottomBouncingScrollPhysics applyTo(ScrollPhysics? ancestor) {
    return BottomBouncingScrollPhysics(parent: buildParent(ancestor));
  }

  @override
  double applyBoundaryConditions(ScrollMetrics position, double value) {
    // Clamp at the top (no bounce when overscrolling up)
    if (value < position.pixels &&
        position.pixels <= position.minScrollExtent) {
      return value - position.pixels;
    }
    // Allow bounce at the bottom (no clamping when overscrolling down)
    return super.applyBoundaryConditions(position, value);
  }
}

class HomePage extends StatefulWidget {
  final VoidCallback? onNavigateToCart;

  const HomePage({super.key, this.onNavigateToCart});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final FirestoreService _firestoreService = FirestoreService();
  final ScrollController _scrollController = ScrollController();

  List<Map<String, String>> categories = [];
  List<Map<String, String>> topSellingProducts = [];
  List<Map<String, String>> newInProducts = [];

  @override
  void initState() {
    super.initState();
    fetchCategories();
    fetchTopSellingProducts();
    fetchNewInProducts();
  }

  Future<void> fetchCategories() async {
    List<Map<String, String>> fetchedCategories = await _firestoreService
        .fetchCategories();
    if (mounted) {
      setState(() {
        categories = fetchedCategories;
      });
    }
  }

  Future<void> fetchTopSellingProducts() async {
    List<Map<String, String>> fetchedTopSellingProducts =
        await _firestoreService.fetchTopSellingProducts();
    if (mounted) {
      setState(() {
        topSellingProducts = fetchedTopSellingProducts;
      });
    }
  }

  Future<void> fetchNewInProducts() async {
    List<Map<String, String>> fetchedNewInProducts = await _firestoreService
        .fetchNewInProducts();
    if (mounted) {
      setState(() {
        newInProducts = fetchedNewInProducts;
      });
    }
  }

  Future<void> _handleRefresh() async {
    // Clear existing data to show shimmer effect
    setState(() {
      categories = [];
      topSellingProducts = [];
      newInProducts = [];
    });

    // Refresh all data simultaneously
    await Future.wait([
      fetchCategories(),
      fetchTopSellingProducts(),
      fetchNewInProducts(),
    ]);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer3<ThemeController, CartController, FavoritesController>(
      builder: (context, themeController, cartController, favoritesController, child) {
        final themeColors = AppThemeColors(themeController.isDarkMode);
        final cartItemCount = cartController.totalItems;
        return Scaffold(
          appBar: AppBar(
            automaticallyImplyLeading: false,
            backgroundColor: themeColors.backgroundColor,
            elevation: 0.0,
            title: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Assets.images.profilePic.image(height: 42, width: 42),
                Center(
                  child: Assets.images.clotoureLogo.image(
                    height: 120.spMin,
                    width: 200.spMin,
                    color: primary200,
                  ),
                ),
                //cart button
                GestureDetector(
                  onTap: () {
                    if (widget.onNavigateToCart != null) {
                      widget.onNavigateToCart!();
                    }
                  },
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Container(
                        height: 40.spMin,
                        width: 40.spMin,
                        padding: EdgeInsets.all(12.spMin),
                        decoration: BoxDecoration(
                          color: primary200,
                          borderRadius: BorderRadius.circular(100.spMin),
                        ),
                        child: Assets.images.shoppingBag.image(
                          height: 16.spMin,
                        ),
                      ),
                      if (cartItemCount > 0)
                        Positioned(
                          right: -2,
                          top: -2,
                          child: Container(
                            padding: EdgeInsets.all(4.spMin),
                            decoration: BoxDecoration(
                              color: Colors.red,
                              shape: BoxShape.circle,
                            ),
                            constraints: BoxConstraints(
                              minWidth: 18.spMin,
                              minHeight: 18.spMin,
                            ),
                            child: Center(
                              child: Text(
                                cartItemCount > 99
                                    ? '99+'
                                    : cartItemCount.toString(),
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 10.spMin,
                                  fontWeight: FontWeight.bold,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          backgroundColor: themeColors.backgroundColor,
          body: LiquidPullToRefresh(
            onRefresh: _handleRefresh,
            color: primary200,
            backgroundColor: themeColors.backgroundColor,
            height: 80.spMin,
            animSpeedFactor: 2.0,
            showChildOpacityTransition: false,
            springAnimationDurationInMilliseconds: 300,
            child: SingleChildScrollView(
              controller: _scrollController,
              physics: const BottomBouncingScrollPhysics(),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight:
                      MediaQuery.of(context).size.height -
                      AppBar().preferredSize.height -
                      MediaQuery.of(context).padding.top,
                ),
                child: Column(
                  children: [
                    SizedBox(height: 24.spMin),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 24.spMin),
                      child: TextField(
                        cursorColor: primary200,
                        decoration: InputDecoration(
                          hintText: 'Search',
                          hintStyle: TextStyle(
                            fontSize: 14.spMin,
                            color: themeColors.secondaryTextColor,
                          ),
                          prefixIcon: Assets.images.searchnormal1.image(
                            height: 16.spMin,
                            width: 16.spMin,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(100.spMin),
                            borderSide: BorderSide.none,
                          ),
                          filled: true,
                          fillColor: themeColors.cardColor,
                        ),
                      ),
                    ),
                    SizedBox(height: 24.spMin),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 24.spMin),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          reusableText(
                            'Categories',
                            16.spMin,
                            FontWeight.bold,
                            themeColors.primaryTextColor,
                            -0.41,
                            TextAlign.left,
                          ),
                          GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (BuildContext context) =>
                                      const CategoriesMen(),
                                ),
                              );
                            },
                            child: reusableText(
                              'See All',
                              16.spMin,
                              FontWeight.w500,
                              themeColors.primaryTextColor,
                              -0.41,
                              TextAlign.left,
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 16.spMin),

                    // Categories List with shimmer effect
                    SizedBox(
                      height: 120.spMin,
                      child: categories.isEmpty
                          ? categoriesShimmerEffect(themeColors: themeColors)
                          : ListView.builder(
                              scrollDirection: Axis.horizontal,
                              itemCount: categories.length,
                              itemBuilder: (context, index) {
                                String categoryName =
                                    categories[index]['name']!;
                                String imageUrl =
                                    categories[index]['imageUrl']!;

                                return Padding(
                                  padding: EdgeInsets.only(
                                    left: index == 0 ? 19.spMin : 8.spMin,
                                    right: 8.spMin,
                                  ),
                                  child: Column(
                                    children: [
                                      CircleAvatar(
                                        backgroundColor: themeColors.cardColor,
                                        radius: 40.spMin,
                                        backgroundImage: NetworkImage(imageUrl),
                                        onBackgroundImageError:
                                            (exception, stackTrace) {
                                              // Handle error silently
                                            },
                                        child: imageUrl.isEmpty
                                            ? Icon(
                                                Icons.image,
                                                color: Colors.grey[400],
                                              )
                                            : null,
                                      ),
                                      SizedBox(height: 8.spMin),
                                      reusableText(
                                        categoryName,
                                        12.spMin,
                                        FontWeight.w500,
                                        themeColors.primaryTextColor,
                                        -0.41,
                                        TextAlign.center,
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                    ),
                    SizedBox(height: 24.spMin),

                    // Top Selling Section
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 24.spMin),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          reusableText(
                            'Top Selling',
                            16.spMin,
                            FontWeight.bold,
                            themeColors.primaryTextColor,
                            -0.41,
                            TextAlign.left,
                          ),
                          GestureDetector(
                            onTap: () {
                              // Navigate to the Top Selling Products page
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (BuildContext context) {
                                    return const TopSelling();
                                  },
                                ),
                              );
                            },
                            child: reusableText(
                              'View All',
                              16.spMin,
                              FontWeight.w500,
                              themeColors.primaryTextColor,
                              -0.41,
                              TextAlign.left,
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 16.spMin),

                    // Top Selling Products List with shimmer effect
                    SizedBox(
                      height: 300.spMin,
                      child: topSellingProducts.isEmpty
                          ? buildProductShimmerEffect(themeColors: themeColors)
                          : ListView.builder(
                              scrollDirection: Axis.horizontal,
                              itemCount: topSellingProducts.length > 3
                                  ? 3
                                  : topSellingProducts.length,
                              itemBuilder: (context, index) {
                                final product = topSellingProducts[index];
                                final String productId = product['id'] ?? '';
                                final String productName = product['name']!;
                                final String productPrice = product['price']!;
                                final String productImage =
                                    product['imageUrl']!;
                                final String heroTag =
                                    'home_topselling_${productName}_${productImage}';

                                // Check if product is in favorites
                                final isFavorite = productId.isNotEmpty
                                    ? favoritesController.favoriteItems.any(
                                        (item) => item.productId == productId,
                                      )
                                    : false;

                                return GestureDetector(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            ProductDetailsScreen(
                                              product: product,
                                              heroTag: heroTag,
                                            ),
                                      ),
                                    );
                                  },
                                  child: Padding(
                                    padding: EdgeInsets.only(
                                      left: index == 0 ? 19.spMin : 8.spMin,
                                      right: 8.spMin,
                                    ),
                                    child: Stack(
                                      children: [
                                        // Background Container with Product Info
                                        Container(
                                          height: 320.spMin,
                                          width: 220.spMin,
                                          decoration: BoxDecoration(
                                            color: themeColors.cardColor,
                                            borderRadius: BorderRadius.circular(
                                              8.spMin,
                                            ),
                                          ),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              // Product Image
                                              Container(
                                                height: 220.spMin,
                                                decoration: BoxDecoration(
                                                  borderRadius:
                                                      BorderRadius.only(
                                                        topLeft:
                                                            Radius.circular(
                                                              8.spMin,
                                                            ),
                                                        topRight:
                                                            Radius.circular(
                                                              8.spMin,
                                                            ),
                                                      ),
                                                  color: themeColors.cardColor,
                                                ),
                                                child: ClipRRect(
                                                  borderRadius:
                                                      BorderRadius.only(
                                                        topLeft:
                                                            Radius.circular(
                                                              8.spMin,
                                                            ),
                                                        topRight:
                                                            Radius.circular(
                                                              8.spMin,
                                                            ),
                                                      ),
                                                  child: Hero(
                                                    tag: heroTag,
                                                    child: Image.network(
                                                      productImage,
                                                      width: double.infinity,
                                                      height: 220.spMin,
                                                      fit: BoxFit.cover,
                                                      errorBuilder:
                                                          (
                                                            context,
                                                            error,
                                                            stackTrace,
                                                          ) {
                                                            return Container(
                                                              width: double
                                                                  .infinity,
                                                              height: 220.spMin,
                                                              color: themeColors
                                                                  .cardColor,
                                                              child: Icon(
                                                                Icons
                                                                    .image_not_supported,
                                                                color: Colors
                                                                    .grey[400],
                                                                size: 40.spMin,
                                                              ),
                                                            );
                                                          },
                                                      loadingBuilder:
                                                          (
                                                            context,
                                                            child,
                                                            loadingProgress,
                                                          ) {
                                                            if (loadingProgress ==
                                                                null) {
                                                              return child;
                                                            }
                                                            return Container(
                                                              width: double
                                                                  .infinity,
                                                              height: 220.spMin,
                                                              color: themeColors
                                                                  .cardColor,
                                                              child: Center(
                                                                child: CircularProgressIndicator(
                                                                  value:
                                                                      loadingProgress
                                                                              .expectedTotalBytes !=
                                                                          null
                                                                      ? loadingProgress.cumulativeBytesLoaded /
                                                                            loadingProgress.expectedTotalBytes!
                                                                      : null,
                                                                  strokeWidth:
                                                                      2,
                                                                  valueColor:
                                                                      AlwaysStoppedAnimation<
                                                                        Color
                                                                      >(
                                                                        primary200,
                                                                      ),
                                                                ),
                                                              ),
                                                            );
                                                          },
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              SizedBox(height: 8.spMin),
                                              Padding(
                                                padding: EdgeInsets.symmetric(
                                                  horizontal: 8.spMin,
                                                ),
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    reusableText(
                                                      productName,
                                                      14.spMin,
                                                      FontWeight.w500,
                                                      themeColors
                                                          .primaryTextColor,
                                                      0,
                                                      TextAlign.start,
                                                    ),
                                                    SizedBox(height: 8.spMin),
                                                    reusableText(
                                                      '\$ $productPrice',
                                                      14.spMin,
                                                      FontWeight.w900,
                                                      themeColors
                                                          .primaryTextColor,
                                                      0,
                                                      TextAlign.start,
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        // Love Icon Positioned at the top-right corner
                                        Positioned(
                                          top: 9.spMin,
                                          right: 12.spMin,
                                          child: GestureDetector(
                                            onTap: () async {
                                              if (productId.isEmpty) {
                                                toastError(
                                                  msg: 'Product ID is missing.',
                                                );
                                                return;
                                              }

                                              final productPriceDouble =
                                                  double.tryParse(
                                                    productPrice
                                                        .replaceAll('\$', '')
                                                        .trim(),
                                                  ) ??
                                                  0.0;

                                              await favoritesController
                                                  .toggleFavorite(
                                                    productId: productId,
                                                    name: productName,
                                                    imageUrl: productImage,
                                                    price: productPriceDouble,
                                                  );

                                              final newIsFavorite =
                                                  await favoritesController
                                                      .isProductFavorite(
                                                        productId,
                                                      );

                                              if (newIsFavorite) {
                                                toastInfo(
                                                  msg: 'Added to favorites!',
                                                );
                                              } else {
                                                toastInfo(
                                                  msg: 'Removed from favorites',
                                                );
                                              }
                                            },
                                            child: Icon(
                                              isFavorite
                                                  ? Icons.favorite
                                                  : Icons.favorite_border,
                                              color: isFavorite
                                                  ? primary200
                                                  : Colors.grey[600],
                                              size: 24.spMin,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                    ),
                    SizedBox(height: 24.spMin),

                    // New In Section
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 24.spMin),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          reusableText(
                            'New In',
                            16.spMin,
                            FontWeight.bold,
                            primary200,
                            -0.41,
                            TextAlign.left,
                          ),
                          GestureDetector(
                            onTap: () {
                              // Navigate to the New In Products page
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (BuildContext context) {
                                    return const NewIn();
                                  },
                                ),
                              );
                            },
                            child: reusableText(
                              'View All',
                              16.spMin,
                              FontWeight.w500,
                              themeColors.primaryTextColor,
                              -0.41,
                              TextAlign.left,
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 16.spMin),

                    // New In Products List with shimmer effect
                    SizedBox(
                      height: 300.spMin,
                      child: newInProducts.isEmpty
                          ? buildProductShimmerEffect(themeColors: themeColors)
                          : ListView.builder(
                              scrollDirection: Axis.horizontal,
                              itemCount: newInProducts.length > 3
                                  ? 3
                                  : newInProducts.length,
                              itemBuilder: (context, index) {
                                final product = newInProducts[index];
                                final String productId = product['id'] ?? '';
                                final String productName = product['name']!;
                                final String productPrice = product['price']!;
                                final String productImage =
                                    product['imageUrl']!;
                                final String heroTag =
                                    'home_newin_${productName}_${productImage}';

                                // Check if product is in favorites
                                final isFavorite = productId.isNotEmpty
                                    ? favoritesController.favoriteItems.any(
                                        (item) => item.productId == productId,
                                      )
                                    : false;

                                return GestureDetector(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            ProductDetailsScreen(
                                              product: product,
                                              heroTag: heroTag,
                                            ),
                                      ),
                                    );
                                  },
                                  child: Padding(
                                    padding: EdgeInsets.only(
                                      left: index == 0 ? 19.spMin : 8.spMin,
                                      right: 8.spMin,
                                    ),
                                    child: Stack(
                                      children: [
                                        // Background Container with Product Info
                                        Container(
                                          height: 320.spMin,
                                          width: 220.spMin,
                                          decoration: BoxDecoration(
                                            color: themeColors.cardColor,
                                            borderRadius: BorderRadius.circular(
                                              8.spMin,
                                            ),
                                          ),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              // Product Image
                                              Container(
                                                height: 220.spMin,
                                                decoration: BoxDecoration(
                                                  borderRadius:
                                                      BorderRadius.only(
                                                        topLeft:
                                                            Radius.circular(
                                                              8.spMin,
                                                            ),
                                                        topRight:
                                                            Radius.circular(
                                                              8.spMin,
                                                            ),
                                                      ),
                                                  color: themeColors.cardColor,
                                                ),
                                                child: ClipRRect(
                                                  borderRadius:
                                                      BorderRadius.only(
                                                        topLeft:
                                                            Radius.circular(
                                                              8.spMin,
                                                            ),
                                                        topRight:
                                                            Radius.circular(
                                                              8.spMin,
                                                            ),
                                                      ),
                                                  child: Hero(
                                                    tag: heroTag,
                                                    child: Image.network(
                                                      productImage,
                                                      width: double.infinity,
                                                      height: 220.spMin,
                                                      fit: BoxFit.cover,
                                                      errorBuilder:
                                                          (
                                                            context,
                                                            error,
                                                            stackTrace,
                                                          ) {
                                                            return Container(
                                                              width: double
                                                                  .infinity,
                                                              height: 220.spMin,
                                                              color: themeColors
                                                                  .cardColor,
                                                              child: Icon(
                                                                Icons
                                                                    .image_not_supported,
                                                                color: Colors
                                                                    .grey[400],
                                                                size: 40.spMin,
                                                              ),
                                                            );
                                                          },
                                                      loadingBuilder:
                                                          (
                                                            context,
                                                            child,
                                                            loadingProgress,
                                                          ) {
                                                            if (loadingProgress ==
                                                                null) {
                                                              return child;
                                                            }
                                                            return Container(
                                                              width: double
                                                                  .infinity,
                                                              height: 220.spMin,
                                                              color: themeColors
                                                                  .cardColor,
                                                              child: Center(
                                                                child: CircularProgressIndicator(
                                                                  value:
                                                                      loadingProgress
                                                                              .expectedTotalBytes !=
                                                                          null
                                                                      ? loadingProgress.cumulativeBytesLoaded /
                                                                            loadingProgress.expectedTotalBytes!
                                                                      : null,
                                                                  strokeWidth:
                                                                      2,
                                                                  valueColor:
                                                                      AlwaysStoppedAnimation<
                                                                        Color
                                                                      >(
                                                                        primary200,
                                                                      ),
                                                                ),
                                                              ),
                                                            );
                                                          },
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              SizedBox(height: 8.spMin),
                                              Padding(
                                                padding: EdgeInsets.symmetric(
                                                  horizontal: 8.spMin,
                                                ),
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    reusableText(
                                                      productName,
                                                      14.spMin,
                                                      FontWeight.w500,
                                                      themeColors
                                                          .primaryTextColor,
                                                      0,
                                                      TextAlign.start,
                                                    ),
                                                    SizedBox(height: 8.spMin),
                                                    reusableText(
                                                      '\$ $productPrice',
                                                      14.spMin,
                                                      FontWeight.w900,
                                                      themeColors
                                                          .primaryTextColor,
                                                      0,
                                                      TextAlign.start,
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        // Love Icon Positioned at the top-right corner
                                        Positioned(
                                          top: 9.spMin,
                                          right: 12.spMin,
                                          child: GestureDetector(
                                            onTap: () async {
                                              if (productId.isEmpty) {
                                                toastError(
                                                  msg: 'Product ID is missing.',
                                                );
                                                return;
                                              }

                                              final productPriceDouble =
                                                  double.tryParse(
                                                    productPrice
                                                        .replaceAll('\$', '')
                                                        .trim(),
                                                  ) ??
                                                  0.0;

                                              await favoritesController
                                                  .toggleFavorite(
                                                    productId: productId,
                                                    name: productName,
                                                    imageUrl: productImage,
                                                    price: productPriceDouble,
                                                  );

                                              final newIsFavorite =
                                                  await favoritesController
                                                      .isProductFavorite(
                                                        productId,
                                                      );

                                              if (newIsFavorite) {
                                                toastInfo(
                                                  msg: 'Added to favorites!',
                                                );
                                              } else {
                                                toastInfo(
                                                  msg: 'Removed from favorites',
                                                );
                                              }
                                            },
                                            child: Icon(
                                              isFavorite
                                                  ? Icons.favorite
                                                  : Icons.favorite_border,
                                              color: isFavorite
                                                  ? primary200
                                                  : Colors.grey[600],
                                              size: 24.spMin,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                    ),
                    SizedBox(height: 24.spMin),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
