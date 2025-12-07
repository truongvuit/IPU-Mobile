import 'package:equatable/equatable.dart';


class TodaysFocusItem extends Equatable {
  final String id;
  final String title;
  final String description;
  final int count;
  final FocusItemType type;
  final FocusItemPriority priority;
  final String? route;
  final Map<String, dynamic>? routeArgs;

  const TodaysFocusItem({
    required this.id,
    required this.title,
    required this.description,
    required this.count,
    required this.type,
    this.priority = FocusItemPriority.normal,
    this.route,
    this.routeArgs,
  });

  @override
  List<Object?> get props => [
    id,
    title,
    description,
    count,
    type,
    priority,
    route,
    routeArgs,
  ];

  factory TodaysFocusItem.fromJson(Map<String, dynamic> json) {
    return TodaysFocusItem(
      id: json['id']?.toString() ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      count: json['count'] ?? 0,
      type: _parseType(json['type']),
      priority: _parsePriority(json['priority']),
      route: json['route'],
      routeArgs: json['routeArgs'],
    );
  }

  static FocusItemType _parseType(String? type) {
    switch (type?.toLowerCase()) {
      case 'attendance':
        return FocusItemType.attendance;
      case 'payment':
        return FocusItemType.payment;
      case 'conflict':
        return FocusItemType.conflict;
      case 'approval':
        return FocusItemType.approval;
      case 'class':
        return FocusItemType.classToday;
      default:
        return FocusItemType.other;
    }
  }

  static FocusItemPriority _parsePriority(String? priority) {
    switch (priority?.toLowerCase()) {
      case 'urgent':
        return FocusItemPriority.urgent;
      case 'high':
        return FocusItemPriority.high;
      case 'normal':
        return FocusItemPriority.normal;
      default:
        return FocusItemPriority.normal;
    }
  }
}

enum FocusItemType {
  attendance,
  payment,
  conflict,
  approval,
  classToday,
  other,
}

enum FocusItemPriority { urgent, high, normal }
