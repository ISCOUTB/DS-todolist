import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/widgets.dart';

class FirestorageService {
  FirebaseFirestore firestore = FirebaseFirestore.instance;

  Future<List> getAllTasks() async {
    try {
      QuerySnapshot snapshot = await firestore.collection('tasks').get();
      List tasks = snapshot.docs.map((doc) => doc.data()).toList();
      debugPrint("Tasks fetched: $tasks");
      return tasks;
    } catch (e) {
      debugPrint("Error fetching tasks: $e");
      return [];
    }
  }
}
