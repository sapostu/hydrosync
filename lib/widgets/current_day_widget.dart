import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CurrentDayWidget extends StatelessWidget {
  final String email;
  final int tempAdjustment;
  final int humidityAdjustment;

  CurrentDayWidget({required this.email, required this.tempAdjustment, required this.humidityAdjustment});

  Stream<QuerySnapshot> _currentDayStream() {
    return FirebaseFirestore.instance.collection('current_day').where('email', isEqualTo: email).snapshots();
  }

  int getAdjustedWater(int currentDay, int humidity, int temp) {
    return (currentDay + humidity + temp);
  }

  int getOriginalWater(int currentDay, int humidity, int temp) {
    return (currentDay - humidity - temp);
  }

  @override
  Widget build(BuildContext context) {
    print('CurrentDayWidget build method called');
    return StreamBuilder<QuerySnapshot>(
      stream: _currentDayStream(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          print('Waiting for current day data...');
          return CircularProgressIndicator();
        }
        if (snapshot.hasError) {
          print('Error in current day stream: ${snapshot.error}');
          return Text('Error: ${snapshot.error}');
        }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          print('No current day data available');
          return Text('No data for today');
        }
        var data = snapshot.data!.docs.first.data() as Map<String, dynamic>;
        int originalWaterPerDay = getOriginalWater(data['water_per_day'], humidityAdjustment, tempAdjustment);
        int adjustedWaterPerDay = getAdjustedWater(originalWaterPerDay, humidityAdjustment, tempAdjustment);

        print('Temperature adjustment: $tempAdjustment');
        print('Humidity adjustment: $humidityAdjustment');

        return Card(
          margin: EdgeInsets.all(8),
          child: Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              children: [
                Text('Water Per Day BEFORE ADJUSTMENT: $originalWaterPerDay liters'),
                // Text('---------------------------------'),
                // Text('TEMPERATURE ADJUSTMENT: $tempAdjustment'),
                // Text('HUMIDITY ADJUSTMENT: $humidityAdjustment'),
                Text('Current Water: ${data['current_water']} / $adjustedWaterPerDay'),
                Text('---------------------------------'),
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
