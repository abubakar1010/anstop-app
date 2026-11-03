import 'dart:math';

import 'package:google_maps_flutter/google_maps_flutter.dart';

/// Geometry for moving a car marker smoothly between GPS fixes.

const double _earthRadiusMeters = 6371000.0;

/// Fixes further than this from the route are drawn where they are rather
/// than pulled onto a road the driver has left.
const double kMaxRouteSnapMeters = 30;

/// Compass bearing from [from] to [to], 0–360° with 0 = north.
double bearingBetween(LatLng from, LatLng to) {
  final lat1 = from.latitude * pi / 180;
  final lat2 = to.latitude * pi / 180;
  final diffLng = (to.longitude - from.longitude) * pi / 180;

  final x = sin(diffLng) * cos(lat2);
  final y = cos(lat1) * sin(lat2) - sin(lat1) * cos(lat2) * cos(diffLng);

  return (atan2(x, y) * 180 / pi + 360) % 360;
}

double distanceMeters(LatLng a, LatLng b) {
  final dLat = (b.latitude - a.latitude) * pi / 180;
  final dLng = (b.longitude - a.longitude) * pi / 180;
  final h = sin(dLat / 2) * sin(dLat / 2) +
      cos(a.latitude * pi / 180) *
          cos(b.latitude * pi / 180) *
          sin(dLng / 2) *
          sin(dLng / 2);
  return _earthRadiusMeters * 2 * atan2(sqrt(h), sqrt(1 - h));
}

LatLng lerpLatLng(LatLng a, LatLng b, double t) => LatLng(
      a.latitude + (b.latitude - a.latitude) * t,
      a.longitude + (b.longitude - a.longitude) * t,
    );

/// Interpolates along the shorter way round, so 350° → 10° turns through 0°
/// instead of spinning the car the long way.
double lerpBearing(double a, double b, double t) {
  final delta = ((b - a + 540) % 360) - 180;
  return (a + delta * t + 360) % 360;
}

typedef RouteProjection = ({
  LatLng position,
  int segmentIndex,
  double bearing,
  double offRouteMeters,
});

/// Projects [pos] onto the closest *segment* of [route] (not just the closest
/// vertex, which made the car hop from point to point). The search starts a
/// little behind [fromIndex] because a car rarely goes backwards.
RouteProjection? projectOntoRoute(LatLng pos, List<LatLng> route,
    {int fromIndex = 0}) {
  if (route.length < 2) return null;

  // Local flat projection around [pos], in metres. Accurate enough at the
  // scale of a single road segment.
  final cosLat = cos(pos.latitude * pi / 180);
  double x(LatLng p) => (p.longitude - pos.longitude) * pi / 180 * cosLat * _earthRadiusMeters;
  double y(LatLng p) => (p.latitude - pos.latitude) * pi / 180 * _earthRadiusMeters;

  RouteProjection? best;
  final start = max(0, min(fromIndex, route.length - 2) - 2);
  for (int i = start; i < route.length - 1; i++) {
    final a = route[i];
    final b = route[i + 1];
    final ax = x(a), ay = y(a), bx = x(b), by = y(b);
    final dx = bx - ax, dy = by - ay;
    final lengthSq = dx * dx + dy * dy;
    // The car is the origin, so the projection parameter is -a·d / |d|².
    final t = lengthSq == 0 ? 0.0 : (-(ax * dx + ay * dy) / lengthSq).clamp(0.0, 1.0);
    final px = ax + dx * t, py = ay + dy * t;
    final dist = sqrt(px * px + py * py);
    if (best == null || dist < best.offRouteMeters) {
      best = (
        position: lerpLatLng(a, b, t),
        segmentIndex: i,
        bearing: lengthSq == 0 ? 0.0 : bearingBetween(a, b),
        offRouteMeters: dist,
      );
    }
  }
  return best;
}
