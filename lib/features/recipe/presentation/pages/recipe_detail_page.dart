import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:recipe_app/features/favorites/presentation/cubits/favorites_cubit.dart';
import 'package:recipe_app/features/favorites/presentation/cubits/favorites_states.dart';
import 'package:recipe_app/features/portion_calculator/presentation/pages/portion_calculator_page.dart';
import 'package:recipe_app/features/recipe/domain/entities/recipe.dart';
import 'package:recipe_app/features/recipe/presentation/cubits/recipe_cubit.dart';
import 'package:recipe_app/features/recipe/presentation/cubits/recipe_states.dart';
import 'package:url_launcher/url_launcher.dart';

class RecipeDetailPage extends StatefulWidget {
  final String recipeId;

  const RecipeDetailPage({super.key, required this.recipeId});

  @override
  State<RecipeDetailPage> createState() => _RecipeDetailPageState();
}

class _RecipeDetailPageState extends State<RecipeDetailPage> {
  @override
  void initState() {
    super.initState();
    context.read<RecipeCubit>().fetchRecipeById(widget.recipeId);
    context.read<FavoritesCubit>().checkIfFavorite(widget.recipeId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: BlocBuilder<RecipeCubit, RecipeState>(
        builder: (context, recipeState) {
          if (recipeState is RecipeLoading &&
              recipeState is! RecipeDetailLoaded) {
            return const Center(child: CircularProgressIndicator());
          }
          if (recipeState is RecipeDetailLoaded) {
            final recipe = recipeState.recipe;
            return CustomScrollView(
              slivers: [
                SliverAppBar(
                  expandedHeight: 280.0,
                  pinned: true,
                  backgroundColor: const Color(0xFFFAAB36),
                  leading: Padding(
                    padding: const EdgeInsets.only(left: 12.0),
                    child: IconButton(
                      icon: const Icon(
                        Icons.arrow_back,
                        color: Colors.white,
                        size: 42,
                      ),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ),
                  flexibleSpace: FlexibleSpaceBar(
                    centerTitle: true,
                    title: Text(
                      recipe.name,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 26,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        shadows: [
                          Shadow(blurRadius: 4.0, color: Colors.black87),
                        ],
                      ),
                    ),
                    background:
                        recipe.imageUrl.isNotEmpty
                            ? Stack(
                              fit: StackFit.expand,
                              children: [
                                Image.asset(
                                  recipe.imageUrl,
                                  fit: BoxFit.cover,
                                  errorBuilder:
                                      (context, error, stackTrace) => Container(
                                        color: Colors.grey,
                                        child: const Center(
                                          child: Icon(Icons.broken_image),
                                        ),
                                      ),
                                ),

                                Container(
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      begin: Alignment.topCenter,
                                      end: Alignment.bottomCenter,
                                      colors: [
                                        Colors.black.withAlpha(150),
                                        Colors.transparent,
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            )
                            : Container(
                              color: Colors.grey,
                              child: const Center(
                                child: Icon(Icons.image_not_supported),
                              ),
                            ),
                  ),
                  actions: [
                    // Favorite Button
                    Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: BlocBuilder<FavoritesCubit, FavoritesState>(
                        buildWhen: (previous, current) {
                          if (current is IsFavoriteStatus &&
                              current.recipeId == widget.recipeId) {
                            return true;
                          }
                          if (current is FavoriteIdsLoaded) return true;
                          return false;
                        },
                        builder: (context, favState) {
                          bool isFavorite = false;
                          if (favState is IsFavoriteStatus &&
                              favState.recipeId == widget.recipeId) {
                            isFavorite = favState.isFavorite;
                          } else if (favState is FavoriteIdsLoaded) {
                            isFavorite = favState.favoriteIds.contains(
                              widget.recipeId,
                            );
                          }
                          return IconButton(
                            icon: Icon(
                              isFavorite
                                  ? Icons.favorite
                                  : Icons.favorite_border,
                              size: 35,
                              color: isFavorite ? Colors.red : Colors.white,
                            ),
                            tooltip:
                                isFavorite
                                    ? 'Entfernen aus Favoriten'
                                    : 'Zu Favoriten hinzufügen',
                            onPressed: () {
                              context.read<FavoritesCubit>().toggleFavorite(
                                widget.recipeId,
                              );
                            },
                          );
                        },
                      ),
                    ),

                    // WhatsApp Share Button
                    Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: IconButton(
                        icon: const FaIcon(
                          FontAwesomeIcons.whatsapp,
                          size: 30,
                          color: Colors.white,
                        ),
                        tooltip: 'Whatsapp share',
                        onPressed: () async {
                          final message =
                              "I found this recipe cool, you might also: ${recipe.name}";
                          final url = Uri.parse(
                            "whatsapp://send?text=${Uri.encodeComponent(message)}",
                          );

                          if (await canLaunchUrl(url)) {
                            await launchUrl(
                              url,
                              mode: LaunchMode.externalApplication,
                            );
                          } else {
                            showDialog(
                              context: context,
                              builder: (context) {
                                return AlertDialog(
                                  backgroundColor:
                                      Colors
                                          .orange
                                          .shade50, // Custom background color
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(
                                      20,
                                    ), // Rounded corners
                                  ),
                                  title: const Text(
                                    'Oops!',
                                    style: TextStyle(
                                      color: Colors.deepOrange, // Title color
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  content: const Text(
                                    "WhatsApp is not installed on your device.",
                                    style: TextStyle(
                                      color:
                                          Colors.black87, // Content text color
                                    ),
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed:
                                          () => Navigator.of(context).pop(),
                                      child: const Text(
                                        'OK',
                                        style: TextStyle(
                                          color: Colors.deepOrange,
                                        ), // Button color
                                      ),
                                    ),
                                  ],
                                );
                              },
                            );
                          }
                        },
                      ),
                    ),

                    // Portion Calculator Button
                    Padding(
                      padding: const EdgeInsets.only(right: 12.0),
                      child: IconButton(
                        icon: const Icon(
                          Icons.restaurant_menu_rounded,
                          size: 35,
                          color: Colors.white,
                        ),
                        tooltip: 'Portionen anpassen',
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder:
                                  (context) =>
                                      PortionCalculatorPage(recipe: recipe),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
                SliverList(
                  delegate: SliverChildListDelegate([
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (recipe.description.isNotEmpty)
                            Padding(
                              padding: const EdgeInsets.only(bottom: 16.0),
                              child: Text(
                                recipe.description,
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                            ),
                          _buildInfoRow(context, recipe),
                          const SizedBox(height: 16.0),
                          Text(
                            "ingredients",
                            style: Theme.of(context).textTheme.titleLarge!
                                .copyWith(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 8.0),
                          _buildIngredientList(recipe.ingredients),
                          const SizedBox(height: 16.0),
                          Text(
                            "Instructions",
                            style: Theme.of(context).textTheme.titleLarge!
                                .copyWith(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 8.0),
                          _buildInstructionList(recipe.instructions),
                        ],
                      ),
                    ),
                  ]),
                ),
              ],
            );
          }
          if (recipeState is RecipeError) {
            return Center(child: Text("Fehler: ${recipeState.message}"));
          }
          return const Center(child: Text("Lade Rezeptdetails..."));
        },
      ),
    );
  }

  Widget _buildInfoRow(BuildContext context, Recipe recipe) {
    List<Widget> infoWidgets = [];
    if (recipe.prepTimeMinutes != null) {
      infoWidgets.add(
        _infoChip(
          context,
          Icons.schedule_rounded,
          '${recipe.prepTimeMinutes} Min Prep Time',
        ),
      );
    }
    if (recipe.cookTimeMinutes != null) {
      infoWidgets.add(
        _infoChip(
          context,
          Icons.local_fire_department_rounded,
          '${recipe.cookTimeMinutes}  Min Cook Time',
        ),
      );
    }
    if (recipe.servings != null) {
      infoWidgets.add(
        _infoChip(context, Icons.groups_2, '${recipe.servings} Servings'),
      );
    }
    if (infoWidgets.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Wrap(spacing: 12.0, runSpacing: 6.0, children: infoWidgets),
    );
  }

  Widget _infoChip(BuildContext context, IconData icon, String label) {
    return Chip(
      avatar: Icon(icon, size: 20, color: Colors.deepOrange),
      label: Text(label),
      backgroundColor: Colors.deepOrangeAccent.withAlpha(20),
      padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 6.0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
    );
  }

  Widget _buildIngredientList(List<String> ingredients) {
    if (ingredients.isEmpty) return const Text("Keine Zutaten aufgelistet.");
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children:
          ingredients
              .map(
                (ingredient) => Card(
                  margin: const EdgeInsets.symmetric(vertical: 4.0),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  color: Theme.of(context).colorScheme.secondary,
                  elevation: 2,
                  child: ListTile(
                    leading: const Icon(
                      Icons.food_bank_rounded,
                      color: Colors.orange,
                    ),
                    title: Text(ingredient),
                  ),
                ),
              )
              .toList(),
    );
  }

  Widget _buildInstructionList(List<String> instructions) {
    if (instructions.isEmpty) return const Text("Keine Anweisungen vorhanden.");
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: List.generate(
        instructions.length,
        (index) => Card(
          margin: const EdgeInsets.symmetric(vertical: 6.0),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          color: Theme.of(context).colorScheme.secondary,
          elevation: 2,
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: Colors.orangeAccent,
              child: Text(
                '${index + 1}',
                style: const TextStyle(color: Colors.white),
              ),
            ),
            title: Text(instructions[index]),
          ),
        ),
      ),
    );
  }
}
