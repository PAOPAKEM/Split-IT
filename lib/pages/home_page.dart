import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class HomePage extends StatelessWidget {
  HomePage({super.key});

  final user = FirebaseAuth.instance.currentUser!;

  @override
  Widget build(BuildContext context) {
    return Scaffold(backgroundColor: Colors.white, body: GroupPage());
  }
}

class GroupPage extends StatefulWidget {
  @override
  _GroupPageState createState() => _GroupPageState();
}

class _GroupPageState extends State<GroupPage> {
  // Placeholder for group data. You might have a class or structure for this.
  List<Map<String, dynamic>> groups = [
    {
      'image': 'https://via.placeholder.com/100x60',
      'name': 'Group 1',
      'date': '2024-03-30',
    },
    {
      'image': 'https://via.placeholder.com/100x60',
      'name': 'Group 2',
      'date': '2024-03-29',
    },
    {
      'image': 'https://via.placeholder.com/100x60',
      'name': 'Group 3',
      'date': '2024-04-29',
    },
  ];

  @override
  void initState() {
    super.initState();
    // TODO: Load your groups here from a database or state management solution.
  }

  Widget _buildGroupList() {
    return ListView.builder(
      itemCount: groups.length,
      itemBuilder: (context, index) {
        var group = groups[index];
        // Each group could be a card or another widget that displays info.
        return ListTile(
          leading: SizedBox(
            width: 100.0,
            height: 60.0,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(6.0),
              child: Image.network(
                group['image'],
                fit: BoxFit.cover, // This is important for resizing while keeping aspect ratio
              ),
            ),
          ), // Replace with proper image handling
          title: Text(group['name']),
          subtitle: Text('Date: ${group['date']}'),
          trailing: const Icon(Icons.chevron_right),
          onTap: () {
            // TODO: Implement navigation to group details
          },
        );
      },
    );
  }

  Widget _buildNoGroupView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Image.asset('assets/empty_group.png', width: 180.0),
          const SizedBox(height: 24.0),
          const Text(
            'Empty',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const Text('You haven’t created a group yet'),
        ],
      ),
    );
  }

  void signUserOut() {
    FirebaseAuth.instance.signOut();
    Navigator.of(context).pushReplacementNamed('/');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // By setting automaticallyImplyLeading to false, we prevent the AppBar from
        // showing a back button automatically.
        automaticallyImplyLeading: false,
        title: const Text(
          'Groups',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [IconButton(onPressed: signUserOut, icon: const Icon(Icons.logout))],
      ),
      body: groups.isEmpty ? _buildNoGroupView() : _buildGroupList(),
      bottomNavigationBar: BottomAppBar(
        shape: const CircularNotchedRectangle(),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: <Widget>[
            IconButton(icon: const Icon(Icons.home), onPressed: () {}),
            IconButton(icon: const Icon(Icons.contacts), onPressed: () {}),
            IconButton(icon: const Icon(Icons.account_circle), onPressed: () {}),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        // TODO: Implement group creation
        onPressed: createNewGroup,
        child: const Icon(Icons.add),
      ),
    );
  }

  void createNewGroup() {}
}
