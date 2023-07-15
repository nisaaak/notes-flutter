import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:notes/modelTodo.dart';
import 'package:flutter/services.dart' as rootBundle;
import 'package:localstorage/localstorage.dart';

class todoScreen extends StatefulWidget {
  const todoScreen({Key? key}) : super(key: key);

  @override
  State<todoScreen> createState() => _todoScreenState();
}

class TodoItem {
  int id;
  String content;
  bool check;

  TodoItem({required this.id, required this.content, required this.check});

  toJSONEncodable() {
    Map<String, dynamic> m = new Map();

    m['id'] = id;
    m['content'] = content;
    m['check'] = check;

    return m;
  }
}

class TodoList {
  List<TodoItem> items = [];

  toJSONEncodable() {
    return items.map((item) {
      return item.toJSONEncodable();
    }).toList();
  }
}

class _todoScreenState extends State<todoScreen> {
  TextEditingController controller = TextEditingController(text: "");
  String action = '';
  final TodoList list = new TodoList();
  final LocalStorage storage = new LocalStorage('todo_app');
  bool initialized = false;

  void _save(TodoItem item) {
    if (action == 'create') {
      if (controller.value.text == '') {
        showDialog(
            context: context,
            builder: (BuildContext context) => AlertDialog(
                  title: Text('Alert'),
                  content: Text('Todo tidak boleh kosong'),
                  actions: <Widget>[
                    TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        child: Text('Ok')),
                  ],
                ));
      } else {
        _addItem(controller.value.text, 0, false);
        controller.clear();
        Navigator.pop(context);
      }
    } else if (action == 'edit') {
      if (controller.value.text == '') {
        showDialog(
            context: context,
            builder: (BuildContext context) => AlertDialog(
                  title: Text('Alert'),
                  content: Text('Todo tidak boleh kosong'),
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
        _addItem(controller.value.text, item.id, item.check);
        controller.clear();
        Navigator.pop(context);
      }
    }
  }

  _addItem(String content, int idLama, bool checkLama) {
    var rng = new Random();
    var id = rng.nextInt(900000) + 100000;
    if (action == 'create') {
      setState(() {
        final item = new TodoItem(id: id, content: content, check: false);
        list.items.add(item);
        _saveToStorage();
      });
    } else if (action == 'edit') {
      setState(() {
        final item =
            new TodoItem(id: idLama, content: content, check: checkLama);
        list.items.add(item);
        _saveToStorage();
      });
    }
  }

  _saveToStorage() {
    storage.setItem('todos', list.toJSONEncodable());
  }

  _clearStorage() async {
    await storage.clear();

    setState(() {
      list.items = storage.getItem('todos') ?? [];
    });
  }

  _toggleItem(TodoItem item) {
    setState(() {
      item.check = !item.check;
      _saveToStorage();
    });
  }

  _deleteItem(TodoItem item) {
    setState(() {
      list.items.removeWhere((e) => e.id == item.id);
      _saveToStorage();
    });
  }

  @override
  void initState() {
    super.initState();
  }

  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.lightBlue[50],
      body: Container(
        margin: EdgeInsets.all(10),
        child: FutureBuilder(
          future: storage.ready,
          builder: (BuildContext context, AsyncSnapshot snapshot) {
            if (snapshot.data == null) {
              return Center(
                child: CircularProgressIndicator(),
              );
            }
            if (!initialized) {
              var items = storage.getItem('todos');
              print(items);
              if (items != null) {
                list.items = List<TodoItem>.from(
                  (items as List).map(
                    (item) => TodoItem(
                        id: item['id'],
                        content: item['content'],
                        check: item['check']),
                  ),
                );
              }
              initialized = true;
            }

            List<Widget> widgets = list.items.map((item) {
              return InkWell(
                child: buildTodo(item),
                onTap: () {
                  modalPost(context, item);
                  setState(() {
                    action = 'edit';
                    controller.text = item.content.toString();
                  });
                },
              );
            }).toList();

            return Column(
              children: <Widget>[
                Expanded(
                  flex: 1,
                  child: ListView(
                    children: widgets,
                    itemExtent: 50.0,
                  ),
                ),
              ],
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          modalPost(context, TodoItem(id: 0, content: '', check: false));
          setState(() {
            action = 'create';
            controller.text = '';
          });
        },
        backgroundColor: Colors.blue,
        child: const Text(
          "+",
          style: TextStyle(fontSize: 40),
        ),
      ),
    );
  }

  Future<void> modalPost(BuildContext context, TodoItem item) {
    return showModalBottomSheet<void>(
      useRootNavigator: true,
      isDismissible: true,
      context: context,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return Container(
          padding:
              EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
          child: Container(
            height: 150,
            padding: EdgeInsets.all(10),
            child: Column(
              children: [
                SizedBox(
                  height: 100,
                  child: TextField(
                    maxLines: 3,
                    decoration: InputDecoration(
                        hintText: "Enter To Do", border: InputBorder.none),
                    controller: controller,
                    autofocus: true,
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    if (action == 'edit')
                      InkWell(
                        onTap: () {
                          Navigator.pop(context);
                          showDialog(
                              context: context,
                              builder: (BuildContext context) => AlertDialog(
                                    title: Text('Hapus Todo'),
                                    content:
                                        Text('Anda yakin akan hapus todo?'),
                                    actions: <Widget>[
                                      TextButton(
                                          onPressed: () {
                                            Navigator.pop(context);
                                          },
                                          child: Text('Cancel')),
                                      TextButton(
                                          onPressed: () {
                                            Navigator.pop(context);
                                            _deleteItem(item);
                                          },
                                          child: Text('Ok')),
                                    ],
                                  ));
                        },
                        child: Padding(
                          padding: const EdgeInsets.only(left: 5, right: 5),
                          child: Text(
                            "Delete",
                            style: TextStyle(
                              color: Colors.red[300],
                            ),
                          ),
                        ),
                      ),
                    InkWell(
                      onTap: () {
                        // Navigator.pop(context);
                        _save(item);
                      },
                      child: Padding(
                        padding: const EdgeInsets.only(left: 5, right: 5),
                        child: Text(
                          "Done",
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Card buildTodo(TodoItem item) {
    return Card(
      elevation: 5,
      child: Row(
        children: <Widget>[
          InkWell(
            child: Container(
              margin: EdgeInsets.all(5),
              child: item.check == false
                  ? Icon(
                      Icons.check_box_outline_blank_outlined,
                    )
                  : Icon(
                      Icons.check_box_outlined,
                    ),
            ),
            onTap: () {
              _toggleItem(item);
            },
          ),
          Text(item.content.toString()),
        ],
      ),
    );
  }

  // Future<List<modelTodo>> ReadJsonData() async {
  //   final jsondata =
  //       await rootBundle.rootBundle.loadString('jsonfile/datatodo.json');
  //   final list = json.decode(jsondata) as List<dynamic>;

  //   return list.map((e) => modelTodo.fromJson(e)).toList();
  // }
}
