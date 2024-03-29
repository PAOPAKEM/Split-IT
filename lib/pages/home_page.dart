import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class HomePage extends StatelessWidget {
  HomePage({super.key});

  final user = FirebaseAuth.instance.currentUser!;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white,
        body: GroupPage());
  }
}

class GroupPage extends StatefulWidget {
  @override
  _GroupPageState createState() => _GroupPageState();
}

class _GroupPageState extends State<GroupPage> {
  // Placeholder for group data. You might have a class or structure for this.
  List<Map<String, dynamic>> groups = [];

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
          leading: Image.network(group['image']), // Replace with proper image handling
          title: Text(group['name']),
          subtitle: Text('Date: ${group['date']}'),
          trailing: Icon(Icons.chevron_right),
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
          SizedBox(height: 24.0),
          Text('Empty',style: TextStyle(fontWeight: FontWeight.bold),),
          Text('You haven’t created a group yet'),
        ],
      ),
    );
  }
  
  void signUserOut() {
    FirebaseAuth.instance.signOut();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Groups',style: TextStyle(fontWeight: FontWeight.bold),),
        actions: [IconButton(onPressed: signUserOut, icon: const Icon(Icons.logout))],
      ),
      body: groups.isEmpty ? _buildNoGroupView() : _buildGroupList(),
      bottomNavigationBar: BottomAppBar(
        shape: CircularNotchedRectangle(),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: <Widget>[
            IconButton(icon: Icon(Icons.home), onPressed: () {}),
            IconButton(icon: Icon(Icons.contacts), onPressed: () {}),
            IconButton(icon: Icon(Icons.account_circle), onPressed: () {}),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // TODO: Implement group creation
        },
        child: Icon(Icons.add),
      ),
    );
  }
}
