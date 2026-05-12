import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/models/trip.dart';

// Holds the in-memory trip currently being viewed.
// Phase 8 will replace this with a Supabase-backed provider.
final currentTripProvider = StateProvider<Trip?>((ref) => null);
