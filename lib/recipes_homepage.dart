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

  factory Meal.fromJson(Map<String, dynamic> json) {
    var random = Random();
    return Meal(
      json['strMeal'] ?? '',
      json['strMealThumb'] ?? '',
      json['strInstructions'] ?? '',
      double.parse((random.nextDouble() * 5).toStringAsFixed(1)),
    );
  }
}

class FavoritesStore {
  static List<Meal> favorites = [];
}

final mealsProvider = FutureProvider<List<Meal>>((ref) async {
  const url = 'https://www.themealdb.com/api/json/v1/1/search.php?s=';
  final response = await http.get(Uri.parse(url));

  if (response.statusCode != 200) return [];

  final data = jsonDecode(response.body);
  final meals = data['meals'] as List?;
  if (meals == null) return [];

  final mealList = meals.map((e) => Meal.fromJson(e)).toList();
  mealList.shuffle();

  return mealList;
});

class RecipesHomepage extends ConsumerStatefulWidget {
  const RecipesHomepage({super.key});

  @override
  ConsumerState<RecipesHomepage> createState() => _RecipesHomepageState();
}

class _RecipesHomepageState extends ConsumerState<RecipesHomepage> {
  bool _initialized = false;

  Future<void> saveFavorites() async {
    final user = ref.read(loggedInUser);
    if (user == null) return;

    final names = FavoritesStore.favorites.map((m) => m.name).toList();
    await AppDatabase.updateFavorites(user['id'], names);
  }

  // popup
  void _showAddRecipeDialog() {
    final name = TextEditingController();
    final image = TextEditingController();
    final instructions = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text(
            "Add Recipe",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          content: SingleChildScrollView(
            child: Column(
              children: [
                TextField(
                  controller: name,
                  decoration: const InputDecoration(
                    labelText: "Recipe Name",
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: image,
                  decoration: const InputDecoration(
                    labelText: "Image URL",
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: instructions,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    labelText: "Instructions",
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              child: const Text("Cancel"),
              onPressed: () => Navigator.pop(context),
            ),
            ElevatedButton(
              child: const Text("Add"),
              onPressed: () async {
                if (name.text.trim().isEmpty ||
                    instructions.text.trim().isEmpty) {
                  return;
                }

                final user = ref.read(loggedInUser);

                if (user != null) {
                  await AppDatabase.addUserRecipe(
                    user['id'],
                    name.text.trim(),
                    image.text.trim(),
                    instructions.text.trim(),
                  );
                }

                UserRecipesStore.userRecipes.add(
                  Meal(
                    name.text.trim(),
                    image.text.trim(),
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
          title: const Text("Delete Recipe?"),
          content: Text("Are you sure you want to delete '${meal.name}'?"),
          actions: [
            TextButton(
              child: const Text("Cancel"),
              onPressed: () => Navigator.pop(dialogCtx),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              child: const Text("Delete"),
              onPressed: () async {
                final user = ref.read(loggedInUser);

                // delete from database
                if (user != null) {
                  await AppDatabase.deleteUserRecipe(user['id'], meal.name);
                }

                // delete locally
                UserRecipesStore.userRecipes.removeWhere((m) => m.name == meal.name);

                // delete from favorites
                FavoritesStore.favorites.removeWhere((m) => m.name == meal.name);

                ref.read(favoriteNamesProvider.notifier).state =
                    FavoritesStore.favorites.map((m) => m.name).toList();

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
                if (!_initialized) {
                  // combines
                  final allMeals = [
                    ...UserRecipesStore.userRecipes,
                    ...list,
                  ];

                  // restore favorites for user recipes and recipes from the API
                  FavoritesStore.favorites = allMeals
                      .where((meal) => savedNames.contains(meal.name))
                      .toList();

                  _initialized = true;
                }


                // ⭐ Combine API recipes + user-created recipes
                final allMeals = [
                  ...UserRecipesStore.userRecipes,
                  ...list,
                ];

                return ListView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: allMeals.length,
                  itemBuilder: (context, index) {
                    final meal = allMeals[index];
                    final isFav = FavoritesStore.favorites
                        .any((m) => m.name == meal.name);

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
                            meal.image,
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

                                // 🗑 DELETE BUTTON (ONLY FOR USER RECIPES)
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

      // ⭐ Floating Add Button
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
              icon: const Icon(Icons.exit_to_app,
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












