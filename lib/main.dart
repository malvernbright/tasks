import 'package:flutter/material.dart';
import 'package:hello/models/task_model.dart';
import 'package:hello/screens/task_editor.dart';
import 'package:hello/widgets/my_list_tile.dart';

import 'package:hive_flutter/adapters.dart';
import 'package:date_format/date_format.dart';
import 'package:path_provider/path_provider.dart'
    as path_provider; // EDIT 1: Add path provider to initialize the Hive directory

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final appDocumentDirectory = await path_provider
      .getApplicationDocumentsDirectory(); // EDIT 2: Initialize this
  await Hive.initFlutter(appDocumentDirectory.path); // EDIT 3: ADD this
  // TODO: Remove openBox() statement here !
  Hive.registerAdapter<Task>(TaskAdapter());
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  // TODO: Make this a stateful widget so that you open the box in FutureBuilder widget
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late final Box box;

  @override
  void initState() {
    super.initState();
    // box = Hive.box("tasks"); // Edit 4
    // TODO: The above statement raises an error: BoxNotFoundError
    // EDIT 5 👇
    // box.add(
    //     Task(title: "bothwell", note: "welcome", create_date: DateTime.now()));
  }

  @override
  void dispose() {
    Hive.box<Task>('tasks').compact();
    Hive.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      // TODO: Add a FutureBuilder 👇
      home: FutureBuilder(
        future: Hive.openBox<Task>('tasks'),
        builder: (_, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            if (snapshot.hasError) {
              return Center(
                child: Text('${snapshot.error}'),
              );
            } else {
              return const HomePage();
            }
          } else {
            return const Center(
              child: CircularProgressIndicator(color: Colors.blueAccent),
            );
          }
        },
      ),
    );
  }
}

// TODO: Make this a StatelessWidget 👇
class HomePage extends StatelessWidget {
  const HomePage({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Hive",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.blue,
        centerTitle: true,
        actions: const [Icon(Icons.settings)],
      ),
      // Hive.openBox<Task>("tasks") // Don't do this 👈
      body: ValueListenableBuilder<Box<Task>>(
        valueListenable: Hive.box<Task>("tasks").listenable(),
        builder: (context, box, _) {
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Todays Task",
                  style: TextStyle(color: Colors.black),
                ),
                const SizedBox(
                  height: 15,
                ),
                Text(formatDate(DateTime.now(), [d, ",", M, "", yyyy])),
                const Divider(
                  height: 40,
                  thickness: 1.0,
                ),
                Expanded(
                  child: ListView.builder(
                      itemCount: box.values.length,
                      itemBuilder: (context, index) {
                        Task currentTask = box.getAt(index)!;
                        return MyListTile(currentTask, index);
                      }),
                ),
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
              context, MaterialPageRoute(builder: (context) => TextEditor()));
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
