import 'package:beautyminder/pages/todo/todo_page.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:timezone/timezone.dart' as tz;

import '../../dto/task_model.dart';
import '../../dto/todo_model.dart';
import '../../services/api_service.dart';
import '../../services/notification_service.dart';
import '../../services/todo_service.dart';
import '../../widget/appBar.dart';
import '../../widget/bottomNavigationBar.dart';
import '../home/home_page.dart';
import '../my/my_page.dart';
import '../pouch/expiry_page.dart';
import '../recommend/recommend_bloc_screen.dart';

class TodoAddPage extends StatefulWidget {
  final List<Todo>? todos;

  const TodoAddPage({Key? key, this.todos = const []}) : super(key: key);

  @override
  State<TodoAddPage> createState() => _TodoAddPage();
}

class _TodoAddPage extends State<TodoAddPage> {
  final int _currentIndex = 3;
  late List<TextEditingController> _controllers = [];
  TextEditingController _dateController = TextEditingController();
  final List<List<bool>> _toggleSelections = [];
  List<String> categories = [];
  Todo? todo;
  DateTime? pickedDate; //  공통으로 사용할 날짜 변수
  List<DateTime>? routineTime = []; // 각자 알람 시간으로 정할 수 있음
  bool isEmptyTextField = false;
  List<String?> dates = [];

  late List<Task> tasks;
  int hour = 23;
  int minute = 59;
  int second = 0;

  @override
  void initState() {
    // 모든 controller을 dispose
    super.initState();
    _controllers.add(TextEditingController());
    _dateController.text = DateTime.now().toString().substring(0, 10);
    _toggleSelections.add([false, false, true]);
    pickedDate = DateTime.parse(_dateController.text);
    dates = widget.todos?.map((e) => e.date).toList() ?? [];
  }

  String formatDate(DateTime date) {
    return DateFormat('yyyy-MM-dd')
        .format(date); // Use DateFormat to format the date
  }

  @override
  void dispose() {
    for (var controller in _controllers) {
      controller.dispose();
    }
    _dateController.dispose();
    super.dispose();
  }

  void _addNewTextField() {
    if (_controllers.length < 20) {
      // Check if the current count is less than 20
      setState(() {
        _controllers.add(TextEditingController());
        _toggleSelections.add([false, false, true]);
      });
    } else {
      _showMaxTextFieldDialog(context);
    }
  }

  void _removeTextField() {
    if (_controllers.length > 1) {
      setState(() {
        _controllers.removeLast();
        _toggleSelections.removeLast();
      });
    } else {
      _showMinTextFieldSnackBar(context);
    }
  }

