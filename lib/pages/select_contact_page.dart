import 'package:flutter/material.dart';
import 'package:contacts_service/contacts_service.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:grouped_list/grouped_list.dart';

class SelectContactPage extends StatefulWidget {
  final Map<String, dynamic> groupData;

  SelectContactPage({Key? key, required this.groupData}) : super(key: key);

  @override
  _SelectContactPageState createState() => _SelectContactPageState();
}

class _SelectContactPageState extends State<SelectContactPage> {
  List<Contact> _contacts = [];
  List<Contact> _selectedContacts = [];
  TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _getPermissionsAndContacts();
  }

  void _getPermissionsAndContacts() async {
    if (await Permission.contacts.request().isGranted) {
      Iterable<Contact> contacts = await ContactsService.getContacts(withThumbnails: false);
      setState(() {
        _contacts = contacts.toList();
      });
    }
  }

  void _saveGroup() async {
    // Retrieve the current user's UID
    final User? currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) {
      print('No user logged in');
      return;
    }
    String userUid = currentUser.uid;

    // Map the selected contacts to their identifi (like phone numbers, emails, etc.)
    // Note: You would need to ensure that the contact identifier is stored in your contacts
    List<String> selectedContact = _selectedContacts.map((contact) {
      // You might want to use another identifier for the contact that's consistent
      // across the app, such as a phone number or email.
      return contact.displayName ?? 'unknown';
    }).toList();

    // Add the selected contacts'  to the group data
    widget.groupData['members'] = selectedContact;

    // Reference the specific user's 'Groups' subcollection
    CollectionReference userGroups = FirebaseFirestore.instance.collection('Users').doc(userUid).collection('Groups');

    // Add the new group data to the user's 'Groups' subcollection
    await userGroups.add(widget.groupData).then((docRef) {
      print('Group added with ID: ${docRef.id}');
      // After saving the group, navigate to the home page
      Navigator.pushReplacementNamed(context, '/home');
    }).catchError((error) {
      // Handle errors, such as by showing a dialog to the user
      print('Error adding group: $error');
    });
  }

  @override
  Widget build(BuildContext context) {
    List<Contact> filteredContacts = _contacts;
    // Filter the contacts based on the search query
    if (_searchController.text.isNotEmpty) {
      filteredContacts = _contacts
          .where((contact) => contact.displayName!.toLowerCase().contains(_searchController.text.toLowerCase()))
          .toList();
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Select Participants'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                disabledBorder: InputBorder.none,
                fillColor: Colors.grey.shade300,
                border: InputBorder.none, // No border when not focused
                focusedBorder: InputBorder.none, // No border when focused
                labelText: 'Search contact',
                suffixIcon: Icon(Icons.search),
              ),
              onChanged: (value) {
                setState(() {}); // Refresh the list with the filtered contacts
              },
            ),
          ),
          Expanded(
            child: GroupedListView<Contact, String>(
              elements: filteredContacts,
              groupBy: (contact) => contact.displayName![0].toUpperCase(),
              groupSeparatorBuilder: (String groupByValue) => Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  groupByValue,
                  textAlign: TextAlign.right,
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
              itemBuilder: (context, Contact contact) {
                bool isSelected = _selectedContacts.contains(contact);
                return ListTile(
                  title: Text(contact.displayName ?? ''),
                  leading: (contact.avatar != null && contact.avatar!.isNotEmpty)
                      ? CircleAvatar(backgroundImage: MemoryImage(contact.avatar!))
                      : CircleAvatar(child: Text(contact.initials())),
                  trailing:
                      isSelected ? Icon(Icons.check_circle, color: Colors.green) : Icon(Icons.check_circle_outline),
                  onTap: () {
                    setState(() {
                      if (isSelected) {
                        _selectedContacts.remove(contact);
                      } else {
                        _selectedContacts.add(contact);
                      }
                    });
                  },
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: Colors.black), // Border color
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25.0),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 50),
                  ),
                  onPressed: () => Navigator.pop(context),
                  child: const Text(
                    'Cancel',
                    style: TextStyle(
                      fontSize: 16.0,
                      color: Colors.black, // Text color
                    ),
                  ),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    primary: Colors.black, // This is the background color
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25.0),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 50),
                  ),
                  onPressed: _saveGroup,
                  child: const Text(
                    'Save',
                    style: TextStyle(
                      fontSize: 16.0,
                      color: Colors.white, // Text color
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
