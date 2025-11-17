import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'signin_page.dart';
import 'recipes_homepage.dart';
import 'recipe_detail_page.dart';
import 'favorites_page.dart';
import 'create_account_page.dart';


void main() {
  runApp(
    const ProviderScope( // gives the entire app access to all the riverpod providers so they work
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // router
  static final GoRouter _router = GoRouter(
    initialLocation: '/',
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
          // state.extra takes whatever data that's passed when navigating
          // extra is a way to send data directly to a route when navigating, so the new page knows what to display
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
      routerConfig: _router, // tells it to use go router for all navigation
      theme: ThemeData(
        scaffoldBackgroundColor: const Color(0xFFFEFEFE),
      ),
    );
  }
}




