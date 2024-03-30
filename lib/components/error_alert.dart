// ignore_for_file: must_be_immutable

import 'package:flutter/material.dart';

class ErrorAlert extends StatelessWidget {
  String message;
  String description;

  ErrorAlert({
    super.key,
    required this.message,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            message,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
      content: Text(
        description,
        textAlign: TextAlign.center,
      ),
      backgroundColor: Colors.white,
    );
  }
}
