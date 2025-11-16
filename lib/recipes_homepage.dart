import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:go_router/go_router.dart';
import 'database.dart';
import 'user_state.dart';

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
                'For You',
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
                  FavoritesStore.favorites = list
                      .where((meal) => savedNames.contains(meal.name))
                      .toList();
                  _initialized = true;
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: list.length,
                  itemBuilder: (context, index) {
                    final meal = list[index];
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
                          ),
                        ),
                        title: Text(
                          meal.name,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('⭐ ${meal.rating}/5'),
                            IconButton(
                              icon: Icon(
                                isFav
                                    ? Icons.favorite
                                    : Icons.favorite_border,
                                color: Colors.red,
                              ),
                              onPressed: () async {
                                setState(() {
                                  if (isFav) {
                                    FavoritesStore.favorites.removeWhere(
                                            (m) => m.name == meal.name);
                                  } else {
                                    FavoritesStore.favorites.add(meal);
                                  }
                                });

                                // ⭐ UPDATE PROVIDER (fixes everything)
                                ref
                                    .read(favoriteNamesProvider.notifier)
                                    .state = FavoritesStore.favorites
                                    .map((m) => m.name)
                                    .toList();

                                await saveFavorites();
                              },
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
              error: (e, _) => Center(child: Text('Error: $e')),
            ),
          ),
        ],
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
                FavoritesStore.favorites.clear();
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











