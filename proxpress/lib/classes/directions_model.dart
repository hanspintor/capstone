import 'package:flutter/foundation.dart';

class Directions {
  final double totalDistance;
  final double totalDuration;

  const Directions({
    @required this.totalDistance,
    @required this.totalDuration,
  });

  factory Directions.fromMap(Map<String, dynamic> map) {
    // Check if route is not available
    if ((map['routes'] as List).isEmpty) return null;

    // Get route information
    final data = Map<String, dynamic>.from(map['routes'][0]);

    // Distance & Duration
    double distance = 0.0;
    double duration = 0.0;
    if ((data['legs'] as List).isNotEmpty) {
      final leg = data['legs'][0];
      distance = leg['distance'].toDouble();
      duration = leg['duration'].toDouble();
    }

    return Directions(
      totalDistance: double.parse((distance / 1000).toStringAsFixed(2)),
      totalDuration: duration / 60,
    );
  }
}