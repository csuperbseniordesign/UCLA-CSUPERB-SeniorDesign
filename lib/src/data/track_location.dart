class TrackLocation {
  final double latitude;
  final double longitude;

  const TrackLocation({
    required this.latitude,
    required this.longitude,
  });

  /* REDUNDANT: never called inside this library. native_call_handler.dart
     builds the location with the TrackLocation(latitude:, longitude:)
     constructor directly. (TrackLocation is exported, so only keep this
     commented out if no outside code calls TrackLocation.fromJson.)
  factory TrackLocation.fromJson(Map<String, dynamic> json) {
    final latitude = json['latitude'] as double;
    final longitude = json['longitude'] as double;

    return TrackLocation(
      latitude: latitude,
      longitude: longitude,
    );
  }
  */
}
