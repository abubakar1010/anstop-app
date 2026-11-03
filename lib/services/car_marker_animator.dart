import 'dart:async';

import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:ride_sharing/services/map_motion.dart';

typedef CarFrame = ({LatLng position, double bearing});

class _CarTrack {
  _CarTrack(LatLng position, double bearing)
      : from = position,
        to = position,
        fromBearing = bearing,
        toBearing = bearing;

  LatLng from;
  LatLng to;
  double fromBearing;
  double toBearing;
  DateTime start = DateTime.now();
  Duration duration = Duration.zero;
  DateTime lastFixAt = DateTime.now();
  int? lastTimestamp;

  double progress(DateTime now) {
    if (duration == Duration.zero) return 1;
    final t = now.difference(start).inMicroseconds / duration.inMicroseconds;
    return t.clamp(0.0, 1.0);
  }

  CarFrame frame(DateTime now) {
    final t = progress(now);
    return (
      position: lerpLatLng(from, to, t),
      bearing: lerpBearing(fromBearing, toBearing, t),
    );
  }
}

/// Glides car markers between GPS fixes instead of teleporting them.
///
/// Each new fix starts a move from wherever the car is drawn *now* to the
/// fix, lasting about as long as the gap since the previous fix, so the car
/// is still moving when the next one arrives. One timer drives every car and
/// stops itself once nothing is moving.
class CarMarkerAnimator {
  CarMarkerAnimator({required this.onFrame});

  /// Called on every animation frame and after every add or remove.
  final void Function() onFrame;

  static const Duration _frameInterval = Duration(milliseconds: 33);
  static const Duration _minMove = Duration(milliseconds: 500);
  static const Duration _maxMove = Duration(seconds: 3);

  final Map<String, _CarTrack> _tracks = {};
  Timer? _timer;
  bool _paused = false;
  bool _disposed = false;

  bool contains(String id) => _tracks.containsKey(id);

  /// Where each car should be drawn right now.
  Map<String, CarFrame> get frames {
    final now = DateTime.now();
    return {for (final e in _tracks.entries) e.key: e.value.frame(now)};
  }

  /// Last fix received for [id] (not the interpolated position).
  LatLng? targetOf(String id) => _tracks[id]?.to;

  double? bearingOf(String id) => _tracks[id]?.toBearing;

  /// Moves car [id] to [position]. [timestamp] (ms, from the sender) drops
  /// fixes that arrive out of order. With [animate] off the car jumps, which
  /// is right for the very first sighting.
  void moveTo(String id, LatLng position, double bearing,
      {int? timestamp, bool animate = true}) {
    // A late socket event must not restart the timer on a closed screen.
    if (_disposed) return;
    final now = DateTime.now();
    final track = _tracks[id];
    if (track == null) {
      _tracks[id] = _CarTrack(position, bearing)..lastTimestamp = timestamp;
      onFrame();
      return;
    }
    if (timestamp != null &&
        track.lastTimestamp != null &&
        timestamp <= track.lastTimestamp!) {
      return;
    }

    final current = track.frame(now);
    final gap = now.difference(track.lastFixAt);
    track
      ..from = current.position
      ..fromBearing = current.bearing
      ..to = position
      ..toBearing = bearing
      ..start = now
      ..duration = !animate
          ? Duration.zero
          : gap < _minMove
              ? _minMove
              : gap > _maxMove
                  ? _maxMove
                  : gap
      ..lastFixAt = now
      ..lastTimestamp = timestamp ?? track.lastTimestamp;
    _ensureTicking();
  }

  void remove(String id) {
    if (_tracks.remove(id) != null) onFrame();
  }

  void removeWhere(bool Function(String id) test) =>
      _removeTracks((id, _) => test(id));

  void _removeTracks(bool Function(String id, _CarTrack track) test) {
    final before = _tracks.length;
    _tracks.removeWhere(test);
    if (_tracks.length != before) onFrame();
  }

  /// Drops cars that haven't reported for [maxAge] — the safety net for a
  /// "removed" event that never arrived.
  void removeStale(Duration maxAge, {bool Function(String id)? where}) {
    final cutoff = DateTime.now().subtract(maxAge);
    _removeTracks((id, track) =>
        (where?.call(id) ?? true) && track.lastFixAt.isBefore(cutoff));
  }

  /// Stops drawing while nobody can see the map (app in background). Fixes
  /// still land; the cars resume from wherever they should be by then.
  void pause() {
    _paused = true;
    _timer?.cancel();
    _timer = null;
  }

  void resume() {
    if (!_paused || _disposed) return;
    _paused = false;
    onFrame();
    _ensureTicking();
  }

  void _ensureTicking() {
    if (_timer != null || _paused || _disposed) return;
    _timer = Timer.periodic(_frameInterval, (_) {
      final now = DateTime.now();
      final moving = _tracks.values.any((t) => t.progress(now) < 1);
      onFrame();
      if (!moving) {
        _timer?.cancel();
        _timer = null;
      }
    });
  }

  void dispose() {
    _disposed = true;
    _timer?.cancel();
    _timer = null;
    _tracks.clear();
  }
}
