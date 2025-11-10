import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:go_router/go_router.dart';

// model for each meal
class Meal {
  final String name;
  final String image;
  final String instructions;

  Meal(this.name, this.image, this.instructions);

  factory Meal.fromJson(Map<String, dynamic> json) {
    return Meal(
      json['strMeal'] ?? '',
      json['strMealThumb'] ?? '',
      json['strInstructions'] ?? '',
    );
  }
}

// provider that fetches multiple meals at once
final mealsProvider = FutureProvider<List<Meal>>((ref) async {
  const url = 'https://www.themealdb.com/api/json/v1/1/search.php?s=';

  final response = await http.get(Uri.parse(url));
  if (response.statusCode != 200) return [];

  final data = jsonDecode(response.body);
  final meals = data['meals'] as List?;
  if (meals == null) return [];

  final mealsList = meals.map((e) => Meal.fromJson(e)).toList();
  mealsList.shuffle();
  return mealsList;
});

class RecipesHomepage extends ConsumerWidget {
  const RecipesHomepage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final meals = ref.watch(mealsProvider);

    return Scaffold(
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
      body: Column (
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Padding(
            padding: EdgeInsets.all(16),
            child: Text(
              'For You',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Expanded(
            child: meals.when(
              data: (list) => ListView.builder(
                padding: const EdgeInsets.all(12),
                itemCount: list.length,
                itemBuilder: (context, index) {
                  final meal = list[index];

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
                        style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 20
                        ),
                      ),
                      subtitle: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '⭐ ${(3 + (2 * (index % 10) / 10)).toStringAsFixed(1)}/5',
                            style: const TextStyle(fontSize: 14),
                          ),
                          IconButton(
                            icon: const Icon(Icons.favorite_border, color: Colors.red),
                            onPressed: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content:
                                  Text('${meal.name} added to favorites ❤️'),
                                  duration: const Duration(seconds: 2),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                      onTap: () {
                        context.push('/detail', extra: meal);
                      },
                    ),
                  );
                },
              ),
              loading: () =>
              const Center(child: CircularProgressIndicator(color: Colors.orange)),
              error: (e, _) => Center(child: Text('Error: $e')),
            ),
          ),
        ],
      )
    );
  }
}



