import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'recipes_homepage.dart';
import 'database.dart';
import 'user_state.dart';
import 'package:go_router/go_router.dart';

class FavoritesPage extends ConsumerStatefulWidget {
  const FavoritesPage({super.key});

  @override
  ConsumerState<FavoritesPage> createState() => _FavoritesPageState();
}

class _FavoritesPageState extends ConsumerState<FavoritesPage> {
  Future<void> saveToDb() async {
    final user = ref.read(loggedInUser);
    if (user == null) return;

    final names = FavoritesStore.favorites.map((m) => m.name).toList();
    await AppDatabase.updateFavorites(user['id'], names);
  }

  @override
  Widget build(BuildContext context) {
    final favs = FavoritesStore.favorites;

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
          style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
        ),
      )
          : ListView.builder(
        padding: const EdgeInsets.all(12),
        itemCount: favs.length,
        itemBuilder: (context, i) {
          final meal = favs[i];

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
                ),
              ),
              title: Text(
                meal.name,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Text('⭐ ${meal.rating}/5'),
              trailing: IconButton(
                icon: const Icon(Icons.favorite, color: Colors.red),
                onPressed: () async {
                  setState(() {
                    FavoritesStore.favorites
                        .removeWhere((m) => m.name == meal.name);
                  });

                  // ⭐ UPDATE PROVIDER (this was missing!)
                  ref.read(favoriteNamesProvider.notifier).state =
                      FavoritesStore.favorites
                          .map((m) => m.name)
                          .toList();

                  await saveToDb();
                },
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



