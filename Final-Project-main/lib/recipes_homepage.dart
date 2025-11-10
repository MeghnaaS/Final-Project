import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:go_router/go_router.dart';


class Meal {
  final String name;
  final String image;
  final String instructions;

  Meal(this.name, this.image, this.instructions);

  // its a factory constructor that build a meal from a JSON map that it gets from the APi
  //              keys are strings, value can be any type
  factory Meal.fromJson(Map<String, dynamic> json) {
    return Meal(
      // ?? '' means that if its null or missing use an empty string instead
      json['strMeal'] ?? '',
      json['strMealThumb'] ?? '',
      json['strInstructions'] ?? '',
    );
  }
}

class FavoritesStore {
  static final List<Meal> favorites = [];
}

final mealsProvider = FutureProvider<List<Meal>>((ref) async {
  const url = 'https://www.themealdb.com/api/json/v1/1/search.php?s=';

  final response = await http.get(Uri.parse(url));
  if (response.statusCode != 200) return [];
  // checks the HTTP results if its not 200 then it returns and empty list instead of crashing
  // if its empty then it doesn't show the meal cards
  // so like if request fails then it says to not even parse the data

  // decodes the json and then request works but the data isn't there, it says to not show anything
  final data = jsonDecode(response.body);
  final meals = data['meals'] as List?;
  if (meals == null) return [];

  final mealList = meals.map((e) => Meal.fromJson(e)).toList(); // turns json item into a meal
  mealList.shuffle();
  return mealList;
});

// consumerstatefulwidget is a stateful widget that can watch riverpod providers
// its basically stateful + riverpod in one widget
class RecipesHomepage extends ConsumerStatefulWidget {
  const RecipesHomepage({super.key});
  @override
  ConsumerState<RecipesHomepage> createState() => _RecipesHomepageState();
}

class _RecipesHomepageState extends ConsumerState<RecipesHomepage> {
  @override
  Widget build(BuildContext context) {
    final meals = ref.watch(mealsProvider);

    return Scaffold(
      backgroundColor: Color(0xFFFEFEFE),
      appBar: AppBar(
        backgroundColor: Colors.orange,
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
          // expanded says to fill the extra space inside a row or column
          Expanded(
            child: meals.when( // it lets me say: when you get data build with the result, when loading show spinner, and when error show an error ui
              data: (list) => ListView.builder(
                padding: const EdgeInsets.all(12),
                itemCount: list.length,
                itemBuilder: (context, index) {
                  final meal = list[index];
                  final isFav = FavoritesStore.favorites.contains(meal);

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
                          errorBuilder: (_, __, ___) => const SizedBox(
                            width: 60,
                            height: 60,
                            child: Icon(
                                Icons.image_not_supported,
                            ),
                          ),
                        ),
                      ),
                      title: Text(
                        meal.name,
                        style: const TextStyle(
                            fontWeight: FontWeight.bold,
                        ),
                      ),
                      subtitle: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            //       3 + (2 * (cycles between 0-9)/turns it into decimals.one decimal place/5
                              '⭐ ${(3 + (2 * (index % 10) / 10)).toStringAsFixed(1)}/5',
                          ),
                          IconButton(
                            icon: Icon(
                              isFav ? Icons.favorite : Icons.favorite_border,
                              color: Colors.red,
                            ),
                            onPressed: () {
                              setState(() { // updates the ui everytime it the user adds/removes from favorites
                                if (isFav) {
                                  FavoritesStore.favorites.remove(meal);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                          '${meal.name} removed from favorites 💔',
                                      ),
                                      duration: Duration(
                                          seconds: 1,
                                      ),
                                    ),
                                  );
                                } else {
                                  FavoritesStore.favorites.add(meal);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text('${meal.name} added to favorites ❤️'),
                                      duration: Duration(
                                          seconds: 1,
                                      ),
                                    ),
                                  );
                                }
                              });
                            },
                          ),
                        ],
                      ),
                      onTap: () => context.push('/detail', extra: meal),
                    ),
                  );
                },
              ),
              loading: () => const Center(
                child: CircularProgressIndicator(color: Colors.orange),
              ),
              error: (e, _) => Center(
                child: Text(
                    'Error: $e',
                ),
              ),
            ),
          ),
        ],
      ),

      bottomNavigationBar: BottomAppBar(
        color: Colors.orange,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            IconButton(
              icon: const Icon(
                  Icons.home,
                  color: Colors.white,
                  size: 30
              ),
              onPressed: () => context.go('/recipes'),
            ),
            IconButton(
              icon: const Icon(
                  Icons.favorite,
                  color: Colors.white,
                  size: 30
              ),
              onPressed: () => context.go('/favorites'),
            ),
            IconButton(
              icon: const Icon(
                  Icons.exit_to_app,
                  color: Colors.white,
                  size: 30
              ),
              onPressed: () => context.go('/'),
            ),
          ],
        ),
      ),
    );
  }
}







