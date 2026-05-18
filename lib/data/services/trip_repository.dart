import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:travel_planner/data/models/itinerary_day.dart';
import 'package:travel_planner/data/models/trip.dart';

// Required Supabase SQL (run once in Dashboard → SQL Editor):
//
// create table public.trips (
//   id text primary key,
//   user_id uuid references auth.users not null,
//   destination text not null,
//   start_date date not null,
//   end_date date not null,
//   budget_type text not null,
//   interests jsonb not null default '[]'::jsonb,
//   days jsonb not null default '[]'::jsonb,
//   created_at timestamptz default now()
// );
// alter table public.trips enable row level security;
// create policy "own trips select" on public.trips for select using (auth.uid() = user_id);
// create policy "own trips insert" on public.trips for insert with check (auth.uid() = user_id);
// create policy "own trips update" on public.trips for update using (auth.uid() = user_id);
// create policy "own trips delete" on public.trips for delete using (auth.uid() = user_id);

class TripRepository {
  final SupabaseClient _supabase;
  Box<String> get _box => Hive.box<String>('trips');

  TripRepository(this._supabase);

  // ─── Save (upsert) ──────────────────────────────────────────────────────────

  Future<void> saveTrip(Trip trip) async {
    // Always write to Hive first (offline-first)
    _box.put(trip.id, jsonEncode(trip.toJson()));

    await _supabase.from('trips').upsert({
      'id': trip.id,
      'user_id': trip.userId,
      'destination': trip.destination,
      'start_date': trip.startDate.toIso8601String().substring(0, 10),
      'end_date': trip.endDate.toIso8601String().substring(0, 10),
      'budget_type': trip.budgetType.name,
      'interests': trip.interests.map((i) => i.name).toList(),
      'days': trip.days.map((d) => d.toJson()).toList(),
    });
  }

  // ─── Fetch ──────────────────────────────────────────────────────────────────

  Future<List<Trip>> fetchTrips(String userId) async {
    try {
      final rows = await _supabase
          .from('trips')
          .select()
          .eq('user_id', userId)
          .order('created_at', ascending: false);

      final trips = (rows as List<dynamic>)
          .map((row) => _fromRow(row as Map<String, dynamic>))
          .toList();

      // Refresh Hive cache with latest from server
      for (final t in trips) {
        _box.put(t.id, jsonEncode(t.toJson()));
      }
      return trips;
    } catch (_) {
      // Network failure — serve from Hive cache
      return _fromHive(userId);
    }
  }

  // ─── Delete ─────────────────────────────────────────────────────────────────

  Future<void> deleteTrip(String id) async {
    _box.delete(id);
    await _supabase.from('trips').delete().eq('id', id);
  }

  // ─── Helpers ────────────────────────────────────────────────────────────────

  Trip _fromRow(Map<String, dynamic> row) => Trip(
        id: row['id'] as String,
        userId: row['user_id'] as String?,
        destination: row['destination'] as String,
        startDate: DateTime.parse(row['start_date'] as String),
        endDate: DateTime.parse(row['end_date'] as String),
        budgetType: BudgetType.values.firstWhere(
          (e) => e.name == row['budget_type'],
          orElse: () => BudgetType.medium,
        ),
        interests: (row['interests'] as List<dynamic>)
            .map((e) => TripInterest.values.firstWhere(
                  (i) => i.name == e,
                  orElse: () => TripInterest.culture,
                ))
            .toList(),
        days: (row['days'] as List<dynamic>)
            .map((e) => ItineraryDay.fromJson(e as Map<String, dynamic>))
            .toList(),
        isSaved: true,
      );

  List<Trip> _fromHive(String userId) {
    return _box.values
        .map((s) {
          try {
            final t = Trip.fromJson(jsonDecode(s) as Map<String, dynamic>);
            if (t.userId == userId) return t;
            return null;
          } catch (_) {
            return null;
          }
        })
        .whereType<Trip>()
        .toList();
  }
}

final tripRepositoryProvider = Provider<TripRepository>((ref) {
  return TripRepository(Supabase.instance.client);
});
