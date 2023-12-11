import 'package:beautyminder/dto/task_model.dart';
import 'package:equatable/equatable.dart';

import '../dto/todo_model.dart';

abstract class TodoState extends Equatable {
  // 필요한 요소 더 추가해야됨
  final bool isError; // error여부
  final List<Todo>? todos; // 모든 todo를 담을 리스트
  final Todo? intialTodo; // 맨처음 노출될 todo객체
  final Todo? todo; // 삭제, 수정에 사용될 객체
  final Task? task;

  const TodoState({this.isError = false, this.todos, this.todo, this.task, this.intialTodo});
}

//Todo 초기 상태
class TodoInitState extends TodoState {
  const TodoInitState();

  @override
  List<Object?> get props => [];
}

// Todo 로딩전 상태 --> getTodo 전
class TodoDownloadedState extends TodoState {
  const TodoDownloadedState({super.isError});

  @override
  List<Object?> get props => [isError];
}

// Todo를 로딩 후 상태  --> Todo리스트가 노출되는 상태
class TodoLoadedState extends TodoState {
  TodoLoadedState({super.todos, super.isError, super.todo, super.task, super.intialTodo});

  @override
  List<Object?> get props => [todos, isError, task,  todo, intialTodo];
}

// Todo를 추가하려는 상태
class TodoAddState extends TodoState {
  TodoAddState({super.todo, super.isError, super.task, super.todos});

  @override
  List<Object?> get props => [todo, isError];
}

// Todo추가가 성공한 상태
class TodoAddedState extends TodoState {
  TodoAddedState({super.todo, super.isError});

  @override
  List<Object?> get props => [todo, isError];
}

//  update전 상태
class TodoUpdateState extends TodoState {
  TodoUpdateState({super.isError, super.task, super.todo, super.todos});

  @override
  List<Object?> get props => [task, isError, todo, todos];
}

// update후 상태
class TodoUpdatedState extends TodoState {
  TodoUpdatedState({super.todo, super.isError, super.todos});

  @override
  List<Object?> get props => [todo, isError, todos];
}

// 삭제중인 상태
class TodoDeleteState extends TodoState {
  TodoDeleteState({super.todo, super.isError, super.todos});

  @override
  List<Object?> get props => [todo, isError, todos];
}

// 삭제 완료된 상태
class TodoDeletedState extends TodoState {
  TodoDeletedState({super.todo, super.isError, super.todos});

  @override
  List<Object?> get props => [todo, isError];
}

// Error가 발생했을 때 상태
class TodoErrorState extends TodoState {
  TodoErrorState({super.isError});

  @override
  List<Object?> get props => [isError];
}

// Calendar에서 day를 변경했을때의 상태
class TodoChangeDayState extends TodoState{
  TodoChangeDayState({super.todo, super.todos, super.task});

  @override
  List<Object?> get props => [todo, todos, task];
}


// Calendar에서 day 변경이 완료 되었을 때의 상태
class TodoChangedDayState extends TodoState{
  TodoChangedDayState({super.todo, super.todos, super.task});

  @override
  List<Object?> get props => [todo, todos, task];

}
