import 'dart:math';

import 'package:flutter/material.dart';
import 'package:collection/collection.dart';
import 'package:uuid/uuid.dart';

void main() {
  runApp(const TodoList());
}

/// Виджет списка задач
class TodoList extends StatefulWidget {
  const TodoList({super.key});

  @override
  State<TodoList> createState() => _TodoListState();
}

class _TodoListState extends State<TodoList> {
  final uuid = const Uuid();
  final List<TodoItem> todoList = [];

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TODO-лист',
      home: Scaffold(
        appBar: AppBar(
          title: const Text('TODO Лист'),
        ),
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Column(
            children: [
              // Поле ввода новой задачи
              TodoInput(
                onAdd: _onAdd,
              ),

              const SizedBox(height: 20),
              // Список задач
              Expanded(
                child: ListView(
                  children: todoList
                      .mapIndexed(
                        (index, item) => TodoItemWidget(
                          key: ValueKey(item.id),
                          item: item,
                          onDelete: () => _onDelete(index),
                          onChecked: (value) => _onChecked(value, index, item),
                        ),
                      )
                      .toList(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _onAdd(String value) {
    setState(() {
      todoList.add(TodoItem(id: uuid.v4(), title: value));
    });
  }

  void _onDelete(int index) {
    setState(() {
      todoList.removeAt(index);
    });
  }

  void _onChecked(bool? value, int index, TodoItem item) {
    setState(() {
      if (value != null) todoList[index] = item.copyWith(done: value);
    });
  }
}

/// Виджет поля ввода новой задачи
class TodoInput extends StatefulWidget {
  final ValueChanged<String> onAdd;
  const TodoInput({super.key, required this.onAdd});

  @override
  State<TodoInput> createState() => _TodoInputState();
}

class _TodoInputState extends State<TodoInput> {
  final TextEditingController _controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: _controller,
      decoration: InputDecoration(
        hintText: 'Введите задачу',
        suffix: IconButton(
          onPressed: () => widget.onAdd(_controller.text),
          icon: const Icon(Icons.add),
        ),
      ),
    );
  }
}

/// Палитра цветов для задач
const todoItemColors = [
  Colors.red,
  Colors.yellow,
  Colors.green,
  Colors.blue,
  Colors.purple,
  Colors.orange,
  Colors.pink,
];

/// Виджет одной задачи
class TodoItemWidget extends StatefulWidget {
  final TodoItem item;
  final VoidCallback onDelete;
  final ValueChanged<bool?> onChecked;

  const TodoItemWidget({
    super.key,
    required this.item,
    required this.onDelete,
    required this.onChecked,
  });

  @override
  State<TodoItemWidget> createState() => _TodoItemWidgetState();
}

class _TodoItemWidgetState extends State<TodoItemWidget> {
  late final Color color;

  @override
  void initState() {
    super.initState();
    // При инициализации виджета выбирается случайный цвет из палитры
    final randomIndex = Random().nextInt(todoItemColors.length);
    color = todoItemColors[randomIndex];
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: ListTile(
        tileColor: color,
        leading: Checkbox(value: widget.item.done, onChanged: widget.onChecked),
        trailing: IconButton(onPressed: widget.onDelete, icon: const Icon(Icons.delete)),
        title: Text(widget.item.title),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}

/// Модель задачи
class TodoItem {
  final String id;
  final String title;
  final bool done;

  const TodoItem({required this.id, required this.title, this.done = false});

  TodoItem copyWith({
    String? id,
    String? title,
    bool? done,
  }) {
    return TodoItem(
      id: id ?? this.id,
      title: title ?? this.title,
      done: done ?? this.done,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is TodoItem &&
            runtimeType == other.runtimeType &&
            id == other.id &&
            title == other.title &&
            done == other.done);
  }

  @override
  int get hashCode => Object.hashAll([id, title, done]);
}
