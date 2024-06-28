import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart'; // For date formatting
import 'main_layout_screen.dart'; // Ensure you have the correct import path for MainLayout

class AddEntryScreen extends StatefulWidget {
  final String email;

  AddEntryScreen({required this.email});

  @override
  _AddEntryScreenState createState() => _AddEntryScreenState();
}

class _AddEntryScreenState extends State<AddEntryScreen> {
  final TextEditingController _waterQuantityController = TextEditingController();
  DateTime _selectedDate = DateTime.now();

  void _addLogEntry() async {
    final waterQuantity = int.tryParse(_waterQuantityController.text);

    if (waterQuantity == null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Invalid water quantity')));
      return;
    }

    // Create the log entry
    final newLog = {
      'email': widget.email,
      'water_quantity': waterQuantity,
      'date': Timestamp.fromDate(_selectedDate),
    };

    await FirebaseFirestore.instance.collection('logs').add(newLog);

    // Check if the log entry date is today
    final today = DateTime.now();
    if (_selectedDate.year == today.year &&
        _selectedDate.month == today.month &&
        _selectedDate.day == today.day) {
      // Update current_water in current_day collection
      final currentDayRef = FirebaseFirestore.instance.collection('current_day').where('email', isEqualTo: widget.email);
      final querySnapshot = await currentDayRef.get();

      if (querySnapshot.docs.isNotEmpty) {
        final doc = querySnapshot.docs.first;
        final currentWater = doc['current_water'] ?? 0;
        final waterPerDay = doc['water_per_day'] ?? 0;
        final newCurrentWater = currentWater + waterQuantity;

        // Check and update completed_today based on the new water consumption
        bool completedToday = newCurrentWater >= waterPerDay;

        await doc.reference.update({
          'current_water': newCurrentWater,
          'completed_today': completedToday,
        });
      } else {
        // If no document exists for the current day, create one
        bool completedToday = waterQuantity >= 0; // Assuming water_per_day defaults to 0 if not set

        await FirebaseFirestore.instance.collection('current_day').add({
          'email': widget.email,
          'current_water': waterQuantity,
          'water_per_day': 0, // default value, adjust as necessary
          'completed_today': completedToday,
        });
      }
    }

    // Show success message and navigate back to main layout
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Entry Added"),
        content: Text("Log entry added successfully!"),
        actions: <Widget>[
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => MainLayout(email: widget.email, password: "YourPasswordHere")), // Update the handling of the password
                (Route<dynamic> route) => false,
              );
            },
            child: Text('OK'),
          ),
        ],
      ),
    );
  }

  void _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Add Log Entry')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            TextField(
              controller: _waterQuantityController,
              decoration: InputDecoration(labelText: 'Water Quantity (liters)'),
              keyboardType: TextInputType.number,
            ),
            SizedBox(height: 10),
            Row(
              children: <Widget>[
                Text("Date: ${DateFormat('yyyy-MM-dd').format(_selectedDate)}"),
                IconButton(
                  icon: Icon(Icons.calendar_today),
                  onPressed: () => _selectDate(context),
                ),
              ],
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _addLogEntry,
              child: Text('Add Entry'),
            ),
          ],
        ),
      ),
    );
  }
}
