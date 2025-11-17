import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'recipes_homepage.dart';
import 'store_user_recipes.dart';
import 'user_state.dart';
import 'database.dart';

class FavoritesPage extends ConsumerStatefulWidget {
  const FavoritesPage({super.key});

  @override
  ConsumerState<FavoritesPage> createState() => _FavoritesPageState();
}

class _FavoritesPageState extends ConsumerState<FavoritesPage> {
  // ----------------------------------------------------------
  // DELETE CONFIRMATION POPUP
  // ----------------------------------------------------------
  void _showDeleteConfirm(Meal meal) {
    showDialog(
      context: context,
      builder: (dialogCtx) {
        return AlertDialog(
          title: const Text(
            "Delete Recipe?",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
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

                // If it's user-created → delete from DB + memory
                if (user != null &&
                    UserRecipesStore.userRecipes.contains(meal)) {
                  await AppDatabase.deleteUserRecipe(user['id'], meal.name);
                  UserRecipesStore.userRecipes
                      .removeWhere((m) => m.name == meal.name);
                }

                // Remove from favorites
                FavoritesStore.favorites
                    .removeWhere((m) => m.name == meal.name);

                // Update favorite names provider
                ref.read(favoriteNamesProvider.notifier).state =
                    FavoritesStore.favorites.map((m) => m.name).toList();

                // Save favorites to DB
                if (user != null) {
                  await AppDatabase.updateFavorites(
                    user['id'],
                    FavoritesStore.favorites.map((m) => m.name).toList(),
                  );
                }

                setState(() {});
                Navigator.pop(dialogCtx);
              },
            ),
          ],
        );
      },
    );
  }

  // ----------------------------------------------------------
  // PAGE BUILD
  // ----------------------------------------------------------
  @override
  Widget build(BuildContext context) {
    final favs = FavoritesStore.favorites;
    final user = ref.read(loggedInUser);

    return Scaffold(
      backgroundColor: const Color(0xFFFEFEFE),
      appBar: AppBar(
        backgroundColor: const Color(0xFFC72123),
        title: const Text(
          'Favorites',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 28,
          ),
        ),
        centerTitle: true,
      ),

      body: favs.isEmpty
          ? const Center(
        child: Text(
          'No favorites saved',
          style: TextStyle(
            fontSize: 25,
            fontWeight: FontWeight.bold,
          ),
        ),
      )
          : ListView.builder(
        padding: const EdgeInsets.all(12),
        itemCount: favs.length,
        itemBuilder: (context, i) {
          final meal = favs[i];
          final isUserRecipe =
          UserRecipesStore.userRecipes.contains(meal);

          return Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
            elevation: 3,
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
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),

              subtitle: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('⭐ ${meal.rating}/5'),

                  Row(
                    children: [
                      // ❤️ UNFAVORITE
                      IconButton(
                        icon: const Icon(Icons.favorite,
                            color: Colors.red),
                        onPressed: () async {
                          FavoritesStore.favorites.removeWhere(
                                  (m) => m.name == meal.name);

                          ref
                              .read(favoriteNamesProvider.notifier)
                              .state =
                              FavoritesStore.favorites
                                  .map((m) => m.name)
                                  .toList();

                          if (user != null) {
                            await AppDatabase.updateFavorites(
                              user['id'],
                              FavoritesStore.favorites
                                  .map((m) => m.name)
                                  .toList(),
                            );
                          }

                          setState(() {});
                        },
                      ),

                      // 🗑 DELETE ONLY IF USER-CREATED
                      if (isUserRecipe)
                        IconButton(
                          icon: const Icon(Icons.delete,
                              color: Colors.black54),
                          onPressed: () => _showDeleteConfirm(meal),
                        ),
                    ],
                  ),
                ],
              ),

              onTap: () => context.push('/detail', extra: meal),
            ),
          );
        },
      ),

      bottomNavigationBar: BottomAppBar(
        color: const Color(0xFFC72123),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            IconButton(
              icon:
              const Icon(Icons.home, color: Colors.white, size: 30),
              onPressed: () => context.go('/recipes'),
            ),
            IconButton(
              icon: const Icon(Icons.exit_to_app,
                  color: Colors.white, size: 30),
              onPressed: () => context.go('/'),
            ),
          ],
        ),
      ),
    );
  }
}




