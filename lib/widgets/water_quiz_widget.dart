import 'package:flutter/material.dart';

class WaterQuizWidget extends StatelessWidget {
  final Map<String, dynamic> questionData;
  final int questionIndex;
  final int totalQuestions;
  final Function(int) onOptionSelected;
  final VoidCallback onSubmit;
  final bool isLastQuestion;
  final int? selectedWeight;

  const WaterQuizWidget({
    Key? key,
    required this.questionData,
    required this.questionIndex,
    required this.totalQuestions,
    required this.onOptionSelected,
    required this.onSubmit,
    required this.isLastQuestion,
    this.selectedWeight,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    String question = questionData['question'] ?? 'No question available';
    List<String> options = ['a', 'b', 'c', 'd'];

    return Card(
      child: Column(
        children: <Widget>[
          ListTile(title: Text(question)),
          ...options.map((option) {
            String optionText = questionData[option] ?? 'N/A';
            int optionWeight = questionData['${option}-weight'] as int? ?? 0;
            return ListTile(
              title: Text(optionText),
              trailing: selectedWeight == optionWeight ? Icon(Icons.check, color: Colors.green) : null,
              onTap: () => onOptionSelected(optionWeight),
            );
          }).toList(),
        ],
      ),
    );
  }
}
