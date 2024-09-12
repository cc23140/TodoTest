part of 'todo_bloc.dart';

@immutable
sealed class TodoState {}

class TodoInitial extends TodoState {}

class TodoLoading extends TodoState {}

class TodoLoaded extends TodoState {
  final List<Todo> todos;

  TodoLoaded(this.todos);
}

class TodoOperationSuccess extends TodoState {
  final String msg;

  TodoOperationSuccess(this.msg);
}

class TodoError extends TodoState {
  final String msg;
  final String errorMessage = 'Deu ruim meu fi';
  TodoError(this.msg);
}


