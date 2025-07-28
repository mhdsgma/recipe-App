import 'package:recipe_app/features/recipe/domain/entities/recipe.dart';
abstract class RecipeRepo {
  Future<List<Recipe>> getAllRecipes();
  Future<List<Recipe>> getRecipesByCategory(String categoryId);
  Future<Recipe?> getRecipeById(String recipeId);
  Future<List<Recipe>> searchRecipes(String query);
}
