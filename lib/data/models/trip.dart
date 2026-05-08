import 'itinerary_day.dart';

enum BudgetType { low, medium, high }

enum TripInterest { adventure, food, culture, nature, shopping, nightlife, wellness }

class Trip {
  final String id;
  final String? userId;
  final String destination;
  final DateTime startDate;
  final DateTime endDate;
  final BudgetType budgetType;
  final List<TripInterest> interests;
  final List<ItineraryDay> days;
  final bool isSaved;

  const Trip({
    required this.id,
    this.userId,
    required this.destination,
    required this.startDate,
    required this.endDate,
    required this.budgetType,
    required this.interests,
    this.days = const [],
    this.isSaved = false,
  });

  int get totalDays => endDate.difference(startDate).inDays + 1;

  factory Trip.fromJson(Map<String, dynamic> json) => Trip(
        id: json['id'] as String,
        userId: json['user_id'] as String?,
        destination: json['destination'] as String,
        startDate: DateTime.parse(json['start_date'] as String),
        endDate: DateTime.parse(json['end_date'] as String),
        budgetType: BudgetType.values.firstWhere(
          (e) => e.name == json['budget_type'],
          orElse: () => BudgetType.medium,
        ),
        interests: (json['interests'] as List<dynamic>?)
                ?.map((e) => TripInterest.values.firstWhere(
                      (i) => i.name == e,
                      orElse: () => TripInterest.culture,
                    ))
                .toList() ??
            [],
        days: (json['days'] as List<dynamic>?)
                ?.map((e) => ItineraryDay.fromJson(e as Map<String, dynamic>))
                .toList() ??
            [],
        isSaved: json['is_saved'] as bool? ?? false,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'user_id': userId,
        'destination': destination,
        'start_date': startDate.toIso8601String(),
        'end_date': endDate.toIso8601String(),
        'budget_type': budgetType.name,
        'interests': interests.map((i) => i.name).toList(),
        'days': days.map((d) => d.toJson()).toList(),
        'is_saved': isSaved,
      };

  Trip copyWith({
    String? id,
    String? userId,
    String? destination,
    DateTime? startDate,
    DateTime? endDate,
    BudgetType? budgetType,
    List<TripInterest>? interests,
    List<ItineraryDay>? days,
    bool? isSaved,
  }) {
    return Trip(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      destination: destination ?? this.destination,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      budgetType: budgetType ?? this.budgetType,
      interests: interests ?? this.interests,
      days: days ?? this.days,
      isSaved: isSaved ?? this.isSaved,
    );
  }
}
