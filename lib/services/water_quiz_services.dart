import 'package:cloud_firestore/cloud_firestore.dart';

class WaterQuizServices {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  List<int?> questionWeights = [];
  late Future<List<QueryDocumentSnapshot>> questionsFuture;

  WaterQuizServices() {
    questionsFuture = _firestore.collection('water_quiz').orderBy('question_num').get().then((snapshot) {
      questionWeights = List<int?>.filled(snapshot.docs.length, null);
      print('Questions loaded: ${snapshot.docs.length}');
      return snapshot.docs;
    });
  }

  void updateWeight(int index, int weight) {
    questionWeights[index] = weight;
    print('Weight updated for question $index: $weight');
  }

  bool validateCurrentSelection(int index) {
    bool isValid = questionWeights[index] != null;
    print('Selection validation for question $index: $isValid');
    return isValid;
  }

  int computeTotalWeight() {
    int total = questionWeights.where((weight) => weight != null).fold(0, (previous, current) => previous! + current!);
    print('Total weight computed: $total');
    return total;
  }

  Future<void> finalizeQuizResults(String userEmail, int totalWeight) async {
    print('Finalizing quiz results for $userEmail');
    await _firestore.collection('accounts').doc(userEmail).update({
      'did_quiz': true,
      'water_per_day': totalWeight
    });
    print('Quiz results finalized for $userEmail');
  }

  Future<void> createCurrentDayEntry(String email, int waterPerDay) async {
    print('Checking for existing current day entry for $email');
    QuerySnapshot snapshot = await _firestore.collection('current_day').where('email', isEqualTo: email).get();

    if (snapshot.docs.isNotEmpty) {
      // Update existing entry
      DocumentReference currentDayRef = snapshot.docs.first.reference;
      print('Updating existing current day entry for $email');
      await currentDayRef.update({
        'water_per_day': waterPerDay,
        'completed_today': false,
        'current_water': 0,
      });
      print('Current day entry updated for $email');
    } else {
      // Create new entry
      print('Creating new current day entry for $email');
      await _firestore.collection('current_day').add({
        'email': email,
        'current_water': 0,
        'water_per_day': waterPerDay,
        'completed_today': false
      });
      print('New current day entry created for $email');
    }
  }
}
