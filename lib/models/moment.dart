class Moment {
  final String id;
  final String videoUrl;
  final String userId;
  final double latitude;
  final double longitude;
  final DateTime createdAt;

  Moment({
    required this.id,
    required this.videoUrl,
    required this.userId,
    required this.latitude,
    required this.longitude,
    required this.createdAt,
  });

  factory Moment.fromMap(Map<String, dynamic> map, String id) {
    return Moment(
      id: id,
      videoUrl: map['videourl'] ?? '', // 소문자
      userId: map['userid'] ?? '',     // 소문자
      latitude: (map['latitude'] as num).toDouble(),
      longitude: (map['longitude'] as num).toDouble(),
      createdAt: map['created_at'] != null 
          ? DateTime.parse(map['created_at'].toString()) 
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'videourl': videoUrl,
      'userid': userId,
      'latitude': latitude,
      'longitude': longitude,
    };
  }
}
