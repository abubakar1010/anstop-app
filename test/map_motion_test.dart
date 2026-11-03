import 'package:flutter_test/flutter_test.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:ride_sharing/services/car_marker_animator.dart';
import 'package:ride_sharing/services/map_motion.dart';

void main() {
  group('lerpBearing', () {
    test('turns the short way across north', () {
      expect(lerpBearing(350, 10, 0.5), closeTo(0, 1e-9));
      expect(lerpBearing(10, 350, 0.5), closeTo(0, 1e-9));
    });

    test('ends exactly on the target', () {
      expect(lerpBearing(90, 270, 1), closeTo(270, 1e-9));
      expect(lerpBearing(45, 135, 0), closeTo(45, 1e-9));
    });
  });

  test('bearingBetween points east and north', () {
    expect(bearingBetween(const LatLng(0, 0), const LatLng(0, 1)), closeTo(90, 1e-6));
    expect(bearingBetween(const LatLng(0, 0), const LatLng(1, 0)), closeTo(0, 1e-6));
  });

  group('projectOntoRoute', () {
    // An L-shaped route: east along the equator, then north.
    const route = [LatLng(0, 0), LatLng(0, 0.01), LatLng(0.01, 0.01)];

    test('lands between vertices, not on the nearest one', () {
      final p = projectOntoRoute(const LatLng(0.0001, 0.004), route)!;
      expect(p.position.latitude, closeTo(0, 1e-9));
      expect(p.position.longitude, closeTo(0.004, 1e-9));
      expect(p.segmentIndex, 0);
      expect(p.bearing, closeTo(90, 1e-6));
      expect(p.offRouteMeters, closeTo(11.1, 0.2));
    });

    test('picks the second leg and its bearing', () {
      final p = projectOntoRoute(const LatLng(0.006, 0.0101), route)!;
      expect(p.segmentIndex, 1);
      expect(p.bearing, closeTo(0, 1e-6));
    });

    test('reports how far a fix is off the route', () {
      final p = projectOntoRoute(const LatLng(0.005, 0.003), route)!;
      expect(p.offRouteMeters, greaterThan(30));
    });

    test('needs at least one segment', () {
      expect(projectOntoRoute(const LatLng(0, 0), const [LatLng(0, 0)]), isNull);
    });
  });

  group('CarMarkerAnimator', () {
    test('first sighting jumps, later fixes glide and stale cars drop', () async {
      var frames = 0;
      final cars = CarMarkerAnimator(onFrame: () => frames++);
      cars.moveTo('a', const LatLng(0, 0), 0);
      expect(cars.frames['a']!.position, const LatLng(0, 0));

      cars.moveTo('a', const LatLng(0, 0.001), 90, timestamp: 2);
      // Still at the start of the move.
      expect(cars.frames['a']!.position.longitude, lessThan(0.001));
      expect(cars.targetOf('a'), const LatLng(0, 0.001));

      // Out-of-order fix is ignored.
      cars.moveTo('a', const LatLng(5, 5), 0, timestamp: 1);
      expect(cars.targetOf('a'), const LatLng(0, 0.001));

      await Future<void>.delayed(const Duration(milliseconds: 700));
      expect(cars.frames['a']!.position.longitude, closeTo(0.001, 1e-9));
      expect(frames, greaterThan(1));

      cars.removeStale(Duration.zero);
      expect(cars.contains('a'), isFalse);
      cars.dispose();
    });

    test('ignores fixes after dispose', () {
      var frames = 0;
      final cars = CarMarkerAnimator(onFrame: () => frames++)..dispose();
      cars.moveTo('a', const LatLng(0, 0), 0);
      expect(cars.contains('a'), isFalse);
      expect(frames, 0);
    });

    test('draws nothing while paused, then lands where the car should be', () async {
      var frames = 0;
      final cars = CarMarkerAnimator(onFrame: () => frames++);
      cars.moveTo('a', const LatLng(0, 0), 0);
      cars.moveTo('a', const LatLng(0, 0.001), 90);
      cars.pause();
      final before = frames;
      await Future<void>.delayed(const Duration(milliseconds: 700));
      expect(frames, before);

      cars.resume();
      expect(frames, before + 1);
      expect(cars.frames['a']!.position.longitude, closeTo(0.001, 1e-9));
      cars.dispose();
    });
  });
}
