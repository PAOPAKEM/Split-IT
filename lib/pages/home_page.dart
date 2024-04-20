import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:split_it/pages/group_datail.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';

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
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  @override
  void initState() {
    super.initState();
  }

  Stream<List<Map<String, dynamic>>> getGroupStream() {
    final String userUid = FirebaseAuth.instance.currentUser!.uid;
    return firestore
        .collection('Users')
        .doc(userUid)
        .collection('Groups')
        .orderBy('date', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        var data = doc.data();
        data['id'] = doc.id; // Include the document ID in the data map
        return data;
      }).toList();
    });
  }

  Widget _buildGroupList(List<Map<String, dynamic>> groups) {
    return AnimationLimiter(
      child: ListView.builder(
        itemCount: groups.length,
        itemBuilder: (context, index) {
          var group = groups[index];
          var formattedDate = group['date'] != null
              ? DateFormat('dd/MM/yyyy').format(
                  (group['date'] as Timestamp).toDate(),
                )
              : 'No Date'; // Handling potential null values
          return AnimationConfiguration.staggeredList(
            position: index,
            duration: const Duration(milliseconds: 375),
            child: SlideAnimation(
              verticalOffset: 50.0,
              child: FadeInAnimation(
                child: ListTile(
                  leading: group['image_url'] != null
                      ? SizedBox(
                          width: 100.0,
                          height: 60.0,
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(6.0),
                            child: Image.network(
                              group['image_url'],
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                // If there's an error loading the image, display a placeholder
                                return const Placeholder(fallbackHeight: 60.0, fallbackWidth: 100.0);
                              },
                            ),
                          ),
                        )
                      : SizedBox(
                          width: 100.0,
                          height: 60.0,
                          child: Image.asset('assets/100x60.png'), // Placeholder when there's no image
                        ),
                  title: Text(group['title'] ?? 'No Title'),
                  subtitle: Text('Date: $formattedDate'), // Use formatted date
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => GroupDetailPage(groupData: group),
                      ),
                    );
                  },

                  contentPadding: const EdgeInsets.all(12),
                ),
              ),
            ),
          );
        },
      ),
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
        centerTitle: true,
        automaticallyImplyLeading: false,
        title: const Text(
          'Groups',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [IconButton(onPressed: signUserOut, icon: const Icon(Icons.logout), tooltip: "Log out")],
      ),
      body: StreamBuilder<List<Map<String, dynamic>>>(
        stream: getGroupStream(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (snapshot.error != null) {
            return Center(child: Text("Error loading groups"));
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return _buildNoGroupView();
          }
          return _buildGroupList(snapshot.data!);
        },
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
      floatingActionButton: Container(
        height: 60,
        width: 60,
        child: FloatingActionButton(
          shape: const CircleBorder(),
          backgroundColor: Colors.grey.shade400,
          onPressed: () {
            Navigator.pushNamed(context, '/newgroup');
          },
          child: const Icon(
            Icons.add,
            size: 30,
            color: Colors.black,
          ),
        ),
      ),
    );
  }
}
