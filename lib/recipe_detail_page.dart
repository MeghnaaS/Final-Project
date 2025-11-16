import 'package:flutter/material.dart';
import 'recipes_homepage.dart';

class RecipeDetailPage extends StatelessWidget {
  final Meal meal;

  const RecipeDetailPage({super.key, required this.meal});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFEFEFE),
      appBar: AppBar(
        backgroundColor: Colors.orange,
        title: Text(
          meal.name,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(meal.image),
            ),
            const SizedBox(height: 20),
            const Text(
              'Instructions',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Text(
              meal.instructions,
              style: const TextStyle(fontSize: 18, height: 1.4),
            ),
          ],
        ),
      ),
    );
  }
}



