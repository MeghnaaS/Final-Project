import 'package:flutter_riverpod/flutter_riverpod.dart';

// currently logged in user
final loggedInUser = StateProvider<Map<String, dynamic>?>( (ref) => null );

// favorite names gets loaded from the database
final favoriteNamesProvider = StateProvider<List<String>>((ref) => []);

