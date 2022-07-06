import 'package:flutter/material.dart';
import 'package:hello/main.dart';
import 'package:hello/models/task_model.dart';
import 'package:hive/hive.dart';

class TextEditor extends StatefulWidget {
  TextEditor({this.task, Key? key}) : super(key: key);
  Task? task;
  @override
  State<TextEditor> createState() => _TextEditorState();
}

class _TextEditorState extends State<TextEditor> {
  @override
  Widget build(BuildContext context) {
    // Hive.openBox("tasks"); // TODO: Here the box is already opened in the main.dart file 👈
    TextEditingController _taskTile = TextEditingController(
        text: widget.task == null ? null : widget.task!.title!);
    TextEditingController _taskNote = TextEditingController(
        text: widget.task == null ? null : widget.task!.note!);
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          widget.task == null ? "Add a new Task" : "Update your Task",
          style: const TextStyle(color: Colors.black),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Your Task Title"),
            const SizedBox(
              height: 12,
            ),
            TextField(
              controller: _taskTile,
              decoration: InputDecoration(
                  fillColor: Colors.blue.shade100.withAlpha(75),
                  filled: true,
                  border: OutlineInputBorder(
                    borderSide: BorderSide.none,
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  hintText: "Your task"),
            ),
            const SizedBox(
              height: 15,
            ),
            TextField(
              keyboardType: TextInputType.multiline,
              minLines: 5,
              maxLines: 25,
              controller: _taskNote,
              decoration: InputDecoration(
                  fillColor: Colors.blue.shade100.withAlpha(75),
                  filled: true,
                  border: OutlineInputBorder(
                    borderSide: BorderSide.none,
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  hintText: "Your Notes"),
            ),
            Expanded(
                child: Align(
              alignment: FractionalOffset.bottomCenter,
              child: SizedBox(
                width: double.infinity,
                height: 60,
                child: RawMaterialButton(
                  onPressed: () async {
                    var newTask = Task(
                      title: _taskTile.text,
                      note: _taskNote.text,
                      create_date: DateTime.now(),
                      done: false,
                    );
                    Box taskBox = Hive.box<Task>("tasks");
                    if (widget.task != null) {
                      widget.task!.title = newTask.title;
                      widget.task!.note = newTask.note;
                      widget.task!.save();
                      Navigator.pop(context);
                    } else {
                      // TODO: Add a .then() method to execute Navigation after your task has been added
                      await taskBox
                          .add(newTask)
                          .then((value) => Navigator.pop(context));
                    }
                  },
                  fillColor: Colors.blueAccent.shade700,
                  child: Text(
                      widget.task == null ? "Add new Task" : "Update Task"),
                ),
              ),
            ))
          ],
        ),
      ),
    );
  }
}
