import 'package:flutter/material.dart';
import 'package:recipe_app/features/categories/presentation/pages/categories_page.dart';
import 'package:recipe_app/features/favorites/presentation/pages/favorites_page.dart';
import 'package:recipe_app/features/home/presentation/components/my_drawer.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../favorites/presentation/cubits/favorites_cubit.dart';
import '../../../favorites/data/firebase_favorites_repo.dart';
import '../../../recipe/data/firebase_recipe_repo.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    CategoriesPage(),
    BlocProvider<FavoritesCubit>(
      create: (context) => FavoritesCubit(
        favoritesRepo: FirebaseFavoritesRepo(),
        recipeRepo: FirebaseRecipeRepo(),
      ),
      child: FavoritesPage(),
    ),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    if (index == 1) {
      Future.delayed(Duration.zero, () {
        context.read<FavoritesCubit>().fetchFavoriteRecipes();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Padding(
          padding: const EdgeInsets.only(top: 30.0),
          child: const Text(
            "Home",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 32,
              color: Colors.white,
            ),
          ),
        ),
        centerTitle: true,
      ),
      drawer: const MyDrawer(),
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        selectedItemColor: Colors.deepPurple,
        unselectedItemColor: Colors.grey,
        backgroundColor: Theme.of(context).colorScheme.tertiary,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.category),
            label: 'Categories',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.favorite),
            label: 'Favorites',
          ),
        ],
      ),
    );
  }
}
