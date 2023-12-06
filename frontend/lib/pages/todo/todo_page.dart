import 'dart:io';

import 'package:beautyminder/pages/todo/skin_Album_page.dart';
import 'package:beautyminder/pages/todo/skin_timeline.dart';
import 'package:beautyminder/services/notification.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:gallery_saver/gallery_saver.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:path/path.dart' as path;

import '../../Bloc/TodoPageBloc.dart';
import '../../State/TodoState.dart';
import '../../dto/task_model.dart';
import '../../dto/todo_model.dart';
import '../../event/TodoPageEvent.dart';
import '../../services/api_service.dart';
import '../../widget/commonAppBar.dart';
import '../../widget/commonBottomNavigationBar.dart';
import '../home/home_page.dart';
import '../my/my_page.dart';
import '../pouch/expiry_page.dart';
import '../recommend/recommend_bloc_screen.dart';
import 'Todo_add_page.dart';

late List<Todo>? global_todos;

class CalendarPage extends StatefulWidget {
  const CalendarPage({Key? key}) : super(key: key);

  @override
  _CalendarPageState createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage> {
  int _currentIndex = 3;
  CalendarFormat _calendarFormat = CalendarFormat.month;

  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay;
    FlutterLocalNotification.init();
  }

  @override
  Widget build(BuildContext context) {

    bool isKeyboardVisible = MediaQuery.of(context).viewInsets.bottom > 0;

    return BlocProvider(
        create: (_) => TodoPageBloc()..add(TodoPageInitEvent()),
        lazy: false,
        child: Scaffold(
            appBar: CommonAppBar(
              automaticallyImplyLeading: false,
              context: context,
            ),
            body: Column(
              children: [
                BlocBuilder<TodoPageBloc, TodoState>(builder: (context, state) {
                  return Expanded(child: todoListWidget());
                }),
                // Expanded(child: imageWidget()),
              ],
            ),
            floatingActionButton: FloatingActionButton(
              //foregroundColor: Color(0xffffecda),
              backgroundColor: Color(0xffd86a04),
              onPressed: () {
                Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) => TodoAddPage(todos: global_todos)));
              },
              tooltip: '등록',
              child: Icon(Icons.add),
              shape: CircleBorder(),
            ),
            floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
            bottomNavigationBar: CommonBottomNavigationBar(
                currentIndex: _currentIndex,
                onTap: (int index) async {
                  // 페이지 전환 로직 추가
                  if (index == 0) {
                    Navigator.of(context).push(MaterialPageRoute(
                        builder: (context) => const RecPage()));
                  } else if (index == 1) {
                    Navigator.of(context).push(MaterialPageRoute(
                        builder: (context) => CosmeticExpiryPage()));
                  } else if (index == 2) {
                    final userProfileResult = await APIService.getUserProfile();
                    Navigator.of(context).push(MaterialPageRoute(
                        builder: (context) =>
                            HomePage(user: userProfileResult.value!)));
                  } else if (index == 4) {
                    Navigator.of(context).push(MaterialPageRoute(
                        builder: (context) => const MyPage()));
                  }
                })));
  }
}

class todoListWidget extends StatefulWidget {
  @override
  _todoListWidget createState() => _todoListWidget();
}

class _todoListWidget extends State<todoListWidget> {
  TextEditingController _controller = TextEditingController();

