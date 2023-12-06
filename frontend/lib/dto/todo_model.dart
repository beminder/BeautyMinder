// import 'package:frontend/dto/user_model.dart';
import 'package:beautyminder/dto/task_model.dart';
import 'package:intl/intl.dart';

import 'user_model.dart';

class Todo {
  Todo({
    this.id,
    required this.date,
    required this.tasks,
    this.user,
    this.createdAt,
  });

  late final String? id;
  late final String? date;
  late final List<Task> tasks;
  late User? user;
  late final DateTime? createdAt;

  @override
  String toString() {
    return '''
Todo {
  id: $id,
  date: $date,
  task : ${tasks.toString()},
  user: $user,
  createdAt: $createdAt
}''';
  }

  factory Todo.fromJson(Map<String, dynamic> json) {
    List<Task> tasksList = (json['tasks'] as List)
        .map((taskJson) => Task.fromJson(taskJson))
        .toList();

    return Todo(
      id: json['id'],
      date: json['date'],
      tasks: tasksList,
      user: User.fromJson(json['user']),
      createdAt: DateTime.parse(json['createdAt']),
    );
  }

  Map<String, dynamic> toJson() {
    List<Map<String, dynamic>> tasksJson =
        tasks.map((task) => task.toJson()).toList();

    //String date = DateFormat('yyyy-MM-dd').format(DateTime.now());
    return {
      'userId': user?.id,
      'date': date,
      'tasks': tasksJson, // Assuming you have a toJson in User model
      'createdAt': createdAt?.toIso8601String(),
    };
  }

}
