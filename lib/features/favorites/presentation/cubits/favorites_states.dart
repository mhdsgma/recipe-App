import 'package:equatable/equatable.dart';
import 'package:recipe_app/features/recipe/domain/entities/recipe.dart';


abstract class FavoritesState extends Equatable {
  const FavoritesState();

  @override
  List<Object?> get props => [];
}

class FavoritesInitial extends FavoritesState {}

class FavoritesLoading extends FavoritesState {}


class FavoriteIdsLoaded extends FavoritesState {
  final List<String> favoriteIds;
  const FavoriteIdsLoaded(this.favoriteIds);
  @override
  List<Object?> get props => [favoriteIds];
}

class FavoriteRecipesLoaded extends FavoritesState {
  final List<Recipe> favoriteRecipes;
  const FavoriteRecipesLoaded(this.favoriteRecipes);
  @override
  List<Object?> get props => [favoriteRecipes];
}

class IsFavoriteStatus extends FavoritesState {
  final String recipeId;
  final bool isFavorite;
  const IsFavoriteStatus(this.recipeId, this.isFavorite);
  @override
  List<Object?> get props => [recipeId, isFavorite];
}

class FavoritesError extends FavoritesState {
  final String message;
  const FavoritesError(this.message);
  @override
  List<Object?> get props => [message];
}
