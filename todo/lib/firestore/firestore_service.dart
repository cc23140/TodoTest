import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:todo/data_models/todo_model.dart';

class FirestoreService{
  final CollectionReference _todosCollection = FirebaseFirestore.instance.collection('todos');


  Stream<List<Todo>> getTodos() {
    return _todosCollection.snapshots().map((snapshot){
      return snapshot.docs.map((doc){
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        return Todo(id: doc.id, title: data['title'], isCompleted: data['isCompleted']);
      }).toList();
    });
  }

  Future<void> addTodo(Todo todo) async{
    await _todosCollection.add({
      'title':todo.title,
      'isCompleted':todo.isCompleted
    });
  }

  Future<void> updateTodo(Todo todo) async{
    await _todosCollection.doc(todo.id).update({
      'title': todo.title,
      'isCompleted':todo.isCompleted
    });
  }

  Future<void> deleteTodo(String todoId) async {
    await _todosCollection.doc(todoId).delete();
  }
}