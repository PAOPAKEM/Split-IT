import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AddExpensePage extends StatefulWidget {
  final Map<String, dynamic> groupData;

  const AddExpensePage({super.key, required this.groupData});

  @override
  _AddExpensePageState createState() => _AddExpensePageState();
}

class _AddExpensePageState extends State<AddExpensePage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _pieceController = TextEditingController();
  String? _selectedCategory;

  void _showCategoryPicker(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Container(
          height: 300,
          child: ListView(
            // TODO: Need to Revise for proper category
            children: [
              ListTile(
                leading: Icon(Icons.games, color: Colors.red),
                title: Text('Games'),
                onTap: () => _selectCategory('Games'),
              ),
              ListTile(
                leading: Icon(Icons.movie, color: Colors.red),
                title: Text('Movies'),
                onTap: () => _selectCategory('Movies'),
              ),
              ListTile(
                leading: Icon(Icons.music_note, color: Colors.red),
                title: Text('Music'),
                onTap: () => _selectCategory('Music'),
              ),
              ListTile(
                leading: Icon(Icons.directions_run, color: Colors.red),
                title: Text('Sports'),
                onTap: () => _selectCategory('Sports'),
              ),
              ListTile(
                leading: Icon(Icons.shopping_cart, color: Colors.green),
                title: Text('Groceries'),
                onTap: () => _selectCategory('Groceries'),
              ),
              ListTile(
                leading: Icon(Icons.restaurant, color: Colors.green),
                title: Text('Dining Out'),
                onTap: () => _selectCategory('Dining Out'),
              ),
              ListTile(
                leading: Icon(Icons.local_bar, color: Colors.green),
                title: Text('Liquor'),
                onTap: () => _selectCategory('Liquor'),
              ),
              // ... add more categories if needed ...
            ],
          ),
        );
      },
    );
  }

  void _selectCategory(String category) {
    Navigator.pop(context); // Close the bottom sheet
    setState(() {
      _selectedCategory = category;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          'Add New Expense',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
        ),
        backgroundColor: Colors.white,
        iconTheme: IconThemeData(color: Colors.black),
        elevation: 0,
        toolbarTextStyle: TextTheme(titleLarge: TextStyle(color: Colors.black)).bodyMedium,
        titleTextStyle: TextTheme(titleLarge: TextStyle(color: Colors.black)).titleLarge,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _titleController,
                decoration: InputDecoration(
                  border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(16))),
                  hintText: 'Title',
                ),
              ),
              SizedBox(height: 16),
              Text(
                'Amount (THB)',
                style: TextStyle(fontWeight: FontWeight.w500, fontSize: 16),
              ),
              TextFormField(
                keyboardType: TextInputType.number,
                controller: _amountController,
                decoration: InputDecoration(
                  border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(16))),
                  hintText: 'Price per piece',
                ),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
                ],
                validator: (value) {
                  if (value != null && value.isEmpty) {
                    return 'Please enter an amount';
                  }
                  if (value != null && double.tryParse(value) == null) {
                    return 'Please enter a valid number';
                  }
                  return null; // Return null if the input is valid
                },
              ),
              SizedBox(height: 16),
              Text(
                'Piece',
                style: TextStyle(fontWeight: FontWeight.w500, fontSize: 16),
              ),
              TextFormField(
                controller: _pieceController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(16))),
                  hintText: 'Enter number of pieces',
                ),
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                ],
                validator: (value) {
                  if (value != null && value.isEmpty) {
                    return 'Please enter a number'; // Validation message
                  }
                  // Add additional validation if needed
                  return null; // Return null if the input is valid
                },
              ),
              SizedBox(height: 16),
              Text(
                'Category',
                style: TextStyle(fontWeight: FontWeight.w500, fontSize: 16),
              ),
              GestureDetector(
                onTap: () => _showCategoryPicker(context),
                child: InputDecorator(
                  decoration: InputDecoration(
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(16.0)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        _selectedCategory ?? 'Select Category',
                        style: TextStyle(
                          color: Colors.black54,
                          fontSize: 16,
                        ),
                      ),
                      Icon(
                        Icons.arrow_drop_down_rounded,
                        color: Colors.black54,
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 20),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Container(
        padding: EdgeInsets.all(8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Expanded(
              child: ElevatedButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text(
                  'Cancel',
                  style: TextStyle(color: Colors.black),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  shape: StadiumBorder(side: BorderSide(color: Colors.black87, width: 1.5)),
                  padding: const EdgeInsets.symmetric(vertical: 16.0),
                ),
              ),
            ),
            SizedBox(width: 10),
            Expanded(
              child: ElevatedButton(
                onPressed: () {
                  saveExpense();
                },
                child: Text(
                  'Save',
                  style: TextStyle(color: Colors.white),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black87,
                  shape: StadiumBorder(),
                  padding: const EdgeInsets.symmetric(vertical: 16.0),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void saveExpense() async {
    if (_formKey.currentState!.validate()) {
      final User? currentUser = FirebaseAuth.instance.currentUser;
      String userUid = currentUser!.uid;

      // Construct the expense data map
      final newExpense = {
        'title': _titleController.text,
        'amount': double.tryParse(_amountController.text) ?? 0,
        'pieces': int.tryParse(_pieceController.text) ?? 0,
        'category': _selectedCategory,
      };

      final firestore = FirebaseFirestore.instance;
      QuerySnapshot groupQuerySnapshot = await firestore
          .collection('Users')
          .doc(userUid)
          .collection('Groups')
          .where('title', isEqualTo: widget.groupData['title'])
          .get();

      if (groupQuerySnapshot.docs.isNotEmpty) {
        // Assuming the title is unique, there should only be one document.
        DocumentSnapshot groupDocSnapshot = groupQuerySnapshot.docs.first;

        // Now we have the group ID.
        String groupId = groupDocSnapshot.id;
        print('Obtained Group ID: $groupId');

        // use this groupId to reference the Expenses subcollection.
        CollectionReference expenses =
            firestore.collection('Users').doc(userUid).collection('Groups').doc(groupId).collection('Expenses');

        // Add the new expense to this group.
        DocumentReference docRef = await expenses.add(newExpense);
        print('Expense added with ID: ${docRef.id}');
      }
      Navigator.pop(context);
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _amountController.dispose();
    _pieceController.dispose();
    super.dispose();
  }
}
