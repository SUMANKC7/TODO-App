import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:intl/intl.dart';

import 'package:todoapp/database/firestore.dart';
import 'package:todoapp/editdata.dart';

class Task extends StatefulWidget {
  const Task({
    super.key,
    required this.isCompleted,
    this.onchange,
    required this.mytask,
    this.deadline,
    required this.docId,
  });

  final bool isCompleted;
  final Function(bool? p1)? onchange;
  final String mytask;
  final DateTime? deadline;
  final String docId;

  @override
  State<Task> createState() => _TaskState();
}

class _TaskState extends State<Task> {
  FireStoreDatabase fireStoreDatabase = FireStoreDatabase();
  // For task update
  void updateTask() {
    showDialog(
        context: context,
        builder: (context) {
          return Editdata(
            task: widget.mytask,
            deadline: widget.deadline,
            docId: widget.docId,
          );
        });
  }

  void deleteTask() {
    fireStoreDatabase.deleteData(widget.docId);
  }

  @override
  Widget build(BuildContext context) {
    String deadlineText = widget.deadline != null
        ? DateFormat('yyyy-MM-dd HH:mm').format(widget.deadline!)
        : 'No deadline set';

    return Column(
      children: [
        const SizedBox(height: 10),
        Padding(
          padding:const EdgeInsets.symmetric(vertical: 10, horizontal: 23),
          child: Slidable(
            endActionPane: ActionPane(motion:const StretchMotion(), children: [
              SlidableAction(
                onPressed: (context) => deleteTask(),
                icon: Icons.delete,
                backgroundColor: Colors.red,
              )
            ]),
            child: Container(
              padding:const EdgeInsets.symmetric(horizontal: 20),
              height: 85,
              decoration: BoxDecoration(
                  color: Colors.blue[300],
                  borderRadius: BorderRadius.circular(10)),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Transform.scale(
                        scale: 1.1,
                        child: Checkbox(
                          value: widget
                              .isCompleted, // Update this based on your needs
                          onChanged: (bool? newValue) {
                            setState(() {
                              widget.onchange?.call(newValue);
                            });
                          },
                        ),
                      ),
                      Expanded(
                        child: Text(
                          widget.mytask,
                          maxLines: null,
                          overflow: TextOverflow.visible,
                          softWrap: true,
                          style:const TextStyle(
                            fontSize: 17,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: IconButton(
                          onPressed: updateTask,
                          icon:const Icon(Icons.edit, color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                  Text(
                    deadlineText,
                    style:const TextStyle(
                        color: Colors.white, fontStyle: FontStyle.italic),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
