import 'package:cloture/gen/assets.gen.dart';
import 'package:cloture/view/screens/product/product_details_screen.dart';
import 'package:cloture/view/constants/colors.dart';
import 'package:cloture/view/constants/text.dart';
import 'package:cloture/view/constants/theme_colors.dart';
import 'package:cloture/view/constants/bottom_nav_screen.dart';
import 'package:cloture/controller/theme_controller.dart';
import 'package:cloture/controller/favorites_controller.dart';
import 'package:cloture/model/favorite_item.dart';
import 'package:cloture/view/widgets/toast_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

class FavouritesScreen extends StatefulWidget {
  const FavouritesScreen({super.key});

  @override
  State<FavouritesScreen> createState() => _FavouritesScreenState();
}

class _FavouritesScreenState extends State<FavouritesScreen> {
  @override
  void initState() {
    super.initState();
    // Load favorites when screen is opened
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<FavoritesController>().loadFavorites();
    });
  }

  Future<void> _removeFavorite(String favoriteItemId) async {
    final favoritesController = context.read<FavoritesController>();
    final success = await favoritesController.removeFavorite(favoriteItemId);
    if (success) {
      toastInfo(msg: 'Removed from favorites');
    } else {
      toastError(msg: 'Failed to remove favorite');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<ThemeController, FavoritesController>(
      builder: (context, themeController, favoritesController, child) {
        final themeColors = AppThemeColors(themeController.isDarkMode);
        final favoriteItems = favoritesController.favoriteItems;
        final isLoading = favoritesController.isLoading;

        return Scaffold(
          backgroundColor: themeColors.backgroundColor,
          appBar: AppBar(
            backgroundColor: themeColors.backgroundColor,
            elevation: 0,
            title: reusableText(
              'My Favourites (${favoriteItems.length})',
              20.spMin,
              FontWeight.bold,
              themeColors.primaryTextColor,
              -0.41,
              TextAlign.center,
            ),
            centerTitle: true,
          ),
          body: isLoading
              ? Center(child: CircularProgressIndicator(color: primary200))
              : favoriteItems.isEmpty
              ? _buildEmptyState(themeColors)
              : _buildFavouritesState(themeColors, favoritesController),
        );
      },
    );
  }

  Widget _buildEmptyState(AppThemeColors themeColors) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Assets.images.emptyState.image(width: 200.spMin, height: 200.spMin),
          SizedBox(height: 32.spMin),
          reusableText(
            'Your Favourites is Empty',
            20.spMin,
            FontWeight.bold,
            themeColors.primaryTextColor,
            -0.41,
            TextAlign.center,
          ),
          SizedBox(height: 32.spMin),
          GestureDetector(
            onTap: () {
              // Navigate to home page (index 0) in bottom nav
              final bottomNavState = context
                  .findAncestorStateOfType<BottomNavScreenState>();
              if (bottomNavState != null) {
                bottomNavState.navigateToTab(0);
              }
            },
            child: Container(
              padding: EdgeInsets.symmetric(
                horizontal: 32.spMin,
                vertical: 16.spMin,
              ),
              decoration: BoxDecoration(
                color: primary200,
                borderRadius: BorderRadius.circular(100.spMin),
              ),
              child: reusableText(
                'Explore Products',
                16.spMin,
                FontWeight.bold,
                themeColors.backgroundColor,
                -0.41,
                TextAlign.center,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFavouritesState(
    AppThemeColors themeColors,
    FavoritesController favoritesController,
  ) {
    final favoriteItems = favoritesController.favoriteItems;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 24.spMin, vertical: 16.spMin),
      child: GridView.builder(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 16.spMin,
          mainAxisSpacing: 16.spMin,
          childAspectRatio:
              0.72, // Slightly reduced to give more vertical space
        ),
        itemCount: favoriteItems.length,
        itemBuilder: (context, index) {
          final item = favoriteItems[index];
          return _buildFavoriteItem(item, themeColors);
        },
      ),
    );
  }

  Widget _buildFavoriteItem(FavoriteItem item, AppThemeColors themeColors) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ProductDetailsScreen(
              product: {
                'id': item.productId,
                'name': item.name,
                'price': item.price.toStringAsFixed(2),
                'imageUrl': item.imageUrl,
              },
            ),
          ),
        );
      },
      child: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              color: themeColors.cardColor,
              borderRadius: BorderRadius.circular(8.spMin),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Product Image
                ClipRRect(
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(8.spMin),
                    topRight: Radius.circular(8.spMin),
                  ),
                  child: Image.network(
                    item.imageUrl,
                    width: double.infinity,
                    height: 180.spMin, // Reduced from 200 to 180
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        width: double.infinity,
                        height: 180.spMin, // Reduced from 200 to 180
                        color: themeColors.cardColor,
                        child: Icon(
                          Icons.image_not_supported,
                          color: Colors.grey[400],
                          size: 40.spMin,
                        ),
                      );
                    },
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return Container(
                        width: double.infinity,
                        height: 180.spMin, // Reduced from 200 to 180
                        color: themeColors.cardColor,
                        child: Center(
                          child: CircularProgressIndicator(
                            value: loadingProgress.expectedTotalBytes != null
                                ? loadingProgress.cumulativeBytesLoaded /
                                      loadingProgress.expectedTotalBytes!
                                : null,
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              primary200,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                SizedBox(height: 8.spMin), // Reduced from 12 to 8
                // Product Name and Price
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 12.spMin),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        item.name,
                        style: TextStyle(
                          fontSize: 14.spMin,
                          fontWeight: FontWeight.w500,
                          color: themeColors.primaryTextColor,
                          letterSpacing: -0.41,
                          height: 1.2,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.left,
                      ),
                      SizedBox(height: 4.spMin),
                      reusableText(
                        '\$${item.price.toStringAsFixed(2)}',
                        16.spMin,
                        FontWeight.bold,
                        themeColors.primaryTextColor,
                        -0.41,
                        TextAlign.left,
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 8.spMin), // Add bottom padding
              ],
            ),
          ),
          // Heart Icon (Favorite indicator)
          Positioned(
            top: 8.spMin,
            right: 8.spMin,
            child: GestureDetector(
              onTap: () => _removeFavorite(item.id),
              child: Container(
                padding: EdgeInsets.all(4.spMin),
                decoration: BoxDecoration(
                  color: Colors.red,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.favorite,
                  color: themeColors.backgroundColor,
                  size: 16.spMin,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
