
import 'package:beautyminder/dto/todo_model.dart';
import 'package:beautyminder/event/TodoPageEvent.dart';
import 'package:beautyminder/services/todo_service.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../State/TodoState.dart';

class TodoPageBloc extends Bloc<TodoPageEvent, TodoState> {

  Function()? onCloseCallback;

  TodoPageBloc() : super(const TodoInitState()) {
    on<TodoPageInitEvent>(_initEvent);
    on<TodoPageAddEvent>(_addEvent);
    on<TodoPageTaskUpdateEvent>(_TaskUpdateEvent);
    on<TodoPageDeleteEvent>(_deleteEvent);
    on<TodoPageErrorEvent>(_errorEvent);
    on<TodoDayChangeEvent>(_dayChangeEvent);
  }

  // Todo를 불러오는 Event
  Future<void> _initEvent(
      TodoPageInitEvent event, Emitter<TodoState> emit) async {
    emit(TodoDownloadedState(isError: state.isError));
    print("initEvent");

    // userId를 통해서 todo받아오기
    // 없으면 아무것도 노출 안됨
    // 오늘 루틴을 받아오기
    final result = (await TodoService.getAllTodos());

    if(result == null){
      // 등록된 todo가 없으면 []을 반환
      emit(TodoLoadedState(todos: const [], isError: state.isError));
      print(" result == null ==> result.value in _initEvent : ${result.value}");
      return ;
    }


    try {
      List<Todo>? todos = result.value;
      if (todos != null) {
        print("TodoLoadedState");

        DateTime today = DateTime.now();

        //Todo? todayTodo=null;

        // for(Todo todo in todos){
        // DateTime todoDate =  DateTime.parse(todo.date!);
        //
        //   if(todoDate.year == today.year && todoDate.month == today.month && todoDate.day == today.day) {
        //     todayTodo = todo;
        //   }
        // }
        final resultToday = await TodoService.getTodoOf();

        print("todayTodo : ${resultToday.value}");



        //정상적으로 데이터를 받아옴
        emit(TodoLoadedState(todos: todos, isError: state.isError, todo: resultToday.value));

      } else {
        print("TodoErrorState");
        emit(TodoErrorState(isError: true));
      }
    } catch (e) {
      print("Error : ${e}");
    }
  }

  Future<void> _changeEvent(
      TodoPageTaskUpdateEvent event, Emitter<TodoState> emit) async {
    print("event.todos : ${event.todos}");

    emit(TodoLoadedState());
  }

  // Todo를 추가하는 Event
  Future<void> _addEvent(
      TodoPageAddEvent event, Emitter<TodoState> emit) async {
    print("addevent");
    print("TodoLoadedstate in addevent");
    // Todo가 로드된 상태에서만 Todo add event가 가능
    emit(TodoAddState(todo: state.todo, isError: state.isError));
    print("state.todo : ${state.todo}");
    try {
      final Todo todo = event.todo;
      print("event.todo : ${event.todo}");
      print("call addTodo in addEvent");
      final result = await TodoService.addTodo(todo);
      print("result.value : ${result.value}");

      if (result.value != null) {
        emit(TodoAddedState(todo: state.todo, isError: state.isError));
        print(todo);
        emit(TodoLoadedState(todos: state.todos, isError: state.isError));
      } else {
        print("Error : ${result.error}");
      }
    } catch (e) {
      print("Error : ${e}");
    }

  }

  Future<void> _TaskUpdateEvent(
      TodoPageTaskUpdateEvent event, Emitter<TodoState> emit) async {
    Todo? todo;
    List<Todo>? todos = [];

    print("update");
    //emit(TodoLoadedState(todos: event.todos, todo: event.todo, task: event.task, isError :state.isError));

    if (state is TodoLoadedState) {
      emit(TodoUpdateState(isError : false, task: state.task, todo: state.todo, todos: state.todos));

      print("this is TodoLoadedState");
      print("state.todos : ${state.todos}");
      try {
        final result = await TodoService.taskUpdateTodo(event.todo, event.task);

        print("result.value : ${result.value}");
        if (result.value!.containsKey('todo')) {
          todo = Todo.fromJson(result.value?['todo']);

          if (todo != null) {
            todos.add(todo);
          }
        }


        if (result.value != null) {
          print("TodoUpdatedState!!");
          emit(TodoUpdatedState(
              todo: todo, isError: false, todos: state.todos));
          print("TodoLoadedState!!");
          emit(TodoLoadedState(
              isError: state.isError, todos: state.todos, todo: state.todo));
        } else {
          // emit(TodoErrorState(isError: true));
        }



      } catch (e) {
        print("Error : ${e}");
      }
    } else {
      emit(TodoErrorState());
    }

    onCloseCallback?.call();
  }

  Future<void> _deleteEvent(
      TodoPageDeleteEvent event, Emitter<TodoState> emit) async {
    Todo? todo;
    List<Todo>? todos = [];

    if (state is TodoLoadedState) {
      emit(TodoDeleteState(
          todo: state.todo, isError: state.isError, todos: state.todos));

      // try {
      final String? taskid = event.task?.taskId;
      final result = await TodoService.deleteTask(event.todo, event.task);


      if (result.value!['todo'] == null) {


        state.todos?.removeWhere((todo) => todo.id == state.todo?.id);


        emit(TodoLoadedState(
            isError: false, todos: state.todos, todo: null /*state.todo*/));
        return;
      }

      if (result.value!.containsKey('todo')) {
        todo = Todo.fromJson(result.value?['todo']);

        if (todo != null) {
          todos.add(todo);
        }
      }

      emit(TodoDeletedState(todo: todo, isError: false, todos: state.todos));
      //print(taskid);
      emit(TodoLoadedState(
          isError: state.isError, todos: state.todos, todo: state.todo));
      // } catch (e) {
      //   print("Error in Delete: ${e}");
      // }
    } else {
      //emit(TodoErrorState(isError: true));
    }
  }

  Future<void> _dayChangeEvent(TodoDayChangeEvent event, Emitter<TodoState> emit)async{
    print("_dayChangeEvent");

    if(state is TodoLoadedState){
      print("TodoLoadedState");
      emit(TodoChangeDayState(todos: event.todos, todo: event.todo));
      print("TodoChangeDayState");
      emit(TodoLoadedState(todo: state.todo, todos: state.todos));
    }else{
      print("TodoErroeState");
    }


  }


  Future<void> _errorEvent(
      TodoPageErrorEvent event, Emitter<TodoState> emit) async {
    if (state is TodoLoadedState) {
      print("TodoErrorEvent");
      emit(TodoErrorState(isError: true));
    }
  }


}


