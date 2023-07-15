import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:notes/modelNote.dart';
import 'package:notes/postScreen.dart';
import 'package:flutter/services.dart' as rootBundle;
import 'package:localstorage/localstorage.dart';

class NoteScreen extends StatefulWidget {
  const NoteScreen({Key? key}) : super(key: key);

  @override
  State<NoteScreen> createState() => _NoteScreenState();
}

class _NoteScreenState extends State<NoteScreen> {
  final NoteList list = new NoteList();
  final LocalStorage storage = LocalStorage('note_app');
  bool initialized = false;

  @override
  void initState() {
    super.initState();
    var items = storage.getItem('notes') ?? [];
    setState(() {
      list.items = List<NoteItem>.from(
        (items as List).map(
          (item) => NoteItem(
              id: item['id'],
              title: item['title'],
              date: item['date'],
              content: item['content']),
        ),
      );
    });
  }

  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.lightBlue[50],
      body: FutureBuilder(
        future: storage.ready,
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          if (snapshot.data == null) {
            return Center(
              child: CircularProgressIndicator(),
            );
          }
          if (!initialized) {
            var items = storage.getItem('notes');
            print(items);
            if (items != null) {
              list.items = List<NoteItem>.from((items as List).map((item) =>
                  NoteItem(
                      id: item['id'],
                      title: item['title'],
                      date: item['date'],
                      content: item['content'])));
            }
            initialized = true;
          }

          List<Widget> widgets = list.items.map((item) {
            return InkWell(
              child: buildNote(item.title, item.date, item.content),
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) {
                  return postScreen(
                    note: item,
                    action: 'edit',
                  );
                }));
              },
            );
          }).toList();

          return SingleChildScrollView(
            child: Container(
              margin: EdgeInsets.all(20),
              child: Wrap(
                spacing: 10,
                runSpacing: 10,
                children: widgets,
              ),
            ),
          );

          // return SingleChildScrollView(
          //   child: Container(
          //     margin: EdgeInsets.all(20),
          //     child: Wrap(
          //       spacing: 10,
          //       runSpacing: 10,
          //       children: [
          //         for (var item in list.items)
          //           InkWell(
          //             child: buildNote(item.title, item.date, item.content),
          //             onTap: () {
          //               Navigator.push(context,
          //                   MaterialPageRoute(builder: (context) {
          //                 return postScreen(
          //                   note: item,
          //                   action: 'edit',
          //                 );
          //               }));
          //             },
          //           )
          //       ],
          //     ),
          //   ),
          // );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(context, MaterialPageRoute(builder: (context) {
            return postScreen(
              note: NoteItem(id: 0, title: '', date: '', content: ''),
              action: 'create',
            );
          }));
        },
        backgroundColor: Colors.blue,
        child: const Text(
          "+",
          style: TextStyle(fontSize: 40),
        ),
      ),
    );
    // );
  }

  Card buildNote(String title, String date, String content) {
    return Card(
      elevation: 5,
      child: Container(
        margin: EdgeInsets.all(10),
        padding: EdgeInsets.all(5),
        width: 140,
        height: 130,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            if (title.length > 10)
              Text(
                title.substring(0, 11) + '...',
                style: TextStyle(color: Colors.blue, fontSize: 20),
              ),
            if (title.length <= 10)
              Text(
                title,
                style: TextStyle(color: Colors.blue, fontSize: 20),
              ),
            Divider(
              color: Colors.blue,
              thickness: 1.0,
              height: 5,
            ),
            Text(
              date,
              style: TextStyle(color: Colors.blue),
            ),
            if (content.length > 40)
              Padding(
                  padding: EdgeInsets.only(top: 5),
                  child: Text(
                    content.substring(0, 41) + '...',
                    style: TextStyle(fontSize: 16),
                  )),
            if (content.length <= 40)
              Padding(
                  padding: EdgeInsets.only(top: 5),
                  child: Text(
                    content,
                    style: TextStyle(fontSize: 16),
                  )),
          ],
        ),
      ),
    );
  }
}
