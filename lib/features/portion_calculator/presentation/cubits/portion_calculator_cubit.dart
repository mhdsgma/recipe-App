import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:recipe_app/features/portion_calculator/domain/utils/ingredient_parser.dart';
import 'package:recipe_app/features/portion_calculator/presentation/cubits/portion_calculator_states.dart';
import 'package:recipe_app/features/recipe/domain/entities/recipe.dart';
class PortionCalculatorCubit extends Cubit<PortionCalculatorState> {
  final Recipe recipe;
  late final List<ParsedIngredient> _originalParsedIngredients;
  late final int _originalServings;

  PortionCalculatorCubit({required this.recipe})
      : super(PortionCalculatorInitial(recipe.servings ?? 1)) {
    _originalServings = recipe.servings ?? 1;
    _originalParsedIngredients = recipe.ingredients
        .map((ing) => IngredientParser.parse(ing))
        .toList();
    updateServings(_originalServings);
  }

  void updateServings(int newServings) {
    if (newServings <= 0) {
      newServings = 1;
    }

    try {
      final scaleFactor = newServings / _originalServings.toDouble();
      final scaledIngredients = _originalParsedIngredients
          .map((ing) => ing.scale(scaleFactor))
          .toList();

      emit(PortionCalculatorUpdated(
        currentServings: newServings,
        originalIngredients: _originalParsedIngredients,
        scaledIngredients: scaledIngredients,
        scaleFactor: scaleFactor,
      ));
    } catch (e) {
      emit(PortionCalculatorError("Error calculating portions: ${e.toString()}"));
      if (state is PortionCalculatorUpdated) {
        emit(state);
      } else {
        emit(PortionCalculatorInitial(_originalServings));
      }
    }
  }
}

