import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

class OnboardingNotifier extends ChangeNotifier {
  bool _done;

  OnboardingNotifier()
      : _done = Hive.box<String>('app_state').get('onboarding_done') == 'true';

  bool get isDone => _done;

  void complete() {
    if (_done) return;
    _done = true;
    Hive.box<String>('app_state').put('onboarding_done', 'true');
    notifyListeners();
  }
}

final onboardingNotifierProvider =
    ChangeNotifierProvider<OnboardingNotifier>((ref) => OnboardingNotifier());
