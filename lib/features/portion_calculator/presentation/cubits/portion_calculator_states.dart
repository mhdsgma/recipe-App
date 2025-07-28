import 'package:equatable/equatable.dart';
import 'package:recipe_app/features/portion_calculator/domain/utils/ingredient_parser.dart';
abstract class PortionCalculatorState extends Equatable {
  const PortionCalculatorState();

  @override
  List<Object?> get props => [];
}

class PortionCalculatorInitial extends PortionCalculatorState {
  final int initialServings;

  const PortionCalculatorInitial(this.initialServings);

  @override
  List<Object?> get props => [initialServings];

  List? get initialScaledIngredients => null;
}

class PortionCalculatorUpdated extends PortionCalculatorState {
  final int currentServings;
  final List<ParsedIngredient> originalIngredients;
  final List<ParsedIngredient> scaledIngredients;
  final double scaleFactor;

  const PortionCalculatorUpdated({
    required this.currentServings,
    required this.originalIngredients,
    required this.scaledIngredients,
    required this.scaleFactor,
  });

  @override
  List<Object?> get props => [currentServings, originalIngredients, scaledIngredients, scaleFactor];
}

class PortionCalculatorError extends PortionCalculatorState {
  final String message;

  const PortionCalculatorError(this.message);

  @override
  List<Object?> get props => [message];
}

