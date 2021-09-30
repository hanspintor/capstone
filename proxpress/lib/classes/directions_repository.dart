import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:proxpress/services/secrets.dart';
import 'package:proxpress/classes/directions_model.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class DirectionsRepository {
  // http://project-osrm.org/docs/v5.5.1/api/#general-options
  static const String _baseUrl =
      'https://router.project-osrm.org/route/v1/car/';

  final Dio _dio;

  DirectionsRepository({Dio dio}) : _dio = dio ?? Dio();

  Future<Directions> getDirections({
    @required LatLng origin,
    @required LatLng destination,
  }) async {
    final response = await _dio.get(
      _baseUrl + '${origin.longitude},${origin.latitude};${destination.longitude},${destination.latitude}',
    );

    // Check if response is successful
    if (response.statusCode == 200) {
      return Directions.fromMap(response.data);
    }
    return null;
  }
}