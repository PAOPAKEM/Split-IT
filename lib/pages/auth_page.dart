import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:split_it/pages/home_page.dart';
import 'package:split_it/pages/sign_in_page.dart';
import 'package:split_it/pages/welcome_page.dart';

// Check If User Sign in or not?
class AuthPage extends StatelessWidget {
  const AuthPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder(
          stream: FirebaseAuth.instance.authStateChanges(),
          builder: (context, snapshot) {
            // user is logged in
            if (snapshot.hasData) {
              return HomePage();
            }
            // user isn't logged in
            else {
              return SigninPage();
            }
          }),
    );
  }
}
