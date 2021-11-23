import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_osm_plugin/flutter_osm_plugin.dart';
import 'package:proxpress/classes/directions_model.dart';

class DirectionsRepository {
  // http://project-osrm.org/docs/v5.5.1/api/#general-options
  static const String _baseUrl =
      'https://router.project-osrm.org/route/v1/car/';

  final Dio _dio;

  DirectionsRepository({Dio dio}) : _dio = dio ?? Dio();

  Future<Directions> getDirections({
    @required GeoPoint origin,
    @required GeoPoint destination,
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