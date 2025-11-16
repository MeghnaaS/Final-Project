import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

// Pages
import 'signin_page.dart';
import 'recipes_homepage.dart';
import 'recipe_detail_page.dart';
import 'favorites_page.dart';
import 'create_account_page.dart';


void main() {
  runApp(
    const ProviderScope(
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // ✨ Router setup
  static final GoRouter _router = GoRouter(
    initialLocation: '/',   // default starting page
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => const SigninPage(),
      ),
      GoRoute(
        path: '/recipes',
        builder: (context, state) => const RecipesHomepage(),
      ),
      GoRoute(
        path: '/favorites',
        builder: (context, state) => const FavoritesPage(),
      ),
      GoRoute(
        path: '/createNewAccount',
        builder: (context, state) => const CreateNewAccountPage(),
      ),
      GoRoute(
        path: '/detail',
        builder: (context, state) {
          final meal = state.extra as Meal;
          return RecipeDetailPage(meal: meal);
        },
      ),
    ],
  );

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      routerConfig: _router,
      theme: ThemeData(
        scaffoldBackgroundColor: const Color(0xFFFEFEFE),
      ),
    );
  }
}




