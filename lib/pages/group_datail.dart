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
    _tabController = TabController(length: 4, vsync: this);
    _tabController.addListener(_handleTabSelection); // Listen for tab changes
  }

  @override
  void dispose() {
    _tabController.removeListener(_handleTabSelection); // Remove listener on dispose
    _tabController.dispose();
    super.dispose();
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
                  showDeleteConfirmationDialog();
                  break;
                case 'notify':
                  // Handle notify action
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
              PopupMenuItem<String>(
                value: 'Notify',
                child: ListTile(
                  leading: Icon(Icons.notifications_active_outlined),
                  title: Text('Notify Group'),
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
              Tab(text: 'Info'),
            ],
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildExpensesList(),
                _buildBillView(),
                _buildTotalsView(),
                _buildGroupInfo(),
              ],
            ),
          )
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
              icon: Icon(Icons.add, color: Colors.black),
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
          await FirebaseStorage.instance.ref('user_bill/$userUid/$groupDocId/$fileName').putFile(file);

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

  Widget _buildExpensesList() {
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

  // Add a state variable to trigger rebuilds
  String _lastUpdated = DateTime.now().toString();
  final String userUid = FirebaseAuth.instance.currentUser!.uid;

  Widget _buildBillView() {
    final String groupDocId = widget.groupData['id'];

    return FutureBuilder<DocumentSnapshot>(
      key: Key(_lastUpdated), // Use a unique key to force rebuild
      future: FirebaseFirestore.instance.collection('Users').doc(userUid).collection('Groups').doc(groupDocId).get(),
      builder: (BuildContext context, AsyncSnapshot<DocumentSnapshot> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }
        if (snapshot.connectionState == ConnectionState.done) {
          if (snapshot.hasData && snapshot.data!.exists) {
            Map<String, dynamic> groupData = snapshot.data!.data() as Map<String, dynamic>;
            return SingleChildScrollView(
              child: Column(
                children: [
                  Padding(
                    padding: EdgeInsets.all(20),
                    child: groupData['bill_image_url'] != null
                        ? Image.network(
                            groupData['bill_image_url'],
                            fit: BoxFit.cover,
                            height: MediaQuery.of(context).size.height / 2,
                          )
                        : Text('No bill uploaded yet.'),
                  ),
                  ElevatedButton.icon(
                    icon: Icon(
                      Icons.camera_alt,
                      color: Colors.white,
                    ),
                    label: Text(
                      'Capture Bill',
                      style: TextStyle(color: Colors.white),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20.0),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 10),
                    ),
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

  Widget _buildTotalsView() {
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
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }

        // Calculate total expense for each user
        double totalExpense = 0;
        if (snapshot.hasData) {
          snapshot.data!.docs.forEach((DocumentSnapshot document) {
            Map<String, dynamic> expense = document.data()! as Map<String, dynamic>;
            double amount = expense['amount'] ?? 0;
            int pieces = expense['pieces'] ?? 0;

            // Calculate total expense
            totalExpense += amount * pieces;
          });
        }

        // Calculate total amount each user needs to pay
        int numberOfUsers = widget.groupData['members'].length;
        double amountPerUser = totalExpense / numberOfUsers;

        // Build the UI
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Container(
                    width: MediaQuery.of(context).size.width * 0.4,
                    height: 100,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.grey.shade400),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.2),
                          spreadRadius: 0.5,
                          blurRadius: 2,
                          offset: Offset(0, 2), // changes position of shadow
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Total',
                          style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                        ),
                        SizedBox(height: 4),
                        Text(
                          '฿$totalExpense',
                          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    width: MediaQuery.of(context).size.width * 0.4,
                    height: 100,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.grey.shade400),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.2),
                          spreadRadius: 1,
                          blurRadius: 2,
                          offset: Offset(0, 2), // changes position of shadow
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Each Person',
                          style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                        ),
                        SizedBox(height: 4),
                        Text(
                          '฿${amountPerUser.toStringAsFixed(2)}',
                          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 16),
          ],
        );
      },
    );
  }

  Widget _buildGroupInfo() {
    return SingleChildScrollView(
      scrollDirection: Axis.vertical,
      child: Container(
        padding: EdgeInsets.all(10),
        margin: EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Group Title',
              style: TextStyle(fontSize: 16.0, color: Colors.grey),
            ),
            Text(
              widget.groupData['title'],
              style: TextStyle(fontSize: 20.0),
            ),
            SizedBox(height: 12),
            Text(
              'Description',
              style: TextStyle(fontSize: 16.0, color: Colors.grey),
            ),
            Text(
              widget.groupData['description'],
              style: TextStyle(fontSize: 20.0),
            ),
            SizedBox(height: 12),
            Text(
              'Category',
              style: TextStyle(fontSize: 16.0, color: Colors.grey),
            ),
            Text(
              widget.groupData['category'],
              style: TextStyle(fontSize: 20.0),
            ),
            SizedBox(height: 12),
            Divider(thickness: 0.5, color: Colors.grey[400], indent: 5, endIndent: 5),
            Text(
              'Group Members',
              style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold),
            ),
            Container(
              height: 300,
              child: ListView.builder(
                itemCount: widget.groupData['members'].length,
                itemBuilder: (context, index) {
                  String memberName = widget.groupData['members'][index];
                  return ListTile(
                    title: Text(memberName),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> showDeleteConfirmationDialog() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // User must tap button to dismiss the dialog
      useSafeArea: true,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          title: Text(
            'Delete Group',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.red[400], fontWeight: FontWeight.w500),
          ),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Divider(
                  thickness: 1,
                ),
                Text('Are you sure you want to delete the group?', textAlign: TextAlign.center),
                SizedBox(
                  height: 10,
                ),
                Text(widget.groupData['title'],
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold), textAlign: TextAlign.center)
              ],
            ),
          ),
          actions: <Widget>[
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
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
                        shape: StadiumBorder(side: BorderSide(color: Colors.black87)),
                        padding: const EdgeInsets.symmetric(vertical: 16.0),
                      ),
                    ),
                  ),
                  SizedBox(width: 8),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                        deleteGroup();
                      },
                      child: Text(
                        'Delete',
                        style: TextStyle(color: Colors.white),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black87,
                        shape: StadiumBorder(side: BorderSide(color: Colors.white)),
                        padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 16),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> deleteGroup() async {
    try {
      final String groupDocId = widget.groupData['id'];
      final User? currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) return; // Ensure there's a user

      final String userUid = currentUser.uid;

      // Reference to the group's expenses collection
      final CollectionReference expenses = FirebaseFirestore.instance
          .collection('Users')
          .doc(userUid)
          .collection('Groups')
          .doc(groupDocId)
          .collection('Expenses');

      // Retrieve all expense documents in the group
      final QuerySnapshot expenseSnapshot = await expenses.get();

      // Use a WriteBatch to delete all expenses in one operation
      WriteBatch batch = FirebaseFirestore.instance.batch();
      for (DocumentSnapshot expenseDoc in expenseSnapshot.docs) {
        batch.delete(expenseDoc.reference);
      }

      // Delete the group document after all expenses have been scheduled for deletion
      batch.delete(FirebaseFirestore.instance.collection('Users').doc(userUid).collection('Groups').doc(groupDocId));

      // Commit the batch write to execute all deletions
      await batch.commit();

      // Navigate back to the previous screen after deletion
      Navigator.pop(context);
    } catch (error) {
      print('Error deleting group: $error');
    }
  }
}
