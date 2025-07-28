import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:recipe_app/features/auth/data/firebase_auth_repo.dart';
import 'package:recipe_app/features/auth/data/offline_repo.dart';
import 'package:recipe_app/features/auth/domain/repos/auth_repo.dart';
import 'package:recipe_app/features/auth/presentation/cubits/auth_cubit.dart';
import 'package:recipe_app/features/categories/data/firebase_category_repo.dart';
import 'package:recipe_app/features/categories/presentation/cubits/category_cubit.dart';
import 'package:recipe_app/features/profile/data/OfflineProfileRepo.dart';
import 'package:recipe_app/features/profile/data/firebase_profile_repo.dart';
import 'package:recipe_app/features/profile/domain/entities/profile_user.dart';
import 'package:recipe_app/features/profile/domain/repos/profile_repo.dart';
import 'package:recipe_app/features/profile/presentation/cubits/profile_cubit.dart';
import 'package:recipe_app/themes/theme_cubit.dart';

import 'features/auth/presentation/cubits/auth_states.dart';
import 'features/auth/presentation/pages/auth_page.dart';
import 'features/home/presentation/pages/home_page.dart';

class MyApp extends StatelessWidget {
  final categoryRepo = FirebaseCategoryRepo();

  MyApp({super.key});

  Future<AuthRepo> _initAuthRepo() async {
    final connectivity = await Connectivity().checkConnectivity();
    final bool hasInternet = connectivity != ConnectivityResult.none;

    if (!hasInternet) {
      return OfflineAuthRepo();
    }

    try {
      await FirebaseAuth.instance.signInAnonymously();
      return FirebaseAuthRepo();
    } catch (e) {
      return OfflineAuthRepo();
    }
  }

  Future<ProfileRepo> _initProfileRepo(AuthRepo authRepo) async {
    final connectivity = await Connectivity().checkConnectivity();
    final hasInternet = connectivity != ConnectivityResult.none;

    if (hasInternet) {
      return FirebaseProfileRepo();
    }

    final offlineRepo = OfflineProfileRepo();
    final user = await authRepo.getCurrentUser();

    if (user != null) {
      final existing = await offlineRepo.fetchUserProfile(user.uid);
      if (existing == null) {
        final newUser = ProfileUser(
          uid: user.uid,
          email: user.email,
          name: user.name,
          bio: '',
          profileImageUrl: '',
        );
        await offlineRepo.updateProfile(newUser);
      }
    }

    return offlineRepo;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<AuthRepo>(
      future: _initAuthRepo(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const MaterialApp(
            home: Scaffold(body: Center(child: CircularProgressIndicator())),
          );
        }

        final authRepo = snapshot.data!;

        return FutureBuilder<ProfileRepo>(
          future: _initProfileRepo(authRepo),
          builder: (context, profileSnap) {
            if (!profileSnap.hasData) {
              return const MaterialApp(
                home: Scaffold(
                  body: Center(child: CircularProgressIndicator()),
                ),
              );
            }

            final profileRepo = profileSnap.data!;

            return MultiBlocProvider(
              providers: [
                BlocProvider<AuthCubit>(
                  create: (_) => AuthCubit(authRepo: authRepo)..checkAuth(),
                ),
                BlocProvider<ProfileCubit>(
                  create: (_) => ProfileCubit(profileRepo: profileRepo),
                ),
                BlocProvider<CategoryCubit>(
                  create: (_) => CategoryCubit(categoryRepo: categoryRepo),
                ),
                BlocProvider<ThemeCubit>(create: (_) => ThemeCubit()),
              ],
              child: BlocBuilder<ThemeCubit, ThemeData>(
                builder: (context, currentTheme) {
                  return MaterialApp(
                    debugShowCheckedModeBanner: false,
                    theme: currentTheme,
                    home: BlocConsumer<AuthCubit, AuthSate>(
                      builder: (context, authState) {
                        if (authState is Unauthenticated) {
                          return const AuthPage();
                        }
                        if (authState is Authenticated) {
                          return const HomePage();
                        }
                        return const Scaffold(
                          body: Center(child: CircularProgressIndicator()),
                        );
                      },
                      listener: (context, state) {
                        if (state is AuthError) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text(state.message)),
                          );
                        }
                      },
                    ),
                  );
                },
              ),
            );
          },
        );
      },
    );
  }
}
