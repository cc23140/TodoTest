import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:todo/firestore/firestore_service.dart';

import '../../data_models/todo_model.dart';

part 'todo_event.dart';
part 'todo_state.dart';

class TodoBloc extends Bloc<TodoEvent, TodoState> {

  final FirestoreService _firestoreService;

  TodoBloc(this._firestoreService) : super(TodoInitial()) {
    on<LoadTodos>((event, emit) async{
      try{
        emit(TodoLoading());
        final todos = await _firestoreService.getTodos().first;
        emit(TodoLoaded(todos));

      }
      catch(e){
        emit(TodoError('Failed to load todos.'));
      }
    });

    on<AddTodo>((event, emit) async{
      try{
        emit(TodoLoading());
        await _firestoreService.addTodo(event.todo);
        emit(TodoOperationSuccess('Todo added successfully'));
      }catch (e){
        emit(TodoError('Falhou rapaize'));
      }
    });

    on<UpdateTodo>((event, emit) async {
      try{
        emit(TodoLoading());
        await _firestoreService.updateTodo(event.todo);
        emit(TodoOperationSuccess('Foi atualizado!'));

      }catch(e){
        emit(TodoError('Deu ruim, chefia'));
      }
    });

    on<DeleteTodo>((event, emit) async{
      try{
        emit(TodoLoading());
        await _firestoreService.deleteTodo(event.todoId);
        emit(TodoOperationSuccess('Todo foi deletado com sucesso!'));

      }catch(e){
        emit(TodoError('Houve falha ao deletar o Todo!'));
      }
    });
    on<TodoEvent>((event, emit) {
      // TODO: implement event handler
    });
  }
}
