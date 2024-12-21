import 'package:ecotracker/Models/electric_devices.dart';
import 'package:ecotracker/Providers/user_provider.dart'; // Import your providers
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ElectricDevicesList extends Notifier<List<ElectricDevices>> {
  @override
  List<ElectricDevices> build() {
    return [
      ElectricDevices(
          id: 1, title: "Air Conditioner", usagePerUse: 3.5, color: "#0000FF"),
      ElectricDevices(
          id: 2, title: 'Washing Machine', usagePerUse: 2.0, color: "#FF0000"),
      ElectricDevices(
          id: 3, title: 'Lights', usagePerUse: 3.0, color: "#FFFF00"),
      ElectricDevices(
          id: 4, title: 'Computer', usagePerUse: 0.42, color: "#008000"),
      ElectricDevices(
          id: 5, title: 'Phones', usagePerUse: 0.35, color: "#FFC0CB"),
    ];
  }

  Future<void> fetchDevices() async {
    final uid = ref.read(currentUserUidProvider);

    try {
      final deviceSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .collection('electric_devices')
          .get();

      final List<ElectricDevices> fetchedDevices = [];

      for (var deviceDoc in deviceSnapshot.docs) {
        final deviceData = deviceDoc.data();
        final device = ElectricDevices(
          id: deviceData['id'],
          title: deviceData['title'],
          usagePerUse: deviceData['usagePerUse'],
          color: deviceData['color'],
        );
        fetchedDevices.add(device);
      }

      state = fetchedDevices; // Update the state with fetched devices
    } catch (e) {
      print("Error fetching water devices: $e");
    }
  }

  Future<void> addDevice(ElectricDevices newDevice) async {
    final uid = ref.read(currentUserUidProvider);
    final newId = (state.isEmpty
        ? 0
        : state.map((device) => device.id).reduce((a, b) => a > b ? a : b) + 1);

    final updatedNewDevice = newDevice.copyWith(id: newId);
    await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('electric_devices')
        .doc(newId.toString())
        .set({
      'id': updatedNewDevice.id,
      'title': updatedNewDevice.title,
      'usagePerUse': updatedNewDevice.usagePerUse,
      'color': updatedNewDevice.color,
    });
    state = [...state, updatedNewDevice];
  }

  Future<void> removeDevice(int deviceId) async {
    final uid = ref.read(currentUserUidProvider);
    await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('electric_devices')
        .doc(deviceId.toString())
        .delete();
    state = state.where((device) => device.id != deviceId).toList();
  }

  Future<void> updateDevice(ElectricDevices updatedDevice) async {
    final uid = ref.read(currentUserUidProvider);
    await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('electric_devices')
        .doc(updatedDevice.id.toString())
        .update({
      'title': updatedDevice.title,
      'usagePerUse': updatedDevice.usagePerUse,
      'color': updatedDevice.color,
    });
    state = [
      for (var device in state)
        if (device.id == updatedDevice.id) updatedDevice else device,
    ];
  }
}

final electricDevicesListProvider =
    NotifierProvider<ElectricDevicesList, List<ElectricDevices>>(
        () => ElectricDevicesList());

class ElectricUsagesList extends Notifier<List<ElectricDevicesUsageLog>> {
  @override
  List<ElectricDevicesUsageLog> build() {
    return [];
  }

  Future<void> fetchUsageLogs() async {
    final uid = ref.read(currentUserUidProvider);

    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .collection('electric_devices')
          .get();

      final List<ElectricDevicesUsageLog> fetchedLogs = [];

      for (var deviceDoc in snapshot.docs) {
        final usageLogSnapshot =
            await deviceDoc.reference.collection('usage_log').get();

        for (var logDoc in usageLogSnapshot.docs) {
          final logData = logDoc.data();
          final usageLog = ElectricDevicesUsageLog(
            usageId: logData['usageId'],
            deviceId: logData['deviceId'],
            timestamp: (logData['timestamp'] as Timestamp).toDate(),
            usage: logData['usage'].toDouble(),
          );
          fetchedLogs.add(usageLog);
        }
      }

      state = fetchedLogs; // Update the state with fetched logs
    } catch (e) {
      print("Error fetching usage logs: $e");
    }
  }

  Future<void> addUsageLog(ElectricDevicesUsageLog newUsage) async {
    final uid = ref.read(currentUserUidProvider);
    final newId = (state.isEmpty
        ? 0
        : state
                .map((usageLog) => usageLog.usageId)
                .reduce((a, b) => a > b ? a : b) +
            1);

    final updatedUsageLog = newUsage.copyWith(usageId: newId);

    await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('electric_devices')
        .doc(updatedUsageLog.deviceId
            .toString()) // The device ID as the document ID
        .collection('usage_log') // Subcollection name
        .doc(newId.toString()) // Document ID for the usage log
        .set({
      'usageId': updatedUsageLog.usageId,
      'deviceId': updatedUsageLog.deviceId,
      'timestamp': updatedUsageLog.timestamp,
      'usage': updatedUsageLog.usage,
    });
    state = [...state, updatedUsageLog];
  }
}

final electricUsagesListProvider =
    NotifierProvider<ElectricUsagesList, List<ElectricDevicesUsageLog>>(
  () => ElectricUsagesList(),
);

class WeeklyUsageAggregator extends Notifier<List<double>> {
  @override
  List<double> build() {
    final logs = ref.watch(electricUsagesListProvider);
    aggregateWeeklyUsage(logs);
    return state;
  }

  void aggregateWeeklyUsage(List<ElectricDevicesUsageLog> logs) {
    final now = DateTime.now();
    final currentWeekStart = now.subtract(Duration(days: now.weekday - 1));

    state = List.filled(7, 0.0);

    for (final log in logs) {
      final logDate =
          DateTime(log.timestamp.year, log.timestamp.month, log.timestamp.day);

      if (logDate.isAfter(currentWeekStart.subtract(const Duration(days: 1))) &&
          logDate.isBefore(currentWeekStart.add(const Duration(days: 7)))) {
        final dayIndex = log.timestamp.weekday - 1;
        state[dayIndex] += log.usage;
      }
    }
  }
}

final weeklyUsageAggregatorProvider =
    NotifierProvider<WeeklyUsageAggregator, List<double>>(
  WeeklyUsageAggregator.new,
);

final electricDevicesWeeklyUsageProvider =
    Provider<List<Map<String, dynamic>>>((ref) {
  final usageLogs = ref.watch(electricUsagesListProvider);
  final devices = ref.watch(electricDevicesListProvider);

  final Map<int, double> deviceUsageMap = {};

  for (var device in devices) {
    deviceUsageMap[device.id] = 0.0;
  }

  for (var log in usageLogs) {
    if (deviceUsageMap.containsKey(log.deviceId)) {
      deviceUsageMap[log.deviceId] = deviceUsageMap[log.deviceId]! + log.usage;
    }
  }

  final List<Map<String, dynamic>> weeklyUsage = devices.map((device) {
    return {
      'title': device.title,
      'color': device.getColorObject(),
      'value': deviceUsageMap[device.id] ?? 0.0,
    };
  }).toList();

  return weeklyUsage;
});
