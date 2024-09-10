import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:todoapp/database/firestore.dart';
import 'package:intl/intl.dart';

class DialogBox extends StatefulWidget {
  const DialogBox({super.key});

  @override
  State<DialogBox> createState() => _DialogBoxState();
}

class _DialogBoxState extends State<DialogBox> {
  TextEditingController taskController = TextEditingController();
  TextEditingController dateTimeController = TextEditingController();
  bool istaskCompleted = false;
  DateTime? selectedDateTime;
  FireStoreDatabase fireStoreDatabase = FireStoreDatabase();

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
          dateTimeController.text = DateFormat('yyyy-MM-dd HH:mm').format(selectedDateTime!); // Format and display the selected date and time
        });
      }
    }      
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Colors.blue,
      title: const Text(
        "Add New Task",
        style: TextStyle(color: Colors.white),
      ),
      content: TextFormField(
        controller: taskController,
        decoration: const InputDecoration(
            hintText: "Enter your task",
            hintStyle: TextStyle(color: Colors.white),
            enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.white))),
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
              await fireStoreDatabase.addTask(
                  taskController.text, istaskCompleted,selectedDateTime);

              Fluttertoast.showToast(
                msg: "Task added successfully!",
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
                msg: "Failed to add task!",
                toastLength: Toast.LENGTH_SHORT,
                gravity: ToastGravity.BOTTOM,
                backgroundColor: Colors.red,
                textColor: Colors.white,
                fontSize: 16.0,
              );
            }
          },
          style: ElevatedButton.styleFrom(backgroundColor: Colors.blue[100]),
          child:const Text("Add"),
        ),
      ],
    );
  }
}
