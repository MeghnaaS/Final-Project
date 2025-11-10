import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'recipes_homepage.dart';

class FavoritesPage extends StatefulWidget {
  const FavoritesPage({super.key});

  @override
  State<FavoritesPage> createState() => _FavoritesPageState();
}

class _FavoritesPageState extends State<FavoritesPage> {
  @override
  Widget build(BuildContext context) {
    final favs = FavoritesStore.favorites;

    return Scaffold(
      backgroundColor: Color(0xFFFEFEFE),
      appBar: AppBar(
        backgroundColor: Colors.orange,
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
        itemCount: favs.length,
        padding: const EdgeInsets.all(12),
        itemBuilder: (context, i) {
          final meal = favs[i];
          final isFav = FavoritesStore.favorites.contains(meal);

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
              subtitle: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                      '⭐ ${(3 + (2 * (i % 10) / 10)).toStringAsFixed(1)}/5',
                  ),
                  IconButton(
                    icon: Icon(
                      isFav ? Icons.favorite : Icons.favorite_border,
                      color: Colors.red,
                    ),
                    onPressed: () {
                      setState(() {
                        if (isFav) {
                          FavoritesStore.favorites.remove(meal);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                '${meal.name} removed from favorites 💔'
                              ),
                              duration: Duration(
                                  seconds: 1
                              ),
                            ),
                          );
                        } else {
                          FavoritesStore.favorites.add(meal);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                '${meal.name} added to favorites ❤️',
                              ),
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



