import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:go_router/go_router.dart';
import 'database.dart';
import 'user_state.dart';
import 'store_user_recipes.dart';

class Meal {
  final String name;
  final String image;
  final String instructions;
  final double rating;

  Meal(this.name, this.image, this.instructions, this.rating);

  // its a factory constructor for the meal class
  // a factory constructor turns the messy json data into a clean meal object by running logic before creating it
  // normal constructors can't do that
  factory Meal.fromJson(Map<String, dynamic> json) {
    return Meal(
      json['strMeal'] ?? '',
      json['strMealThumb'] ?? '',
      json['strInstructions'] ?? '',
      double.parse((Random().nextDouble() * 5).toStringAsFixed(1)), // random rating generator thing
    );
  }
}

// a shared list to store all the recipes the user favorited
class FavoritesStore {
  static List<Meal> favorites = [];
}

// a riverpod provider that loads a list of meal objects at different times from the api
final mealsProvider = FutureProvider<List<Meal>>((ref) async {
  const url = 'https://www.themealdb.com/api/json/v1/1/search.php?s=';
  final response = await http.get(Uri.parse(url)); // makes the actual network request to download the json data

  if (response.statusCode != 200) return []; // basically saying that if the request fails, return an empty list so that nothing crashes

  final data = jsonDecode(response.body); // translates json into a dart map
  final meals = data['meals'] as List?; // gets the list of recipes from the data
  if (meals == null) return []; // if api doesn't return anything, then it returns a empty life

  final mealList = meals.map((e) => Meal.fromJson(e)).toList(); // converts each recipe into a meal object using the factory constructor
  mealList.shuffle();

  return mealList;
});

class RecipesHomepage extends ConsumerStatefulWidget {
  const RecipesHomepage({super.key});

  @override
  ConsumerState<RecipesHomepage> createState() => _RecipesHomepageState();
}

class _RecipesHomepageState extends ConsumerState<RecipesHomepage> {
  bool _initialized = false; // starts at false and become true once favorites finish loading so that it doesn't keep reloading again and again and again

  Future<void> saveFavorites() async { //saves the current favs list into the database and doesn't return nothing
    final user = ref.read(loggedInUser); // gets the currently logged in user from riverpod
    if (user == null) return;

    final names = FavoritesStore.favorites.map((m) => m.name).toList(); // takes the list of meal objects and gets the recipes names and turns them into a list of strings
    await AppDatabase.updateFavorites(user['id'], names);
  }

