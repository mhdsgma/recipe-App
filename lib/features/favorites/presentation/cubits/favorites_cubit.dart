import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:recipe_app/features/favorites/domain/repos/favorites_repo.dart';
import 'package:recipe_app/features/favorites/presentation/cubits/favorites_states.dart';
import 'package:recipe_app/features/recipe/domain/entities/recipe.dart';
import '../../../recipe/domain/entities/recipe_repo.dart';

class FavoritesCubit extends Cubit<FavoritesState> {
  final FavoritesRepo favoritesRepo;
  final RecipeRepo recipeRepo;
  StreamSubscription? _favoritesSubscription;
  List<String> _currentFavoriteIds = [];

  FavoritesCubit({required this.favoritesRepo, required this.recipeRepo})
      : super(FavoritesInitial()) {
    _listenToFavorites();
  }

  void _listenToFavorites() {
    _favoritesSubscription?.cancel();
    try {
      _favoritesSubscription = favoritesRepo.getFavoritesStream().listen((ids) {
        _currentFavoriteIds = ids;

        fetchFavoriteRecipes();
      }, onError: (error) {
        emit(FavoritesError("Error listening to favorites: ${error.toString()}"));
      });
    } catch (e) {
      emit(FavoritesError("Failed to start listening to favorites: ${e.toString()}"));
    }
  }

  Future<void> toggleFavorite(String recipeId) async {
    try {
      final isCurrentlyFavorite = _currentFavoriteIds.contains(recipeId);
      if (isCurrentlyFavorite) {
        await favoritesRepo.removeFavorite(recipeId);
      } else {
        await favoritesRepo.addFavorite(recipeId);
      }
      emit(IsFavoriteStatus(recipeId, !isCurrentlyFavorite));
      await fetchFavoriteRecipes();
    } catch (e) {
      emit(FavoritesError("Failed to toggle favorite status for $recipeId: "+e.toString()));
    }
  }

  Future<void> checkIfFavorite(String recipeId) async {
    final isFav = _currentFavoriteIds.contains(recipeId);
    emit(IsFavoriteStatus(recipeId, isFav));
  }

  Future<void> fetchFavoriteRecipes() async {
    print('==> fetchFavoriteRecipes() wurde aufgerufen!');
    emit(FavoritesLoading());
    try {
      final ids = await favoritesRepo.getFavoriteRecipeIds();
      print('IDs aus DB: $ids');
      if (ids.isEmpty) {
        print('Keine Favoriten gefunden');
        emit(const FavoriteRecipesLoaded([]));
        return;
      }
      print('Starte das Laden der Rezepte...');
      List<Future<Recipe?>> recipeFutures = ids.map((id) => recipeRepo.getRecipeById(id)).toList();
      List<Recipe?> recipes = await Future.wait(recipeFutures);
      print('Ergebnis von Future.wait: $recipes');
      List<Recipe> favoriteRecipes = recipes.where((recipe) => recipe != null).cast<Recipe>().toList();
      print('Gefilterte Favoriten: $favoriteRecipes');
      emit(FavoriteRecipesLoaded(favoriteRecipes));
    } catch (e) {
      print('Fehler beim Laden der Favoriten: $e');
      emit(FavoritesError("Failed to fetch favorite recipes: ${e.toString()}"));
    }
  }

  void reset() {
    emit(FavoritesInitial());
  }

  @override
  Future<void> close() {
    _favoritesSubscription?.cancel();
    return super.close();
  }
}

