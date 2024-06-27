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
  Stream<int?>? waterPerDayStream;  // Restored stream for water per day

  @override
  void initState() {
    super.initState();
    service = HomeScreenService(widget.email);
    didQuizStream = service.getDidQuizStatus();
    waterPerDayStream = service.getWaterPerDay();  // Initialize the stream
  }

  void _navigateAndDisplayQuiz(BuildContext context) async {
    final result = await Navigator.of(context).push<int>(
      MaterialPageRoute(builder: (context) => WaterQuizScreen(email: widget.email)),
    );

    if (result != null) {
      setState(() {
        service.finalizeQuizResults(result);  // This updates Firestore and should trigger stream updates
      });
    }
  }

  void _toggleDidQuiz() {
    service.toggleDidQuiz();
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
              return Text('Error: ${didQuizSnapshot.error}');
            }
            if (didQuizSnapshot.connectionState == ConnectionState.waiting) {
              return CircularProgressIndicator();
            }
            final didQuiz = didQuizSnapshot.data ?? false;
            return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Text('Welcome, ${widget.email}'),
                StreamBuilder<int?>(
                  stream: waterPerDayStream,
                  builder: (context, waterSnapshot) {
                    if (waterSnapshot.hasData && didQuiz) {
                      return Card(
                        margin: EdgeInsets.all(8),
                        child: Padding(
                          padding: EdgeInsets.all(16),
                          child: Text('Total Water Per Day: ${waterSnapshot.data} liters'),
                        ),
                      );
                    }
                    return SizedBox.shrink();
                  }
                ),
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