  // add recipe popup
  void _showAddRecipeDialog() {
    final name = TextEditingController();
    final image = TextEditingController();
    final instructions = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text(
            'Add Recipe',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          content: SingleChildScrollView(
            child: Column(
              children: [
                TextField(
                  controller: name,
                  decoration: const InputDecoration(
                    labelText: 'Recipe Name',
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: image,
                  decoration: const InputDecoration(
                    labelText: 'Image URL',
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: instructions,
                  maxLines: null,
                  decoration: const InputDecoration(
                    labelText: 'Instructions',
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              child: const Text(
                'Cancel',
                style: TextStyle(
                  color: Color(0xFF2A5A1E),
                ),
              ),
              onPressed: () => Navigator.pop(context),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFF2A5A1E),
                foregroundColor: Colors.white,
              ),
              child: const Text(
                'Add',
                style: TextStyle(
                  color: Colors.white,
                ),
              ),
              onPressed: () async {
                if (name.text.trim().isEmpty ||
                    instructions.text.trim().isEmpty) {
                  return;
                }

                final user = ref.read(loggedInUser);

                if (user != null) {
                  await AppDatabase.addUserRecipe( // adds the recipe into the database
                    user['id'],
                    name.text.trim(),
                    image.text.trim(),
                    instructions.text.trim(),
                  );
                }

                // FIX: placeholder for blank images
                final finalImage = image.text.trim().isEmpty
                    ? 'https://via.placeholder.com/300'
                    : image.text.trim();

                // this lets it show up on the homepage, favorites (if the user saves it), and stays in the memory
                UserRecipesStore.userRecipes.add( // adds a new meal object into the list that stores all the recipes the user created
                  Meal(
                    name.text.trim(),
                    finalImage,
                    instructions.text.trim(),
                    double.parse((Random().nextDouble() * 5).toStringAsFixed(1)),
                  ),
                );

                setState(() {});
                Navigator.pop(context);
              },
            ),
          ],
        );
      },
    );
  }

  void _showDeleteConfirm(Meal meal) {
    showDialog(
      context: context,
      builder: (dialogCtx) {
        return AlertDialog(
          title: const Text('Delete Recipe?'),
          content: Text('Are you sure you want to delete ${meal.name}?'),
          actions: [
            TextButton(
              child: const Text(
                'Cancel',
                style: TextStyle(
                  color: Color(0xFF2A5A1E),
                ),
              ),
              onPressed: () => Navigator.pop(dialogCtx),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFF2A5A1E),
                foregroundColor: Colors.white,
              ),
              child: const Text(
                'Delete',
                style: TextStyle(
                  color: Colors.white,
                ),
              ),
              onPressed: () async {
                final user = ref.read(loggedInUser);

                // deletes from database
                if (user != null) {
                  await AppDatabase.deleteUserRecipe(user['id'], meal.name);
                }

                // deletes locally
                UserRecipesStore.userRecipes.removeWhere((m) => m.name == meal.name);

                // deletes from favorites
                FavoritesStore.favorites.removeWhere((m) => m.name == meal.name);

                ref.read(favoriteNamesProvider.notifier).state = FavoritesStore.favorites.map((m) => m.name).toList();

                await saveFavorites();

                setState(() {});
                Navigator.pop(dialogCtx);
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final meals = ref.watch(mealsProvider);
    final savedNames = ref.watch(favoriteNamesProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFFEFEFE),
      appBar: AppBar(
        backgroundColor: const Color(0xFF7EA228),
        title: const Text(
          'Go Recipe',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 28,
          ),
        ),
        centerTitle: true,
      ),

      body: Column(
        children: [
          const Padding(
            padding: EdgeInsets.all(16),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Welcome back!',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 28,
                ),
              ),
            ),
          ),

          Expanded(
            child: meals.when(
              data: (list) {
                // this part is so that it loads the favorites recipes correctly
                // exclamation means not so if it isn't initialized then do it but otherwise stop bc it's already done once
                if (!_initialized) { // boolean that was declared earlier and at the start it was false and the setup is run once it flips to true
                  // combines all the recipes the user created and all the recipes from the api
                  final allMeals = [ // the three dots is a spread operator and unpacks the list and dumps everything into this list
                    ...UserRecipesStore.userRecipes,
                    ...list,
                  ];

                  // restore favorites for user recipes and recipes from the api
                  FavoritesStore.favorites = allMeals.where((meal) => savedNames.contains(meal.name)).toList();
                  _initialized = true;
                }

                // this part runs every rebuild bc the ui always needs the list of recipes
                // combines api recipes and user created recipes
                final allMeals = [
                  ...UserRecipesStore.userRecipes,
                  ...list,
                ];

                return ListView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: allMeals.length,
                  itemBuilder: (context, index) {
                    final meal = allMeals[index];
                    final isFav = FavoritesStore.favorites.any((m) => m.name == meal.name);

                    return Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      elevation: 4,
                      margin: const EdgeInsets.symmetric(vertical: 10),
                      child: ListTile(
                        leading: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.network(
                            meal.image.isEmpty
                                ? 'https://via.placeholder.com/300'
                                : meal.image,
                            width: 60,
                            height: 60,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) =>
                            const Icon(Icons.image_not_supported),
                          ),
                        ),
                        title: Text(
                          meal.name,
                          style:
                          const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // rating text
                            Text('⭐ ${meal.rating}/5'),

                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                // ❤️ favorite button
                                IconButton(
                                  icon: Icon(
                                    isFav ? Icons.favorite : Icons.favorite_border,
                                    color: Colors.red,
                                  ),
                                  onPressed: () async {
                                    setState(() {
                                      if (isFav) {
                                        FavoritesStore.favorites.removeWhere((m) => m.name == meal.name);
                                      } else {
                                        FavoritesStore.favorites.add(meal);
                                      }
                                    });

                                    ref.read(favoriteNamesProvider.notifier).state =
                                        FavoritesStore.favorites.map((m) => m.name).toList();

                                    await saveFavorites();
                                  },
                                ),

                                // delete button for the recipes the user creates
                                if (UserRecipesStore.userRecipes.contains(meal))
                                  Column(
                                    children: [
                                      IconButton(
                                        icon: const Icon(Icons.delete, color: Colors.black54),
                                        onPressed: () => _showDeleteConfirm(meal),
                                      ),
                                    ],
                                  ),
                              ],
                            ),
                          ],
                        ),

                        onTap: () => context.push('/detail', extra: meal),
                      ),
                    );
                  },
                );
              },
              loading: () => const Center(
                child:
                CircularProgressIndicator(color: Color(0xFF7EA228)),
              ),
              error: (e, _) => Center(child: Text("Error: $e")),
            ),
          ),
        ],
      ),

      // floating add button for users to add their own recipes
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF7EA228),
        child: const Icon(
          Icons.add,
          color: Colors.white,
          size: 32,
        ),
        onPressed: _showAddRecipeDialog,
      ),

      bottomNavigationBar: BottomAppBar(
        color: const Color(0xFF7EA228),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            IconButton(
              icon: const Icon(Icons.favorite,
                  color: Colors.white, size: 30),
              onPressed: () => context.go('/favorites'),
            ),
            IconButton(
              icon: const Icon(Icons.logout,
                  color: Colors.white, size: 30),
              onPressed: () {
                UserRecipesStore.userRecipes.clear();
                FavoritesStore.favorites.clear();
                UserRecipesStore.userRecipes.clear();
                ref.read(favoriteNamesProvider.notifier).state = [];
                ref.read(loggedInUser.notifier).state = null;
                context.go('/');
              },
            ),
          ],
        ),
      ),
    );
  }
}













