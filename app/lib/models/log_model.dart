class LogModel {
  String time;
  String userId;
  String? userAdmId;
  String action;
  String? codBook;
  LogModel({
    required this.time,
    required this.userId,
    this.userAdmId,
    required this.action,
    this.codBook,
  });

  LogModel copyWith({
    String? time,
    String? userId,
    String? userAdmId,
    String? action,
    String? codBook,
  }) {
    return LogModel(
      time: time ?? this.time,
      userId: userId ?? this.userId,
      userAdmId: userAdmId ?? this.userAdmId,
      action: action ?? this.action,
      codBook: codBook ?? this.codBook,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'time': time,
      'userId': userId,
      'userAdmId': userAdmId,
      'action': action,
      'codBook': codBook,
    };
  }

  factory LogModel.fromMap(Map<String, dynamic> map) {
    return LogModel(
      time: map['time']?.toString() ?? '',
      userId: map['userId']?.toString() ?? '',
      userAdmId: map['userAdmId']?.toString(),
      action: map['action']?.toString() ?? '',
      codBook: map['codBook']?.toString(),
    );
  }

  @override
  String toString() {
    return 'LogModel(time: $time, userId: $userId, userAdmId: $userAdmId, action: $action, codBook: $codBook)';
  }
}
