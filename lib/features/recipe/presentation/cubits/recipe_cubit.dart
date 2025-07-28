import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:recipe_app/features/recipe/presentation/cubits/recipe_states.dart';
import '../../domain/entities/recipe_repo.dart';

class RecipeCubit extends Cubit<RecipeState> {
  final RecipeRepo recipeRepo;

  RecipeCubit({required this.recipeRepo}) : super(RecipeInitial());

  Future<void> fetchAllRecipes() async {
    emit(RecipeLoading());
    try {
      final recipes = await recipeRepo.getAllRecipes();
      emit(RecipesLoaded(recipes));
    } catch (e) {
      emit(RecipeError("Failed to fetch all recipes: ${e.toString()}"));
    }
  }

  Future<void> fetchRecipesByCategory(String categoryId) async {
    emit(RecipeLoading());
    try {
      final recipes = await recipeRepo.getRecipesByCategory(categoryId);
      emit(RecipesLoaded(recipes));
    } catch (e) {
      emit(RecipeError("Failed to fetch recipes for category $categoryId: ${e.toString()}"));
    }
  }

  Future<void> fetchRecipeById(String recipeId) async {
    emit(RecipeLoading());
    try {
      final recipe = await recipeRepo.getRecipeById(recipeId);
      if (recipe != null) {
        emit(RecipeDetailLoaded(recipe));
      } else {
        emit(RecipeError("Recipe with ID $recipeId not found."));
      }
    } catch (e) {
      emit(RecipeError("Failed to fetch recipe $recipeId: ${e.toString()}"));
    }
  }

  Future<void> searchRecipes(String query) async {
    emit(RecipeLoading());
    try {
      final recipes = await recipeRepo.searchRecipes(query);
      emit(RecipesLoaded(recipes));
    } catch (e) {
      emit(RecipeError("Failed to search recipes: ${e.toString()}"));
    }
  }
}

