import 'package:flutter/material.dart';
import 'recipes_homepage.dart';

// shows the details about the recipes when you click on them
class RecipeDetailPage extends StatelessWidget {
  final Meal meal;
  const RecipeDetailPage({super.key, required this.meal});
  // super.key just sends the key to the stateless widget (the parent)
  // kinda just gives it like an id so that it can be tracked across rebuilds

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFFEFEFE),
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
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // makes it rounded rectangle
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(
                  meal.image,
                  fit: BoxFit.cover,
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Instructions',
              style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              meal.instructions,
              style: const TextStyle(
                  fontSize: 18,
                  height: 1.4,
              ),
            ),
          ],
        ),
      ),
    );
  }
}


