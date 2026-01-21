import 'package:cloture/view/constants/colors.dart';
import 'package:cloture/view/constants/text.dart';
import 'package:cloture/view/constants/theme_colors.dart';
import 'package:cloture/controller/theme_controller.dart';
import 'package:cloture/controller/cart_controller.dart';
import 'package:cloture/controller/favorites_controller.dart';
import 'package:cloture/view/widgets/toast_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

class ProductDetailsScreen extends StatefulWidget {
  final Map<String, String> product;
  final String? heroTag;

  const ProductDetailsScreen({super.key, required this.product, this.heroTag});

  @override
  State<ProductDetailsScreen> createState() => _ProductDetailsScreenState();
}

class _ProductDetailsScreenState extends State<ProductDetailsScreen> {
  String selectedSize = 'S';
  String selectedColor = 'Green';
  int quantity = 1;
  bool _isAddingToCart = false;
  bool _isTogglingFavorite = false;

  final List<String> sizes = ['S', 'M', 'L', 'XL', 'XXL'];
  final List<Map<String, dynamic>> colors = [
    {'name': 'Green', 'color': const Color(0xFFA8C5A0)},
    {'name': 'Black', 'color': Colors.black},
    {'name': 'Blue', 'color': Colors.blue},
    {'name': 'Red', 'color': Colors.red},
  ];

  Future<void> _handleAddToBag() async {
    final cartController = context.read<CartController>();
    final productId = widget.product['id'] ?? '';
    final productName = widget.product['name'] ?? 'Product';
    final productPriceStr = widget.product['price'] ?? '0';
    final productImage = widget.product['imageUrl'] ?? '';

    // Validate product ID
    if (productId.isEmpty) {
      toastError(msg: 'Product ID is missing. Cannot add to cart.');
      return;
    }

    // Parse price
    final productPrice =
        double.tryParse(productPriceStr.replaceAll('\$', '').trim()) ?? 0.0;

    setState(() {
      _isAddingToCart = true;
    });

    try {
      final success = await cartController.addToCart(
        productId: productId,
        name: productName,
        imageUrl: productImage,
        price: productPrice,
        size: selectedSize,
        color: selectedColor,
        quantity: quantity,
      );

      if (success) {
        toastInfo(msg: 'Added to bag successfully!');
      } else {
        toastError(msg: 'Failed to add to bag. Please try again.');
      }
    } catch (e) {
      toastError(msg: 'An error occurred. Please try again.');
    } finally {
      if (mounted) {
        setState(() {
          _isAddingToCart = false;
        });
      }
    }
  }

