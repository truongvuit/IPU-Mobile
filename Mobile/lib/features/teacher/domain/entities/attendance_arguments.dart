class AttendanceArguments {  
  final String sessionId;  
  final String classId;  
  final String? className;
  final DateTime? sessionDate;
  final String? room;
  final bool viewOnly;

  const AttendanceArguments({
    required this.sessionId,
    required this.classId,
    this.className,
    this.sessionDate,
    this.room,
    this.viewOnly = false,
  });
  
  factory AttendanceArguments.fromSchedule({
    required String sessionId,
    required String classId,
    String? className,
    DateTime? sessionDate,
    String? room,
    bool viewOnly = false,
  }) {
    return AttendanceArguments(
      sessionId: sessionId,
      classId: classId,
      className: className,
      sessionDate: sessionDate,
      room: room,
      viewOnly: viewOnly,
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
