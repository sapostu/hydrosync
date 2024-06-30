import 'package:flutter/material.dart';
import '../services/home_screen_service.dart';
import 'water_quiz_screen.dart';
import 'login_screen.dart'; // Assuming the login screen is named 'login_screen.dart'
import '../widgets/current_day_widget.dart'; // Import the new CurrentDayWidget
import '../widgets/weather_widget.dart'; // Import the new WeatherWidget
import '../widgets/steps_widget.dart'; // Import the new StepsWidget

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
  Stream<int?>? waterPerDayStream;

  int _selectedIndex = 0; // For bottom navigation bar

  int tempAdjustment = 0;
  int humidityAdjustment = 0;
  int stepsAdjustment = 0;

  @override
  void initState() {
    super.initState();
    service = HomeScreenService(widget.email);
    didQuizStream = service.getDidQuizStatus();
    waterPerDayStream = service.getWaterPerDay();
    print('HomeScreen initialized for user: ${widget.email}');
  }

  void _navigateAndDisplayQuiz(BuildContext context) async {
    final result = await Navigator.of(context).push<int>(
      MaterialPageRoute(builder: (context) => WaterQuizScreen(email: widget.email)),
    );

    if (result != null) {
      service.finalizeQuizResults(result);
      print('Quiz result received: $result');
    }
  }

  void _toggleDidQuiz() {
    service.toggleDidQuiz();
    print('Toggled didQuiz flag');
  }

  void _updateAdjustments(int tempAdj, int humidityAdj) {
    setState(() {
      tempAdjustment = tempAdj;
      humidityAdjustment = humidityAdj;
    });
    print('Adjustments updated: tempAdjustment=$tempAdjustment, humidityAdjustment=$humidityAdjustment');
  }

  void _updateStepsAdjustment(int stepsAdj) {
    setState(() {
      stepsAdjustment = stepsAdj;
    });
    print('Steps adjustment updated: $stepsAdjustment');
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
          builder: (context, didQuizSnapshot) {
            if (didQuizSnapshot.hasError) {
              print('Error in didQuiz stream: ${didQuizSnapshot.error}');
              return Text('Error: ${didQuizSnapshot.error}');
            }
            if (didQuizSnapshot.connectionState == ConnectionState.waiting) {
              print('Waiting for didQuiz data...');
              return CircularProgressIndicator();
            }
            final didQuiz = didQuizSnapshot.data ?? false;
            print('DidQuiz data received: $didQuiz');
            return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Text('Welcome, ${widget.email}'),
                if (didQuiz) ...[
                  CurrentDayWidget(
                    email: widget.email,
                    tempAdjustment: tempAdjustment,
                    humidityAdjustment: humidityAdjustment,
                    stepsAdjustment: stepsAdjustment,
                  ),
                  WeatherWidget(
                    email: widget.email,
                    updateAdjustments: _updateAdjustments,
                  ),
                  StepsWidget(
                    email: widget.email,
                    updateStepsAdjustment: _updateStepsAdjustment,
                  ),
                ],
                ElevatedButton(
                  onPressed: _toggleDidQuiz,
                  child: Text('Change Quiz Flag')
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
          },
        ),
      ),
    );
  }
}
