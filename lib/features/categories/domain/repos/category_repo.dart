import 'package:recipe_app/features/categories/domain/entities/category.dart';

abstract class CategoryRepo {
  Future<List<Category>> getAllCategories();
  // Future<List<Category>> searchCategories(String query);
}