  CalendarFormat _calendarFormat = CalendarFormat.month;

  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  late List<Task> taskList;

  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Widget _todoList(List<Todo>? todos, Todo? todo) {
    if (todo == null) {
      return SizedBox(
        height: MediaQuery.sizeOf(context).height/4,
        child: Center(
          child: Text(
            "입력된 루틴이 없습니다.\n루틴을 등록해주세요.",
            style: TextStyle(color: Colors.grey, fontSize: 18),
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    // Todos
    return Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: _buildChildren(todos, todo),
        ));
  }

  List<Widget> _buildChildren(List<Todo>? todos, Todo? todo) {
    List<Widget> children = [];
    List<Widget> morningTasks = [];
    List<Widget> dinnerTasks = [];
    List<Widget> otherTasks = [];

    //debugPrint("todo.id : ${todo?.id} ");

    if (todos == null || todos.isEmpty) {
      return children;
    }

    //taskList = todos!.expand((todo) => todo.tasks).toList();

    taskList = [];

    if (todo != null || todo?.tasks != null) {
      for (Task task in todo!.tasks) {
        taskList.add(task);
      }
    }

    // taskList를 순회하며 작업 수행
    for (var task in taskList) {
      if (task.category == 'morning') {
        print(task.taskId);
        morningTasks.add(_todo(task, todo!, todos));
      } else if (task.category == 'dinner') {
        print(task.taskId);
        dinnerTasks.add(_todo(task, todo!, todos));
      } else {
        otherTasks.add(_todo(task, todo!, todos));
      }
    }

    if (morningTasks.isNotEmpty) {
      children.add(_row('아침'));
      children.addAll(morningTasks);
    }

    if (dinnerTasks.isNotEmpty) {
      children.add(_row('저녁'));
      children.addAll(dinnerTasks);
    }

    if (otherTasks.isNotEmpty) {
      children.add(_row('기타'));
      children.addAll(otherTasks);
    }

    return children;
  }

  Widget _calendar(List<Todo>? todos) {
    List<Todo> _getTodosForDay(DateTime day) {
      return todos
              ?.where((todo) => isSameDay(DateTime.parse(todo.date!), day))
              .toList() ??
          [];
    }

    return TableCalendar(
      firstDay: DateTime.utc(2010, 10, 16),
      lastDay: DateTime.utc(2030, 3, 14),
      focusedDay: _focusedDay,
      selectedDayPredicate: (day) {
        return isSameDay(_selectedDay, day);
      },
      onDaySelected: (selectedDay, focusedDay) {
        setState(() {
          _selectedDay = selectedDay;
          _focusedDay = focusedDay;
          print("_selectedDay : ${_selectedDay}");
          print("_focusedDay : ${_focusedDay}");

          List<Todo> dayList = _getTodosForDay(_selectedDay!);

          for (Todo todo in dayList) {
            print("todo in dayList:${todo.toString()}");
          }

          BlocProvider.of<TodoPageBloc>(context)
              .add(TodoDayChangeEvent(todo: dayList[0], todos: todos));
        });
      },
      eventLoader: _getTodosForDay,
      calendarFormat: _calendarFormat,
      onFormatChanged: (format) {
        setState(() {
          _calendarFormat = format;
        });
      },
      onPageChanged: (focusedDay) {
        _focusedDay = focusedDay;
      },
    );
  }

  Widget _row(String name) {
    return Row(
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 10.0),
          child: Container(
            width: 100,
            height: 35,
            decoration: BoxDecoration(
              border: Border.all(color: Colors.black),
              borderRadius: BorderRadius.circular(15),
            ),
            child: Center(
              child: Text(name),
            ),
          ),
        ),
      ],
    );
  }

  Widget _todo(Task task, Todo todo, List<Todo>? todos) {
    return Slidable(
      startActionPane: ActionPane(
        motion: const DrawerMotion(),
        extentRatio: 0.25,
        dragDismissible: false,
        children: [
          SlidableAction(
            label: '수정',
            backgroundColor: Colors.orange,
            icon: Icons.archive,
            onPressed: (context) {
              List<bool> isSelected = [
                task.category == 'morning',
                task.category == 'dinner',
                task.category != 'morning' && task.category != 'dinner'
              ];

              // context.read<TodoPageBloc>().add(TodoPageUpdateEvent(task: task, todo: todo));
              showDialog(
                  context: context,
                  builder: (BuildContext dialogcontext) {
                    _controller.text = task.description;
                    return BlocProvider.value(
                        value: BlocProvider.of<TodoPageBloc>(context),
                        child:
                            StatefulBuilder(builder: (context, setDialogState) {
                          return AlertDialog(
                            title: Text('수정'),
                            content: SingleChildScrollView(
                              child: Column(
                                children: [
                                  ToggleButtons(
                                    isSelected: isSelected,
                                    onPressed: (int index) {
                                      setDialogState(() {
                                        for (int buttonIndex = 0;
                                            buttonIndex < isSelected.length;
                                            buttonIndex++) {
                                          isSelected[buttonIndex] =
                                              buttonIndex == index;
                                        }
                                        if (index == 0) {
                                          task.category = 'morning';
                                        } else if (index == 1) {
                                          task.category = 'dinner';
                                        } else {
                                          task.category = 'other';
                                        }
                                      });
                                    },
                                    children: const [
                                      Padding(
                                        padding: EdgeInsets.symmetric(
                                            horizontal: 10),
                                        child: Text('아침'),
                                      ),
                                      Padding(
                                        padding: EdgeInsets.symmetric(
                                            horizontal: 10),
                                        child: Text('저녁'),
                                      ),
                                      Padding(
                                        padding: EdgeInsets.symmetric(
                                            horizontal: 10),
                                        child: Text('기타'),
                                      ),
                                    ],
                                  ),
                                  Row(
                                    children: [
                                      Expanded(
                                          child: TextField(
                                        controller: _controller,
                                        onChanged: (value) {},
                                      )),
                                      IconButton(
                                        icon: Icon(Icons.edit),
                                        onPressed: () {
                                          task.description = _controller.text;

                                          print("update todos : ${todos}");

                                          context
                                              .read<TodoPageBloc>()
                                              .onCloseCallback = () {
                                            Navigator.of(context).pop();
                                          };
                                          context.read<TodoPageBloc>().add(
                                              TodoPageTaskUpdateEvent(
                                                  task: task,
                                                  todo: todo,
                                                  todos: todos));
                                        },
                                      )
                                    ],
                                  ),
                                  const Padding(
                                      padding:
                                          EdgeInsets.symmetric(vertical: 10)),
                                  TextButton.icon(
                                      onPressed: () {
                                        Navigator.of(context).pop();
                                      },
                                      icon: Icon(Icons.cancel),
                                      label: Text('취소'))
                                ],
                              ),
                            ),
                          );
                        }));
                  });
            },
          ),
        ],
      ),
      endActionPane: ActionPane(
        motion: const DrawerMotion(),
        extentRatio: 0.25,
        dragDismissible: false,
        dismissible: DismissiblePane(onDismissed: () {}),
        children: [
          SlidableAction(
            label: '삭제',
            backgroundColor: Colors.red,
            icon: Icons.delete,
            onPressed: (context) async {
              context.read<TodoPageBloc>().add(
                  TodoPageDeleteEvent(task: task, todo: todo, todos: todos));
            },
          ),
        ],
      ),
      child: ListTile(
        title: Text(
          task.description,
          style: TextStyle(
            decoration: task.done ? TextDecoration.lineThrough : null,
          ),
        ),
        leading: Checkbox(
          value: task.done,
          onChanged: (bool? newValue) {
            setState(() {
              task.done = newValue ?? false;
            });
            context.read<TodoPageBloc>().add(
                TodoPageTaskUpdateEvent(task: task, todo: todo, todos: todos));
          },
        ),
        onTap: () {
          setState(() {
            task.done = !task.done;
          });
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: BlocBuilder<TodoPageBloc, TodoState>(
        builder: (context, state) {
          if (state is TodoInitState || state is TodoDownloadedState) {
            return Container(
                height: MediaQuery.of(context).size.height,
                width: MediaQuery.of(context).size.width,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SpinKitThreeInOut(
                      color: Color(0xffd86a04),
                      size: 50.0,
                      duration: Duration(seconds: 2),
                    )
                  ],
                ));
          } else if (state is TodoLoadedState) {
            global_todos = state.todos;
            return Column(
              mainAxisSize: MainAxisSize.max,
              children: [
                _calendar(state.todos),
                Buttons(),
                SizedBox(
                  height: 10,
                ),
                // Container(
                //   height: MediaQuery.of(context).size.height / 4,
                //   child: _todoList(state.todos, state.todo),
                // ),
                _todoList(state.todos, state.todo),
              ],
            );
          } else if (state is TodoDeletedState) {
            global_todos = state.todos;
            return Column(
              mainAxisSize: MainAxisSize.max,
              children: [
                _calendar(state.todos),
                Buttons(),
                _todoList(state.todos, state.todo),
              ],
            );
          } else {
            global_todos = state.todos;
            return Column(
              children: [
                _calendar(state.todos),
                Buttons(),
              ],
            );
          }
        },
      ),
    );
  }
}

