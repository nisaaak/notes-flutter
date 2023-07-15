import 'package:flutter/material.dart';
import 'package:notes/NoteScreen.dart';
import 'package:notes/main.dart';
import 'package:notes/modelNote.dart';
import 'dart:math';
import 'package:localstorage/localstorage.dart';
import 'package:intl/intl.dart';

class postScreen extends StatefulWidget {
  const postScreen({Key? key, required this.note, required this.action})
      : super(key: key);

  final String action;
  final NoteItem note;

  @override
  State<postScreen> createState() => _postScreenState(note, action);
}

class _postScreenState extends State<postScreen> {
  NoteItem note;
  String action;
  _postScreenState(this.note, this.action);
  TextEditingController ctrlTitle = TextEditingController(text: '');
  TextEditingController ctrlContent = TextEditingController(text: '');
  // new
  final NoteList list = new NoteList();
  final LocalStorage storage = new LocalStorage('note_app');
  bool initialized = false;

  void _save(NoteItem item) {
    if (action == 'create') {
      if (ctrlContent.value.text == '' || ctrlTitle.value.text == '') {
        showDialog(
            context: context,
            builder: (BuildContext context) => AlertDialog(
                  title: Text('Alert'),
                  content: Text('Note atau Title tidak boleh kosong'),
                  actions: <Widget>[
                    TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        child: Text('Ok')),
                  ],
                ));
      } else {
        _addItem(ctrlContent.value.text, ctrlTitle.value.text, 0);
        ctrlContent.clear();
        ctrlTitle.clear();
        // Navigator.pop(context);
        Navigator.push(context, MaterialPageRoute(builder: (context) {
          return MyApp();
        }));
      }
    } else if (action == 'edit') {
      if (ctrlContent.value.text == '' || ctrlTitle.value.text == '') {
        showDialog(
            context: context,
            builder: (BuildContext context) => AlertDialog(
                  title: Text('Alert'),
                  content: Text('Note atau Title tidak boleh kosong'),
                  actions: <Widget>[
                    TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        child: Text('Ok')),
                  ],
                ));
      } else {
        setState(() {
          list.items.removeWhere((e) => e.id == item.id);
          _saveToStorage();
        });
        _addItem(ctrlContent.value.text, ctrlTitle.value.text, item.id);
        ctrlContent.clear();
        ctrlTitle.clear();
        // Navigator.pop(context);
        Navigator.push(context, MaterialPageRoute(builder: (context) {
          return MyApp();
        }));
      }
    }
  }

  _addItem(String content, String title, int idLama) {
    var rng = new Random();
    var id = rng.nextInt(900000) + 100000;
    if (action == 'create') {
      setState(() {
        final item = new NoteItem(
          id: id,
          title: title,
          date: DateFormat("EEE, dd-mm-yyyy").format(DateTime.now()),
          content: content,
        );
        list.items.add(item);
        _saveToStorage();
      });
    } else if (action == 'edit') {
      setState(() {
        final item = new NoteItem(
          id: idLama,
          title: title,
          date: DateFormat("EEE, dd-mm-yyyy").format(DateTime.now()),
          content: content,
        );
        list.items.add(item);
        _saveToStorage();
      });
    }
  }

  _saveToStorage() {
    storage.setItem('notes', list.toJSONEncodable());
  }

  _deleteItem(NoteItem item) {
    setState(() {
      list.items.removeWhere((e) => e.id == item.id);
      _saveToStorage();
    });
  }

  @override
  void initState() {
    super.initState();
    ctrlContent.text = note.content == null ? '' : note.content.toString();
    ctrlTitle.text = note.title == null ? '' : note.title.toString();
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
    print(action);
    var items = storage.getItem('notes');
    print(items);
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: Icon(Icons.arrow_back),
            iconSize: 30,
            onPressed: () {
              // Navigator.pop(context);
              Navigator.push(context, MaterialPageRoute(builder: (context) {
                return MyApp();
              }));
            },
          ),
          actions: [
            if (action == 'edit')
              IconButton(
                icon: Icon(Icons.close),
                iconSize: 30,
                color: Colors.red[200],
                onPressed: () {
                  showDialog(
                      context: context,
                      builder: (BuildContext context) => AlertDialog(
                            title: Text('Hapus Todo'),
                            content: Text('Anda yakin akan hapus note?'),
                            actions: <Widget>[
                              TextButton(
                                  onPressed: () {
                                    // Navigator.pop(context);
                                    Navigator.push(context,
                                        MaterialPageRoute(builder: (context) {
                                      return MyApp();
                                    }));
                                  },
                                  child: Text('Cancel')),
                              TextButton(
                                  onPressed: () {
                                    // Navigator.pop(context);
                                    Navigator.push(context,
                                        MaterialPageRoute(builder: (context) {
                                      return MyApp();
                                    }));
                                    _deleteItem(note);
                                  },
                                  child: Text('Ok')),
                            ],
                          ));
                },
              ),
            IconButton(
              icon: Icon(Icons.check),
              iconSize: 30,
              onPressed: () {
                _save(note);
              },
            ),
          ],
        ),
        body: Container(
          color: Colors.lightBlue[100],
          padding: EdgeInsets.all(10),
          child: Container(
            color: Colors.white,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                SizedBox(
                  height: 50,
                  child: TextField(
                    decoration: InputDecoration(
                      fillColor: Colors.white,
                      filled: true,
                      hintText: "Notes Title",
                      hintStyle: TextStyle(fontWeight: FontWeight.bold),
                      border: InputBorder.none,
                    ),
                    controller: ctrlTitle,
                  ),
                ),
                Container(
                  padding: EdgeInsets.only(left: 10),
                  child: Text(
                    DateFormat("EEE, dd-mm-yyyy").format(DateTime.now()),
                  ),
                ),
                Divider(
                  color: Colors.black,
                  thickness: 1.0,
                ),
                SizedBox(
                  height: 300,
                  child: TextField(
                    maxLines: 300,
                    decoration: InputDecoration(
                        fillColor: Colors.white,
                        filled: true,
                        hintText: "Notes Content",
                        border: InputBorder.none),
                    controller: ctrlContent,
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
