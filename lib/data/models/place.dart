class Place {
  final String id;
  final String name;
  final String description;
  final double lat;
  final double lng;
  final String? imageUrl;
  final String category; // food, culture, adventure, nature, shopping, etc.
  final double? rating;

  const Place({
    required this.id,
    required this.name,
    required this.description,
    required this.lat,
    required this.lng,
    this.imageUrl,
    required this.category,
    this.rating,
  });

  factory Place.fromJson(Map<String, dynamic> json) => Place(
        id: json['id'] as String,
        name: json['name'] as String,
        description: json['description'] as String? ?? '',
        lat: (json['lat'] as num).toDouble(),
        lng: (json['lng'] as num).toDouble(),
        imageUrl: json['image_url'] as String?,
        category: json['category'] as String? ?? 'general',
        rating: (json['rating'] as num?)?.toDouble(),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'description': description,
        'lat': lat,
        'lng': lng,
        'image_url': imageUrl,
        'category': category,
        'rating': rating,
      };
}
