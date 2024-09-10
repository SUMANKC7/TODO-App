import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:todoapp/addtask.dart';
import 'package:todoapp/database/firestore.dart';
import 'package:todoapp/task.dart';

class ToDoApp extends StatefulWidget {
  const ToDoApp({super.key});

  @override
  State<ToDoApp> createState() => _ToDoAppState();
}

class _ToDoAppState extends State<ToDoApp> {
  void createNewTask() {
    showDialog(
      context: context,
      builder: (context) {
        return const DialogBox();
      },
    );
  }

  Stream<QuerySnapshot>? todolistStream;

  @override
  void initState() {
    super.initState();
    listToDo();
  }

  listToDo() {
    todolistStream = FireStoreDatabase().getToDotask();
  }

  void updateTaskCompletion(String docId, bool isCompleted) async {
    try {
      await FireStoreDatabase().updateTaskCompletion(docId, isCompleted);
    } catch (e) {
      "Error updating task completion: $e";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue[100],
      body: StreamBuilder<QuerySnapshot>(
        stream: todolistStream,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data?.docs.isEmpty == true) {
            return const Center(child: Text("No task is left"));
          }

          return ListView.builder(
            itemCount: snapshot.data?.docs.length,
            itemBuilder: (BuildContext context, index) {
              DocumentSnapshot ds = snapshot.data!.docs[index];
              bool isCompleted = ds["isCompleted"] ?? false;
              String task = ds["task"] ?? '';
              Timestamp? deadlineTimestamp = ds["deadline"];
              DateTime? deadline = deadlineTimestamp?.toDate();

              return Task(
                isCompleted: isCompleted,
                onchange: (value) => updateTaskCompletion(ds.id, value!),
                mytask: task,
                deadline: deadline,
                docId: ds.id,
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: createNewTask,
        backgroundColor: Colors.blue,
        shape: const CircleBorder(side: BorderSide(width: 0)),
        elevation: 10,
        child: const Icon(Icons.add),
      ),
    );
  }
}
