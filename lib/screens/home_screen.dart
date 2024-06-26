import 'package:flutter/material.dart';
import '../services/home_screen_service.dart';

class HomeScreen extends StatefulWidget {
  final String email;
  final String password;

  HomeScreen({required this.email, required this.password});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late HomeScreenService service;
  Stream<bool?>? didQuizStream;

  @override
  void initState() {
    super.initState();
    service = HomeScreenService(widget.email);
    didQuizStream = service.getDidQuizStatus();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Home Screen')),
      body: Center(
        child: StreamBuilder<bool?>(
          stream: didQuizStream,
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return Text('Error: ${snapshot.error}');
            }
            switch (snapshot.connectionState) {
              case ConnectionState.waiting:
                return Text('Loading...');
              default:
                final didQuiz = snapshot.data ?? false;
                return Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Text('Welcome, ${widget.email}'),
                    if (didQuiz)
                      Card(
                        margin: EdgeInsets.all(8),
                        child: Padding(
                          padding: EdgeInsets.all(16),
                          child: Text('You have completed the quiz!'),
                        ),
                      ),
                    ElevatedButton(
                      onPressed: () => service.toggleDidQuiz(didQuiz).catchError((error) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Error updating status'))
                        );
                      }),
                      child: Text('Toggle Quiz Completion Status'),
                    ),
                  ],
                );
            }
          },
        ),
      ),
    );
  }
}
