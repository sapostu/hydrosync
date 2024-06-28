import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'main_layout_screen.dart'; // Make sure to import MainLayout correctly

class CreateAccountScreen extends StatefulWidget {
  @override
  _CreateAccountScreenState createState() => _CreateAccountScreenState();
}

class _CreateAccountScreenState extends State<CreateAccountScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  void _createAccount() async {
    FirebaseFirestore.instance.collection('accounts').doc(_emailController.text).set({
      'email': _emailController.text,
      'password': _passwordController.text, // Remember to use proper security practices for storing passwords.
      'did_quiz': false,
      'water_per_day': -1
    }).then((value) => Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => MainLayout(email: _emailController.text, password: _passwordController.text))
    ));
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
