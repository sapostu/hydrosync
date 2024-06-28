import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';  // Used for formatting date display
import 'main_layout_screen.dart';

class AddEntryScreen extends StatefulWidget {
  final String email;

  AddEntryScreen({required this.email});

  @override
  _AddEntryScreenState createState() => _AddEntryScreenState();
}

class _AddEntryScreenState extends State<AddEntryScreen> {
  final TextEditingController _waterQuantityController = TextEditingController();
  DateTime _selectedDate = DateTime.now();  // Default to today's date

  // Function to present date picker and handle user selection
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  void _addLogEntry() async {
    int waterQuantity = int.tryParse(_waterQuantityController.text) ?? 0;
    await FirebaseFirestore.instance.collection('logs').add({
      'email': widget.email,
      'water_quantity': waterQuantity,
      'date': Timestamp.fromDate(_selectedDate),
    });

    // Show an alert dialog on success
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Success"),
        content: Text("Entry added!"),
        actions: <Widget>[
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(); // Close the alert dialog
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (context) => MainLayout(email: widget.email, password: "")), // Redirect back to MainLayout
              );
            },
            child: Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add Log Entry'),
        automaticallyImplyLeading: false,
        ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: <Widget>[
            TextField(
              controller: _waterQuantityController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Water Quantity (liters)',
              ),
            ),
            SizedBox(height: 20),
            ListTile(
              title: Text("Date: ${DateFormat('yyyy-MM-dd').format(_selectedDate)}"),
              trailing: Icon(Icons.calendar_today),
              onTap: () => _selectDate(context),  // Trigger the date picker on tap
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
