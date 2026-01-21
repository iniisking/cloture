// Method to build the shimmer effect
import 'package:cloture/view/constants/colors.dart';
import 'package:cloture/view/constants/theme_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shimmer/shimmer.dart';

Widget categoriesShimmerEffect({AppThemeColors? themeColors}) {
  final isDark = themeColors?.isDark ?? false;
  final baseColor = isDark ? Colors.grey[700]! : Colors.grey[300]!;
  final highlightColor = isDark ? Colors.grey[500]! : Colors.grey[100]!;
  final cardColor = themeColors?.cardColor ?? bgLight2;

  return ListView.builder(
    scrollDirection: Axis.horizontal,
    itemCount: 5, // Show 5 shimmer placeholders
    itemBuilder: (context, index) {
      return Padding(
        padding: EdgeInsets.only(
          left: index == 0 ? 19.spMin : 8.spMin,
          right: 8.spMin,
        ),
        child: Shimmer.fromColors(
          baseColor: baseColor,
          highlightColor: highlightColor,
          child: Column(
            children: [
              CircleAvatar(backgroundColor: cardColor, radius: 40.spMin),
              SizedBox(height: 8.spMin),
              Container(
                width: 60.spMin,
                height: 12.spMin,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12.spMin),
                ),
              ),
            ],
          ),
        ),
      );
    },
  );
}

// Method to build the shimmer effect for the product container
Widget buildProductShimmerEffect({AppThemeColors? themeColors}) {
  final isDark = themeColors?.isDark ?? false;
  final baseColor = isDark ? Colors.grey[700]! : Colors.grey[300]!;
  final highlightColor = isDark ? Colors.grey[500]! : Colors.grey[100]!;
  final cardColor = themeColors?.cardColor ?? bgLight2;

  return ListView.builder(
    scrollDirection: Axis.horizontal,
    itemCount: 4, // Number of shimmer placeholders
    itemBuilder: (context, index) {
      return Padding(
        padding: EdgeInsets.only(
          left: index == 0 ? 19.spMin : 8.spMin,
          right: 8.spMin,
        ),
        child: Stack(
          children: [
            // Background Container with Product Info (matches actual structure)
            Container(
              height: 320.spMin,
              width: 220.spMin,
              decoration: BoxDecoration(
                color: cardColor,
                borderRadius: BorderRadius.circular(8.spMin),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Product Image shimmer
                  Shimmer.fromColors(
                    baseColor: baseColor,
                    highlightColor: highlightColor,
                    child: Container(
                      height: 220.spMin,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(8.spMin),
                          topRight: Radius.circular(8.spMin),
                        ),
                        color: Colors.white,
                      ),
                    ),
                  ),
                  SizedBox(height: 8.spMin),
                  // Product name and price shimmer
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 8.spMin),
                    child: Shimmer.fromColors(
                      baseColor: baseColor,
                      highlightColor: highlightColor,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Product name placeholder
                          Container(
                            height: 14.spMin,
                            width: 120.spMin,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(14.spMin),
                            ),
                          ),
                          SizedBox(height: 8.spMin),
                          // Product price placeholder
                          Container(
                            height: 14.spMin,
                            width: 60.spMin,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(14.spMin),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Placeholder for love icon
            Positioned(
              top: 9.spMin,
              right: 12.spMin,
              child: Shimmer.fromColors(
                baseColor: baseColor,
                highlightColor: highlightColor,
                child: Container(
                  height: 24.spMin,
                  width: 24.spMin,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
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

Widget shopByCategoriesShimmerEffect({AppThemeColors? themeColors}) {
  final isDark = themeColors?.isDark ?? false;
  final baseColor = isDark ? Colors.grey[700]! : Colors.grey[300]!;
  final highlightColor = isDark ? Colors.grey[500]! : Colors.grey[100]!;
  final cardColor = themeColors?.cardColor ?? bgLight2;

  return Shimmer.fromColors(
    baseColor: baseColor,
    highlightColor: highlightColor,
    child: Container(
      padding: EdgeInsets.symmetric(vertical: 12.spMin),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(8.spMin),
      ),
      child: Row(
        children: [
          // CircleAvatar placeholder
          SizedBox(width: 16.spMin),
          CircleAvatar(backgroundColor: Colors.white, radius: 32.spMin),
          SizedBox(width: 16.spMin),
          // Text placeholder
          Expanded(
            child: Container(
              height: 16.spMin,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16.spMin),
              ),
            ),
          ),
          SizedBox(width: 16.spMin),
        ],
      ),
    ),
  );
}

// Grid shimmer effect for 2 columns (for TopSelling and NewIn screens)
Widget buildProductGridShimmerEffect({AppThemeColors? themeColors}) {
  final isDark = themeColors?.isDark ?? false;
  final baseColor = isDark ? Colors.grey[700]! : Colors.grey[300]!;
  final highlightColor = isDark ? Colors.grey[500]! : Colors.grey[100]!;
  final cardColor = themeColors?.cardColor ?? bgLight2;

  return GridView.builder(
    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
      crossAxisCount: 2,
      crossAxisSpacing: 8.spMin,
      mainAxisSpacing: 16.spMin,
      childAspectRatio: 0.85,
    ),
    padding: EdgeInsets.symmetric(horizontal: 19.spMin, vertical: 16.spMin),
    itemCount: 6, // Show 6 shimmer placeholders
    itemBuilder: (context, index) {
      return Stack(
        children: [
          // Background Container with Product Info (matches actual structure)
          Container(
            decoration: BoxDecoration(
              color: cardColor,
              borderRadius: BorderRadius.circular(8.spMin),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Product Image shimmer
                Shimmer.fromColors(
                  baseColor: baseColor,
                  highlightColor: highlightColor,
                  child: Container(
                    height: 160.spMin,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(8.spMin),
                        topRight: Radius.circular(8.spMin),
                      ),
                      color: Colors.white,
                    ),
                  ),
                ),
                SizedBox(height: 8.spMin),
                // Product name and price shimmer
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 8.spMin),
                  child: Shimmer.fromColors(
                    baseColor: baseColor,
                    highlightColor: highlightColor,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Product name placeholder
                        Container(
                          height: 12.spMin,
                          width: 90.spMin,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12.spMin),
                          ),
                        ),
                        SizedBox(height: 6.spMin),
                        // Product price placeholder
                        Container(
                          height: 12.spMin,
                          width: 55.spMin,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12.spMin),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Placeholder for love icon
          Positioned(
            top: 6.spMin,
            right: 8.spMin,
            child: Shimmer.fromColors(
              baseColor: baseColor,
              highlightColor: highlightColor,
              child: Container(
                height: 20.spMin,
                width: 20.spMin,
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ),
        ],
      );
    },
  );
}
