import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:split_it/pages/select_contact_page.dart';

class NewGroupPage extends StatefulWidget {
  @override
  _NewGroupPageState createState() => _NewGroupPageState();
}

class _NewGroupPageState extends State<NewGroupPage> {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  final ImagePicker _picker = ImagePicker();
  XFile? _imageFile;

  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  DateTime _selectedDate = DateTime.now();
  String _selectedCategory = 'Other';

  // You may need to create a data model or class for this.
  List<Category> categories = [
    Category('Trip', Icons.flight_takeoff),
    Category('Family', Icons.family_restroom),
    Category('Couple', Icons.favorite),
    Category('Event', Icons.event),
    Category('Project', Icons.work),
    Category('Other', Icons.more_horiz),
  ];

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final XFile? pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    setState(() {
      _imageFile = pickedFile;
    });
  }

  Future<void> _uploadImageAndSaveGroup() async {
    if (_formKey.currentState!.validate()) {
      String? localImagePath;

      if (_imageFile != null) {
        // Use the local file path
        localImagePath = _imageFile!.path;
        print('File Path: $localImagePath');
      } else {
        print('No image file selected');
        return;
      }

      // Generate the rest of the group details
      final newGroup = {
        'title': _titleController.text,
        'description': _descriptionController.text,
        'date': _selectedDate,
        'category': _selectedCategory,
        'image_path': localImagePath,
      };

      // Navigate to SelectContactPage with the newGroup data
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => SelectContactPage(groupData: newGroup),
        ),
      );
    }
  }

  void _pickDate() async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (pickedDate != null && pickedDate != _selectedDate) {
      setState(() {
        _selectedDate = pickedDate;
      });
    }
  }

  Widget _buildCategoryChips() {
    return Wrap(
      spacing: 8.0,
      runSpacing: 8.0,
      children: categories.map((category) {
        bool isSelected = _selectedCategory == category.name;
        return ChoiceChip(
          avatar: Icon(
            category.icon,
            size: 20.0,
            color: isSelected ? Colors.white : Colors.black,
          ),
          label: Text(category.name),
          selected: isSelected,
          onSelected: (selected) {
            setState(() {
              _selectedCategory = (selected ? category.name : null)!;
            });
          },
          selectedColor: Colors.black87, // Change to your desired color
          labelStyle: TextStyle(color: isSelected ? Colors.white : Colors.black),
          backgroundColor: isSelected ? Colors.black54 : Colors.grey.shade200, // Change to your desired color
          showCheckmark: false,
          padding: EdgeInsets.symmetric(horizontal: 10.0, vertical: 10.0),
          side: BorderSide.none,
        );
      }).toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('New Group'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: EdgeInsets.all(16),
          children: <Widget>[
            GestureDetector(
              onTap: _pickImage,
              child: Container(
                height: 150,
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(20.0),
                ),
                alignment: Alignment.center,
                child: _imageFile == null
                    ? Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Icon(Icons.image_outlined, color: Colors.black45, size: 50),
                          Text('Upload Cover Image', style: TextStyle(color: Colors.black45))
                        ],
                      )
                    : ClipRRect(
                        borderRadius: BorderRadius.circular(20.0),
                        child: Image.file(File(_imageFile!.path), fit: BoxFit.cover),
                      ),
              ),
            ),
            SizedBox(height: 16),
            Text(
              'Title',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
            ),
            TextFormField(
              controller: _titleController,
              decoration: InputDecoration(
                  border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(16))), hintText: 'Title'),
            ),
            SizedBox(height: 16),
            Text(
              'Description',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
            ),
            TextFormField(
              controller: _descriptionController,
              maxLines: 3,
              decoration: InputDecoration(
                  border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(16))),
                  hintText: 'Description'),
            ),
            SizedBox(height: 16),
            Text(
              'Date',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
            ),
            InkWell(
              onTap: _pickDate,
              child: Container(
                padding: EdgeInsets.symmetric(vertical: 0),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey), // Set the border color here
                  borderRadius: BorderRadius.circular(16.0), // Set the border radius here
                ),
                child: ListTile(
                  contentPadding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                  title: Text(
                    DateFormat('dd/MM/yyyy').format(_selectedDate),
                    style: TextStyle(fontSize: 16), // Add the font size or any other style you want
                  ),
                  trailing: Icon(Icons.calendar_today),
                ),
              ),
            ),
            SizedBox(height: 16),
            _buildCategoryChips(),
            SizedBox(height: 16),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        padding: EdgeInsets.all(8),
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.black, // This is the background color
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20.0),
            ),
            padding: const EdgeInsets.symmetric(vertical: 16.0),
          ),
          onPressed: _uploadImageAndSaveGroup,
          child: const Text(
            'Continue',
            style: TextStyle(
              fontSize: 16.0,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}

class Category {
  String name;
  IconData icon;
  Category(this.name, this.icon);
}
