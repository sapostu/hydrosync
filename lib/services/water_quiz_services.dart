import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class WaterQuizServices {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  List<int?> questionWeights = [];
  late Future<List<QueryDocumentSnapshot>> questionsFuture;

  WaterQuizServices() {
    questionsFuture = _firestore.collection('water_quiz').orderBy('question_num').get().then((snapshot) {
      questionWeights = List<int?>.filled(snapshot.docs.length, null);
      return snapshot.docs;
    });
  }

  void updateWeight(int index, int weight) {
    questionWeights[index] = weight;
  }

  // Validate if a selection has been made for the current question index
  bool validateCurrentSelection(int index) {
    return questionWeights[index] != null;
  }

  int computeTotalWeight() {
    // Calculate the total weight by summing up all non-null weights
    return questionWeights.where((weight) => weight != null).fold(0, (previous, current) => previous! + current!);
  }
}
