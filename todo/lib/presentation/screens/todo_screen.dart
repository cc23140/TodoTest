import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:todo/presentation/blocs/todo_page_bloc/todo_bloc.dart';
import 'package:todo/data_models/todo_model.dart';
class HomeView extends StatefulWidget {
  const HomeView({Key? key}): super(key:key);

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {

  @override
  void initState() {
    BlocProvider.of<TodoBloc>(context).add(LoadTodos());
    super.initState();
  }
  @override
  Widget build(BuildContext context) {

    final TodoBloc _todoBloc = BlocProvider.of<TodoBloc>(context);
    return Scaffold(
      appBar: AppBar(
        title: Text('Testando Firestore'),
      ),
      body: BlocBuilder<TodoBloc, TodoState>(builder: (context, state){
        if(state is TodoLoading){
          return const Center(child: CircularProgressIndicator(),);
        }
        else if(state is TodoLoaded){
          final todos = state.todos;
          return ListView.builder(
            itemCount: todos.length,
            itemBuilder: (context, index){
              final todo = todos[index];

              return ListTile(
                title: Text(todo.title),
                leading: Checkbox(value: todo.isCompleted,
                    onChanged: (value){
                      final updatedTodo = todo.copyWith(isCompleted: value);
                      _todoBloc.add(UpdateTodo(updatedTodo));
                }),
                trailing: IconButton(onPressed: (){_todoBloc.add(DeleteTodo(todo.id));}, icon: const Icon(Icons.delete)),
              );
            },
          );
        }else if(state is TodoOperationSuccess){
          _todoBloc.add(LoadTodos());
          return Container();

        }else if(state is TodoError){
          return Center(child: Text(state.errorMessage));
        }else{
          return Container();
        }
      }),
      floatingActionButton: FloatingActionButton(
          onPressed: (){
            _showAddTodoDialog(context);
          },
          child: const Icon(Icons.add),
      ),
    );
  }

  void _showAddTodoDialog(BuildContext context){
    final _titleController = TextEditingController();

    showDialog(context: context, builder: (context){
      return AlertDialog(
        title: const Text('Add Todo'),
        content: TextField(controller: _titleController,
          decoration: const InputDecoration(hintText: 'Todo title'),
        ),
        actions: [
          ElevatedButton(onPressed: (){Navigator.pop(context);}, child: const Text('Cancel')),
          ElevatedButton(onPressed: (){
            final todo = Todo(
              id: DateTime.now().toString(),
              title: _titleController.text,
              isCompleted: false
            );

            BlocProvider.of<TodoBloc>(context).add(AddTodo(todo));
            Navigator.pop(context);
          }, child: const Text('Add'))
        ],

      );
    });
  }
}
