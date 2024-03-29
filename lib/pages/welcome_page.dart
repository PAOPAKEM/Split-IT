import 'package:flutter/material.dart';
import 'package:split_it/pages/sign_in_page.dart';
import 'package:split_it/pages/sign_up_page.dart';

class LandingPage extends StatelessWidget {
  const LandingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                // Logo here
                Image.asset(
                  'assets/logo.png',
                  width: 150,
                ),
                const SizedBox(height: 50),
                // Welcome Text
                const Text(
                  'Welcome to Split Bill App',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                // App slogan
                const Text(
                  'Easily split expenses with friends and family.',
                  style: TextStyle(fontSize: 18),
                ),
                const SizedBox(height: 150),
                // Sign Up Button
                ElevatedButton(
                  onPressed: () {
                    // Handle sign up
                  },
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.white, backgroundColor: Colors.black, // Text color
                    minimumSize: const Size(double.infinity, 50),
                  ),
                  child: const Text('Sign up'),
                ),
                const SizedBox(height: 16),
                // Sign In Button
                OutlinedButton(
                  onPressed: () {
                    // Handle sign in
                  },
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.black,
                    side: const BorderSide(color: Colors.black),
                    minimumSize: const Size(double.infinity, 50),
                  ),
                  child: const Text('Sign in'),
                ),
                const SizedBox(height: 16),
                // Sign in with Google Button
                ElevatedButton.icon(
                  icon: Image.asset('assets/google_logo.png', height: 24, width: 24), // Placeholder image
                  label: const Text('Sign in with Google'),
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.black,
                    backgroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 108.0),
                    minimumSize: const Size(double.infinity, 50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(40),
                      side: const BorderSide(color: Colors.black),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
