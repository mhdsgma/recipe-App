import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:recipe_app/features/categories/domain/entities/category.dart';
import 'package:recipe_app/features/recipe/data/firebase_recipe_repo.dart';
import 'package:recipe_app/features/recipe/presentation/cubits/recipe_cubit.dart';
import 'package:recipe_app/features/recipe/presentation/pages/recipe_list_page.dart';

class CategoryTile extends StatelessWidget {
  final Category category;
  final bool isSingleResult;

  const CategoryTile({super.key, required this.category, this.isSingleResult = false});

  @override
  Widget build(BuildContext context) {
    final Color backgroundColor = category.color;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 8.0),
      child: GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              settings: RouteSettings(
                arguments: {"imageUrl": category.imageUrl},
              ),
              builder:
                  (context) => BlocProvider<RecipeCubit>(
                    create:
                        (context) =>
                            RecipeCubit(recipeRepo: FirebaseRecipeRepo()),
                    child: RecipeListPage(
                      type: RecipeListType.category,
                      categoryId: category.id,
                      pageTitle: category.name,
                      categoryName: '',
                    ),
                  ),
            ),
          );
        },
        child: Hero(
          tag: 'category-image-${category.id}',
          child: Material(
            elevation: 12,
            borderRadius: BorderRadius.circular(28),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(28),
              child: Stack(
                children: [
                  category.imageUrl.isNotEmpty
                      ? Image.asset(
                        category.imageUrl,
                        height: 180,
                        width: double.infinity,
                        fit: BoxFit.cover,
                      )
                      : Container(
                        height: 180,
                        width: double.infinity,
                        color: backgroundColor,
                      ),
                  Positioned.fill(
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.black.withOpacity(0.6),
                            Colors.transparent,
                          ],
                          begin: Alignment.bottomCenter,
                          end: Alignment.center,
                        ),
                      ),
                    ),
                  ),
                  // Icon oben rechts, wenn Einzelmodus
                  if (isSingleResult)
                    Positioned(
                      top: 12,
                      right: 18,
                      child: Icon(Icons.info_outline, color: Colors.orangeAccent, size: 32),
                    ),
                  // Text
                  Positioned(
                    left: 20,
                    right: 20,
                    bottom: 24,
                    child: Text(
                      category.name,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        shadows: [
                          Shadow(
                            blurRadius: 8.0,
                            color: Colors.black87,
                            offset: Offset(1.0, 1.0),
                          ),
                        ],
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
