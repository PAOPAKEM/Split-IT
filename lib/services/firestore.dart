import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

class FirestoreService {
  // get collection of groups
  final CollectionReference _groupsCollection = FirebaseFirestore.instance.collection('groups');

  // Create
  Future<void> addGroup({required String name, required List<dynamic> members, String? bill}) {
    return _groupsCollection.add({
      'name': name,
      'members': members,
      'bill': bill, // bill image
      'timestamp': Timestamp.now(),
    });
  }
  // Read

  // Update

  // Delete
}
