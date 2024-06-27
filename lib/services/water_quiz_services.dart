import 'package:cloud_firestore/cloud_firestore.dart';

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

  bool validateCurrentSelection(int index) {
    return questionWeights[index] != null;
  }

  int computeTotalWeight() {
    return questionWeights.where((weight) => weight != null).fold(0, (previous, current) => previous! + current!);
  }

  Future<void> finalizeQuizResults(String userEmail, int totalWeight) async {
    await _firestore.collection('accounts').doc(userEmail).update({
      'did_quiz': true,
      'water_per_day': totalWeight
    });
  }
}
