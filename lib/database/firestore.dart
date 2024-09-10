import 'package:cloud_firestore/cloud_firestore.dart';

class FireStoreDatabase {
  //Add a new note to database
  final firestoreDB = FirebaseFirestore.instance;

  Future<void> addTask(
      String task, bool isTaskCompleted, DateTime? deadline) async {
    try {
      firestoreDB.collection('todotask').doc().set({
        "task": task,
        "isCompleted": isTaskCompleted,
        if (deadline != null) "deadline": Timestamp.fromDate(deadline)
      });
    } catch (e) {
      throw Exception("Error adding task to Firestore");
    }
  }

  //Read data from database
  Stream<QuerySnapshot> getToDotask() {
    return firestoreDB.collection("todotask").snapshots();
  }

  updateTaskCompletion(String docId, bool isCompleted) async {
    await firestoreDB.collection("todotask").doc(docId).update({
      "isCompleted": isCompleted,
    });
  }

  updateData(String docId, Map<String, dynamic> newData) {
    firestoreDB.collection("todotask").doc(docId).update(newData).then((_) {
      "Update data successful";
    }).catchError((error) {
      "Failed to update data:$error";
    });
  }
//Delete data from database

  deleteData(String docId) {
    firestoreDB.collection("todotask").doc(docId).delete();
  }
}
