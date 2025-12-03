class AttendanceArguments {  
  final String sessionId;  
  final String classId;  
  final String? className;
  final DateTime? sessionDate;
  final String? room;

  const AttendanceArguments({
    required this.sessionId,
    required this.classId,
    this.className,
    this.sessionDate,
    this.room,
  });
  
  factory AttendanceArguments.fromSchedule({
    required String sessionId,
    required String classId,
    String? className,
    DateTime? sessionDate,
    String? room,
  }) {
    return AttendanceArguments(
      sessionId: sessionId,
      classId: classId,
      className: className,
      sessionDate: sessionDate,
      room: room,
    );
  }
  
  factory AttendanceArguments.fromClassId(String classId, {String? className}) {
    return AttendanceArguments(
      sessionId: '', 
      classId: classId,
      className: className,
    );
  }
  
  bool get hasSessionId => sessionId.isNotEmpty;
}
