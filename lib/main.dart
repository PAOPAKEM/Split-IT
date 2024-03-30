// ignore_for_file: use_key_in_widget_constructors, library_private_types_in_public_api

import 'package:flutter/material.dart';
// import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:split_it/pages/auth_page.dart';
import 'package:split_it/pages/home_page.dart';
import 'package:split_it/pages/sign_in_page.dart';
import 'package:split_it/pages/sign_up_page.dart';
import 'package:split_it/pages/welcome_page.dart';
import 'firebase_options.dart';

// !: Check The Page Navigator
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Split Bill App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      debugShowCheckedModeBanner: false,
      // home: const AuthPage(),
      routes: {
        '/': (BuildContext context) => const AuthPage(),
        '/signin': (BuildContext context) => const SigninPage(),
        '/signup': (BuildContext context) => SignUpPage(),
        '/home': (BuildContext context) => HomePage(),
      },
      initialRoute: '/',
    );
  }
}
