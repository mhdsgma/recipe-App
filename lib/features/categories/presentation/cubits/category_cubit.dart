import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:recipe_app/features/categories/domain/repos/category_repo.dart';
import 'package:recipe_app/features/categories/presentation/cubits/category_states.dart';

class CategoryCubit extends Cubit<CategoryState> {
  final CategoryRepo categoryRepo;

  CategoryCubit({required this.categoryRepo}) : super(CategoryInitial());

  Future<void> fetchCategories() async {
    print("--- CategoryCubit: Starting to fetch categories ---");
    emit(CategoryLoading());
    try {
      print("--- CategoryCubit: Calling categoryRepo.getAllCategories() ---");
      final categories = await categoryRepo.getAllCategories();
      print("--- CategoryCubit: Received ${categories.length} categories ---");
      if (categories.isEmpty) {
        print("!!! WARNING: No categories returned from repository !!!");
      } else {
        print("--- CategoryCubit: Categories received: ${categories.map((c) => c.name).join(', ')} ---");
      }
      emit(CategoriesLoaded(categories));
    } catch (e) {
      print("!!! ERROR in CategoryCubit: $e");
      emit(CategoryError("Failed to fetch categories: ${e.toString()}"));
    }
  }

  // Future<void> searchCategories(String query) async {
  //   ...
  // }
}

