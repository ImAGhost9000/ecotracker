import 'package:flutter_riverpod/flutter_riverpod.dart';

class SelectedDateNotifier extends Notifier<DateTime> {
  @override
  DateTime build() {
    return DateTime.now();
  }

  void updateDate(DateTime newDate) {
    state = newDate;
  }

  void resetToDefault() {
    state = DateTime.now();
  }
}

final selectedDateNotifierProvider =
    NotifierProvider<SelectedDateNotifier, DateTime>(
        () => SelectedDateNotifier());
