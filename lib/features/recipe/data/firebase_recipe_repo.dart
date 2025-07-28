import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:recipe_app/features/recipe/domain/entities/recipe.dart';


import '../domain/entities/recipe_repo.dart';


class FirebaseRecipeRepo implements RecipeRepo {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collectionPath = "recipes";

  @override
  Future<List<Recipe>> getAllRecipes() async {
    try {
      QuerySnapshot snapshot = await _firestore.collection(_collectionPath).get();
      return snapshot.docs
          .map((doc) => Recipe.fromJson(doc.data() as Map<String, dynamic>, doc.id))
          .toList();
    } catch (e) {
      if (kDebugMode) {
        print("Error getting all recipes: $e");
      }
      throw Exception("Failed to fetch recipes: $e");
    }
  }

  @override
  Future<List<Recipe>> getRecipesByCategory(String categoryId) async {
    try {
      QuerySnapshot snapshot = await _firestore
          .collection(_collectionPath)
          .where("categoryId", isEqualTo: categoryId)
          .get();
      return snapshot.docs
          .map((doc) => Recipe.fromJson(doc.data() as Map<String, dynamic>, doc.id))
          .toList();
    } catch (e) {
      print("Error getting recipes by category $categoryId: $e");
      throw Exception("Failed to fetch recipes for category $categoryId: $e");
    }
  }

  @override
  Future<Recipe?> getRecipeById(String recipeId) async {
    try {
      DocumentSnapshot doc = await _firestore.collection(_collectionPath).doc(recipeId).get();
      if (doc.exists) {
        return Recipe.fromJson(doc.data() as Map<String, dynamic>, doc.id);
      } else {
        return null;
      }
    } catch (e) {
      if (kDebugMode) {
        print("Error getting recipe by ID $recipeId: $e");
      }
      throw Exception("Failed to fetch recipe $recipeId: $e");
    }
  }

  @override
  Future<List<Recipe>> searchRecipes(String query) async {
    if (query.isEmpty) {
      return [];
    }
    print("--- FirebaseRecipeRepo: Searching recipes locally (case-insensitive) for query: $query ---");
    try {
      QuerySnapshot allDocs = await _firestore.collection(_collectionPath).get();
      final results = allDocs.docs
          .map((doc) => Recipe.fromJson(doc.data() as Map<String, dynamic>, doc.id))
          .where((recipe) => recipe.name.toLowerCase().contains(query.toLowerCase()))
          .toList();

      if (kDebugMode) {
        print("--- FirebaseRecipeRepo: Found ${results.length} matching recipes locally. ---");
      }
      return results;

    } catch (e) {
      if (kDebugMode) {
        print("Error searching recipes (local filter) for query $query: $e");
      }
      throw Exception("Failed to search recipes: $e");
    }
  }

}

