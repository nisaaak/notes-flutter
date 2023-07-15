class modelTodo {
  int? id;
  String? content;
  String? check;

  modelTodo({this.id, this.content, this.check});

  modelTodo.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    content = json['content'];
    check = json['check'];
  }
}
