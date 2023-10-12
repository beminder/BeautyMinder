abstract class RegisterEvent {}

class RegisterStarted extends RegisterEvent {
  final String email;
  final String password;
  final String? nickname;

  RegisterStarted({required this.email, required this.password, this.nickname});
}
