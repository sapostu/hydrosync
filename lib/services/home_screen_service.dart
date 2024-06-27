import 'package:cloud_firestore/cloud_firestore.dart';

class HomeScreenService {
  late DocumentReference userDoc;

  HomeScreenService(String userEmail) {
    userDoc = FirebaseFirestore.instance.collection('accounts').doc(userEmail);
  }

  Stream<bool?> getDidQuizStatus() {
    return userDoc.snapshots().map((snapshot) {
      if (snapshot.exists) {
        var data = snapshot.data() as Map<String, dynamic>;
        return data['did_quiz'] as bool?;
      } else {
        // If no document found, initialize it with default 'did_quiz' as false
        userDoc.set({'did_quiz': false});
        return false;
      }
    });
  }

  Future<void> toggleDidQuiz() async {
    userDoc.get().then((snapshot) {
      if (snapshot.exists) {
        var data = snapshot.data() as Map<String, dynamic>;
        bool currentStatus = data['did_quiz'] as bool? ?? false;
        userDoc.update({'did_quiz': !currentStatus});
      } else {
        userDoc.set({'did_quiz': true});  // Default to true if not set
      }
    });
  }

  Stream<int?> getWaterPerDay() {
    return userDoc.snapshots().map((snapshot) {
      if (snapshot.exists) {
        var data = snapshot.data() as Map<String, dynamic>;
        return data['water_per_day'] as int?;
      } else {
        // Initialize default if no document exists
        userDoc.set({'water_per_day': 0});
        return 0;
      }
    });
  }

  Future<void> finalizeQuizResults(int totalWeight) async {
    await userDoc.update({
      'did_quiz': true,
      'water_per_day': totalWeight
    });
  }
}