class Buttons extends StatelessWidget {
  const Buttons({
    super.key,
  });

  void _takePhoto() async {
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.camera);

    if (pickedFile != null) {
      // 임시 파일 가져오기
      final tempImageFile = File(pickedFile.path);

      // 문서 디렉토리 경로 얻기
      final directory = await getApplicationDocumentsDirectory();

      // 새로운 파일명 생성 (예: Skinrecord_<timestamp>.jpg)
      String newFileName = 'Skinrecord_${DateTime.now()}.jpg';
      final newFilePath = path.join(directory.path, newFileName);

      // 파일을 새 경로와 이름으로 이동
      final newImageFile = await tempImageFile.copy(newFilePath);

      print("새로운 사진이 저장된 경로: ${newImageFile.path}");

      // 선택적: GallerySaver를 사용하여 갤러리에도 저장
      GallerySaver.saveImage(newImageFile.path);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        ElevatedButton.icon(
          onPressed: () {
            _takePhoto();
          },
          icon: const Icon(Icons.camera_alt_outlined, color: Color(0xffd86a04)),
          label: const Text(
            "피부촬영",
            style: TextStyle(color: Color(0xffd86a04)),
          ),
          style: ElevatedButton.styleFrom(
              foregroundColor: const Color(0xffffecda),
              backgroundColor: const Color(0xffffecda)),
        ),
        const SizedBox(
          width: 20,
        ),
        ElevatedButton.icon(
          onPressed: () {
            Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => const skinAlbumPage()));
          },
          icon: const Icon(Icons.album_rounded, color: Color(0xffd86a04)),
          label: const Text(
            "앨범",
            style: TextStyle(color: Color(0xffd86a04)),
          ),
          style: ElevatedButton.styleFrom(
              foregroundColor: const Color(0xffffecda),
              backgroundColor: const Color(0xffffecda)),
        ),
        const SizedBox(
          width: 20,
        ),
        ElevatedButton.icon(
          onPressed: () {
            Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => const timeLine()));
          },
          icon: const Icon(Icons.album_rounded, color: Color(0xffd86a04)),
          label: const Text(
            "타임라인",
            style: TextStyle(color: Color(0xffd86a04)),
          ),
          style: ElevatedButton.styleFrom(
              foregroundColor: const Color(0xffffecda),
              backgroundColor: const Color(0xffffecda)),
        )
      ],
    );
  }
}
