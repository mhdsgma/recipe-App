import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:recipe_app/features/recipe/presentation/components/recipe_card.dart';
import 'package:recipe_app/features/recipe/presentation/cubits/recipe_cubit.dart';
import 'package:recipe_app/features/recipe/presentation/cubits/recipe_states.dart';

enum RecipeListType { all, category, search, favorites }

class RecipeListPage extends StatefulWidget {
  final RecipeListType type;
  final String? categoryId;
  final String? searchQuery;
  final String? pageTitle;

  const RecipeListPage({
    super.key,
    required this.type,
    this.categoryId,
    this.searchQuery,
    this.pageTitle,
    required String categoryName,
  }) : assert(
         (type == RecipeListType.category && categoryId != null) ||
             (type == RecipeListType.search && searchQuery != null) ||
             (type == RecipeListType.all) ||
             (type == RecipeListType.favorites), // Added for future use
       );

  @override
  State<RecipeListPage> createState() => _RecipeListPageState();
}

class _RecipeListPageState extends State<RecipeListPage> {
  @override
  void initState() {
    super.initState();
    final recipeCubit = context.read<RecipeCubit>();
    if (widget.type == RecipeListType.category) {
      recipeCubit.fetchRecipesByCategory(widget.categoryId!);
    } else if (widget.type == RecipeListType.search) {
      recipeCubit.searchRecipes(widget.searchQuery!);
    } else if (widget.type == RecipeListType.all) {
      recipeCubit.fetchAllRecipes();
    } else if (widget.type == RecipeListType.favorites) {}
  }

  @override
  Widget build(BuildContext context) {
    final isCategory = widget.type == RecipeListType.category;
    final categoryId = widget.categoryId;
    final categoryName = widget.pageTitle;
    final categoryImageUrl =
        ModalRoute.of(context)?.settings.arguments is Map
            ? (ModalRoute.of(context)!.settings.arguments as Map)["imageUrl"]
                as String?
            : null;
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.secondary,
      body: CustomScrollView(
        slivers: [
          if (isCategory && categoryId != null)
            SliverAppBar(
              pinned: true,
              expandedHeight: 200,
              backgroundColor: const Color(0xFFFFA726),
              leading: IconButton(
                icon: Stack(
                  children: [
                    Icon(Icons.arrow_back, color: Colors.white, size: 42),
                    Positioned(
                      left: 2,
                      top: 2,
                      child: Icon(
                        Icons.arrow_back,
                        color: Colors.white,
                        size: 36,
                      ),
                    ),
                  ],
                ),
                onPressed: () => Navigator.of(context).maybePop(),
                tooltip: 'Zurück',
              ),
              flexibleSpace: FlexibleSpaceBar(
                title: Text(
                  categoryName ?? '',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    shadows: [
                      Shadow(
                        blurRadius: 8.0,
                        color: Colors.black87,
                        offset: Offset(1.0, 1.0),
                      ),
                    ],
                  ),
                ),
                background: Hero(
                  tag: 'category-image-$categoryId',
                  child:
                      categoryImageUrl != null && categoryImageUrl.isNotEmpty
                          ? Image.asset(
                            categoryImageUrl,
                            fit: BoxFit.cover,
                            errorBuilder:
                                (context, error, stackTrace) => Container(
                                  color: Colors.grey,
                                  child: const Center(
                                    child: Icon(Icons.broken_image),
                                  ),
                                ),
                          )
                          : Container(
                            color: Colors.grey,
                            child: const Center(
                              child: Icon(Icons.image_not_supported),
                            ),
                          ),
                ),
                centerTitle: true,
              ),
            )
          else
            SliverAppBar(
              pinned: true,
              backgroundColor: const Color(0xFFFFA726),
              leading: IconButton(
                icon: Stack(
                  children: [
                    Icon(Icons.arrow_back, color: Colors.white, size: 42),
                    Positioned(
                      left: 2,
                      top: 2,
                      child: Icon(
                        Icons.arrow_back,
                        color: Colors.white,
                        size: 36,
                      ),
                    ),
                  ],
                ),
                onPressed: () => Navigator.of(context).maybePop(),
                tooltip: 'Zurück',
              ),
              title: Text(
                widget.pageTitle ?? _getDefaultTitle(),
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              centerTitle: true,
            ),
          BlocBuilder<RecipeCubit, RecipeState>(
            builder: (context, state) {
              if (state is RecipeLoading) {
                return const SliverFillRemaining(
                  child: Center(child: CircularProgressIndicator()),
                );
              }
              if (state is RecipesLoaded) {
                if (state.recipes.isEmpty) {
                  return const SliverFillRemaining(
                    child: Center(child: Text("No recipes found.")),
                  );
                }
                return SliverList(
                  delegate: SliverChildBuilderDelegate((context, index) {
                    final recipe = state.recipes[index];
                    bool shouldUseReplace =
                        (widget.type == RecipeListType.category ||
                            widget.type == RecipeListType.search);
                    return RecipeCard(
                      recipe: recipe,
                      replaceRoute: shouldUseReplace,
                    );
                  }, childCount: state.recipes.length),
                );
              }
              if (state is RecipeError) {
                return SliverFillRemaining(
                  child: Center(child: Text("Error: " + state.message)),
                );
              }
              return const SliverFillRemaining(
                child: Center(child: Text("Please fetch recipes.")),
              );
            },
          ),
        ],
      ),
    );
  }

  String _getDefaultTitle() {
    switch (widget.type) {
      case RecipeListType.category:
        return widget.pageTitle ?? "Category Recipes";
      case RecipeListType.search:
        return "Search Results";
      case RecipeListType.favorites:
        return "Favorites";
      case RecipeListType.all:
        return "All Recipes";
    }
  }
}
