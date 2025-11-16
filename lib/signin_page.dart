import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'database.dart';
import 'user_state.dart';
import 'package:go_router/go_router.dart';

class SigninPage extends ConsumerStatefulWidget {
  const SigninPage({super.key});

  @override
  ConsumerState<SigninPage> createState() => _SigninPageState();
}

class _SigninPageState extends ConsumerState<SigninPage> {
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
                'Sign In',
                style: TextStyle(fontSize: 42, fontWeight: FontWeight.bold),
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
                    String email = emailController.text.trim();
                    String password = passwordController.text.trim();

                    final user = await AppDatabase.loginUser(email, password);

                    if (user != null) {
                      ref.read(loggedInUser.notifier).state = user;

                      final favNames =
                      await AppDatabase.getFavorites(user['id']);
                      ref.read(favoriteNamesProvider.notifier).state =
                          favNames;

                      context.go('/recipes');
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Invalid email or password'),
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

                  child: const Text('Sign In'),
                ),
              ),
              const SizedBox(height: 10),

              TextButton(
                onPressed: () => context.go('/createNewAccount'),
                child: const Text(
                  "Don't have an account yet? Sign up now",
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





