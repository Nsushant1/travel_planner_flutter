import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../core/constants/app_colors.dart';
import '../../../data/models/trip.dart';
import '../../itinerary/providers/itinerary_provider.dart';
import '../providers/trip_setup_provider.dart';

class TripSetupScreen extends ConsumerWidget {
  const TripSetupScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(tripSetupProvider);
    final notifier = ref.read(tripSetupProvider.notifier);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Plan a Trip'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => context.pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _DestinationField(notifier: notifier, state: state),
            const SizedBox(height: 28),
            _DatesSection(notifier: notifier, state: state),
            const SizedBox(height: 28),
            _BudgetSection(notifier: notifier, state: state),
            const SizedBox(height: 28),
            _InterestsSection(notifier: notifier, state: state),
            const SizedBox(height: 36),
            _GenerateButton(state: state),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}

// ─── Destination ─────────────────────────────────────────────────────────────

class _DestinationField extends StatelessWidget {
  final TripSetupNotifier notifier;
  final TripSetupState state;
  const _DestinationField({required this.notifier, required this.state});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionLabel(number: '1', label: 'Where are you going?'),
        const SizedBox(height: 12),
        TextFormField(
          initialValue: state.destination,
          onChanged: notifier.setDestination,
          textCapitalization: TextCapitalization.words,
          decoration: const InputDecoration(
            hintText: 'e.g. Paris, Bali, New York',
            prefixIcon: Icon(Icons.location_on_outlined, color: AppColors.primary),
          ),
        ),
      ],
    );
  }
}

// ─── Dates & Duration ────────────────────────────────────────────────────────

class _DatesSection extends StatelessWidget {
  final TripSetupNotifier notifier;
  final TripSetupState state;
  const _DatesSection({required this.notifier, required this.state});

  @override
  Widget build(BuildContext context) {
    final fmt = DateFormat('dd MMM yyyy');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionLabel(number: '2', label: 'When are you travelling?'),
        const SizedBox(height: 12),
        // Start date picker
        GestureDetector(
          onTap: () async {
            final picked = await showDatePicker(
              context: context,
              initialDate: state.startDate,
              firstDate: DateTime.now(),
              lastDate: DateTime.now().add(const Duration(days: 730)),
              builder: (context, child) => Theme(
                data: Theme.of(context).copyWith(
                  colorScheme: const ColorScheme.light(
                    primary: AppColors.primary,
                    onSurface: AppColors.textPrimary,
                  ),
                ),
                child: child!,
              ),
            );
            if (picked != null) notifier.setStartDate(picked);
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: AppColors.surfaceVariant,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                const Icon(Icons.calendar_today_outlined,
                    color: AppColors.primary, size: 20),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Start Date',
                        style: TextStyle(
                            fontSize: 11,
                            color: AppColors.textSecondary,
                            fontWeight: FontWeight.w500)),
                    Text(fmt.format(state.startDate),
                        style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary)),
                  ],
                ),
                const Spacer(),
                const Icon(Icons.chevron_right_rounded,
                    color: AppColors.textSecondary),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        // Number of days stepper
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: AppColors.surfaceVariant,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              const Icon(Icons.nights_stay_outlined,
                  color: AppColors.primary, size: 20),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Duration',
                      style: TextStyle(
                          fontSize: 11,
                          color: AppColors.textSecondary,
                          fontWeight: FontWeight.w500)),
                  Text(
                    '${state.numDays} ${state.numDays == 1 ? 'day' : 'days'}',
                    style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary),
                  ),
                ],
              ),
              const Spacer(),
              _StepperButton(
                icon: Icons.remove,
                onTap: () => notifier.setNumDays(state.numDays - 1),
                enabled: state.numDays > 1,
              ),
              const SizedBox(width: 8),
              _StepperButton(
                icon: Icons.add,
                onTap: () => notifier.setNumDays(state.numDays + 1),
                enabled: state.numDays < 14,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _StepperButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final bool enabled;
  const _StepperButton(
      {required this.icon, required this.onTap, required this.enabled});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: enabled ? onTap : null,
      child: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: enabled ? AppColors.primary : AppColors.divider,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon,
            size: 18,
            color: enabled ? Colors.white : AppColors.textHint),
      ),
    );
  }
}

// ─── Budget ──────────────────────────────────────────────────────────────────

class _BudgetSection extends StatelessWidget {
  final TripSetupNotifier notifier;
  final TripSetupState state;
  const _BudgetSection({required this.notifier, required this.state});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionLabel(number: '3', label: "What's your budget?"),
        const SizedBox(height: 12),
        Row(
          children: [
            _BudgetCard(
              label: 'Budget',
              subtitle: 'Hostels & street food',
              icon: Icons.savings_outlined,
              color: AppColors.budgetLow,
              selected: state.budgetType == BudgetType.low,
              onTap: () => notifier.setBudget(BudgetType.low),
            ),
            const SizedBox(width: 10),
            _BudgetCard(
              label: 'Mid-Range',
              subtitle: 'Hotels & restaurants',
              icon: Icons.hotel_outlined,
              color: AppColors.budgetMedium,
              selected: state.budgetType == BudgetType.medium,
              onTap: () => notifier.setBudget(BudgetType.medium),
            ),
            const SizedBox(width: 10),
            _BudgetCard(
              label: 'Luxury',
              subtitle: 'Resorts & fine dining',
              icon: Icons.diamond_outlined,
              color: AppColors.budgetHigh,
              selected: state.budgetType == BudgetType.high,
              onTap: () => notifier.setBudget(BudgetType.high),
            ),
          ],
        ),
      ],
    );
  }
}

