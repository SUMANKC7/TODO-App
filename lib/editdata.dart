// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';

import 'package:todoapp/database/firestore.dart';

class Editdata extends StatefulWidget {
  final String task;
  final DateTime? deadline;
  final String docId;

  const Editdata({
    super.key,
    required this.task,
    this.deadline,
    required this.docId,
  });

  @override
  State<Editdata> createState() => _EditdataState();
}

class _EditdataState extends State<Editdata> {
  TextEditingController taskController = TextEditingController();
  TextEditingController dateTimeController = TextEditingController();
  bool istaskCompleted = false;
  DateTime? selectedDateTime;
  FireStoreDatabase fireStoreDatabase = FireStoreDatabase();

  @override
  void initState() {
    super.initState();
    taskController.text = widget.task;
    if (widget.deadline != null) {
      selectedDateTime = widget.deadline;
      dateTimeController.text =
          DateFormat('yyyy-MM-dd HH:mm').format(widget.deadline!);
    }
  }

  Future<void> selectDateTime(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
        context: context,
        initialDate: DateTime.now(),
        firstDate: DateTime(2000),
        lastDate: DateTime(2100));

    if (pickedDate != null) {
      // Show time picker after date is selected
      final TimeOfDay? pickedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.now(),
      );

      if (pickedTime != null) {
        // Combine date and time into a single DateTime object
        setState(() {
          selectedDateTime = DateTime(
            pickedDate.year,
            pickedDate.month,
            pickedDate.day,
            pickedTime.hour,
            pickedTime.minute,
          );
          dateTimeController.text = DateFormat('yyyy-MM-dd HH:mm').format(
              selectedDateTime!); // Format and display the selected date and time
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Colors.blue,
      title: const Text(
        "Update Task",
        style: TextStyle(color: Colors.white),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextFormField(
            controller: taskController,
            decoration: const InputDecoration(
                hintText: "Enter your task",
                hintStyle: TextStyle(color: Colors.white),
                enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.white))),
          ),
        ],
      ),
      actions: [
        TextFormField(
          controller: dateTimeController,
          readOnly: true,
          decoration: const InputDecoration(
            hintText: "Select deadline",
            hintStyle: TextStyle(color: Colors.white),
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.white),
            ),
            suffixIcon: Icon(Icons.calendar_today,
                color: Colors.white), // Calendar icon
          ),
          onTap: () {
            selectDateTime(context);
          },
        ),
        ElevatedButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child:const Text("Cancel"),
        ),
        ElevatedButton(
          onPressed: () async {
            if (taskController.text.isEmpty) {
              Fluttertoast.showToast(
                msg: "Please enter a task before adding!",
                toastLength: Toast.LENGTH_SHORT,
                gravity: ToastGravity.BOTTOM,
                backgroundColor: Colors.orange,
                textColor: Colors.red[900],
                fontSize: 16.0,
              );
              return;
            }

            try {
              Map<String, dynamic> updatedData = {
                "task": taskController.text,
                if (selectedDateTime != null)
                  "deadline": Timestamp.fromDate(selectedDateTime!)
              };
              await fireStoreDatabase.updateData(widget.docId, updatedData);

              Fluttertoast.showToast(
                msg: "Task updated successfully!",
                toastLength: Toast.LENGTH_SHORT,
                gravity: ToastGravity.BOTTOM,
                backgroundColor: Colors.green,
                textColor: Colors.white,
                fontSize: 16.0,
              );
              taskController.clear();
              Navigator.of(context).pop();
            } catch (e) {
              Fluttertoast.showToast(
                msg: "Failed to update task!",
                toastLength: Toast.LENGTH_SHORT,
                gravity: ToastGravity.BOTTOM,
                backgroundColor: Colors.red,
                textColor: Colors.white,
                fontSize: 16.0,
              );
            }
          },
          style: ElevatedButton.styleFrom(backgroundColor: Colors.blue[100]),
          child: const Text("Update"),
        ),
      ],
    );
  }
}
