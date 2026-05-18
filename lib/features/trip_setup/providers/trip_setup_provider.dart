import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import 'package:travel_planner/data/models/trip.dart';
import 'package:travel_planner/data/services/itinerary_generator.dart';
import 'package:travel_planner/data/services/places_service.dart';

const _uuid = Uuid();

class TripSetupState {
  final String destination;
  final DateTime startDate;
  final int numDays;
  final BudgetType budgetType;
  final Set<TripInterest> selectedInterests;
  final bool isGenerating;
  final String? generationError;

  const TripSetupState({
    this.destination = '',
    required this.startDate,
    this.numDays = 3,
    this.budgetType = BudgetType.medium,
    this.selectedInterests = const {},
    this.isGenerating = false,
    this.generationError,
  });

  bool get isValid =>
      destination.trim().isNotEmpty &&
      selectedInterests.isNotEmpty &&
      !isGenerating;

  TripSetupState copyWith({
    String? destination,
    DateTime? startDate,
    int? numDays,
    BudgetType? budgetType,
    Set<TripInterest>? selectedInterests,
    bool? isGenerating,
    Object? generationError = _sentinel,
  }) =>
      TripSetupState(
        destination: destination ?? this.destination,
        startDate: startDate ?? this.startDate,
        numDays: numDays ?? this.numDays,
        budgetType: budgetType ?? this.budgetType,
        selectedInterests: selectedInterests ?? this.selectedInterests,
        isGenerating: isGenerating ?? this.isGenerating,
        generationError: generationError == _sentinel
            ? this.generationError
            : generationError as String?,
      );
}

// Sentinel so copyWith can explicitly null out generationError
const _sentinel = Object();

class TripSetupNotifier extends StateNotifier<TripSetupState> {
  final PlacesService _placesService;

  TripSetupNotifier(this._placesService)
      : super(TripSetupState(
          startDate: DateTime.now().add(const Duration(days: 7)),
        ));

  void setDestination(String v) =>
      state = state.copyWith(destination: v, generationError: null);
  void setStartDate(DateTime d) => state = state.copyWith(startDate: d);

  void setNumDays(int n) {
    if (n < 1 || n > 14) return;
    state = state.copyWith(numDays: n);
  }

  void setBudget(BudgetType b) => state = state.copyWith(budgetType: b);

  void toggleInterest(TripInterest interest) {
    final updated = Set<TripInterest>.from(state.selectedInterests);
    if (updated.contains(interest)) {
      updated.remove(interest);
    } else {
      updated.add(interest);
    }
    state = state.copyWith(selectedInterests: updated);
  }

  /// Returns the generated [Trip], or null if geocoding failed hard.
  /// Even on failure it falls back to template generation, so null means
  /// a programming error rather than a user-facing error.
  Future<Trip> generateTrip() async {
    state = state.copyWith(isGenerating: true, generationError: null);

    try {
      final dest = state.destination.trim();
      final days = await ItineraryGenerator.generateAsync(
        destination: dest,
        numDays: state.numDays,
        budget: state.budgetType,
        interests: state.selectedInterests.toList(),
        placesService: _placesService,
      );

      final trip = Trip(
        id: _uuid.v4(),
        destination: dest,
        startDate: state.startDate,
        endDate: state.startDate.add(Duration(days: state.numDays - 1)),
        budgetType: state.budgetType,
        interests: state.selectedInterests.toList(),
        days: days,
      );

      state = state.copyWith(isGenerating: false);
      return trip;
    } catch (e) {
      state = state.copyWith(
        isGenerating: false,
        generationError:
            'Could not load places for this destination. Using suggested itinerary.',
      );
      // Fallback to pure templates so the user still gets an itinerary
      final dest = state.destination.trim();
      final days = ItineraryGenerator.generate(
        destination: dest,
        numDays: state.numDays,
        budget: state.budgetType,
        interests: state.selectedInterests.toList(),
      );
      return Trip(
        id: _uuid.v4(),
        destination: dest,
        startDate: state.startDate,
        endDate: state.startDate.add(Duration(days: state.numDays - 1)),
        budgetType: state.budgetType,
        interests: state.selectedInterests.toList(),
        days: days,
      );
    }
  }
}

final tripSetupProvider =
    StateNotifierProvider<TripSetupNotifier, TripSetupState>(
  (ref) => TripSetupNotifier(ref.watch(placesServiceProvider)),
);
