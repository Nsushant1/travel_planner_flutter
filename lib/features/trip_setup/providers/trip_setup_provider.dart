import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../../data/models/trip.dart';
import '../../../data/models/itinerary_day.dart';
import '../../../data/services/itinerary_generator.dart';

const _uuid = Uuid();

class TripSetupState {
  final String destination;
  final DateTime startDate;
  final int numDays;
  final BudgetType budgetType;
  final Set<TripInterest> selectedInterests;

  const TripSetupState({
    this.destination = '',
    required this.startDate,
    this.numDays = 3,
    this.budgetType = BudgetType.medium,
    this.selectedInterests = const {},
  });

  bool get isValid =>
      destination.trim().isNotEmpty && selectedInterests.isNotEmpty;

  TripSetupState copyWith({
    String? destination,
    DateTime? startDate,
    int? numDays,
    BudgetType? budgetType,
    Set<TripInterest>? selectedInterests,
  }) =>
      TripSetupState(
        destination: destination ?? this.destination,
        startDate: startDate ?? this.startDate,
        numDays: numDays ?? this.numDays,
        budgetType: budgetType ?? this.budgetType,
        selectedInterests: selectedInterests ?? this.selectedInterests,
      );
}

class TripSetupNotifier extends StateNotifier<TripSetupState> {
  TripSetupNotifier()
      : super(TripSetupState(
          startDate: DateTime.now().add(const Duration(days: 7)),
        ));

  void setDestination(String v) => state = state.copyWith(destination: v);
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

  Trip buildTrip() {
    final List<ItineraryDay> days = ItineraryGenerator.generate(
      destination: state.destination.trim(),
      numDays: state.numDays,
      budget: state.budgetType,
      interests: state.selectedInterests.toList(),
    );

    return Trip(
      id: _uuid.v4(),
      destination: state.destination.trim(),
      startDate: state.startDate,
      endDate: state.startDate.add(Duration(days: state.numDays - 1)),
      budgetType: state.budgetType,
      interests: state.selectedInterests.toList(),
      days: days,
    );
  }
}

final tripSetupProvider =
    StateNotifierProvider<TripSetupNotifier, TripSetupState>(
  (ref) => TripSetupNotifier(),
);
