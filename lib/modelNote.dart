// class modelNote {
//   int? id;
//   String? title;
//   String? content;
//   String? date;

//   modelNote({this.id, this.title, this.content, this.date});

//   modelNote.fromJson(Map<String, dynamic> json) {
//     id = json['id'];
//     title = json['title'];
//     content = json['content'];
//     date = json['date'];
//   }
// }

class NoteItem {
  int id;
  String title;
  String content;
  String date;

  NoteItem(
      {required this.id,
      required this.title,
      required this.date,
      required this.content});

  toJSONEncodable() {
    Map<String, dynamic> m = new Map();

    m['id'] = id;
    m['title'] = title;
    m['date'] = date;
    m['content'] = content;

    return m;
  }
}

class NoteList {
  List<NoteItem> items = [];

  toJSONEncodable() {
    return items.map((item) {
      return item.toJSONEncodable();
    }).toList();
  }
}
