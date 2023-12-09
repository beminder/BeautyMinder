class User {
  User({
    required this.id,
    required this.email,
    required this.password,
    this.nickname,
    this.profileImage,
    required this.createdAt,
    required this.authorities,
    required this.phoneNumber,

    //add
    required this.baumann,
    required this.baumannScores,
  });

  late final String id;
  late final String email;
  late final String password;
  late final String? nickname;
  late final String? profileImage;
  late final DateTime createdAt;
  late final String
      authorities; // authorities: [ { authority: ROLE_USER } ] -> ".."
  late final String? phoneNumber;

  //add
  late final String? baumann;
  late final Object? baumannScores;

  @override
  String toString() {
    return '''
User {
  id: $id,
  email: $email,
  password: $password,
  nickname: $nickname,
  profileImage: $profileImage,
  createdAt: $createdAt,
  authorities: $authorities,
  phoneNumber: $phoneNumber,
  baumann: $baumann,
  baumannScores: $baumannScores
}''';
  }

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      email: json['email'],
      password: json['password'],
      nickname: json['nickname'],
      profileImage: json['profileImage'],
      createdAt: DateTime.parse(json['createdAt']),
      phoneNumber: json['phoneNumber'],
      baumann: json['baumann'],
      baumannScores: json['baumannScores'],
      authorities: (json['authorities'] as List<dynamic>)
          .map((obj) => obj['authority'] as String)
          .join(','), // Convert List of maps to comma-separated string
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'password': password,
      'nickname': nickname,
      'profileImage': profileImage,
      'createdAt': createdAt.toIso8601String(),
      'phoneNumber': phoneNumber,
      'baumann': baumann,
      'baumannScores': baumannScores,
      'authorities': authorities
          .split(',')
          .map((authority) => {'authority': authority})
          .toList(), // Convert comma-separated string back to List of maps
    };
  }

  // Convert the createdAt array to a DateTime object
  static DateTime toDateTime(List<dynamic> createdAtArray) {
    return DateTime(
      createdAtArray[0],
      createdAtArray[1],
      createdAtArray[2],
      createdAtArray[3],
      createdAtArray[4],
      createdAtArray[5],
      createdAtArray[6] ~/ 1000000,
      // Nanoseconds to milliseconds
      createdAtArray[6] %
          1000000 ~/
          1000, // Remaining nanoseconds to microseconds
    );
  }

  // Convert a DateTime object to the createdAt array
  static List<int> fromDateTime(DateTime createdAt) {
    return [
      createdAt.year,
      createdAt.month,
      createdAt.day,
      createdAt.hour,
      createdAt.minute,
      createdAt.second,
      createdAt.millisecond * 1000000 + createdAt.microsecond,
    ];
  }
}
