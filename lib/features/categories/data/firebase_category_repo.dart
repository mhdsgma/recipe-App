import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:recipe_app/features/categories/domain/entities/category.dart';
import 'package:recipe_app/features/recipe/presentation/pages/recipe_list_page.dart';

import '../domain/repos/category_repo.dart';

class FirebaseCategoryRepo implements CategoryRepo {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Future<List<Category>> getAllCategories() async {
    print("--- FirebaseCategoryRepo: Starting to fetch categories ---");
    print("--- FirebaseCategoryRepo: Firestore instance: $_firestore ---");

    try {
      print(
        "--- FirebaseCategoryRepo: Attempting to access 'categories' collection ---",
      );
      final collection = _firestore.collection('categories');
      print("--- FirebaseCategoryRepo: Collection reference obtained ---");

      final snapshot = await collection.get();
      print(
        "--- FirebaseCategoryRepo: Fetched ${snapshot.docs.length} category documents ---",
      );

      if (snapshot.docs.isEmpty) {
        print("!!! WARNING: No categories found in Firestore !!!");
        return [];
      }

      final categories =
          snapshot.docs
              .map((doc) {
                final rawData = doc.data();
                print(
                  "--- FirebaseCategoryRepo: Processing document ID: ${doc.id} ---",
                );
                print("--- FirebaseCategoryRepo: Raw data: $rawData ---");

                try {
                  final category = Category.fromJson(rawData, doc.id);
                  print(
                    "--- FirebaseCategoryRepo: Successfully created category: ${category.name} ---",
                  );
                  return category;
                } catch (e) {
                  print("!!! ERROR parsing category doc ID ${doc.id}: $e");
                  print("!!! Raw data that caused error: $rawData");
                  return null;
                }
              })
              .where((category) => category != null)
              .cast<Category>()
              .toList();

      print(
        "--- FirebaseCategoryRepo: Successfully processed ${categories.length} categories ---",
      );
      return categories;
    } catch (e) {
      print("!!! ERROR fetching categories: $e");
      print("!!! Stack trace: ${StackTrace.current}");
      return [];
    }
  }

  // Future<List<Category>> searchCategories(String query) async {
  //   ...
  // }
}

class CategoryTile extends StatelessWidget {
  final Category category;

  const CategoryTile({super.key, required this.category});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            settings: RouteSettings(arguments: {"imageUrl": category.imageUrl}),
            builder:
                (context) => RecipeListPage(
                  type: RecipeListType.category,
                  categoryId: category.id,
                  pageTitle: category.name,
                  categoryName: '',
                ),
          ),
        );
      },
      child: Hero(
        tag: 'category-image-${category.id}',
        child: Image.network(
          category.imageUrl,
          fit: BoxFit.cover,
          height: 180,
          width: double.infinity,
        ),
      ),
    );
  }
}
