import 'dart:math';

import 'package:flutter/material.dart';
import 'package:localstorage/localstorage.dart';
import 'package:notes/NoteScreen.dart';
import 'package:notes/todoScreen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: DefaultTabController(
        length: 2,
        child: Scaffold(
          appBar: AppBar(
            title: Text("Notes app"),
            bottom: const TabBar(
              tabs: [
                Tab(text: 'Notes'),
                Tab(
                  text: 'To Do',
                ),
              ],
            ),
          ),
          body: const TabBarView(
            children: [
              NoteScreen(),
              todoScreen(),
            ],
          ),
        ),
      ),
    );
  }
}
