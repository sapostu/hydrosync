import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../widgets/water_quiz_widget.dart';
import '../services/water_quiz_services.dart';
import 'main_layout_screen.dart'; // Ensure you have the correct import path for MainLayout

class WaterQuizScreen extends StatefulWidget {
  final String email;

  WaterQuizScreen({Key? key, required this.email}) : super(key: key);

  @override
  _WaterQuizScreenState createState() => _WaterQuizScreenState();
}

class _WaterQuizScreenState extends State<WaterQuizScreen> {
  late WaterQuizServices quizServices;
  int _currentQuestionIndex = 0;

  @override
  void initState() {
    super.initState();
    quizServices = WaterQuizServices();
    print('WaterQuizScreen initialized for user: ${widget.email}');
  }

  void _nextQuestion() {
    if (quizServices.validateCurrentSelection(_currentQuestionIndex)) {
      if (_currentQuestionIndex < quizServices.questionWeights.length - 1) {
        setState(() {
          _currentQuestionIndex++;
          print('Moved to next question: $_currentQuestionIndex');
        });
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("Please select an option before proceeding."),
      ));
    }
  }

  void _previousQuestion() {
    if (_currentQuestionIndex > 0) {
      setState(() {
        _currentQuestionIndex--;
        print('Moved to previous question: $_currentQuestionIndex');
      });
    } else {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text("Quit Quiz"),
            content: Text("Are you sure you want to quit the quiz?"),
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  print('User confirmed to quit quiz');
                  Navigator.of(context).pop(); // close the dialog
                  Navigator.of(context).pop(); // go back to main layout
                },
                child: Text("Yes"),
              ),
              TextButton(
                onPressed: () {
                  print('User canceled quitting quiz');
                  Navigator.of(context).pop(); // just close the dialog
                },
                child: Text("No"),
              ),
            ],
          );
        },
      );
    }
  }

  Future<void> _handleSubmit() async {
    Navigator.of(context).pop(); // Close the dialog first

    int totalWeight = quizServices.computeTotalWeight();
    print('Total weight computed: $totalWeight');

    try {
      await quizServices.finalizeQuizResults(widget.email, totalWeight);
      print('Quiz results finalized for ${widget.email}');

      await quizServices.createCurrentDayEntry(widget.email, totalWeight);
      print('Current day entry created for ${widget.email}');

      if (mounted) { // Check if the widget is still mounted before navigating
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
            builder: (context) => MainLayout(email: widget.email, password: "YourPasswordHere"),
          ),
          (Route<dynamic> route) => false,
        );
      }
    } catch (error) {
      if (mounted) { // Check if the widget is still mounted before showing a SnackBar
        print('Error during quiz submission: $error');
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Failed to complete the quiz: $error")));
      }
    }
  }

  void _showSubmitDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Submit Quiz"),
          content: Text("Are you sure you want to submit your answers and finish the quiz?"),
          actions: <Widget>[
            TextButton(
              onPressed: () => _handleSubmit(),
              child: Text("Yes"),
            ),
            TextButton(
              onPressed: () {
                print('User canceled quiz submission');
                Navigator.of(context).pop(); // Just close the dialog
              },
              child: Text("No"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Water Quiz'),
        automaticallyImplyLeading: false // Prevents the AppBar from showing a back button
      ),
      body: FutureBuilder<List<QueryDocumentSnapshot>>(
        future: quizServices.questionsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return CircularProgressIndicator();
          }
          if (snapshot.hasError) {
            return Text("Error loading quiz: ${snapshot.error}");
          }

          var documents = snapshot.data ?? [];
          if (documents.isNotEmpty && _currentQuestionIndex < documents.length) {
            Map<String, dynamic> questionData = documents[_currentQuestionIndex].data() as Map<String, dynamic>;
            bool isLastQuestion = _currentQuestionIndex == documents.length - 1;
            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    questionData['question'],
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
                Expanded(
                  child: WaterQuizWidget(
                    questionData: questionData,
                    questionIndex: _currentQuestionIndex,
                    totalQuestions: documents.length,
                    onOptionSelected: (weight) {
                      quizServices.updateWeight(_currentQuestionIndex, weight);
                      setState(() {});
                      print('Option selected for question $_currentQuestionIndex: $weight');
                    },
                    onSubmit: _showSubmitDialog,
                    isLastQuestion: isLastQuestion,
                    selectedWeight: quizServices.questionWeights[_currentQuestionIndex],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text('Total Weight: ${quizServices.computeTotalWeight()}'),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton(
                      onPressed: _previousQuestion,
                      child: Text('Previous'),
                    ),
                    if (!isLastQuestion)
                      ElevatedButton(
                        onPressed: _nextQuestion,
                        child: Text('Next'),
                      ),
                    if (isLastQuestion)
                      ElevatedButton(
                        onPressed: _showSubmitDialog,
                        child: Text('Submit Quiz'),
                        style: ButtonStyle(backgroundColor: MaterialStateProperty.all(Colors.green)),
                      ),
                  ],
                ),
              ],
            );
          } else {
            return Center(child: Text("No more questions or invalid question index."));
          }
        },
      ),
    );
  }
}
