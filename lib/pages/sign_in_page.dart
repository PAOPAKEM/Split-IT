// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:split_it/pages/sign_up_page.dart';
import 'package:split_it/pages/welcome_page.dart';

// !: Check The Page Navigator (Issue from Stack) Navigator 1.0

class SigninPage extends StatefulWidget {
  const SigninPage({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _SigninPageState createState() => _SigninPageState();
}

class _SigninPageState extends State<SigninPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _rememberMe = false;

  // wrong Sign_in message pop up
  void wrongEmailPasswordMessage() {
    showDialog(
      context: context,
      builder: (context) {
        return const AlertDialog(
          title: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Sign In Failed',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          content: Text(
            'Sign in with an incorrect email address or password.',
            textAlign: TextAlign.center,
          ),
          backgroundColor: Colors.white,
        );
      },
    );
  }

  void emptyInputMessage() {
    showDialog(
      context: context,
      builder: (context) {
        return const AlertDialog(
          title: Text('Fill All Fields!'),
        );
      },
    );
  }

  Future<void> signUserIn() async {
    // try sign in
    try {
      await FirebaseAuth.instance
          .signInWithEmailAndPassword(email: _emailController.text, password: _passwordController.text);
      // On successful sign-in, navigate to the home page
      // and remove all previous routes (e.g., the sign-in page)
      Navigator.pushReplacementNamed(context, '/home');
    } on FirebaseAuthException catch (e) {
      // print(e.toString());
      if (e.code == 'invalid-credential' || e.code == 'invalid-email' || e.code == 'channel-error') {
        wrongEmailPasswordMessage();
      } else {
        emptyInputMessage();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            // Handle back button (welcome_page)
            Navigator.pop(context);
          },
        ),
        // backgroundColor: Colors.white,
        elevation: 0,
      ),
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            // mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              const SizedBox(height: 20.0),
              const Text(
                'Welcome back 👋',
                style: TextStyle(
                  fontSize: 28.0,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.start,
              ),
              const SizedBox(height: 20.0),
              const Text(
                'Please enter your email & password to sign in.',
                style: TextStyle(
                  fontSize: 16.0,
                  // fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.start,
              ),
              const SizedBox(height: 48.0),
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.email_outlined),
                ),
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 20.0),
              TextFormField(
                controller: _passwordController,
                decoration: const InputDecoration(
                  labelText: 'Password',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.lock_outlined),
                ),
                obscureText: true,
              ),
              const SizedBox(height: 24.0),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Checkbox(
                    value: _rememberMe,
                    onChanged: (bool? value) {
                      setState(() {
                        _rememberMe = value ?? false;
                      });
                    },
                  ),
                  const Text('Remember me'),
                  const Spacer(),
                  TextButton(
                    child: const Text(
                      'Forgot Password?',
                      style: TextStyle(
                        color: Colors.black54,
                      ),
                    ),
                    onPressed: () {
                      // TODO: Implement forgot password functionality
                    },
                  ),
                ],
              ),
              const Divider(),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text("Don't have an account?"),
                  GestureDetector(
                    child: TextButton(
                      child: const Text("Sign up"),
                      onPressed: () {
                        // TODO: Navigate to sign-up screen
                        Navigator.pushNamed(context, '/signup');
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24.0),
              ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.white,
                    backgroundColor: Colors.black,
                    padding: const EdgeInsets.all(16),
                  ),
                  onPressed: signUserIn,
                  child: const Text('Sign in')),
            ],
          ),
        ),
      ),
    );
  }
}
