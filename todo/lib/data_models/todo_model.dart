
class Todo{
  String id;
  String title;
  bool isCompleted;

  Todo({
    required this.id,
    required this.title,
    required this.isCompleted
  });

  Todo copyWith({
    String? id,
    String? title,
    bool? isCompleted
  }){
    return Todo(id: id ?? this.id, title: title ?? this.title, isCompleted: isCompleted ?? this.isCompleted);
  }


}