import 'package:flutter_riverpod/flutter_riverpod.dart';

// currently logged in user
final loggedInUser = StateProvider<Map<String, dynamic>?>( (ref) => null );

// favorite NAMES loaded from DB (strings only)
final favoriteNamesProvider = StateProvider<List<String>>((ref) => []);

