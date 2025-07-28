import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:recipe_app/features/portion_calculator/presentation/cubits/portion_calculator_cubit.dart';
import 'package:recipe_app/features/portion_calculator/presentation/cubits/portion_calculator_states.dart';
import 'package:recipe_app/features/recipe/domain/entities/recipe.dart';

class PortionCalculatorPage extends StatelessWidget {
  final Recipe recipe;

  const PortionCalculatorPage({super.key, required this.recipe});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => PortionCalculatorCubit(recipe: recipe),
      child: Scaffold(
        backgroundColor: Theme.of(context).colorScheme.surface,
        appBar: AppBar(
          backgroundColor: Theme.of(context).colorScheme.secondary,
          iconTheme: const IconThemeData(color: Colors.white, size: 45),
          title: Text(
            'Adjust portions: ${recipe.name}',
            style: TextStyle(
              color: Theme.of(context).colorScheme.inversePrimary,
            ),
          ),
          centerTitle: true,
          elevation: 2,
        ),
        body: BlocBuilder<PortionCalculatorCubit, PortionCalculatorState>(
          builder: (context, state) {
            if (state is PortionCalculatorUpdated) {
              return Column(
                children: [
                  _buildServingSelector(context, state.currentServings),
                  const SizedBox(height: 8),
                  Expanded(
                    child: _buildIngredientList(state.scaledIngredients),
                  ),
                ],
              );
            }
            if (state is PortionCalculatorInitial) {
              return Column(
                children: [
                  _buildServingSelector(context, state.initialServings),
                  const Expanded(
                    child: Center(child: CircularProgressIndicator()),
                  ),
                ],
              );
            }
            if (state is PortionCalculatorError) {
              return Center(child: Text('Fehler: ${state.message}'));
            }
            return const Center(child: CircularProgressIndicator());
          },
        ),
      ),
    );
  }

  Widget _buildServingSelector(BuildContext context, int currentServings) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.secondary,
        borderRadius: BorderRadius.circular(24),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 6, offset: Offset(0, 3)),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.restaurant_menu_rounded, color: Colors.orange),
          const SizedBox(width: 8),
          Text(
            'Servings:',
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
          ),
          const SizedBox(width: 16),
          _circleButton(
            icon: Icons.remove,
            color: Colors.redAccent,
            onPressed:
                currentServings > 1
                    ? () => context
                        .read<PortionCalculatorCubit>()
                        .updateServings(currentServings - 1)
                    : null,
          ),
          const SizedBox(width: 16),
          Text(
            '$currentServings',
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(width: 16),
          _circleButton(
            icon: Icons.add,
            color: Colors.green,
            onPressed:
                () => context.read<PortionCalculatorCubit>().updateServings(
                  currentServings + 1,
                ),
          ),
        ],
      ),
    );
  }

  Widget _circleButton({
    required IconData icon,
    required Color color,
    VoidCallback? onPressed,
  }) {
    return CircleAvatar(
      radius: 22,
      backgroundColor: color,
      child: IconButton(
        icon: Icon(icon, color: Colors.white),
        onPressed: onPressed,
      ),
    );
  }

  Widget _buildIngredientList(List<dynamic> scaledIngredients) {
    if (scaledIngredients.isEmpty) {
      return const Center(child: Text("Keine Zutaten vorhanden."));
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      itemCount: scaledIngredients.length,
      itemBuilder: (context, index) {
        final ingredient = scaledIngredients[index];
        final formattedIngredient = ingredient.format();

        return Card(
          color: Theme.of(context).colorScheme.secondary,
          elevation: 3,
          margin: const EdgeInsets.symmetric(vertical: 6),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: ListTile(
            leading: const Icon(
              Icons.food_bank_rounded,
              color: Colors.orangeAccent,
            ),
            title: Text(
              formattedIngredient,
              style: Theme.of(
                context,
              ).textTheme.bodyLarge?.copyWith(fontSize: 16),
            ),
          ),
        );
      },
    );
  }
}
