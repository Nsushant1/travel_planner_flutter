import 'dart:math';

/// Nearest-Neighbor TSP heuristic with Haversine distance.
///
/// For each day we only have 3 stops (morning / afternoon / evening) so even
/// a brute-force O(n!) would be instant — but Nearest-Neighbor scales to any
/// number of places once we get real GPS coordinates from the Places API.
class TspSolver {
  static const _earthRadiusKm = 6371.0;

  // ─── Distance ──────────────────────────────────────────────────────────────

  /// Great-circle distance in km between two GPS points (Haversine formula).
  static double haversineKm(
    double lat1, double lng1,
    double lat2, double lng2,
  ) {
    final dLat = _rad(lat2 - lat1);
    final dLng = _rad(lng2 - lng1);
    final a = sin(dLat / 2) * sin(dLat / 2) +
        cos(_rad(lat1)) * cos(_rad(lat2)) * sin(dLng / 2) * sin(dLng / 2);
    final c = 2 * atan2(sqrt(a), sqrt(1 - a));
    return _earthRadiusKm * c;
  }

  static double _rad(double deg) => deg * pi / 180;

  // ─── Nearest-Neighbor heuristic ───────────────────────────────────────────

  /// Returns the visit order as a list of indices into [points].
  /// Starts from index 0 (the morning activity) and greedily picks the
  /// closest unvisited point each step.
  static List<int> nearestNeighbor(List<({double lat, double lng})> points) {
    final n = points.length;
    if (n <= 1) return List.generate(n, (i) => i);

    final visited = List<bool>.filled(n, false);
    final route = <int>[];
    var current = 0;
    visited[0] = true;
    route.add(0);

    while (route.length < n) {
      var nearest = -1;
      var minDist = double.infinity;

      for (var i = 0; i < n; i++) {
        if (visited[i]) continue;
        final d = haversineKm(
          points[current].lat, points[current].lng,
          points[i].lat, points[i].lng,
        );
        if (d < minDist) {
          minDist = d;
          nearest = i;
        }
      }

      if (nearest == -1) break;
      visited[nearest] = true;
      route.add(nearest);
      current = nearest;
    }

    return route;
  }

  // ─── Route stats ──────────────────────────────────────────────────────────

  /// Total route distance in km for a given index order.
  static double totalDistanceKm(
    List<({double lat, double lng})> points,
    List<int> order,
  ) {
    var total = 0.0;
    for (var i = 0; i < order.length - 1; i++) {
      total += haversineKm(
        points[order[i]].lat, points[order[i]].lng,
        points[order[i + 1]].lat, points[order[i + 1]].lng,
      );
    }
    return total;
  }

  /// Estimated walking time in minutes (avg 5 km/h walking speed).
  static int walkingMinutes(double distanceKm) =>
      (distanceKm / 5.0 * 60).round();

  /// Percentage distance saved: (original - optimized) / original * 100.
  /// Returns 0 if original is 0 (no coordinates yet).
  static double savingsPercent(double original, double optimized) {
    if (original == 0) return 0;
    return ((original - optimized) / original * 100).clamp(0, 100);
  }
}
