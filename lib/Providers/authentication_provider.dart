import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:ecotracker/providers/electricdevices_provider.dart'; // Ensure this is correctly imported

// This provider streams changes in authentication state (user login/logout)
final authStateProvider = StreamProvider<User?>((ref) {
  final user = FirebaseAuth.instance.authStateChanges();
  user.listen((user) {
    if (user == null) {
      // Clear relevant state when logging out
      ref.invalidate(electricDevicesListProvider);
      ref.invalidate(electricUsagesListProvider);
    }
  });
  return user;
});

// This provider triggers the refresh of the weekly usage aggregator when a user logs in
final userLoginProvider = Provider<void>((ref) {
  final user = ref.watch(authStateProvider).asData?.value;
  if (user != null) {
    // Fetch and update data for the new user
    ref.refresh(electricDevicesListProvider);
    ref.refresh(electricUsagesListProvider);
    ref.refresh(weeklyUsageAggregatorProvider); // Recalculate weekly usage
  }
});
