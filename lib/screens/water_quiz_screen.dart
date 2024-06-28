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
  }

  void _nextQuestion() {
    if (quizServices.validateCurrentSelection(_currentQuestionIndex)) {
      if (_currentQuestionIndex < quizServices.questionWeights.length - 1) {
        setState(() {
          _currentQuestionIndex++;
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
                  Navigator.of(context).pop(); // close the dialog
                  Navigator.of(context).pop(); // go back to main layout
                },
                child: Text("Yes"),
              ),
              TextButton(
                onPressed: () {
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

  void _handleSubmit() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Submit Quiz"),
          content: Text("Are you sure you want to submit your answers and finish the quiz?"),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
                int totalWeight = quizServices.computeTotalWeight();
                quizServices.finalizeQuizResults(widget.email, totalWeight).then((_) {
                  // Navigate directly to MainLayout instead of HomeScreen
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (context) => MainLayout(email: widget.email, password: "YourPasswordHere")), // Update the handling of the password
                    (Route<dynamic> route) => false,
                  );
                }).catchError((error) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Failed to submit quiz results: $error")));
                });
              },
              child: Text("Yes"),
            ),
            TextButton(
              onPressed: () {
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
                Expanded(
                  child: WaterQuizWidget(
                    questionData: questionData,
                    questionIndex: _currentQuestionIndex,
                    totalQuestions: documents.length,
                    onOptionSelected: (weight) {
                      quizServices.updateWeight(_currentQuestionIndex, weight);
                      setState(() {});
                    },
                    onSubmit: _handleSubmit,
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
                        onPressed: _handleSubmit,
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
