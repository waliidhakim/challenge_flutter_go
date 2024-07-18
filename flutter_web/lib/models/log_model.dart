class Log {
  final int id;
  final String logLevel;
  final String logMessage;
  final DateTime creationDate;

  Log({
    required this.id,
    required this.logLevel,
    required this.logMessage,
    required this.creationDate,
  });

  factory Log.fromJson(Map<String, dynamic> json) {
    return Log(
      id: json['ID'],
      logLevel: json['LogLevel'],
      logMessage: json['LogMessage'],
      creationDate: DateTime.parse(json['CreationDate']),
    );
  }
}