import 'package:flutter/material.dart';
import '../services/home_screen_service.dart';
import 'water_quiz_screen.dart';
import 'login_screen.dart'; // Assuming the login screen is named 'login_screen.dart'

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

  @override
  void initState() {
    super.initState();
    service = HomeScreenService(widget.email);
    didQuizStream = service.getDidQuizStatus();
    waterPerDayStream = service.getWaterPerDay();
  }

  void _navigateAndDisplayQuiz(BuildContext context) async {
    final result = await Navigator.of(context).push<int>(
      MaterialPageRoute(builder: (context) => WaterQuizScreen(email: widget.email)),
    );

    if (result != null) {
      service.finalizeQuizResults(result);
    }
  }

  void _toggleDidQuiz() {
    service.toggleDidQuiz();
  }

  // void _onItemTapped(int index) {
  //   setState(() {
  //     _selectedIndex = index;
  //   });

  //   // Navigation based on the selected index
  //   switch (index) {
  //     case 0:
  //       // Home - do nothing since we are already on home
  //       break;
  //     case 1:
  //       // Logs - navigate to login screen for now as an example
  //       Navigator.push(
  //         context,
  //         MaterialPageRoute(builder: (context) => LoginScreen()), // Assuming a LoginScreen exists
  //       );
  //       break;
  //     case 2:
  //       // Add (+) - placeholder action
  //       break;
  //     case 3:
  //       // Account - placeholder action
  //       break;
  //   }
  // }

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
                if (didQuiz && waterPerDayStream != null) // Display water per day if data is available and quiz was done
                  StreamBuilder<int?>(
                    stream: waterPerDayStream,
                    builder: (context, waterSnapshot) {
                      if (waterSnapshot.hasData) {
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
      // bottomNavigationBar: BottomNavigationBar(
      //   items: const <BottomNavigationBarItem>[
      //     BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
      //     BottomNavigationBarItem(icon: Icon(Icons.list), label: 'Logs'),
      //     BottomNavigationBarItem(icon: Icon(Icons.add), label: '+'),
      //     BottomNavigationBarItem(icon: Icon(Icons.account_circle), label: 'Account'),
      //   ],
      //   currentIndex: _selectedIndex,
      //   selectedItemColor: Colors.amber[800],
      //   unselectedItemColor: Colors.grey[400], // Color for unselected items
      //   onTap: _onItemTapped,
      // ),
    );
  }
}
