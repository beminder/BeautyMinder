import 'package:beautyminder/Bloc/TodoPageBloc.dart';
import 'package:beautyminder/dto/task_model.dart';
import 'package:beautyminder/event/TodoPageEvent.dart';
import 'package:beautyminder/pages/TodoUpdatePage.dart';
import 'package:beautyminder/pages/Todo_Add_Page_Test.dart';
import 'package:beautyminder/pages/pouch_page.dart';
import 'package:beautyminder/pages/recommend_bloc_screen.dart';
import 'package:beautyminder/pages/todo_page.dart';
import 'package:beautyminder/widget/commonAppBar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:table_calendar/table_calendar.dart';

import 'package:beautyminder/services/todo_service.dart';
import 'package:test/test.dart';

import '../../State/TodoState.dart';
import '../dto/todo_model.dart';
import '../widget/commonBottomNavigationBar.dart';
import 'home_page.dart';
import 'my_page.dart';

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
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
        create: (_) => TodoPageBloc()..add(TodoPageInitEvent()),
        lazy: false,
        child: Scaffold(
            appBar: AppBar(title: Text("CalendarPage"),)
            //CommonAppBar()
            ,
            body: Column(
              children: [
                BlocBuilder<TodoPageBloc, TodoState>(builder: (context, state) {
                  return Expanded(child: todoListWidget());
                  //_calendar();
                })
              ],
            ),
            bottomNavigationBar: CommonBottomNavigationBar(
                currentIndex: _currentIndex,
                onTap: (int index) {
                  // 페이지 전환 로직 추가
                  if (index == 0) {
                    Navigator.of(context).push(MaterialPageRoute(
                        builder: (context) => const RecPage()));
                  } else if (index == 1) {
                    Navigator.of(context).push(MaterialPageRoute(
                        builder: (context) => const PouchPage()));
                  } else if (index == 2) {
                    Navigator.of(context).push(MaterialPageRoute(
                        builder: (context) => const HomePage()));
                  } else if (index == 3) {
                    Navigator.of(context).push(MaterialPageRoute(
                        builder: (context) => const TodoPage()));
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

  CalendarFormat _calendarFormat = CalendarFormat.month;

  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  late List<Task> taskList;


  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay;
  }



  Widget _todoList(/*List<Map<String, dynamic>>? todos*/ List<Todo>? todos) {
    return Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: _buildChildren(todos),

        ));
  }

  List<Widget> _buildChildren(/*List<Map<String, dynamic>>? todos*/ List<Todo>? todos) {
    List<Widget> _children = [];
    List<Widget> _morningTasks = [];
    List<Widget> _dinnerTasks = [];
    //var todos = TodoService.getAllTodos();

    print("_buildChidren");
    print("todos : ${todos}");

    //  taskList = todos != null
    //     ? todos.map((todo) => (todo['tasks'] as List).map((task) => {
    //   'description': task['description'],
    //   'category': task['category'],
    //   'isDone': task['done']
    // }))

    taskList = todos!.expand((todo) => todo.tasks).toList();


    // for (int i = 0; i < taskList.length; i++) {
    //   if (taskList[i]['category'] == 'morning') {
    //     _morningTasks
    //         .add(_todo(taskList[i]['description'], taskList[i]['isDone'],));
    //   } else if (taskList[i]['category'] == 'dinner') {
    //     _dinnerTasks
    //         .add(_todo(taskList[i]['description'], taskList[i]['isDone'],));
    //   }
    // }

    // taskList를 순회하며 작업 수행
    taskList.forEach((task) {
      if (task.category == 'morning') {
        print(task.taskId);
        _morningTasks.add(_todo(task, todos[0]));
      } else if (task.category == 'dinner') {
        print(task.taskId);
        _dinnerTasks.add(_todo(task, todos[0]));
      }
    });


    _children.add(_row('morning'));
    _children.addAll(_morningTasks);
    _children.add(_row('dinner'));
    _children.addAll(_dinnerTasks);

    return _children;
  }


  Widget _calendar(List<Todo>? todos) {
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
        });
      },
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

  Widget _todo(Task task, Todo todo) {
    return Slidable(
      startActionPane: ActionPane(
        motion: const DrawerMotion(),
        extentRatio: 0.25,
        dragDismissible: false,
        children: [
          SlidableAction(
            label: 'Update',
            backgroundColor: Colors.orange,
            icon: Icons.archive,
            onPressed: (context) {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => TodoUpdatePage(),
                ),
              );
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
            label: 'Delete',
            backgroundColor: Colors.red,
            icon: Icons.delete,
            onPressed: (context) async {
              context.read<TodoPageBloc>().add(
                TodoPageDeleteEvent(task: task, todo: todo));
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
                // TodoPageUpdateEvent(update_todo:taskList, isDone: true, todos: [])
               TodoPageDeleteEvent(task: task, todo: todo)
             );
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
            return SizedBox(
              width: MediaQuery.of(context).size.width,
              height: 100,
              child: GestureDetector(
                // onTap: () {
                //   HapticFeedback.mediumImpact();
                //   context.read<RecommendPageBloc>().add(RecommendPageInitEvent());
                //},
                child: SpinKitThreeInOut(
                  color: Color(0xffd86a04),
              size: 50.0,
              duration: Duration(seconds: 2),
            ),
              ),
            );
          } else if (state is TodoLoadedState) {
            return Column(
              mainAxisSize: MainAxisSize.max,
              children: [

                _calendar(state.todos),
                //Text("${state.todos}"),
                _todoList(/*state.todos?.map((e) => e.toJson()).toList() ?? []*/ state.todos),
              ],
            );
          } else  {
            return Column(
              mainAxisSize: MainAxisSize.max,
              children: [
                _calendar(state.todos),
                //Text("${state.todo}"),
                _todoList(/*state.todos?.map((e) => e.toJson()).toList() ?? []*/ state.todos),
              ],
            );
          }
        },
      ),
    );
  }
}
