// ignore_for_file: unused_element, deprecated_member_use

import 'package:cloture/gen/assets.gen.dart';
import 'package:cloture/view/constants/colors.dart';
import 'package:cloture/view/constants/text.dart';
import 'package:cloture/view/constants/theme_colors.dart';
import 'package:cloture/view/constants/bottom_nav_screen.dart';
import 'package:cloture/controller/theme_controller.dart';
import 'package:cloture/controller/cart_controller.dart';
import 'package:cloture/model/cart_item.dart';
import 'package:cloture/view/widgets/toast_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

class OrdersScreen extends StatefulWidget {
  const OrdersScreen({super.key});

  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> {
  @override
  void initState() {
    super.initState();
    // Load cart when screen is opened
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CartController>().loadCart();
    });
  }

  Future<void> _updateQuantity(String cartItemId, int newQuantity) async {
    final cartController = context.read<CartController>();
    await cartController.updateQuantity(cartItemId, newQuantity);
  }

  Future<void> _removeItem(String cartItemId) async {
    final cartController = context.read<CartController>();
    final success = await cartController.removeItem(cartItemId);
    if (success) {
      toastInfo(msg: 'Item removed from cart');
    } else {
      toastError(msg: 'Failed to remove item');
    }
  }

  Future<void> _removeAll() async {
    final cartController = context.read<CartController>();
    final success = await cartController.clearCart();
    if (success) {
      toastInfo(msg: 'Cart cleared');
    } else {
      toastError(msg: 'Failed to clear cart');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<ThemeController, CartController>(
      builder: (context, themeController, cartController, child) {
        final themeColors = AppThemeColors(themeController.isDarkMode);
        final cartItems = cartController.cartItems;
        final isLoading = cartController.isLoading;

        return Scaffold(
          backgroundColor: themeColors.backgroundColor,
          appBar: AppBar(
            backgroundColor: themeColors.backgroundColor,
            elevation: 0,
            title: reusableText(
              'Cart',
              20.spMin,
              FontWeight.bold,
              themeColors.primaryTextColor,
              -0.41,
              TextAlign.center,
            ),
            centerTitle: true,
            actions: cartItems.isNotEmpty
                ? [
                    Padding(
                      padding: EdgeInsets.only(right: 16.spMin),
                      child: GestureDetector(
                        onTap: _removeAll,
                        child: Center(
                          child: reusableText(
                            'Remove All',
                            16.spMin,
                            FontWeight.w500,
                            themeColors.primaryTextColor,
                            -0.41,
                            TextAlign.right,
                          ),
                        ),
                      ),
                    ),
                  ]
                : null,
          ),
          body: isLoading
              ? Center(child: CircularProgressIndicator(color: primary200))
              : cartItems.isEmpty
              ? _buildEmptyState(themeColors)
              : _buildCartState(themeColors, cartController),
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
            'Your Cart is Empty',
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

  Widget _buildCartState(
    AppThemeColors themeColors,
    CartController cartController,
  ) {
    final subtotal = cartController.subtotal;
    final shippingCost = cartController.shippingCost;
    final tax = cartController.tax;
    final total = cartController.total;
    final cartItems = cartController.cartItems;

    return Column(
      children: [
        // Cart Items List
        Expanded(
          child: ListView.builder(
            padding: EdgeInsets.symmetric(
              horizontal: 24.spMin,
              vertical: 16.spMin,
            ),
            itemCount: cartItems.length,
            itemBuilder: (context, index) {
              final item = cartItems[index];
              return _buildCartItem(item, themeColors);
            },
          ),
        ),

        // Order Summary and Checkout
        Container(
          padding: EdgeInsets.all(24.spMin),
          decoration: BoxDecoration(
            color: themeColors.backgroundColor,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, -2),
              ),
            ],
          ),
          child: Column(
            children: [
              // Order Summary
              _buildOrderSummaryRow(
                'Subtotal',
                '\$${subtotal.toStringAsFixed(2)}',
                themeColors,
              ),
              SizedBox(height: 12.spMin),
              _buildOrderSummaryRow(
                'Shipping Cost',
                '\$${shippingCost.toStringAsFixed(2)}',
                themeColors,
              ),
              SizedBox(height: 12.spMin),
              _buildOrderSummaryRow(
                'Tax',
                '\$${tax.toStringAsFixed(2)}',
                themeColors,
              ),
              SizedBox(height: 16.spMin),
              Divider(color: themeColors.cardColor, thickness: 1),
              SizedBox(height: 16.spMin),
              _buildOrderSummaryRow(
                'Total',
                '\$${total.toStringAsFixed(2)}',
                themeColors,
                isBold: true,
              ),
              SizedBox(height: 24.spMin),

              // Coupon Code Input
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: 16.spMin,
                  vertical: 12.spMin,
                ),
                decoration: BoxDecoration(
                  color: themeColors.cardColor,
                  borderRadius: BorderRadius.circular(8.spMin),
                ),
                child: Row(
                  children: [
                    Icon(Icons.percent, color: Colors.green, size: 24.spMin),
                    SizedBox(width: 12.spMin),
                    Expanded(
                      child: TextField(
                        decoration: InputDecoration(
                          hintText: 'Enter Coupon Code',
                          hintStyle: TextStyle(
                            fontSize: 14.spMin,
                            color: themeColors.secondaryTextColor,
                          ),
                          border: InputBorder.none,
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        // TODO: Apply coupon
                      },
                      child: Container(
                        width: 40.spMin,
                        height: 40.spMin,
                        decoration: BoxDecoration(
                          color: primary200,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.arrow_forward,
                          color: themeColors.backgroundColor,
                          size: 20.spMin,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 24.spMin),

              // Checkout Button
              GestureDetector(
                onTap: () {
                  // TODO: Navigate to checkout
                },
                child: Container(
                  width: double.infinity,
                  padding: EdgeInsets.symmetric(vertical: 16.spMin),
                  decoration: BoxDecoration(
                    color: primary200,
                    borderRadius: BorderRadius.circular(8.spMin),
                  ),
                  child: Center(
                    child: reusableText(
                      'Checkout',
                      18.spMin,
                      FontWeight.bold,
                      themeColors.backgroundColor,
                      -0.41,
                      TextAlign.center,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCartItem(CartItem item, AppThemeColors themeColors) {
    return Container(
      margin: EdgeInsets.only(bottom: 16.spMin),
      padding: EdgeInsets.all(16.spMin),
      decoration: BoxDecoration(
        color: themeColors.cardColor,
        borderRadius: BorderRadius.circular(8.spMin),
      ),
      child: Row(
        children: [
          // Product Image
          ClipRRect(
            borderRadius: BorderRadius.circular(8.spMin),
            child: Image.network(
              item.imageUrl,
              width: 80.spMin,
              height: 80.spMin,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  width: 80.spMin,
                  height: 80.spMin,
                  color: themeColors.cardColor,
                  child: Icon(
                    Icons.image_not_supported,
                    color: Colors.grey[400],
                  ),
                );
              },
            ),
          ),
          SizedBox(width: 16.spMin),
          // Product Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                reusableText(
                  item.name,
                  16.spMin,
                  FontWeight.w500,
                  themeColors.primaryTextColor,
                  -0.41,
                  TextAlign.left,
                ),
                SizedBox(height: 4.spMin),
                reusableText(
                  'Size - ${item.size}',
                  14.spMin,
                  FontWeight.normal,
                  themeColors.secondaryTextColor,
                  -0.41,
                  TextAlign.left,
                ),
                SizedBox(height: 2.spMin),
                reusableText(
                  'Color - ${item.color}',
                  14.spMin,
                  FontWeight.normal,
                  themeColors.secondaryTextColor,
                  -0.41,
                  TextAlign.left,
                ),
              ],
            ),
          ),
          // Price and Quantity Controls
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              reusableText(
                '\$${item.price.toStringAsFixed(2)}',
                16.spMin,
                FontWeight.bold,
                themeColors.primaryTextColor,
                -0.41,
                TextAlign.right,
              ),
              SizedBox(height: 8.spMin),
              Row(
                children: [
                  // Minus Button
                  GestureDetector(
                    onTap: () => _updateQuantity(item.id, item.quantity - 1),
                    child: Container(
                      width: 32.spMin,
                      height: 32.spMin,
                      decoration: BoxDecoration(
                        color: primary200,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.remove,
                        color: themeColors.backgroundColor,
                        size: 18.spMin,
                      ),
                    ),
                  ),
                  SizedBox(width: 12.spMin),
                  reusableText(
                    '${item.quantity}',
                    16.spMin,
                    FontWeight.normal,
                    themeColors.primaryTextColor,
                    -0.41,
                    TextAlign.center,
                  ),
                  SizedBox(width: 12.spMin),
                  // Plus Button
                  GestureDetector(
                    onTap: () => _updateQuantity(item.id, item.quantity + 1),
                    child: Container(
                      width: 32.spMin,
                      height: 32.spMin,
                      decoration: BoxDecoration(
                        color: primary200,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.add,
                        color: themeColors.backgroundColor,
                        size: 18.spMin,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildOrderSummaryRow(
    String label,
    String value,
    AppThemeColors themeColors, {
    bool isBold = false,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        reusableText(
          label,
          16.spMin,
          isBold ? FontWeight.bold : FontWeight.normal,
          themeColors.primaryTextColor,
          -0.41,
          TextAlign.left,
        ),
        reusableText(
          value,
          16.spMin,
          isBold ? FontWeight.bold : FontWeight.normal,
          themeColors.primaryTextColor,
          -0.41,
          TextAlign.right,
        ),
      ],
    );
  }
}
