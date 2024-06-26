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
        // If no document found, create one with default 'did_quiz' as false
        userDoc.set({'did_quiz': false});
        return false;
      }
    });
  }

  Future<void> toggleDidQuiz(bool? currentStatus) async {
    final newValue = currentStatus == null ? true : !currentStatus;
    return userDoc.set({'did_quiz': newValue}, SetOptions(merge: true));
  }
}