  @override
  void initState() {
    super.initState();
    // Check if product is already in favorites
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkFavoriteStatus();
    });
  }

  Future<void> _checkFavoriteStatus() async {
    final favoritesController = context.read<FavoritesController>();
    final productId = widget.product['id'] ?? '';
    if (productId.isNotEmpty) {
      await favoritesController.isProductFavorite(productId);
    }
  }

  Future<void> _handleToggleFavorite() async {
    final favoritesController = context.read<FavoritesController>();
    final productId = widget.product['id'] ?? '';
    final productName = widget.product['name'] ?? 'Product';
    final productPriceStr = widget.product['price'] ?? '0';
    final productImage = widget.product['imageUrl'] ?? '';

    // Validate product ID
    if (productId.isEmpty) {
      toastError(msg: 'Product ID is missing. Cannot add to favorites.');
      return;
    }

    // Parse price
    final productPrice =
        double.tryParse(productPriceStr.replaceAll('\$', '').trim()) ?? 0.0;

    setState(() {
      _isTogglingFavorite = true;
    });

    try {
      final success = await favoritesController.toggleFavorite(
        productId: productId,
        name: productName,
        imageUrl: productImage,
        price: productPrice,
      );

      if (success) {
        final isFavorite = await favoritesController.isProductFavorite(
          productId,
        );
        if (isFavorite) {
          toastInfo(msg: 'Added to favorites!');
        } else {
          toastInfo(msg: 'Removed from favorites');
        }
      } else {
        toastError(msg: 'Failed to update favorites. Please try again.');
      }
    } catch (e) {
      toastError(msg: 'An error occurred. Please try again.');
    } finally {
      if (mounted) {
        setState(() {
          _isTogglingFavorite = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<ThemeController, FavoritesController>(
      builder: (context, themeController, favoritesController, child) {
        final themeColors = AppThemeColors(themeController.isDarkMode);
        final productName = widget.product['name'] ?? 'Product';
        final productPrice = widget.product['price'] ?? '0';
        final productImage = widget.product['imageUrl'] ?? '';
        final productId = widget.product['id'] ?? '';
        final screenHeight = MediaQuery.of(context).size.height;
        final topHalfHeight = screenHeight * 0.5;
        final heroTag =
            widget.heroTag ?? 'product_${productName}_${productImage}';

        // Calculate total price based on quantity
        final basePrice =
            double.tryParse(productPrice.replaceAll('\$', '').trim()) ?? 0.0;
        final totalPrice = basePrice * quantity;

        // Check if product is in favorites
        final isFavorite = productId.isNotEmpty
            ? favoritesController.favoriteItems.any(
                (item) => item.productId == productId,
              )
            : false;

        return Scaffold(
          backgroundColor: themeColors.backgroundColor,
          body: Column(
            children: [
              // Top Half: Product Image as Background with Overlaid Buttons
              SizedBox(
                height: topHalfHeight,
                child: Stack(
                  children: [
                    // Product Image as Background (extends to top edge)
                    Hero(
                      tag: heroTag,
                      child: Image.network(
                        productImage,
                        width: double.infinity,
                        height: topHalfHeight,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            width: double.infinity,
                            height: topHalfHeight,
                            color: themeColors.cardColor,
                            child: Icon(
                              Icons.image_not_supported,
                              color: Colors.grey[400],
                              size: 60.spMin,
                            ),
                          );
                        },
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) return child;
                          return Container(
                            width: double.infinity,
                            height: topHalfHeight,
                            color: themeColors.cardColor,
                            child: Center(
                              child: CircularProgressIndicator(
                                value:
                                    loadingProgress.expectedTotalBytes != null
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
                    // Back and Favorite Buttons Overlay (with SafeArea)
                    SafeArea(
                      child: Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: 19.spMin,
                          vertical: 16.spMin,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            // Back Button
                            GestureDetector(
                              onTap: () => Navigator.pop(context),
                              child: Container(
                                width: 40.spMin,
                                height: 40.spMin,
                                decoration: BoxDecoration(
                                  color: themeColors.cardColor,
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  Icons.chevron_left,
                                  color: themeColors.primaryTextColor,
                                  size: 24.spMin,
                                ),
                              ),
                            ),
                            // Favorite Button
                            GestureDetector(
                              onTap: _isTogglingFavorite
                                  ? null
                                  : _handleToggleFavorite,
                              child: Container(
                                width: 40.spMin,
                                height: 40.spMin,
                                decoration: BoxDecoration(
                                  color: themeColors.cardColor,
                                  shape: BoxShape.circle,
                                ),
                                child: _isTogglingFavorite
                                    ? SizedBox(
                                        width: 20.spMin,
                                        height: 20.spMin,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          valueColor:
                                              AlwaysStoppedAnimation<Color>(
                                                primary200,
                                              ),
                                        ),
                                      )
                                    : Icon(
                                        isFavorite
                                            ? Icons.favorite
                                            : Icons.favorite_border,
                                        color: isFavorite
                                            ? primary200
                                            : themeColors.primaryTextColor,
                                        size: 24.spMin,
                                      ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Bottom Half: Scrollable Product Information
              Expanded(
                child: SingleChildScrollView(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 24.spMin),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(height: 24.spMin),
                        // Product Title
                        reusableText(
                          productName,
                          20.spMin,
                          FontWeight.bold,
                          themeColors.primaryTextColor,
                          -0.41,
                          TextAlign.left,
                        ),
                        SizedBox(height: 8.spMin),
                        // Product Price
                        reusableText(
                          '\$ $productPrice',
                          20.spMin,
                          FontWeight.bold,
                          primary200,
                          -0.41,
                          TextAlign.left,
                        ),
                        SizedBox(height: 32.spMin),

                        // Size Selector
                        _buildSelector(
                          themeColors: themeColors,
                          label: 'Size',
                          value: selectedSize,
                          onTap: () => _showSizeSelector(context, themeColors),
                        ),
                        SizedBox(height: 16.spMin),

                        // Color Selector
                        _buildColorSelector(themeColors),
                        SizedBox(height: 16.spMin),

                        // Quantity Selector
                        _buildQuantitySelector(themeColors),
                        SizedBox(
                          height: 100.spMin,
                        ), // Extra space for bottom button
                      ],
                    ),
                  ),
                ),
              ),
              // Add to Bag Button
              SafeArea(
                top: false,
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 24.spMin,
                    vertical: 16.spMin,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.transparent,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: const Offset(0, -2),
                      ),
                    ],
                  ),
                  child: GestureDetector(
                    onTap: _isAddingToCart ? null : _handleAddToBag,
                    child: Container(
                      width: double.infinity,
                      padding: EdgeInsets.symmetric(
                        vertical: 16.spMin,
                        horizontal: 24.spMin,
                      ),
                      decoration: BoxDecoration(
                        color: primary200,
                        borderRadius: BorderRadius.circular(100.spMin),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          reusableText(
                            '\$ ${totalPrice.toStringAsFixed(2)}',
                            18.spMin,
                            FontWeight.bold,
                            themeColors.backgroundColor,
                            -0.41,
                            TextAlign.left,
                          ),
                          _isAddingToCart
                              ? SizedBox(
                                  width: 20.spMin,
                                  height: 20.spMin,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      themeColors.backgroundColor,
                                    ),
                                  ),
                                )
                              : reusableText(
                                  'Add to Bag',
                                  18.spMin,
                                  FontWeight.bold,
                                  themeColors.backgroundColor,
                                  -0.41,
                                  TextAlign.right,
                                ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showSizeSelector(BuildContext context, AppThemeColors themeColors) {
    showModalBottomSheet(
      context: context,
      backgroundColor: themeColors.backgroundColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.spMin)),
      ),
      builder: (context) => Container(
        padding: EdgeInsets.all(24.spMin),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            reusableText(
              'Select Size',
              18.spMin,
              FontWeight.bold,
              themeColors.primaryTextColor,
              -0.41,
              TextAlign.center,
            ),
            SizedBox(height: 24.spMin),
            Wrap(
              spacing: 12.spMin,
              runSpacing: 12.spMin,
              children: sizes.map((size) {
                final isSelected = size == selectedSize;
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      selectedSize = size;
                    });
                    Navigator.pop(context);
                  },
                  child: Container(
                    width: 60.spMin,
                    height: 60.spMin,
                    decoration: BoxDecoration(
                      color: isSelected ? primary200 : themeColors.cardColor,
                      borderRadius: BorderRadius.circular(8.spMin),
                      border: Border.all(
                        color: isSelected
                            ? primary200
                            : themeColors.secondaryTextColor,
                        width: 1,
                      ),
                    ),
                    child: Center(
                      child: reusableText(
                        size,
                        16.spMin,
                        FontWeight.w500,
                        isSelected
                            ? themeColors.backgroundColor
                            : themeColors.primaryTextColor,
                        -0.41,
                        TextAlign.center,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            SizedBox(height: 24.spMin),
          ],
        ),
      ),
    );
  }

  Widget _buildColorSelector(AppThemeColors themeColors) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        reusableText(
          'Color',
          16.spMin,
          FontWeight.w500,
          themeColors.primaryTextColor,
          -0.41,
          TextAlign.left,
        ),
        SizedBox(height: 12.spMin),
        GestureDetector(
          onTap: () => _showColorSelector(context, themeColors),
          child: Container(
            padding: EdgeInsets.symmetric(
              horizontal: 16.spMin,
              vertical: 16.spMin,
            ),
            decoration: BoxDecoration(
              color: themeColors.cardColor,
              borderRadius: BorderRadius.circular(8.spMin),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      width: 24.spMin,
                      height: 24.spMin,
                      decoration: BoxDecoration(
                        color: colors.firstWhere(
                          (c) => c['name'] == selectedColor,
                        )['color'],
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: themeColors.secondaryTextColor,
                          width: 1,
                        ),
                      ),
                    ),
                    SizedBox(width: 12.spMin),
                    reusableText(
                      selectedColor,
                      16.spMin,
                      FontWeight.normal,
                      themeColors.primaryTextColor,
                      -0.41,
                      TextAlign.left,
                    ),
                  ],
                ),
                Icon(
                  Icons.chevron_right,
                  color: themeColors.secondaryTextColor,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  void _showColorSelector(BuildContext context, AppThemeColors themeColors) {
    showModalBottomSheet(
      context: context,
      backgroundColor: themeColors.backgroundColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.spMin)),
      ),
      builder: (context) => Container(
        padding: EdgeInsets.all(24.spMin),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            reusableText(
              'Select Color',
              18.spMin,
              FontWeight.bold,
              themeColors.primaryTextColor,
              -0.41,
              TextAlign.center,
            ),
            SizedBox(height: 24.spMin),
            Wrap(
              spacing: 12.spMin,
              runSpacing: 12.spMin,
              children: colors.map((colorData) {
                final isSelected = colorData['name'] == selectedColor;
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      selectedColor = colorData['name'];
                    });
                    Navigator.pop(context);
                  },
                  child: Container(
                    width: 60.spMin,
                    height: 60.spMin,
                    decoration: BoxDecoration(
                      color: colorData['color'],
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isSelected
                            ? primary200
                            : themeColors.secondaryTextColor,
                        width: isSelected ? 3 : 1,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            SizedBox(height: 24.spMin),
          ],
        ),
      ),
    );
  }

  Widget _buildQuantitySelector(AppThemeColors themeColors) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        reusableText(
          'Quantity',
          16.spMin,
          FontWeight.w500,
          themeColors.primaryTextColor,
          -0.41,
          TextAlign.left,
        ),
        SizedBox(height: 12.spMin),
        Container(
          padding: EdgeInsets.symmetric(
            horizontal: 16.spMin,
            vertical: 16.spMin,
          ),
          decoration: BoxDecoration(
            color: themeColors.cardColor,
            borderRadius: BorderRadius.circular(8.spMin),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              GestureDetector(
                onTap: () {
                  if (quantity > 1) {
                    setState(() {
                      quantity--;
                    });
                  }
                },
                child: Container(
                  width: 40.spMin,
                  height: 40.spMin,
                  decoration: BoxDecoration(
                    color: themeColors.backgroundColor,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: themeColors.secondaryTextColor,
                      width: 1,
                    ),
                  ),
                  child: Icon(
                    Icons.remove,
                    color: themeColors.primaryTextColor,
                    size: 20.spMin,
                  ),
                ),
              ),
              reusableText(
                quantity.toString(),
                18.spMin,
                FontWeight.bold,
                themeColors.primaryTextColor,
                -0.41,
                TextAlign.center,
              ),
              GestureDetector(
                onTap: () {
                  setState(() {
                    quantity++;
                  });
                },
                child: Container(
                  width: 40.spMin,
                  height: 40.spMin,
                  decoration: BoxDecoration(
                    color: primary200,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.add,
                    color: themeColors.backgroundColor,
                    size: 20.spMin,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSelector({
    required AppThemeColors themeColors,
    required String label,
    required String value,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16.spMin, vertical: 16.spMin),
        decoration: BoxDecoration(
          color: themeColors.cardColor,
          borderRadius: BorderRadius.circular(8.spMin),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            reusableText(
              label,
              16.spMin,
              FontWeight.normal,
              themeColors.primaryTextColor,
              -0.41,
              TextAlign.left,
            ),
            Row(
              children: [
                reusableText(
                  value,
                  16.spMin,
                  FontWeight.normal,
                  themeColors.primaryTextColor,
                  -0.41,
                  TextAlign.right,
                ),
                SizedBox(width: 8.spMin),
                Icon(
                  Icons.keyboard_arrow_down,
                  color: themeColors.primaryTextColor,
                  size: 24.spMin,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
