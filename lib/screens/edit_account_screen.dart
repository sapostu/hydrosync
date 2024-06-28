import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'water_quiz_screen.dart';

class EditAccountScreen extends StatefulWidget {
  final String email;

  EditAccountScreen({required this.email});

  @override
  _EditAccountScreenState createState() => _EditAccountScreenState();
}

class _EditAccountScreenState extends State<EditAccountScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _waterPerDayController = TextEditingController();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  void initState() {
    super.initState();
    _emailController.text = widget.email;
    _fetchCurrentDetails();
  }

  void _fetchCurrentDetails() async {
    DocumentReference ref = _firestore.collection('accounts').doc(widget.email);
    DocumentSnapshot snapshot = await ref.get();
    if (snapshot.exists) {
      Map<String, dynamic> data = snapshot.data() as Map<String, dynamic>;
      _passwordController.text = data['password'] ?? '';
      _waterPerDayController.text = data['water_per_day'].toString();
    }
  }

  Future<void> _updateField(String field, dynamic value, String message) async {
    if (value == null || value.toString().isEmpty) return;

    try {
      await _firestore.collection('accounts').doc(widget.email).update({
        field: value
      });

      if (field == 'water_per_day') {
        // Update current_day collection as well
        QuerySnapshot snapshot = await _firestore.collection('current_day').where('email', isEqualTo: widget.email).get();
        if (snapshot.docs.isNotEmpty) {
          DocumentReference currentDayRef = snapshot.docs.first.reference;
          await currentDayRef.update({'water_per_day': value});
        }
      }

      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text("Update Successful"),
          content: Text("$message updated successfully!"),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('OK'),
            ),
          ],
        ),
      );
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update $message. Error: $error'))
      );
    }
  }

  Future<void> _startWaterQuiz() async {
    final result = await Navigator.push<int>(
      context,
      MaterialPageRoute(
        builder: (context) => WaterQuizScreen(email: widget.email),
      ),
    );

    if (result != null) {
      // Update current_day collection with the new water_per_day value
      QuerySnapshot snapshot = await _firestore.collection('current_day').where('email', isEqualTo: widget.email).get();
      if (snapshot.docs.isNotEmpty) {
        DocumentReference currentDayRef = snapshot.docs.first.reference;
        await currentDayRef.update({'water_per_day': result});
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Account'),
        automaticallyImplyLeading: false
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              'For best results, change water per day with quiz',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _emailController,
                    decoration: InputDecoration(labelText: 'Email'),
                  ),
                ),
                ElevatedButton(
                  onPressed: () => _updateField('email', _emailController.text, 'Email'),
                  child: Text('Update'),
                ),
              ],
            ),
            SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _passwordController,
                    decoration: InputDecoration(labelText: 'Password'),
                    obscureText: false,
                  ),
                ),
                ElevatedButton(
                  onPressed: () => _updateField('password', _passwordController.text, 'Password'),
                  child: Text('Update'),
                ),
              ],
            ),
            SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _waterPerDayController,
                    decoration: InputDecoration(labelText: 'Water per day (liters)'),
                    keyboardType: TextInputType.number,
                  ),
                ),
                ElevatedButton(
                  onPressed: () => _updateField('water_per_day', int.tryParse(_waterPerDayController.text), 'Water per day'),
                  child: Text('Update'),
                ),
              ],
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _startWaterQuiz,
              child: Text('Water Quiz'),
            ),
          ],
        ),
      ),
    );
  }
}
