import 'package:travel_planner/data/models/activity.dart';

class ItineraryDay {
  final int dayNumber;
  final String title;
  final List<Activity> activities;

  const ItineraryDay({
    required this.dayNumber,
    required this.title,
    required this.activities,
  });

  factory ItineraryDay.fromJson(Map<String, dynamic> json) => ItineraryDay(
        dayNumber: json['day_number'] as int,
        title: json['title'] as String,
        activities: (json['activities'] as List<dynamic>?)
                ?.map((e) => Activity.fromJson(e as Map<String, dynamic>))
                .toList() ??
            [],
      );

  Map<String, dynamic> toJson() => {
        'day_number': dayNumber,
        'title': title,
        'activities': activities.map((a) => a.toJson()).toList(),
      };

  ItineraryDay copyWith({
    int? dayNumber,
    String? title,
    List<Activity>? activities,
  }) {
    return ItineraryDay(
      dayNumber: dayNumber ?? this.dayNumber,
      title: title ?? this.title,
      activities: activities ?? this.activities,
    );
  }
}
