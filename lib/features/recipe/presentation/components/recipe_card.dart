import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:recipe_app/features/recipe/domain/entities/recipe.dart';

import '../../../favorites/presentation/cubits/favorites_cubit.dart';
import '../cubits/recipe_cubit.dart';
import '../pages/recipe_detail_page.dart';

class RecipeCard extends StatelessWidget {
  final Recipe recipe;
  final bool replaceRoute;

  const RecipeCard({
    super.key,
    required this.recipe,
    this.replaceRoute = false,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 10,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () {
          final recipeCubit = BlocProvider.of<RecipeCubit>(context);
          if (replaceRoute) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => RecipeDetailPage(recipeId: recipe.id),
              ),
            );
          } else {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => RecipeDetailPage(recipeId: recipe.id),
              ),
            ).then((_) {
              // Nach Rückkehr aus der Detailansicht Favoriten neu laden, falls vorhanden
              try {
                final cubit = BlocProvider.of<FavoritesCubit>(
                  context,
                  listen: false,
                );
                cubit.fetchFavoriteRecipes();
              } catch (e) {
                // Bloc nicht gefunden, nichts tun
              }
            });
          }
        },
        child: Stack(
          children: [
            // Rezeptbild mit Hero-Animation
            Hero(
              tag: 'recipe-image-${recipe.id}',
              child:
                  recipe.imageUrl.isNotEmpty
                      ? Image.asset(
                        recipe.imageUrl,
                        height: 180,
                        width: double.infinity,
                        fit: BoxFit.cover,
                      )
                      : Container(
                        height: 180,
                        width: double.infinity,
                        color: Colors.grey[300],
                        child: const Center(
                          child: Icon(
                            Icons.image_not_supported,
                            color: Colors.grey,
                            size: 50,
                          ),
                        ),
                      ),
            ),
            // Gericht-Icon oben rechts
            Positioned(
              top: 12,
              right: 18,
              child: Icon(Icons.restaurant_menu, color: Colors.deepOrange, size: 32),
            ),
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.black.withAlpha(1), Colors.transparent],
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                  ),
                ),
              ),
            ),
            // Text-Overlay
            Positioned(
              left: 16,
              right: 16,
              bottom: 18,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    recipe.name,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      shadows: [Shadow(blurRadius: 8, color: Colors.black)],
                    ),
                  ),
                  if (recipe.description.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 4.0),
                      child: Text(
                        recipe.description,
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 15,
                          shadows: [Shadow(blurRadius: 8, color: Colors.black)],
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
