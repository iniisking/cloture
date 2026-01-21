import 'package:cloture/view/widgets/buttons.dart';
import 'package:cloture/view/constants/text.dart';
import 'package:cloture/view/constants/theme_colors.dart';
import 'package:cloture/controller/theme_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloture/view/widgets/shimmer_widget.dart';
import 'package:provider/provider.dart';

class CategoriesMen extends StatefulWidget {
  const CategoriesMen({super.key});

  @override
  State<CategoriesMen> createState() => _CategoriesMenState();
}

class _CategoriesMenState extends State<CategoriesMen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // List to hold categories
  List<Map<String, String>> categories = [];

  @override
  void initState() {
    super.initState();
    fetchAllCategories(); // Fetch categories when the screen is loaded
  }

  Future<void> fetchAllCategories() async {
    try {
      // Get the categories collection from Firestore
      QuerySnapshot querySnapshot = await _firestore
          .collection('categories')
          .get();

      // Extract category names and image URLs
      List<Map<String, String>> fetchedCategories = querySnapshot.docs.map((
        doc,
      ) {
        return {
          'name': doc['name'] as String, // Cast to String
          'imageUrl': doc['imageUrl'] as String, // Cast to String
        };
      }).toList();

      // Check if the widget is still mounted before calling setState
      if (mounted) {
        setState(() {
          categories = fetchedCategories;
        });
      }
    } catch (e) {
      print('Error fetching categories: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeController>(
      builder: (context, themeController, child) {
        final themeColors = AppThemeColors(themeController.isDarkMode);
        return Scaffold(
          backgroundColor: themeColors.backgroundColor,
          body: SafeArea(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 27.spMin),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 20.spMin),
                  backButton(() {
                    Navigator.of(context).pop();
                  }),
                  SizedBox(height: 16.spMin),

                  // Shop by Categories Text
                  reusableText(
                    'Shop by Categories',
                    24.spMin,
                    FontWeight.bold,
                    themeColors.primaryTextColor,
                    -0.41,
                    TextAlign.left,
                  ),

              SizedBox(height: 12.spMin),

              // Dynamic content based on categories
              Expanded(
                child: categories.isEmpty
                    ? ListView.builder(
                        itemCount: 6, // Number of shimmer placeholders
                        itemBuilder: (context, index) {
                          return Padding(
                            padding: EdgeInsets.symmetric(vertical: 4.spMin),
                            child: shopByCategoriesShimmerEffect(themeColors: themeColors),
                          );
                        },
                      )
                    : ListView.builder(
                        padding: EdgeInsets.zero,
                        itemCount: categories.length,
                        itemBuilder: (context, index) {
                          String categoryName = categories[index]['name']!;
                          String imageUrl = categories[index]['imageUrl']!;

                          return Padding(
                            padding: EdgeInsets.symmetric(vertical: 8.spMin),
                            child: Container(
                              padding: EdgeInsets.symmetric(vertical: 12.spMin),
                              decoration: BoxDecoration(
                                color: themeColors.cardColor,
                                borderRadius: BorderRadius.circular(8.spMin),
                              ),
                              child: ListTile(
                                leading: CircleAvatar(
                                  backgroundColor: themeColors.cardColor,
                                  backgroundImage: NetworkImage(imageUrl),
                                  radius: 32.spMin,
                                  onBackgroundImageError: (exception, stackTrace) {
                                    // Handle error silently
                                  },
                                  child: imageUrl.isEmpty
                                      ? Icon(Icons.image, color: Colors.grey[400], size: 20.spMin)
                                      : null,
                                ),
                                title: reusableText(
                                  categoryName,
                                  16.spMin,
                                  FontWeight.w500,
                                  themeColors.primaryTextColor,
                                  -0.41,
                                  TextAlign.left,
                                ),
                              ),
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
        );
      },
    );
  }
}
