import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'main_layout_screen.dart';  // Make sure you have a file named 'main_layout.dart'

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  void _signIn() async {
    var collection = FirebaseFirestore.instance.collection('accounts');
    var querySnapshot = await collection.where('email', isEqualTo: _emailController.text).where('password', isEqualTo: _passwordController.text).get();
    if (querySnapshot.docs.isNotEmpty) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => MainLayout(email: _emailController.text, password: _passwordController.text)),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Invalid credentials')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Sign In')),
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
            SizedBox(height: 20),  // Added some spacing before the button
            ElevatedButton(
              onPressed: _signIn,
              child: Text('Sign In'),
            ),
          ],
        ),
      ),
    );
  }
}
