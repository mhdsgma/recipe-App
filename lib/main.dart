import 'dart:async';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:recipe_app/config/firebase_options.dart';
import 'app.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:recipe_app/features/favorites/presentation/cubits/favorites_cubit.dart';
import 'package:recipe_app/features/favorites/data/firebase_favorites_repo.dart';
import 'package:recipe_app/features/recipe/data/firebase_recipe_repo.dart';
import 'package:recipe_app/features/recipe/presentation/cubits/recipe_cubit.dart';

void main() {
  runZonedGuarded(
    () async {

      WidgetsFlutterBinding.ensureInitialized();
      try {
        await Firebase.initializeApp(
          options: DefaultFirebaseOptions.currentPlatform,
        );
      } catch (e) {
        print("!!! ERROR initializing Firebase: $e");
        print("!!! Stack trace: "+StackTrace.current.toString());
      }

      FlutterError.onError =
          FirebaseCrashlytics.instance.recordFlutterFatalError;
      runApp(
        MultiBlocProvider(
          providers: [
            BlocProvider<FavoritesCubit>(
              create: (context) => FavoritesCubit(
                favoritesRepo: FirebaseFavoritesRepo(),
                recipeRepo: FirebaseRecipeRepo(),
              ),
            ),
            BlocProvider<RecipeCubit>(
              create: (context) => RecipeCubit(
                recipeRepo: FirebaseRecipeRepo(),
              ),
            ),
          ],
          child: MyApp(),
        ),
      );
    },
    (error, stackTrace) {
      print("!!! FATAL ERROR: $error");
      print("!!! Stack trace: $stackTrace");
      FirebaseCrashlytics.instance.recordError(error, stackTrace, fatal: true);
    },
  );
}
