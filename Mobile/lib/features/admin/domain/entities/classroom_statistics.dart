enum RoomStatus {
  available, // Đang sử dụng
  occupied, // Đang sử dụng
  maintenance, // Bảo trì
}

class ClassroomStatistics {
  final int totalRooms;
  final int availableRooms;
  final int occupiedRooms;
  final int maintenanceRooms;
  final double utilizationRate;
  final List<ClassroomUsage> roomUsage;
  final Map<String, int> usageByTimeSlot;

  const ClassroomStatistics({
    required this.totalRooms,
    required this.availableRooms,
    required this.occupiedRooms,
    required this.maintenanceRooms,
    required this.utilizationRate,
    required this.roomUsage,
    required this.usageByTimeSlot,
  });

  String get utilizationRateText => '${utilizationRate.toStringAsFixed(0)}%';
}

class ClassroomUsage {
  final String roomId;
  final String roomName;
  final RoomStatus status;
  final int capacity;
  final int totalHoursUsed;
  final int totalHoursAvailable;
  final List<RoomSchedule> schedule;

  const ClassroomUsage({
    required this.roomId,
    required this.roomName,
    required this.status,
    required this.capacity,
    required this.totalHoursUsed,
    required this.totalHoursAvailable,
    required this.schedule,
  });

  double get utilizationRate {
    if (totalHoursAvailable == 0) return 0;
    return (totalHoursUsed / totalHoursAvailable) * 100;
  }

  String get statusText {
    switch (status) {
      case RoomStatus.available:
        return 'Sẵn sàng';
      case RoomStatus.occupied:
        return 'Đang sử dụng';
      case RoomStatus.maintenance:
        return 'Bảo trì';
    }
  }

  String get utilizationText => '${utilizationRate.toStringAsFixed(0)}%';
}

class RoomSchedule {
  final String classId;
  final String className;
  final String timeSlot;
  final String dayOfWeek;
  final String teacherName;

  const RoomSchedule({
    required this.classId,
    required this.className,
    required this.timeSlot,
    required this.dayOfWeek,
    required this.teacherName,
  });
}
