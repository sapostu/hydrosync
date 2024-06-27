import 'package:flutter/material.dart';
import '../services/home_screen_service.dart';
import 'water_quiz_screen.dart';

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
  int? totalWeight;

  @override
  void initState() {
    super.initState();
    service = HomeScreenService(widget.email);
    didQuizStream = service.getDidQuizStatus();
  }

  void _navigateAndDisplayQuiz(BuildContext context) async {
    // Start the WaterQuizScreen and await the result from Navigator.pop.
    final result = await Navigator.of(context).push<int>(
      MaterialPageRoute(builder: (context) => WaterQuizScreen(email: widget.email)),
    );

    // After the Navigator.pop on the Quiz screen, set the state with the result.
    if (result != null) {
      setState(() {
        totalWeight = result;
      });
      service.finalizeQuizResults(result);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Home Screen'),
        automaticallyImplyLeading: false
      ),
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
                    if (totalWeight != -1)
                      Card(
                        margin: EdgeInsets.all(8),
                        child: Padding(
                          padding: EdgeInsets.all(16),
                          child: Text('Total Water Per Day: $totalWeight liters'),
                        ),
                      ),
                    if (!didQuiz)
                      Card(
                        margin: EdgeInsets.all(8),
                        child: ListTile(
                          title: Text('Take Water Quiz'),
                          onTap: () => _navigateAndDisplayQuiz(context),
                        ),
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
