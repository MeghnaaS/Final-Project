import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'database.dart';
import 'user_state.dart';
import 'package:go_router/go_router.dart';

class CreateNewAccountPage extends ConsumerStatefulWidget {
  const CreateNewAccountPage({super.key});

  @override
  ConsumerState<CreateNewAccountPage> createState() =>
      _CreateNewAccountPageState();
}

class _CreateNewAccountPageState
    extends ConsumerState<CreateNewAccountPage> {
  final firstController = TextEditingController();
  final lastController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFEFEFE),
      appBar: AppBar(
        backgroundColor: const Color(0xFF2A5A1E),
        title: const Text(
          'Go Recipe',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
            fontSize: 32,
          ),
        ),
        centerTitle: true,
      ),

      body: Center(
        child: SingleChildScrollView(
          child: Column(
            children: [
              Image.network(
                'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcQ5VIJ7UYPylwCOHQkDKrlXkPKvqP5XAfRQAQ&s',
                width: 200,
                height: 200,
              ),

              const SizedBox(height: 20),

              const Text(
                'Create Account',
                style: TextStyle(fontSize: 42, fontWeight: FontWeight.bold),
              ),

              const SizedBox(height: 25),

              SizedBox(
                width: 400,
                child: TextField(
                  controller: firstController,
                  decoration: const InputDecoration(
                    labelText: 'First Name',
                    border: OutlineInputBorder(),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              SizedBox(
                width: 400,
                child: TextField(
                  controller: lastController,
                  decoration: const InputDecoration(
                    labelText: 'Last Name',
                    border: OutlineInputBorder(),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              SizedBox(
                width: 400,
                child: TextField(
                  controller: emailController,
                  decoration: const InputDecoration(
                    labelText: 'Email',
                    border: OutlineInputBorder(),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              SizedBox(
                width: 400,
                child: TextField(
                  controller: passwordController,
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: 'Password',
                    border: OutlineInputBorder(),
                  ),
                ),
              ),

              const SizedBox(height: 30),

              SizedBox(
                width: 200,
                height: 50,
                child: ElevatedButton(
                  onPressed: () async {
                    String first = firstController.text.trim();
                    String last = lastController.text.trim();
                    String email = emailController.text.trim();
                    String password = passwordController.text.trim();

                    // Check all fields filled
                    if (first.isEmpty || last.isEmpty || email.isEmpty || password.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Please fill out all fields'),
                          duration: Duration(seconds: 1),
                        ),
                      );
                      return;
                    }

                    // Check if email already exists
                    final db = await AppDatabase.getDatabase();
                    final existing = await db.query(
                      'users',
                      where: 'email = ?',
                      whereArgs: [email],
                    );

                    if (existing.isNotEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Email already exists'),
                          duration: Duration(seconds: 1),
                        ),
                      );
                      return;
                    }

                    // Create new user
                    await AppDatabase.createUser(first, last, email, password);

                    // Log in new user immediately
                    final user = await AppDatabase.loginUser(email, password);

                    if (user != null) {
                      ref.read(loggedInUser.notifier).state = user;
                      ref.read(favoriteNamesProvider.notifier).state = [];

                      context.go('/recipes');
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Something went wrong'),
                          duration: Duration(seconds: 1),
                        ),
                      );
                    }
                  },

                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2A5A1E),
                    foregroundColor: Colors.white,
                    textStyle: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  child: const Text('Sign Up'),
                ),
              ),
              const SizedBox(height: 10),

              TextButton(
                onPressed: () => context.go('/'),
                child: const Text(
                  "Already have an account? Sign in",
                  style: TextStyle(color: Color(0xFF2A5A1E)),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}