class _BudgetCard extends StatelessWidget {
  final String label;
  final String subtitle;
  final IconData icon;
  final Color color;
  final bool selected;
  final VoidCallback onTap;

  const _BudgetCard({
    required this.label,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 10),
          decoration: BoxDecoration(
            color: selected
                ? color.withValues(alpha: 0.1)
                : AppColors.surface,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: selected ? color : AppColors.divider,
              width: selected ? 2 : 1,
            ),
          ),
          child: Column(
            children: [
              Icon(icon, color: selected ? color : AppColors.textSecondary, size: 26),
              const SizedBox(height: 6),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: selected ? color : AppColors.textPrimary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: const TextStyle(
                    fontSize: 10, color: AppColors.textSecondary),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Interests ───────────────────────────────────────────────────────────────

class _InterestsSection extends StatelessWidget {
  final TripSetupNotifier notifier;
  final TripSetupState state;
  const _InterestsSection({required this.notifier, required this.state});

  static const _interests = [
    (interest: TripInterest.adventure, label: 'Adventure', icon: Icons.terrain_rounded),
    (interest: TripInterest.food, label: 'Food', icon: Icons.restaurant_rounded),
    (interest: TripInterest.culture, label: 'Culture', icon: Icons.account_balance_rounded),
    (interest: TripInterest.nature, label: 'Nature', icon: Icons.park_rounded),
    (interest: TripInterest.shopping, label: 'Shopping', icon: Icons.shopping_bag_outlined),
    (interest: TripInterest.nightlife, label: 'Nightlife', icon: Icons.nightlife_rounded),
    (interest: TripInterest.wellness, label: 'Wellness', icon: Icons.self_improvement_rounded),
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionLabel(number: '4', label: 'What are you into?'),
        const SizedBox(height: 4),
        const Text('Pick at least one',
            style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
        const SizedBox(height: 12),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: _interests.map((item) {
            final selected = state.selectedInterests.contains(item.interest);
            return GestureDetector(
              onTap: () => notifier.toggleInterest(item.interest),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: selected
                      ? AppColors.primary.withValues(alpha: 0.1)
                      : AppColors.surface,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: selected ? AppColors.primary : AppColors.divider,
                    width: selected ? 2 : 1,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(item.icon,
                        size: 18,
                        color: selected
                            ? AppColors.primary
                            : AppColors.textSecondary),
                    const SizedBox(width: 6),
                    Text(
                      item.label,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: selected
                            ? AppColors.primary
                            : AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}

// ─── Generate button ──────────────────────────────────────────────────────────

class _GenerateButton extends ConsumerWidget {
  final TripSetupState state;
  const _GenerateButton({required this.state});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (state.generationError != null) ...[
          Container(
            padding: const EdgeInsets.all(12),
            margin: const EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(
              color: Colors.orange.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.orange.withValues(alpha: 0.4)),
            ),
            child: Row(
              children: [
                const Icon(Icons.info_outline, color: Colors.orange, size: 18),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    state.generationError!,
                    style: const TextStyle(fontSize: 12, color: Colors.orange),
                  ),
                ),
              ],
            ),
          ),
        ],
        ElevatedButton.icon(
          onPressed: state.isValid
              ? () async {
                  final trip = await ref
                      .read(tripSetupProvider.notifier)
                      .generateTrip();
                  if (!context.mounted) return;
                  ref.read(currentTripProvider.notifier).state = trip;
                  context.push('/itinerary/${trip.id}');
                }
              : null,
          icon: state.isGenerating
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
              : const Icon(Icons.auto_awesome_rounded, size: 20),
          label: Text(state.isGenerating
              ? 'Searching places in ${ref.watch(tripSetupProvider).destination.trim().isNotEmpty ? ref.watch(tripSetupProvider).destination.trim() : ''}...'
              : 'Generate My Itinerary'),
          style: ElevatedButton.styleFrom(
            disabledBackgroundColor: AppColors.divider,
            disabledForegroundColor: AppColors.textHint,
          ),
        ),
      ],
    );
  }
}

// ─── Shared section label ─────────────────────────────────────────────────────

class _SectionLabel extends StatelessWidget {
  final String number;
  final String label;
  const _SectionLabel({required this.number, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 24,
          height: 24,
          decoration: const BoxDecoration(
            color: AppColors.primary,
            shape: BoxShape.circle,
          ),
          alignment: Alignment.center,
          child: Text(number,
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w700)),
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
      ],
    );
  }
}
