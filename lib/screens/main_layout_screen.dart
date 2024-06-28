import 'package:flutter/material.dart';
import 'home_screen.dart';
import 'logs_screen.dart'; // Make sure to import LogsScreen
// import 'account_screen.dart'; // Uncomment if AccountScreen is ready

class MainLayout extends StatefulWidget {
  final String email;
  final String password;

  MainLayout({required this.email, required this.password});

  @override
  _MainLayoutState createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> {
  int _selectedIndex = 0;

  // List of widgets to use as bodies for the navigation bar.
  late List<Widget> _widgetOptions;

  @override
  void initState() {
    super.initState();
    _widgetOptions = [
      HomeScreen(email: widget.email, password: widget.password),
      LogsScreen(email: widget.email), // Pass the email to LogsScreen
      Container(child: Text("Add new content here")), // Placeholder for add screen
      // AccountScreen(), // Uncomment if AccountScreen is ready
    ];
    print("MainLayout initialized with user: ${widget.email}"); // Debug: Track user for whom the layout is initialized
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    print("Navigation tab changed to index: $index"); // Debug: Track tab changes
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: _widgetOptions.elementAt(_selectedIndex),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.list), label: 'Logs'),
          BottomNavigationBarItem(icon: Icon(Icons.add), label: '+'),
          BottomNavigationBarItem(icon: Icon(Icons.account_circle), label: 'Account'),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.amber[800],
        unselectedItemColor: Colors.grey[400],
        onTap: _onItemTapped,
      ),
    );
  }
}
