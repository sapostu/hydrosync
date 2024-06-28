import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CurrentDayWidget extends StatelessWidget {
  final String email;

  CurrentDayWidget({required this.email});

  Stream<QuerySnapshot> _currentDayStream() {
    return FirebaseFirestore.instance.collection('current_day').where('email', isEqualTo: email).snapshots();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: _currentDayStream(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return CircularProgressIndicator();
        }
        if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Text('No data for today');
        }
        var data = snapshot.data!.docs.first.data() as Map<String, dynamic>;
        return Card(
          margin: EdgeInsets.all(8),
          child: Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              children: [
                Text('Current Water: ${data['current_water']} / ${data['water_per_day']}'),
                Text((data['completed_today']) ? 
                  'Good job! You met your water goal for the day' : 
                  'Almost there! Please drink more water' ),
              ],
            ),
          ),
        );
      },
    );
  }
}
