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
  late String _originalEmail;

  @override
  void initState() {
    super.initState();
    _emailController.text = widget.email;
    _originalEmail = widget.email;
    _fetchCurrentDetails();
  }

  void _fetchCurrentDetails() async {
    DocumentReference ref = FirebaseFirestore.instance.collection('accounts').doc(widget.email);
    DocumentSnapshot snapshot = await ref.get();
    if (snapshot.exists) {
      Map<String, dynamic> data = snapshot.data() as Map<String, dynamic>;
      _passwordController.text = data['password'] ?? '';
      _waterPerDayController.text = data['water_per_day'].toString();
    }
  }

  Future<void> _updateEmail(String newEmail) async {
    if (newEmail.isEmpty || newEmail == _originalEmail) return;

    DocumentReference newEmailRef = FirebaseFirestore.instance.collection('accounts').doc(newEmail);
    DocumentSnapshot newEmailSnapshot = await newEmailRef.get();

    if (newEmailSnapshot.exists) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Account exists already"), backgroundColor: Colors.red),
      );
      return;
    }

    DocumentReference originalRef = FirebaseFirestore.instance.collection('accounts').doc(_originalEmail);
    DocumentSnapshot originalSnapshot = await originalRef.get();
    if (originalSnapshot.exists) {
      Map<String, dynamic> data = originalSnapshot.data() as Map<String, dynamic>;
      data['email'] = newEmail; // Update the email field within the document
      await newEmailRef.set(data);
      await originalRef.delete();

      setState(() {
        _originalEmail = newEmail;
      });

      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text("Update Successful"),
          content: Text("Email updated successfully!"),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('OK'),
            ),
          ],
        ),
      );
    }
  }

  void _updateField(String field, dynamic value, String message) async {
    if (value == null || value.toString().isEmpty) return;

    FirebaseFirestore.instance.collection('accounts').doc(_originalEmail).update({
      field: value
    }).then((_) {
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
    }).catchError((error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update $message.'))
      );
    });
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
                  onPressed: () => _updateEmail(_emailController.text),
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
                    obscureText: true,
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

  void _startWaterQuiz() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => WaterQuizScreen(email: _originalEmail),
      ),
    );
  }
}
