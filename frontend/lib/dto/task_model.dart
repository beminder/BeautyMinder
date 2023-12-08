class Task {
  late String? taskId;
  late String description;
  late String category;
  late bool done;

  Task(
      {this.taskId,
      required this.category, // 아침/ 저녁 --> 프론트단에서 설정할 수 있게 하면
      required this.description,
      required this.done});

  @override
  String toString() {
    return '''
    Task{
    taskId: $taskId,
    description: $description,
    category : $category,
    done : $done
    }
    ''';
  }

  Map<String, dynamic> toJson() {
    return {
      'taskId': "String",
      'description': description,
      'category': category,
      'done': done
    };
  }

  factory Task.fromJson(Map<String, dynamic> json) {
    return Task(
        taskId: json['taskId'],
        category: json['category'],
        description: json['description'],
        done: json['done']);
  }
}
