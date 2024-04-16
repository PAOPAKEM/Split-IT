import 'package:flutter/material.dart';
import 'package:contacts_service/contacts_service.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:grouped_list/grouped_list.dart';
import 'package:split_it/components/error_alert.dart';

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
    final User? currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) {
      print('No user logged in');
      return;
    }
    String userUid = currentUser.uid;

    // Reference to the user's 'Groups' subcollection
    CollectionReference userGroups = FirebaseFirestore.instance.collection('Users').doc(userUid).collection('Groups');

    // Get the current number of groups to determine the next index
    QuerySnapshot querySnapshot = await userGroups.get();
    int currentGroupCount = querySnapshot.docs.length;

    String customGroupId = 'group_${currentGroupCount + 1}';

    List<String> selectedContact = _selectedContacts.map((contact) {
      return contact.displayName ?? 'unknown';
    }).toList();

    // Add yourself to members
    selectedContact.add("Me");

    // Add the selected contacts to the group data
    widget.groupData['members'] = selectedContact;
    widget.groupData['group_id'] = customGroupId;

    // Set the new group data with a custom document ID
    DocumentReference groupDocRef = userGroups.doc(customGroupId);

    await groupDocRef.set(widget.groupData).then((_) {
      print('Group added with custom ID: $customGroupId');
      Navigator.pushReplacementNamed(context, '/home');
    }).catchError((error) {
      // Handle errors by showing a dialog to the user
      showDialog(
        context: context,
        builder: (context) {
          return ErrorAlert(
            message: 'Error adding group',
            description: '$error',
          );
        },
      );
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
                hintText: 'Search contact',
                prefixIcon: Icon(Icons.search),
                filled: true,
                fillColor: Colors.grey.shade200,
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.grey.shade200),
                  borderRadius: BorderRadius.all(Radius.circular(8.0)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.grey.shade200),
                  borderRadius: BorderRadius.all(Radius.circular(8.0)),
                ),
                contentPadding: EdgeInsets.symmetric(vertical: 20, horizontal: 20),
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
                  trailing: isSelected
                      ? Icon(Icons.check_rounded, color: Colors.black87)
                      : Icon(Icons.check_rounded, color: Colors.white.withOpacity(0)),
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
        ],
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
                onPressed: _saveGroup,
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
}
