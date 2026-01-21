import 'package:cloture/view/screens/product/product_details_screen.dart';
import 'package:cloture/view/widgets/buttons.dart';
import 'package:cloture/view/constants/colors.dart';
import 'package:cloture/view/constants/text.dart';
import 'package:cloture/view/constants/theme_colors.dart';
import 'package:cloture/controller/theme_controller.dart';
import 'package:cloture/controller/favorites_controller.dart';
import 'package:cloture/view/widgets/toast_widget.dart';
import 'package:cloture/services/firestore_service.dart';
import 'package:cloture/view/widgets/shimmer_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:liquid_pull_to_refresh/liquid_pull_to_refresh.dart';
import 'package:provider/provider.dart';

class NewIn extends StatefulWidget {
  const NewIn({super.key});

  @override
  State<NewIn> createState() => _NewInState();
}

class _NewInState extends State<NewIn> {
  final FirestoreService _firestoreService = FirestoreService();
  final ScrollController _scrollController = ScrollController();

  List<Map<String, String>> newInProducts = [];

  @override
  void initState() {
    super.initState();
    fetchNewInProducts();
  }

  Future<void> fetchNewInProducts() async {
    List<Map<String, String>> fetchedProducts = await _firestoreService
        .fetchNewInProducts();
    if (mounted) {
      setState(() {
        newInProducts = fetchedProducts;
      });
    }
  }

  Future<void> _handleRefresh() async {
    setState(() {
      newInProducts = [];
    });
    await fetchNewInProducts();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<ThemeController, FavoritesController>(
      builder: (context, themeController, favoritesController, child) {
        final themeColors = AppThemeColors(themeController.isDarkMode);
    return Scaffold(
          backgroundColor: themeColors.backgroundColor,
          appBar: AppBar(
            automaticallyImplyLeading: false,
            backgroundColor: themeColors.backgroundColor,
            elevation: 0.0,
            title: Row(
          children: [
            backButton(() {
              Navigator.of(context).pop();
            }),
                SizedBox(width: 16.spMin),
                reusableText(
                  'New In',
                  20.spMin,
                  FontWeight.bold,
                  primary200,
                  -0.41,
                  TextAlign.left,
                ),
              ],
            ),
          ),
          body: LiquidPullToRefresh(
            onRefresh: _handleRefresh,
            color: primary200,
            backgroundColor: themeColors.backgroundColor,
        height: 80.spMin,
        animSpeedFactor: 2.0,
        showChildOpacityTransition: false,
        springAnimationDurationInMilliseconds: 300,
        child: newInProducts.isEmpty
            ? buildProductGridShimmerEffect(themeColors: themeColors)
            : GridView.builder(
                controller: _scrollController,
                physics: const AlwaysScrollableScrollPhysics(
                  parent: BouncingScrollPhysics(),
                ),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 8.spMin,
                  mainAxisSpacing: 16.spMin,
                  childAspectRatio: 0.85,
                ),
                padding: EdgeInsets.symmetric(
                  horizontal: 19.spMin,
                  vertical: 16.spMin,
                ),
                itemCount: newInProducts.length,
                itemBuilder: (context, index) {
                  final product = newInProducts[index];
                  final String productId = product['id'] ?? '';
                  final String productName = product['name']!;
                  final String productPrice = product['price']!;
                  final String productImage = product['imageUrl']!;
                  final String heroTag = 'newin_product_${productName}_${productImage}';
                  
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
                          builder: (context) => ProductDetailsScreen(
                            product: product,
                            heroTag: heroTag,
                          ),
                        ),
                      );
                    },
                    child: Stack(
                      children: [
                      // Background Container with Product Info
                      Container(
                        decoration: BoxDecoration(
                          color: themeColors.cardColor,
                          borderRadius: BorderRadius.circular(8.spMin),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Product Image
                            Container(
                              height: 160.spMin,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.only(
                                  topLeft: Radius.circular(8.spMin),
                                  topRight: Radius.circular(8.spMin),
                                ),
                                color: themeColors.cardColor,
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.only(
                                  topLeft: Radius.circular(8.spMin),
                                  topRight: Radius.circular(8.spMin),
                                ),
                                child: Hero(
                                  tag: heroTag,
                                  child: Image.network(
                                    productImage,
                                    width: double.infinity,
                                    height: 160.spMin,
                                    fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    return Container(
                                      width: double.infinity,
                                      height: 160.spMin,
                                      color: themeColors.cardColor,
                                      child: Icon(
                                        Icons.image_not_supported,
                                        color: Colors.grey[400],
                                        size: 30.spMin,
                                      ),
                                    );
                                  },
                                  loadingBuilder:
                                      (context, child, loadingProgress) {
                                        if (loadingProgress == null)
                                          return child;
                                        return Container(
                                          width: double.infinity,
                                          height: 160.spMin,
                                          color: themeColors.cardColor,
                                          child: Center(
                                            child: CircularProgressIndicator(
                                              value:
                                                  loadingProgress
                                                          .expectedTotalBytes !=
                                                      null
                                                  ? loadingProgress
                                                            .cumulativeBytesLoaded /
                                                        loadingProgress
                                                            .expectedTotalBytes!
                                                  : null,
                                              strokeWidth: 2,
                                              valueColor:
                                                  AlwaysStoppedAnimation<Color>(
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
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  reusableText(
                                    productName,
                                    12.spMin,
                                    FontWeight.w500,
                                    themeColors.primaryTextColor,
                                    0,
                                    TextAlign.start,
                                  ),
                                  SizedBox(height: 6.spMin),
                                  reusableText(
                                    '\$ $productPrice',
                                    12.spMin,
                                    FontWeight.w900,
                                    themeColors.primaryTextColor,
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
                        top: 6.spMin,
                        right: 8.spMin,
                        child: GestureDetector(
                          onTap: () async {
                            if (productId.isEmpty) {
                              toastError(msg: 'Product ID is missing.');
                              return;
                            }
                            
                            final productPriceDouble = double.tryParse(
                              productPrice.replaceAll('\$', '').trim(),
                            ) ?? 0.0;
                            
                            await favoritesController.toggleFavorite(
                              productId: productId,
                              name: productName,
                              imageUrl: productImage,
                              price: productPriceDouble,
                            );
                            
                            final newIsFavorite =
                                await favoritesController.isProductFavorite(
                              productId,
                            );
                            
                            if (newIsFavorite) {
                              toastInfo(msg: 'Added to favorites!');
                            } else {
                              toastInfo(msg: 'Removed from favorites');
                            }
                          },
                          child: Icon(
                            isFavorite
                                ? Icons.favorite
                                : Icons.favorite_border,
                            color: isFavorite ? primary200 : Colors.grey[600],
                            size: 20.spMin,
                          ),
                        ),
                      ),
                    ],
                  ),
                  );
                },
        ),
      ),
        );
      },
    );
  }
}
