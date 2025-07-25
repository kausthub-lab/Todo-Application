import 'package:cloud_firestore/cloud_firestore.dart';

class FirebaseTaskService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<QuerySnapshot> getTasks(String uid) {
    return _firestore
        .collection('tasks')
        .doc(uid)
        .collection('userTasks')
        .orderBy('createdAt', descending: true)
        .snapshots();
  }

  Future<void> addTask(String uid, String title) async {
    await _firestore.collection('users').doc(uid).collection('tasks').add({
      'title': title,
      'completed': false,
      'timestamp': FieldValue.serverTimestamp(),
    });
  }

  Future<void> updateTask(String uid, String taskId, bool completed) async {
    return _firestore
        .collection('tasks')
        .doc(uid)
        .collection('userTasks')
        .doc(taskId)
        .update({
          'completed': completed,
        }); // ✅ Only one Map argument here — previously this caused the error
  }

  Future<void> deleteTask(String uid, String taskId) async {
    return _firestore
        .collection('tasks')
        .doc(uid)
        .collection('userTasks')
        .doc(taskId)
        .delete();
  }
}
