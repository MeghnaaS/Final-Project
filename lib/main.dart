import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_training_template/recipe_detail_page.dart';
import 'package:go_router/go_router.dart';
import 'recipes_homepage.dart';

void main() {
  runApp(
    const ProviderScope(
      child: MyApp(),
    ),
  );
}
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  static final GoRouter _router = GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => const MyHomePage(),
      ),
      GoRoute(
        path: '/recipes',
        builder: (context, state) => const RecipesHomepage(),
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
    );
  }
}

// Sign In Page
class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  String email = 'meghnaasojy1@gmail.com';
  String password = '123';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.orange,
        title: const Text(
          'Go Recipe',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
            fontSize: 32,
          ),
        ),
        centerTitle: true,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.network(
              'https://thumbs.dreamstime.com/b/bowl-overflowing-assortment-vibrant-fresh-fruits-logo-local-food-pantry-features-stylized-fruit-basket-317955691.jpg',
              width: 200,
              height: 200,
            ),
            const SizedBox(height: 10),
            const Text(
              'Sign In',
              style: TextStyle(
                fontSize: 42,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: 400,
              child: TextField(
                decoration: const InputDecoration(
                  labelText: 'Email',
                  hintText: 'Enter your email',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(8.0)),
                  ),
                  contentPadding:
                  EdgeInsets.symmetric(vertical: 8.0, horizontal: 12.0),
                ),
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: 400,
              child: TextField(
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Password',
                  hintText: 'Enter your password',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(8.0)),
                  ),
                  contentPadding:
                  EdgeInsets.symmetric(vertical: 8.0, horizontal: 12.0),
                ),
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: 400,
              height: 40,
              child: ElevatedButton(
                onPressed: () {
                  // This makes it go to the recipe page when the user clicks sign in
                  context.go('/recipes');
                },
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.white,
                  backgroundColor: Colors.orange,
                  textStyle: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                  padding: const EdgeInsets.symmetric(
                      vertical: 12, horizontal: 40),
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(8.0)),
                  ),
                ),
                child: const Text('Sign In'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

