import 'package:equatable/equatable.dart';
import 'package:recipe_app/features/recipe/domain/entities/recipe.dart';

abstract class RecipeState extends Equatable {
  const RecipeState();

  @override
  List<Object?> get props => [];
}

class RecipeInitial extends RecipeState {}

class RecipeLoading extends RecipeState {}

class RecipesLoaded extends RecipeState {
  final List<Recipe> recipes;

  const RecipesLoaded(this.recipes);

  @override
  List<Object?> get props => [recipes];
}

class RecipeDetailLoaded extends RecipeState {
  final Recipe recipe;

  const RecipeDetailLoaded(this.recipe);

  @override
  List<Object?> get props => [recipe];
}

class RecipeError extends RecipeState {
  final String message;

  const RecipeError(this.message);

  @override
  List<Object?> get props => [message];
}
