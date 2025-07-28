import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:recipe_app/features/favorites/presentation/cubits/favorites_cubit.dart';
import 'package:recipe_app/features/favorites/presentation/cubits/favorites_states.dart';
import 'package:recipe_app/features/recipe/presentation/components/recipe_card.dart';


class FavoritesPage extends StatefulWidget {
  const FavoritesPage({super.key});

  @override
  State<FavoritesPage> createState() => _FavoritesPageState();
}

class _FavoritesPageState extends State<FavoritesPage> {
  String _searchText = '';
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    context.read<FavoritesCubit>().fetchFavoriteRecipes();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.secondary,
      appBar: AppBar(
        title: const Text('Favorites'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Material(
              elevation: 3,
              borderRadius: BorderRadius.circular(18),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Theme.of(context).colorScheme.surface,
                  hintText: 'Search favorites...',
                  prefixIcon: Icon(Icons.search_rounded, color: Colors.deepPurple, size: 28),
                  contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 18),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(18.0),
                    borderSide: BorderSide.none,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(18.0),
                    borderSide: BorderSide(color: Colors.deepPurple, width: 2),
                  ),
                ),
                style: const TextStyle(fontSize: 18),
                onChanged: (value) {
                  setState(() {
                    _searchText = value;
                  });
                },
              ),
            ),
          ),
          Expanded(
            child: BlocBuilder<FavoritesCubit, FavoritesState>(
              builder: (context, state) {
                if (state is FavoritesInitial || state is FavoritesLoading) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (state is FavoriteRecipesLoaded) {
                  final filteredRecipes = state.favoriteRecipes
                      .where((recipe) => recipe.name.toLowerCase().contains(_searchText.toLowerCase()))
                      .toList();
                  if (filteredRecipes.isEmpty) {
                    return const Center(
                      child: Padding(
                        padding: EdgeInsets.all(16.0),
                        child: Text(
                          "No favorites found.",
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    );
                  }
                  return ListView.builder(
                    padding: const EdgeInsets.all(8.0),
                    itemCount: filteredRecipes.length,
                    itemBuilder: (context, index) {
                      final recipe = filteredRecipes[index];
                      return RecipeCard(recipe: recipe, replaceRoute: false);
                    },
                  );
                }
                if (state is FavoritesError) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Text(
                        "Error loading favorites: "+state.message,
                        textAlign: TextAlign.center,
                      ),
                    ),
                  );
                }
                // Fallback
                return const Center(child: CircularProgressIndicator());
              },
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    context.read<FavoritesCubit>().reset();
    super.dispose();
  }
}
