import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:recipe_app/features/categories/presentation/components/category_tile.dart';
import 'package:recipe_app/features/categories/presentation/cubits/category_cubit.dart';
import 'package:recipe_app/features/categories/presentation/cubits/category_states.dart';
import 'package:recipe_app/features/recipe/data/firebase_recipe_repo.dart';
import 'package:recipe_app/features/recipe/domain/entities/recipe.dart';
import 'package:recipe_app/features/recipe/presentation/components/recipe_card.dart';

class CategoriesPage extends StatefulWidget {
  const CategoriesPage({super.key});

  @override
  State<CategoriesPage> createState() => _CategoriesPageState();
}

class _CategoriesPageState extends State<CategoriesPage> with SingleTickerProviderStateMixin {
  String _searchText = '';
  final TextEditingController _searchController = TextEditingController();

  List<Recipe> _searchedCategoryRecipes = [];
  List<Recipe> _searchedRecipeResults = [];
  bool _loadingCategoryRecipes = false;
  bool _loadingRecipeResults = false;
  String? _lastSearchedCategoryId;
  String? _lastRecipeQuery;

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    context.read<CategoryCubit>().fetchCategories();
    _searchController.text = _searchText;

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeIn,
      ),
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _onSearchTextChanged(String value, List filteredCategories) {
    print('Suchtext geändert: $value');
    setState(() {
      _searchText = value;
    });
    // Rezepte nach Name suchen (immer, unabhängig von Kategorien)
    if (value.isNotEmpty) {
      print('Starte Rezeptsuche für: $value');
      _searchRecipesByName(value);
    } else {
      setState(() {
        _searchedRecipeResults = [];
        _lastRecipeQuery = null;
      });
    }

    if (filteredCategories.length == 1) {
      final category = filteredCategories.first;
      if (_lastSearchedCategoryId != category.id) {
        print('Lade Rezepte für Kategorie: ${category.name}');
        _loadRecipesForCategory(category.id);
      }
    } else {
      setState(() {
        _searchedCategoryRecipes = [];
        _lastSearchedCategoryId = null;
      });
    }
  }

  Future<void> _loadRecipesForCategory(String categoryId) async {
    setState(() {
      _loadingCategoryRecipes = true;
      _searchedCategoryRecipes = [];
      _lastSearchedCategoryId = categoryId;
    });
    final repo = FirebaseRecipeRepo();
    final recipes = await repo.getRecipesByCategory(categoryId);
    setState(() {
      _searchedCategoryRecipes = recipes;
      _loadingCategoryRecipes = false;
    });
  }

  Future<void> _searchRecipesByName(String query) async {
    if (_lastRecipeQuery == query) return;
    setState(() {
      _loadingRecipeResults = true;
      _searchedRecipeResults = [];
      _lastRecipeQuery = query;
    });
    final repo = FirebaseRecipeRepo();
    final recipes = await repo.searchRecipes(query);
    print('Gefundene Rezepte für "$query": ${recipes.map((r) => r.name).toList()}');
    setState(() {
      _searchedRecipeResults = recipes;
      _loadingRecipeResults = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.secondary,
      appBar: AppBar(
        title: const Text('Categories'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                BlocBuilder<CategoryCubit, CategoryState>(
                  builder: (context, state) {
                    List filteredCategories = [];
                    if (state is CategoriesLoaded) {
                      filteredCategories = state.categories
                          .where((category) => category.name.toLowerCase().contains(_searchText.toLowerCase()))
                          .toList();
                    }
                    return Material(
                      elevation: 3,
                      borderRadius: BorderRadius.circular(18),
                      child: TextField(
                        controller: _searchController,
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: Theme.of(context).brightness == Brightness.dark
                              ? Colors.grey[900]
                              : Theme.of(context).colorScheme.surface,
                          hintText: 'Search categories or recipes...',
                          hintStyle: TextStyle(
                            color: Theme.of(context).brightness == Brightness.dark
                                ? Colors.white54
                                : Colors.black38,
                          ),
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
                        style: TextStyle(
                          fontSize: 17,
                          color: Theme.of(context).brightness == Brightness.dark
                              ? Colors.white
                              : Colors.black87,
                        ),
                        onChanged: (value) => _onSearchTextChanged(value, filteredCategories),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
          Expanded(
            child: BlocBuilder<CategoryCubit, CategoryState>(
              builder: (context, state) {
                if (_searchText.isNotEmpty) {
                  List filteredCategories = [];
                  if (state is CategoriesLoaded) {
                    filteredCategories = state.categories
                        .where((category) => category.name.toLowerCase().contains(_searchText.toLowerCase()))
                        .toList();
                  }
                  final hasCategories = filteredCategories.isNotEmpty;
                  final hasRecipes = _searchedRecipeResults.isNotEmpty;
                  final isLoading = _loadingRecipeResults || _loadingCategoryRecipes;
                  final nothingFound = !hasCategories && !hasRecipes && !isLoading;
                  final showCategoryRecipes = filteredCategories.length == 1;
                  return ListView(
                    children: [
                      if (hasCategories)
                        ...filteredCategories.map((category) => Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16.0,
                            vertical: 8.0,
                          ),
                          child: CategoryTile(category: category, isSingleResult: filteredCategories.length == 1),
                        )),
                      if (showCategoryRecipes && _loadingCategoryRecipes)
                        const Center(child: CircularProgressIndicator()),
                      if (showCategoryRecipes && !_loadingCategoryRecipes && _searchedCategoryRecipes.isEmpty)
                        const Center(child: Text("Keine Gerichte in dieser Kategorie.")),
                      if (showCategoryRecipes)
                        ..._searchedCategoryRecipes.map((recipe) => RecipeCard(recipe: recipe)).toList(),
                      if (_loadingRecipeResults)
                        const Center(child: CircularProgressIndicator()),
                      if (hasRecipes)
                        ..._searchedRecipeResults
                          .where((recipe) => !showCategoryRecipes || !_searchedCategoryRecipes.any((catRecipe) => catRecipe.id == recipe.id))
                          .map((recipe) => RecipeCard(recipe: recipe)).toList(),
                      if (nothingFound)
                        const Center(child: Padding(
                          padding: EdgeInsets.only(top: 32.0),
                          child: Text("Keine Ergebnisse gefunden.", style: TextStyle(fontSize: 18)),
                        )),
                    ],
                  );
                }
                // Standardanzeige: Kategorienliste
                if (state is CategoryLoading) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (state is CategoriesLoaded) {
                  if (state.categories.isEmpty) {
                    return const Center(child: Text("Keine Kategorien gefunden."));
                  }
                  return CustomScrollView(
                    slivers: [
                      SliverList(
                        delegate: SliverChildBuilderDelegate((context, index) {
                          final category = state.categories[index];
                          return Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16.0,
                              vertical: 8.0,
                            ),
                            child: CategoryTile(category: category),
                          );
                        }, childCount: state.categories.length),
                      ),
                    ],
                  );
                }
                if (state is CategoryError) {
                  return Center(child: Text("Fehler: ${state.message}"));
                }
                return const Center(child: Text("Lade Kategorien..."));
              },
            ),
          ),
        ],
      ),
    );
  }
}
