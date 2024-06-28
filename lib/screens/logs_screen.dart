import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart'; // Add this import to format dates

class LogsScreen extends StatelessWidget {
  final String email; // Add an email parameter to pass the current user's email

  LogsScreen({required this.email}); // Modify the constructor to accept the email

  @override
  Widget build(BuildContext context) {
    print("LogsScreen build initiated for email: $email"); // Debug: Track which user's logs are loaded
    // Accessing Firestore to retrieve logs ordered by date, filtered by email
    final Stream<QuerySnapshot> _logsStream = FirebaseFirestore.instance
        .collection('logs')
        .where('email', isEqualTo: email) // Filter logs by email
        .orderBy('date', descending: true) // Ensuring the logs are shown in chronological order
        .snapshots();

    return Scaffold(
      appBar: AppBar(
        title: Text('Logs'),
        automaticallyImplyLeading: false
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _logsStream,
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.hasError) {
            print("Error loading logs: ${snapshot.error}"); // Debug: Error in fetching logs
            return Text('Something went wrong');
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            print("Waiting for logs data..."); // Debug: Logs data loading state
            return Center(child: CircularProgressIndicator());
          }

          print("Displaying logs data..."); // Debug: Logs data is ready to be displayed
          // Displaying logs in a list view
          return ListView(
            children: snapshot.data!.docs.map((DocumentSnapshot document) {
              Map<String, dynamic> data = document.data()! as Map<String, dynamic>;
              // Convert Timestamp to DateTime and format it
              DateTime date = (data['date'] as Timestamp).toDate();
              String formattedDate = DateFormat('yyyy-MM-dd – kk:mm').format(date); // Example format

              return ListTile(
                leading: Icon(Icons.water_drop), // Icon for visual hint
                title: Text(formattedDate), // Displaying formatted date
                subtitle: Text('Water Quantity: ${data['water_quantity']} liters'), // Displaying water quantity
              );
            }).toList(),
          );
        },
      ),
    );
  }
}
