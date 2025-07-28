
abstract class FavoritesRepo {

  Future<List<String>> getFavoriteRecipeIds();


  Future<void> addFavorite(String recipeId);


  Future<void> removeFavorite(String recipeId);


  Future<bool> isFavorite(String recipeId);

  Stream<List<String>> getFavoritesStream();
}

