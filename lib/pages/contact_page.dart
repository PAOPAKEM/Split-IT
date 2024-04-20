import 'package:flutter/material.dart';
import 'package:contacts_service/contacts_service.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:grouped_list/grouped_list.dart';

class ContactPage extends StatefulWidget {
  ContactPage({Key? key}) : super(key: key);

  @override
  _ContactPageState createState() => _ContactPageState();
}

class _ContactPageState extends State<ContactPage> {
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
        centerTitle: true,
        title: Text(
          'Contact',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField( 
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
                      ? Icon(Icons.star, color: Colors.black87)
                      : Icon(Icons.star_border_outlined, color: Colors.white.withOpacity(0)),
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
      bottomNavigationBar: BottomAppBar(
        shape: const CircularNotchedRectangle(),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: <Widget>[
            IconButton(
              icon: const Icon(Icons.home),
              onPressed: () {
                Navigator.pushReplacementNamed(context, '/home');
              },
              tooltip: "Home",
            ),
            IconButton(
              icon: const Icon(Icons.contacts),
              onPressed: () {
                Navigator.pushReplacementNamed(context, '/contact');
              },
              tooltip: "Contact",
            ),
            IconButton(
              icon: const Icon(Icons.account_circle),
              onPressed: () {},
              tooltip: "Profile",
            ),
          ],
        ),
      ),
    );
  }
}
