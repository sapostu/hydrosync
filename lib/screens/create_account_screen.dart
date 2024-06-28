import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'main_layout_screen.dart'; // Ensure the correct import path

class CreateAccountScreen extends StatefulWidget {
  @override
  _CreateAccountScreenState createState() => _CreateAccountScreenState();
}

class _CreateAccountScreenState extends State<CreateAccountScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  void _createAccount() async {
    DocumentReference accountRef = FirebaseFirestore.instance.collection('accounts').doc(_emailController.text);

    // Check if account already exists
    DocumentSnapshot accountSnapshot = await accountRef.get();
    if (accountSnapshot.exists) {
      // Show a banner if the account already exists
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Account exists already!"),
          backgroundColor: Colors.red,
        ),
      );
    } else {
      // Create the account if it does not exist
      accountRef.set({
        'email': _emailController.text,
        'password': _passwordController.text, // Consider using a secure way to store passwords.
        'did_quiz': false,
        'water_per_day': -1
      }).then((value) => Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => MainLayout(email: _emailController.text, password: _passwordController.text))
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Create Account')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            TextField(
              controller: _emailController,
              decoration: InputDecoration(labelText: 'Email'),
            ),
            TextField(
              controller: _passwordController,
              decoration: InputDecoration(labelText: 'Password'),
              obscureText: true,
            ),
            SizedBox(height: 20), // Provides spacing before the button
            ElevatedButton(
              onPressed: _createAccount,
              child: Text('Submit'),
            ),
          ],
        ),
      ),
    );
  }
}