  void _showMaxTextFieldDialog(BuildContext context) {
    const snackBar = SnackBar(
      content: Text('루틴은 최대 20까지 등록할 수 있습니다.'),
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  void _showMinTextFieldSnackBar(BuildContext context) {
    const snackBar = SnackBar(
      content: Text('항목을 제거할 수 없습니다. 최소 하나의 항목이 존재해야 합니다.'),
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  bool anyTextFieldEmpty() {
    return _controllers.any((e) => e.text.trim().isEmpty);
  }

  void _showEmptyTextFieldSnackBar() {
    const snackBar = SnackBar(
      content: Text('내용을 작성해주세요.'),
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  Future<void> _selectDate(BuildContext context) async {
    // Date를 저장하는 함수
    pickedDate = await showDatePicker(
        context: context,
        initialDate: DateTime.now(),
        firstDate: DateTime.now().subtract(const Duration(days: 30)),
        lastDate: DateTime(2101),
        builder: (context, child) {
          return Theme(
            data: Theme.of(context).copyWith(
                disabledColor: Colors.black87,
                colorScheme: const ColorScheme.light(
                    primary: Color(0xffffecda),
                    onPrimary: Color(0xffd86a04),
                    onSurface: Colors.black
                    // onSurface: Colors.black87
                    ),
                textButtonTheme: TextButtonThemeData(
                    style: TextButton.styleFrom(
                        backgroundColor: const Color(0xffffecda),
                        foregroundColor: const Color(0xffd86a04)))),
            child: child!,
          );
        });
  }

  _selectTime() async {
    TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            // Apply similar theme settings as DatePicker
            colorScheme: const ColorScheme.light(
              primary: Color(0xffd86a04),
              onPrimary: Colors.black87,
              onSurface: Colors.black,
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                backgroundColor: const Color(0xffffecda),
                foregroundColor: const Color(0xffd86a04),
              ),
            ),
            // Additional theme settings for TimePicker can go here
          ),
          child: child!,
        );
      },
    );

    if (pickedTime != null) {
      // 날짜와 시간을 결합하여 _dateController에 설정합니다.
      DateTime finalDateTime = DateTime(
        pickedDate!.year,
        pickedDate!.month,
        pickedDate!.day,
        pickedTime.hour,
        pickedTime.minute,
      );
      hour = pickedTime.hour;
      minute = pickedTime.minute;

      print("finalDateTime : ${finalDateTime.toString()}");

      routineTime!.add(finalDateTime);
      print("routine_time : ${routineTime}");
    }
  }

  List<Task> createTasks() {
    tasks = List.generate(_controllers.length, (index) {
      String description = _controllers[index].text;
      String category = getCategory(_toggleSelections[index]);
      return Task(category: category, description: description, done: false);
    });

    for (int i = 0; i < tasks.length; i++) {
      if (tasks[i].description.isEmpty) {
        tasks.removeAt(i);
      }
    }

    return tasks.isEmpty ? [] : tasks;
  }

  Todo? createRoutine() {
    print("createRoutine");
    createTasks();
    print("_dateController.text : ${_dateController.text}");
    print("picekd : $pickedDate");
    todo = Todo(date: formatDate(pickedDate!), tasks: tasks);
    print("todo in create Routine :${todo.toString()}");
    return todo;
  }

  String getCategory(List<bool> categorys) {
    if (categorys[0]) {
      return "dinner";
    } else if (categorys[1]) {
      return "morning";
    } else {
      return "other";
    }
  }

  @override
  Widget build(BuildContext context) {
    bool isKeyboardVisible = MediaQuery.of(context).viewInsets.bottom > 0;
    return Scaffold(
      appBar: UsualAppBar(
        onAddPressed: () {
          _addNewTextField();
        },
        onMinusPressed: () {
          _removeTextField();
        },
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(
              height: 20,
            ),
            Padding(
                padding: const EdgeInsets.all(20),
                child: GestureDetector(
                  onTap: () => {
                    _selectDate(context),
                  },
                  child: AbsorbPointer(
                    child: TextField(
                      controller: _dateController,
                      decoration: InputDecoration(
                          prefixStyle:
                              const TextStyle(color: Color(0xffd86a04)),
                          labelText: '날짜 및 시간',
                          hintText: '날짜 및 시간 선택',
                          icon: const Icon(
                            Icons.calendar_month,
                            color: Color(0xffd86a04),
                          ),
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: const BorderSide(
                                  color: Colors.black, width: 1.0)),
                          contentPadding: const EdgeInsets.all(10)),
                    ),
                  ),
                )),
            ..._controllers.asMap().entries.map((entry) {
              int index = entry.key;
              TextEditingController controller = entry.value;
              return Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          // 최대 글자수 제한은 50개로.
                          maxLength: 20,
                          controller: controller,
                          decoration: InputDecoration(
                              labelText: '루틴 ${index + 1}',
                              hintText: '루틴 ${index + 1} 입력',
                              icon: const Icon(Icons.add_task_sharp,
                                  color: Color(0xffd86a04)),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              focusedBorder: const OutlineInputBorder(
                                  borderSide: BorderSide(
                                      color: Color(0xfffe9738), width: 2.0))),
                        ),
                      ),
                      const SizedBox(
                        width: 10,
                      ),
                      Visibility(
                        visible: !kIsWeb, // kIsWeb이 false일 때만 보이도록 설정합니다.
                        child: Container(
                          decoration: BoxDecoration(
                            border: Border.all(
                                color: const Color(0xfffe9738), width: 4),
                            color: const Color(0xfffe9738),
                            shape: BoxShape.circle,
                          ),
                          child: IconButton(
                            iconSize: 25,
                            icon: const Icon(Icons.alarm_add_outlined),
                            onPressed: () {
                              if (!kIsWeb) {
                                _selectTime();
                              }
                            },
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      ToggleButtons(
                        isSelected: _toggleSelections[index],
                        onPressed: (int buttonIndex) {
                          setState(() {
                            if (!_toggleSelections[index][buttonIndex]) {
                              for (int i = 0;
                                  i < _toggleSelections[index].length;
                                  i++) {
                                _toggleSelections[index][i] = i == buttonIndex;
                              }
                            }
                          });
                        },
                        color: Colors.black,
                        borderRadius: BorderRadius.circular(10),
                        // selectedColor: Colors.white,
                        fillColor: const Color(0xfffe9738),
                        borderColor: Colors.grey,
                        selectedBorderColor: const Color(0xfffe9738),
                        children: <Widget>[
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 8),
                            child: Text(
                              '저녁',
                              style: TextStyle(
                                color: _toggleSelections[index][0]
                                    ? Colors.white
                                    : Colors.black,
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 8),
                            child: Text(
                              '아침',
                              style: TextStyle(
                                color: _toggleSelections[index][1]
                                    ? Colors.white
                                    : Colors.black,
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 8),
                            child: Text(
                              '기타',
                              style: TextStyle(
                                color: _toggleSelections[index][2]
                                    ? Colors.white
                                    : Colors.black,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ));
            }).toList(),
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.07,
              width: MediaQuery.of(context).size.width * 0.9,
              child: TextButton(
                style: TextButton.styleFrom(
                  backgroundColor: const Color(0xfffe9738),
                  minimumSize: Size(MediaQuery.of(context).size.width - 50, 30),
                ),
                onPressed: () async {
                  if (anyTextFieldEmpty()) {
                    _showEmptyTextFieldSnackBar();
                  } else {
                    createRoutine();
                    if (tasks.length == 0) {
                      // 입력한 task가 없으면 생성 x
                      Navigator.of(context).push(MaterialPageRoute(
                          builder: (context) => const CalendarPage()));
                    } else if (tasks.length > 0 &&
                        dates.contains(formatDate(pickedDate!))) {
                      Todo? existingTodo = widget.todos!.firstWhere(
                        (todo) =>
                            todo.date ==
                            formatDate(
                                pickedDate!), // Provide a default value (null) if no match is found
                      );
                      if (!kIsWeb) {
                        if (todo!.tasks.length > routineTime!.length) {
                          for (int i = routineTime!.length;
                              i <= todo!.tasks.length;
                              i++) {
                            routineTime?.add(DateTime.now());
                          }
                        }

                        for (int i = 0; i < todo!.tasks.length; i++) {
                          tz.TZDateTime date =
                              FlutterLocalNotification.makeDate(
                            // hout, minute를 task모델의 멤버 변수로 변경해야됨
                            pickedDate!.year,
                            pickedDate!.month,
                            pickedDate!.day,
                            routineTime![i].hour,
                            routineTime![i].minute,
                          );
                          if (!date.isBefore(tz.TZDateTime.now(
                              tz.getLocation('Asia/Seoul')))) {
                            FlutterLocalNotification.showNotification_time(
                                'BeautyMinder', _controllers[i].text, date, i);
                          }
                        }
                      }

                      await TodoService.taskAddInTodo(existingTodo, tasks);
                      print("_dateController.text : ${_dateController.text}");
                      Navigator.of(context).push(MaterialPageRoute(
                          builder: (context) => const CalendarPage()));
                    } else {
                      print("addtodo 실행");
                      print("todo : ${todo}");
                      print("_dateController.text : ${_dateController.text}");
                      if (!kIsWeb) {
                        if (todo!.tasks.length > routineTime!.length) {
                          for (int i = routineTime!.length;
                              i <= todo!.tasks.length;
                              i++) {
                            routineTime?.add(DateTime.now());
                          }
                        }

                        for (int i = 0; i < todo!.tasks.length; i++) {
                          tz.TZDateTime date =
                              FlutterLocalNotification.makeDate(
                            // hout, minute를 task모델의 멤버 변수로 변경해야됨
                            pickedDate!.year,
                            pickedDate!.month,
                            pickedDate!.day,
                            routineTime![i].hour,
                            routineTime![i].minute,
                          );
                          if (!date.isBefore(tz.TZDateTime.now(
                              tz.getLocation('Asia/Seoul')))) {
                            FlutterLocalNotification.showNotification_time(
                                'BeautyMinder', _controllers[i].text, date, i);
                          }
                        }
                      }
                      await TodoService.addTodo(todo!);
                      Navigator.of(context).push(MaterialPageRoute(
                          builder: (context) => const CalendarPage()));
                    }
                  }
                },
                child: const Text('등록',
                    style: TextStyle(fontSize: 20, color: Colors.white)),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: CommonBottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (int index) async {
            // 페이지 전환 로직 추가
            if (index == 0) {
              Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) => const RecPage()));
            } else if (index == 1) {
              Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) => CosmeticExpiryPage()));
            } else if (index == 2) {
              final userProfileResult = await APIService.getUserProfile();
              Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) =>
                      HomePage(user: userProfileResult.value!)));
            } else if (index == 4) {
              Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) => const MyPage()));
            }
          }),
    );
  }
}
