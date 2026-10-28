/// One row of `GET /rides/my-rides`. The server returns the rides where the
/// user is the rider or the driver, so both "My rides" and the driver's
/// "My trips" use this model.
class MyRideModel {
  final String id;
  final Driver driver;
  final Driver rider;
  final Location? pickup;
  final Location? destination;
  final String distance;
  final double fare;
  final String status;
  final DateTime createdAt;

  /// Accepted, on the way, or finished but not yet paid.
  static const ongoingStatuses = {'ACCEPTED', 'ONGOING', 'COMPLETED'};

  /// A ride is only over for both sides once it is paid.
  static const completedStatuses = {'PAID'};

  MyRideModel({
    required this.id,
    required this.driver,
    required this.rider,
    required this.pickup,
    required this.destination,
    required this.distance,
    required this.createdAt,
    required this.fare,
    required this.status,
  });

  bool get isOngoing => ongoingStatuses.contains(status);
  bool get isCompleted => completedStatuses.contains(status);

  factory MyRideModel.fromJson(Map<String, dynamic> json) {
    // The server's field is "pickUp"; "pickup" is kept for older payloads.
    final pickup = json['pickUp'] ?? json['pickup'];
    return MyRideModel(
      id: json['_id'],
      driver: Driver.fromJson(json['driverId']),
      rider: Driver.fromJson(json['riderId']),
      pickup: pickup != null ? Location.fromJson(pickup) : null,
      destination: json['destination'] != null
          ? Location.fromJson(json['destination'])
          : null,
      distance: '${json['distance'] ?? ''}',
      fare: (json['fare'] as num? ?? 0).toDouble(),
      status: json['status'] ?? '',
      createdAt: DateTime.tryParse(json['createdAt'] ?? '')?.toLocal() ?? DateTime.now(),
    );
  }

  /// Newest first; shared by both lists.
  static List<MyRideModel> newestFirst(Iterable<MyRideModel> rides) =>
      rides.toList()..sort((a, b) => b.createdAt.compareTo(a.createdAt));
}

/// A rider or driver as populated on a ride.
class Driver {
  final String id;
  final String name;
  final String? profilePicture;

  Driver({
    required this.id,
    required this.name,
    required this.profilePicture,
  });

  /// Accepts a populated user, a bare id string, or null (no driver yet).
  factory Driver.fromJson(dynamic json) {
    if (json is! Map<String, dynamic>) {
      return Driver(id: json is String ? json : '', name: '', profilePicture: null);
    }
    final first = json['firstName'] ?? json['name'] ?? '';
    final last = json['lastName'] ?? '';
    return Driver(
      id: json['_id'] ?? '',
      name: '$first $last'.trim(),
      profilePicture: json['profilePicture'],
    );
  }
}

class Location {
  final String id;
  final String name;
  final List<double> coordinates;

  Location({
    required this.id,
    required this.name,
    required this.coordinates,
  });

  factory Location.fromJson(Map<String, dynamic> json) {
    return Location(
      id: json['_id'] ?? '',
      name: json['name'] ?? '',
      coordinates: List<double>.from(
        (json['coordinates'] as List? ?? []).map((e) => (e as num).toDouble()),
      ),
    );
  }
}
