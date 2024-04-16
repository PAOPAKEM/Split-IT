import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:split_it/pages/add_expense.dart';

class GroupDetailPage extends StatefulWidget {
  final Map<String, dynamic> groupData;

  GroupDetailPage({Key? key, required this.groupData}) : super(key: key);

  @override
  _GroupDetailPageState createState() => _GroupDetailPageState();
}

class _GroupDetailPageState extends State<GroupDetailPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _showFab = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(_handleTabSelection); // Listen for tab changes
  }

  void _handleTabSelection() {
    if (_tabController.index == 0) {
      // Check if 'Expenses' tab is active
      if (!_showFab) {
        setState(() {
          _showFab = true; // Show FAB when 'Expenses' tab is selected
        });
      }
    } else {
      if (_showFab) {
        setState(() {
          _showFab = false; // Hide FAB when other tabs are selected
        });
      }
    }
  }

  Widget _buildExpensesList() {
    // Assume 'groupDocId' is the document ID of your group in Firestore.
    final String groupDocId = widget.groupData['id'];
    final User? currentUser = FirebaseAuth.instance.currentUser;
    String userUid = currentUser!.uid;
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('Users')
          .doc(userUid)
          .collection('Groups')
          .doc(groupDocId)
          .collection('Expenses')
          .snapshots(),
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }
        switch (snapshot.connectionState) {
          case ConnectionState.waiting:
            return Center(child: CircularProgressIndicator());
          default:
            if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
              return Center(child: Text('No expenses added yet.'));
            }
            // Convert the snapshot to a list of expense widgets
            return ListView(
              children: snapshot.data!.docs.map((DocumentSnapshot document) {
                Map<String, dynamic> expense = document.data()! as Map<String, dynamic>;
                return ListTile(
                  leading: Text(
                    'x ${expense['pieces']}',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  title: Text(
                    expense['title'] ?? 'No title',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text('Price: ${expense['amount']}'),
                  trailing: Chip(
                      label: Text("${expense['amount'] * expense['pieces']}฿"), backgroundColor: Colors.blueGrey[50]),
                );
              }).toList(),
            );
        }
      },
    );
  }

  @override
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          widget.groupData['title'] ?? 'Trip Details',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
        ),
        actions: [
          PopupMenuButton<String>(
            color: Colors.white,
            onSelected: (String result) {
              switch (result) {
                case 'edit':
                  // Handle edit action
                  break;
                case 'delete':
                  // Handle delete action
                  break;
              }
            },
            itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
              PopupMenuItem<String>(
                value: 'edit',
                child: ListTile(
                  leading: Icon(Icons.edit_outlined),
                  title: Text('Edit Group'),
                ),
              ),
              PopupMenuItem<String>(
                value: 'delete',
                child: ListTile(
                  iconColor: Colors.red.shade400,
                  textColor: Colors.red.shade400,
                  leading: Icon(Icons.delete_outlined),
                  title: Text('Delete Group'),
                ),
              ),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          Image.network(
            widget.groupData['image_url'],
            fit: BoxFit.cover,
            height: 200,
            width: double.infinity,
          ),
          TabBar(
            controller: _tabController,
            labelColor: Colors.black,
            indicatorWeight: 4,
            tabs: [
              Tab(text: 'Expenses'),
              Tab(text: 'Bill'),
              Tab(text: 'Totals'),
            ],
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildExpensesList(),
                _buildBillView(), // This should now show the bill upload and view options
                Center(child: Text('Totals')) // This is a placeholder for the "Totals" tab
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: _showFab
          ? FloatingActionButton.extended(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => AddExpensePage(groupData: widget.groupData),
                  ),
                );
              },
              icon: Icon(Icons.add),
              label: Text(
                'Add Expense',
                style: TextStyle(color: Colors.black),
              ),
              backgroundColor: Colors.grey.shade400,
            )
          : null, // Only show the FAB when _showFab is true
    );
  }

  Future<void> _captureAndUploadBill() async {
    final ImagePicker _picker = ImagePicker();
    // Capture the image
    final XFile? image = await _picker.pickImage(source: ImageSource.camera);
    if (image == null) return; // User cancelled the picker

    final User? currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) return; // Ensure there's a user

    final String userUid = currentUser.uid;
    final String groupDocId = widget.groupData['id'];

    // Upload the image to Firebase Storage
    File file = File(image.path);
    String fileName = 'bill_${DateTime.now().millisecondsSinceEpoch}.jpg';
    try {
      // Uploading the image
      TaskSnapshot snapshot =
          await FirebaseStorage.instance.ref('users/$userUid/groups/$groupDocId/bills/$fileName').putFile(file);

      // Get the image URL
      final String downloadUrl = await snapshot.ref.getDownloadURL();

      // Store the image URL to Firestore
      await FirebaseFirestore.instance
          .collection('Users')
          .doc(userUid)
          .collection('Groups')
          .doc(groupDocId)
          .update({'bill_image_url': downloadUrl});

      // Set state to refresh the UI if needed
      setState(() {});
    } catch (e) {
      print('Error uploading bill image: $e');
      // Handle errors here
    }
  }

  // Add a state variable to trigger rebuilds
  String _lastUpdated = DateTime.now().toString();
  final String userUid = FirebaseAuth.instance.currentUser!.uid;

  Widget _buildBillView() {
    final String groupDocId = widget.groupData['id'];

    return FutureBuilder<DocumentSnapshot>(
      key: Key(_lastUpdated), // Use a unique key to force rebuild
      future: FirebaseFirestore.instance.collection('Users').doc(userUid).collection('Groups').doc(groupDocId).get(),
      builder: (BuildContext context, AsyncSnapshot<DocumentSnapshot> snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          if (snapshot.hasData && snapshot.data!.exists) {
            Map<String, dynamic> groupData = snapshot.data!.data() as Map<String, dynamic>;
            return SingleChildScrollView(
              child: Column(
                children: [
                  if (groupData['bill_image_url'] != null)
                    Image.network(groupData['bill_image_url'], fit: BoxFit.cover),
                  Padding(
                    padding: EdgeInsets.all(20),
                    child: groupData['bill_image_url'] != null ? Text('') : Text('No bill uploaded yet.'),
                  ),
                  ElevatedButton.icon(
                    icon: Icon(Icons.camera_alt),
                    label: Text('Capture Bill'),
                    onPressed: () {
                      _captureAndUploadBill().then((_) {
                        // Update lastUpdated to trigger a FutureBuilder rebuild
                        setState(() {
                          _lastUpdated = DateTime.now().toString();
                        });
                      });
                    },
                  ),
                ],
              ),
            );
          } else {
            return SingleChildScrollView(
              child: Column(
                children: [
                  Padding(
                    padding: EdgeInsets.all(20),
                    child: Text('No bill uploaded yet.'),
                  ),
                  ElevatedButton.icon(
                    icon: Icon(Icons.camera_alt),
                    label: Text('Capture Bill'),
                    onPressed: _captureAndUploadBill,
                  ),
                ],
              ),
            );
          }
        }

        return Center(child: CircularProgressIndicator());
      },
    );
  }

  @override
  void dispose() {
    _tabController.removeListener(_handleTabSelection); // Remove listener on dispose
    _tabController.dispose();
    super.dispose();
  }
}
