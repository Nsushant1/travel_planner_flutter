import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/models/trip.dart';
import '../../../data/services/trip_repository.dart';
import '../../auth/providers/auth_provider.dart';

class SavedTripsNotifier extends AsyncNotifier<List<Trip>> {
  @override
  Future<List<Trip>> build() async {
    final userId = ref.watch(authStateProvider).userId;
    if (userId == null) return [];
    return ref.read(tripRepositoryProvider).fetchTrips(userId);
  }

  Future<void> saveTrip(Trip trip) async {
    final userId = ref.read(authStateProvider).userId;
    if (userId == null) return;

    final toSave = trip.copyWith(userId: userId, isSaved: true);
    await ref.read(tripRepositoryProvider).saveTrip(toSave);

    final current = state.valueOrNull ?? [];
    final idx = current.indexWhere((t) => t.id == toSave.id);
    if (idx >= 0) {
      final updated = [...current];
      updated[idx] = toSave;
      state = AsyncData(updated);
    } else {
      state = AsyncData([toSave, ...current]);
    }
  }

  Future<void> deleteTrip(String id) async {
    await ref.read(tripRepositoryProvider).deleteTrip(id);
    final current = state.valueOrNull ?? [];
    state = AsyncData(current.where((t) => t.id != id).toList());
  }

  bool isSaved(String tripId) =>
      state.valueOrNull?.any((t) => t.id == tripId) ?? false;
}

final savedTripsProvider =
    AsyncNotifierProvider<SavedTripsNotifier, List<Trip>>(
  SavedTripsNotifier.new,
);
