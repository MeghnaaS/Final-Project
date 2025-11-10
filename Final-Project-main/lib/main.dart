import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'recipes_homepage.dart';
import 'recipe_detail_page.dart';
import 'favorites_page.dart';

// provider scope is used bc it powers up state for everything and it lets screens read the
// same providers
void main() {
  runApp(const ProviderScope(
      child: MyApp()
  ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // static makes it a shared router for the entire class and it doesn't have duplicates
  // final is so that we that router once and doesn't reassign it
  // final is better than const in this case bc go router is built at runtime so it can't be const
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
          // state.extra is the data passed into the route
          // as meal is so that its casted as a meal and if it isn't it crashes
          final meal = state.extra as Meal;
          return RecipeDetailPage(meal: meal);
        },
      ),
      GoRoute(
        path: '/favorites',
        builder: (context, state) => const FavoritesPage(),
      ),
    ],
  );

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      // plugs the router into the material app router so all of it follows the same setup
      routerConfig: _router,
    );
  }
}

// sign in page

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  String email = '';
  String password = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFFEFEFE),
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
                fontWeight: FontWeight.bold
              ),
            ),
            const SizedBox(height: 20),

            // email
            SizedBox(
              width: 400,
              child: TextField(
                onChanged: (value) => email = value, // value is whatever the user typed and then it saves it into the email variable
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

            // password
            SizedBox(
              width: 400,
              child: TextField(
                onChanged: (value) => password = value, // same thing as email
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

            // sign In
            SizedBox(
              width: 400,
              height: 40,
              child: ElevatedButton(
                onPressed: () {
                  if (email == 'meghnaasojy1@gmail.com' && password == '123') {
                    context.go('/recipes');
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                            'Invalid email or password',
                        ),
                        duration: Duration(seconds: 1),
                      ),
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.white,
                  backgroundColor: Colors.orange,
                  textStyle: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                  padding:
                  const EdgeInsets.symmetric(vertical: 12, horizontal: 40),
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






