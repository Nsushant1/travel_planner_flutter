class Activity {
  final String id;
  final String title;
  final String description;
  final String timeSlot; // morning | afternoon | evening
  final String locationName;
  final double latitude;
  final double longitude;
  final String category;
  final String? imageUrl;
  final int estimatedDurationMinutes;

  const Activity({
    required this.id,
    required this.title,
    required this.description,
    required this.timeSlot,
    required this.locationName,
    required this.latitude,
    required this.longitude,
    required this.category,
    this.imageUrl,
    this.estimatedDurationMinutes = 60,
  });

  factory Activity.fromJson(Map<String, dynamic> json) => Activity(
        id: json['id'] as String,
        title: json['title'] as String,
        description: json['description'] as String? ?? '',
        timeSlot: json['time_slot'] as String,
        locationName: json['location_name'] as String,
        latitude: (json['latitude'] as num).toDouble(),
        longitude: (json['longitude'] as num).toDouble(),
        category: json['category'] as String? ?? 'general',
        imageUrl: json['image_url'] as String?,
        estimatedDurationMinutes: json['duration_minutes'] as int? ?? 60,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'description': description,
        'time_slot': timeSlot,
        'location_name': locationName,
        'latitude': latitude,
        'longitude': longitude,
        'category': category,
        'image_url': imageUrl,
        'duration_minutes': estimatedDurationMinutes,
      };

  /// Nominal start time for display, derived from the time slot.
  String get scheduledTime => switch (timeSlot) {
    'morning' => '9:00 AM',
    'afternoon' => '1:00 PM',
    'evening' => '6:30 PM',
    _ => '',
  };

  /// Approximate end time based on start time + activity duration.
  String get scheduledEndTime {
    final startMins = switch (timeSlot) {
      'morning' => 9 * 60,
      'afternoon' => 13 * 60,
      'evening' => 18 * 60 + 30,
      _ => 9 * 60,
    };
    final end = startMins + estimatedDurationMinutes;
    final h = (end ~/ 60) % 24;
    final m = end % 60;
    final period = h >= 12 ? 'PM' : 'AM';
    final display = h > 12 ? h - 12 : (h == 0 ? 12 : h);
    return '$display:${m.toString().padLeft(2, '0')} $period';
  }

  Activity copyWith({
    String? id,
    String? title,
    String? description,
    String? timeSlot,
    String? locationName,
    double? latitude,
    double? longitude,
    String? category,
    String? imageUrl,
    int? estimatedDurationMinutes,
  }) {
    return Activity(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      timeSlot: timeSlot ?? this.timeSlot,
      locationName: locationName ?? this.locationName,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      category: category ?? this.category,
      imageUrl: imageUrl ?? this.imageUrl,
      estimatedDurationMinutes:
          estimatedDurationMinutes ?? this.estimatedDurationMinutes,
    );
  }
}
