import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Todo List App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: TodoListPage(),
    );
  }
}

class TodoListPage extends StatefulWidget {
  @override
  _TodoListPageState createState() => _TodoListPageState();
}

class _TodoListPageState extends State<TodoListPage> {
  List<TodoItem> _todoItems = [];
  final _formKey = GlobalKey<FormState>();
  final _fileName = 'todo_list.json';

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _tagsController = TextEditingController();
  DateTime? _dueDate;
  bool _isCompleted = false;

  @override
  void initState() {
    super.initState();
    _loadTodoItems();
  }

  Future<void> _loadTodoItems() async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/$_fileName');

      if (await file.exists()) {
        final contents = await file.readAsString();
        final List<dynamic> jsonList = json.decode(contents);

        setState(() {
          _todoItems = jsonList.map((item) => TodoItem.fromJson(item)).toList();
        });
      }
    } catch (e) {
      print("Error loading todo items: $e");
    }
  }

  Future<void> _saveTodoItems() async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/$_fileName');

      final jsonList = _todoItems.map((item) => item.toJson()).toList();
      await file.writeAsString(json.encode(jsonList));
    } catch (e) {
      print("Error saving todo items: $e");
    }
  }

  void _addTodoItem() {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _todoItems.add(TodoItem(
          name: _nameController.text,
          description: _descriptionController.text,
          dueDate: _dueDate,
          isCompleted: _isCompleted,
          tags:
              _tagsController.text.split(',').map((tag) => tag.trim()).toList(),
        ));

        _saveTodoItems();

        _nameController.clear();
        _descriptionController.clear();
        _tagsController.clear();
        _dueDate = null;
        _isCompleted = false;

        Navigator.of(context).pop();
      });
    }
  }

  void _toggleTodoCompletion(int index) {
    setState(() {
      _todoItems[index].isCompleted = !_todoItems[index].isCompleted;
      _saveTodoItems();
    });
  }

  Future<void> _selectDueDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );

    if (picked != null && picked != _dueDate) {
      setState(() {
        _dueDate = picked;
      });
    }
  }

  void _showAddTodoDialog() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: Container(
            padding: EdgeInsets.all(20),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Añadir nueva tarea',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 20),
                  TextFormField(
                    controller: _nameController,
                    decoration: InputDecoration(
                      labelText: 'Nombre',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Por favor ingresa un nombre';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 15),
                  TextFormField(
                    controller: _descriptionController,
                    decoration: InputDecoration(
                      labelText: 'Descripción',
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 3,
                  ),
                  SizedBox(height: 15),
                  TextFormField(
                    controller: _tagsController,
                    decoration: InputDecoration(
                      labelText: 'Etiquetas (separadas por comas)',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  SizedBox(height: 15),
                  ListTile(
                    title: Text(
                      _dueDate == null
                          ? 'Seleccionar fecha de vencimiento'
                          : 'Fecha: ${DateFormat('dd/MM/yyyy').format(_dueDate!)}',
                    ),
                    trailing: Icon(Icons.calendar_today),
                    onTap: () => _selectDueDate(context),
                  ),
                  SizedBox(height: 15),
                  CheckboxListTile(
                    title: Text('Completada'),
                    value: _isCompleted,
                    onChanged: (bool? value) {
                      setState(() {
                        _isCompleted = value ?? false;
                      });
                    },
                  ),
                  SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: _addTodoItem,
                    child: Text('Guardar tarea'),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _editTodoItem(int index) {
    _nameController.text = _todoItems[index].name;
    _descriptionController.text = _todoItems[index].description;
    _tagsController.text = _todoItems[index].tags.join(', ');
    _dueDate = _todoItems[index].dueDate;
    _isCompleted = _todoItems[index].isCompleted;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: Container(
            padding: EdgeInsets.all(20),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Editar tarea',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 20),
                  TextFormField(
                    controller: _nameController,
                    decoration: InputDecoration(
                      labelText: 'Nombre',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Por favor ingresa un nombre';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 15),
                  TextFormField(
                    controller: _descriptionController,
                    decoration: InputDecoration(
                      labelText: 'Descripción',
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 3,
                  ),
                  SizedBox(height: 15),
                  TextFormField(
                    controller: _tagsController,
                    decoration: InputDecoration(
                      labelText: 'Etiquetas (separadas por comas)',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  SizedBox(height: 15),
                  ListTile(
                    title: Text(
                      _dueDate == null
                          ? 'Seleccionar fecha de vencimiento'
                          : 'Fecha: ${DateFormat('dd/MM/yyyy').format(_dueDate!)}',
                    ),
                    trailing: Icon(Icons.calendar_today),
                    onTap: () => _selectDueDate(context),
                  ),
                  SizedBox(height: 15),
                  CheckboxListTile(
                    title: Text('Completada'),
                    value: _isCompleted,
                    onChanged: (bool? value) {
                      setState(() {
                        _isCompleted = value ?? false;
                      });
                    },
                  ),
                  SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        setState(() {
                          _todoItems[index] = TodoItem(
                            name: _nameController.text,
                            description: _descriptionController.text,
                            dueDate: _dueDate,
                            isCompleted: _isCompleted,
                            tags: _tagsController.text
                                .split(',')
                                .map((tag) => tag.trim())
                                .toList(),
                          );
                          _saveTodoItems();
                          _nameController.clear();
                          _descriptionController.clear();
                          _tagsController.clear();
                          _dueDate = null;
                          _isCompleted = false;
                          Navigator.of(context).pop();
                        });
                      }
                    },
                    child: Text('Guardar cambios'),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _deleteTodoItem(int index) {
    setState(() {
      _todoItems.removeAt(index);
      _saveTodoItems();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Todo List App'),
      ),
      body: ListView.builder(
        itemCount: _todoItems.length,
        itemBuilder: (context, index) {
          final item = _todoItems[index];
          return Card(
            margin: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            child: ListTile(
              title: Text(
                item.name,
                style: TextStyle(
                  decoration: item.isCompleted
                      ? TextDecoration.lineThrough
                      : TextDecoration.none,
                ),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (item.description.isNotEmpty) Text(item.description),
                  if (item.dueDate != null)
                    Text(
                      'Vence: ${DateFormat('dd/MM/yyyy').format(item.dueDate!)}',
                      style: TextStyle(
                        color: item.dueDate!.isBefore(DateTime.now()) &&
                                !item.isCompleted
                            ? Colors.red
                            : null,
                      ),
                    ),
                  if (item.tags.isNotEmpty)
                    Text(
                      'Etiquetas: ${item.tags.join(', ')}',
                      style: TextStyle(color: Colors.grey),
                    ),
                ],
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: Icon(Icons.edit),
                    onPressed: () => _editTodoItem(index),
                  ),
                  IconButton(
                    icon: Icon(Icons.delete),
                    onPressed: () => _deleteTodoItem(index),
                  ),
                  Checkbox(
                    value: item.isCompleted,
                    onChanged: (bool? value) {
                      _toggleTodoCompletion(index);
                    },
                  ),
                ],
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddTodoDialog,
        child: Icon(Icons.add),
        tooltip: 'Añadir nueva tarea',
      ),
    );
  }
}

class TodoItem {
  final String name;
  final String description;
  final DateTime? dueDate;
  bool isCompleted;
  final List<String> tags;

  TodoItem({
    required this.name,
    this.description = '',
    this.dueDate,
    this.isCompleted = false,
    this.tags = const [],
  });

  factory TodoItem.fromJson(Map<String, dynamic> json) {
    return TodoItem(
      name: json['name'],
      description: json['description'],
      dueDate: json['dueDate'] != null ? DateTime.parse(json['dueDate']) : null,
      isCompleted: json['isCompleted'],
      tags: List<String>.from(json['tags'] ?? []),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'description': description,
      'dueDate': dueDate?.toIso8601String(),
      'isCompleted': isCompleted,
      'tags': tags,
    };
  }
}
