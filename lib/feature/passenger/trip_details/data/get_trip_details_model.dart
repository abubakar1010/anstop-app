class GetTripDetailsModel {
  final int statusCode;
  final String message;
  final TripDetailsData data;

  GetTripDetailsModel({
    required this.statusCode,
    required this.message,
    required this.data,
  });

  factory GetTripDetailsModel.fromJson(Map<String, dynamic> json) {
    return GetTripDetailsModel(
      statusCode: json['statusCode'] ?? 0,
      message: json['message'] ?? '',
      data: TripDetailsData.fromJson(json['data'] ?? {}),
    );
  }
}

/// One ride from `GET /rides/:id`. Used by both roles: the rider looks at
/// [driverId], the driver at [riderId].
class TripDetailsData {
  final String id;
  final TripUserInfo driverId;
  final TripUserInfo riderId;
  final LocationInfo pickup;
  final LocationInfo destination;
  final String distance;
  final double fare;
  final String status;
  final String paymentMethod;
  final DateTime createdAt;

  TripDetailsData({
    required this.id,
    required this.driverId,
    required this.riderId,
    required this.pickup,
    required this.destination,
    required this.distance,
    required this.fare,
    required this.status,
    required this.paymentMethod,
    required this.createdAt,
  });

  factory TripDetailsData.fromJson(Map<String, dynamic> json) {
    return TripDetailsData(
      id: json['_id'] ?? '',
      driverId: TripUserInfo.fromJson(json['driverId']),
      riderId: TripUserInfo.fromJson(json['riderId']),
      // The server's field is "pickUp"; "pickup" is kept for older payloads.
      pickup: LocationInfo.fromJson(json['pickUp'] ?? json['pickup'] ?? {}),
      destination: LocationInfo.fromJson(json['destination'] ?? {}),
      distance: '${json['distance'] ?? ''}',
      fare: (json['fare'] as num?)?.toDouble() ?? 0.0,
      status: json['status'] ?? '',
      paymentMethod: json['paymentMethod'] ?? '',
      createdAt: DateTime.tryParse(json['createdAt'] ?? '')?.toLocal() ?? DateTime.now(),
    );
  }
}

/// The rider or driver of a ride, as populated by the server.
class TripUserInfo {
  final String id;
  final String name;
  final String? profilePicture;
  final double rating;
  final int totalRides;

  TripUserInfo({
    required this.id,
    required this.name,
    this.profilePicture,
    this.rating = 0,
    this.totalRides = 0,
  });

  /// Accepts a populated user, a bare id string, or null (no driver yet).
  factory TripUserInfo.fromJson(dynamic json) {
    if (json is! Map<String, dynamic>) {
      return TripUserInfo(id: json is String ? json : '', name: '');
    }
    final first = json['firstName'] ?? json['name'] ?? '';
    final last = json['lastName'] ?? '';
    return TripUserInfo(
      id: json['_id'] ?? '',
      name: '$first $last'.trim(),
      profilePicture: json['profilePicture'],
      rating: (json['rating'] as num?)?.toDouble() ?? 0,
      totalRides: (json['totalRides'] as num?)?.toInt() ?? 0,
    );
  }
}

class LocationInfo {
  final String name;
  /// GeoJSON order: [longitude, latitude].
  final List<double> coordinates;
  final String id;

  LocationInfo({
    required this.name,
    required this.coordinates,
    required this.id,
  });

  bool get hasPosition => coordinates.length == 2;
  double get latitude => coordinates[1];
  double get longitude => coordinates[0];

  factory LocationInfo.fromJson(Map<String, dynamic> json) {
    return LocationInfo(
      name: json['name'] ?? '',
      coordinates: (json['coordinates'] as List<dynamic>?)
              ?.map((e) => (e as num).toDouble())
              .toList() ??
          [],
      id: json['_id'] ?? '',
    );
  }
}
