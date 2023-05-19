import 'package:flutter/material.dart';

void main() {
  runApp(TodoApp());
}

class Todo {
  String title;
  DateTime dueDate;
  bool isCompleted;

  Todo({
    required this.title,
    required this.dueDate,
    this.isCompleted = false,
  });
}

class TodoApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SimpliDo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: TodoScreen(),
    );
  }
}

class TodoScreen extends StatefulWidget {
  @override
  _TodoScreenState createState() => _TodoScreenState();
}

class _TodoScreenState extends State<TodoScreen> {
  List<Todo> todos = [];

  TextEditingController _todoController = TextEditingController();
  DateTime _selectedDate = DateTime.now();

  @override
  void dispose() {
    _todoController.dispose();
    super.dispose();
  }

  void showErrorDialog(BuildContext context, String errorMessage) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Error'),
          content: Text(errorMessage),
          actions: [
            ElevatedButton(
              child: Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void addTodo() {
    String todoTitle = _todoController.text.trim();
    if (todoTitle.isEmpty) {
      showErrorDialog(
          context, 'Task cannot be empty. Please enter a task description.');
      return;
    }

    Todo newTodo = Todo(
      title: todoTitle,
      dueDate: _selectedDate,
    );
    setState(() {
      todos.add(newTodo);
      todos.sort((a, b) {
        if (a.isCompleted != b.isCompleted) {
          return a.isCompleted ? 1 : -1;
        } else {
          return a.dueDate.compareTo(b.dueDate);
        }
      });
      _todoController.clear();
    });
  }

  void toggleTodoStatus(int index) {
    setState(() {
      todos[index].isCompleted = !todos[index].isCompleted;
      todos.sort((a, b) {
        if (a.isCompleted != b.isCompleted) {
          return a.isCompleted ? 1 : -1;
        } else {
          return a.dueDate.compareTo(b.dueDate);
        }
      });
    });
  }

  void deleteTodo(int index) {
    setState(() {
      todos.removeAt(index);
    });
  }

  Widget buildTodoTile(int index) {
    Todo todo = todos[index];
    return ListTile(
      leading: GestureDetector(
        onTap: () {
          toggleTodoStatus(index);
        },
        child: todo.isCompleted
            ? Icon(Icons.check_box, color: Colors.red)
            : Icon(Icons.check_box_outline_blank),
      ),
      title: Text(
        todo.title,
        style: TextStyle(
          decoration: todo.isCompleted
              ? TextDecoration.lineThrough
              : TextDecoration.none,
        ),
      ),
      subtitle: Text(
        'Due Date: ${todo.dueDate.toString().split(' ')[0]}',
      ),
      trailing: IconButton(
        icon: Icon(Icons.delete),
        onPressed: () {
          deleteTodo(index);
        },
      ),
    );
  }

  Future<void> selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2021),
      lastDate: DateTime(2030),
    );
    if (picked != null && picked != _selectedDate)
      setState(() {
        _selectedDate = picked;
      });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('SimpliDo'),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: todos.length,
              itemBuilder: (context, index) {
                if (index > 0 &&
                    todos[index].isCompleted != todos[index - 1].isCompleted) {
                  return Column(
                    children: [
                      Divider(),
                      ListTile(
                        title: Text(
                          todos[index].isCompleted
                              ? 'Completed Tasks'
                              : 'Incomplete Tasks',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16.0,
                          ),
                        ),
                      ),
                      buildTodoTile(index),
                    ],
                  );
                } else {
                  return buildTodoTile(index);
                }
              },
            ),
          ),
          Padding(
            padding: EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _todoController,
                    decoration: InputDecoration(
                      labelText: 'Add a to-do',
                    ),
                  ),
                ),
                SizedBox(width: 8.0),
                GestureDetector(
                  onTap: () {
                    selectDate(context);
                  },
                  child: Row(
                    children: [
                      Icon(Icons.calendar_today),
                      SizedBox(width: 4.0),
                      Text(_selectedDate.toString().split(' ')[0]),
                    ],
                  ),
                ),
                SizedBox(width: 8.0),
                ElevatedButton(
                  onPressed: addTodo,
                  child: Text('Add'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
