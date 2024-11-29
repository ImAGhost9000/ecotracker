import 'package:ecotracker/Models/electric_devices.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';

class Electricdeviceslist extends Notifier<List<ElectricDevices>>{
  
  @override
  List<ElectricDevices> build(){
    return [
      ElectricDevices(id: 1, title: "Air Conditioner", usagePerUse: 3.5, color: Colors.blue),
      ElectricDevices(id: 2, title: 'Washing Machine', usagePerUse: 2.0, color: Colors.red),
      ElectricDevices(id: 3, title: 'Lights', usagePerUse: 3.0, color: Colors.yellow),
      ElectricDevices(id: 4, title: 'Computer', usagePerUse: 0.42, color: Colors.green),
      ElectricDevices(id: 5, title: 'Phones', usagePerUse: 0.35, color: Colors.pink),
    ];
  }
   
  addDevice(ElectricDevices newDevice){
    final newId = (state.isEmpty ? 0 : state.map((device) => device.id).reduce((a,b) => a > b ? a: b) + 1); //finds the highest id number and adds 1
    final updatedNewDevice = newDevice.copyWith(id: newId);
    state = [...state,updatedNewDevice];
  }

  removeDevice(int deviceId){
    state = state.where((device) => device.id != deviceId).toList();
  }
  
  updateDevice(ElectricDevices updatedDevice) {
    state = [
      for (var device in state)
        if (device.id == updatedDevice.id) updatedDevice else device,
    ];
  }
}

final electricDevicesListProvider = NotifierProvider<Electricdeviceslist,List<ElectricDevices>>(
  () => Electricdeviceslist()
);


class Electricusageslist extends Notifier<List<ElectricDevicesUsageLog>>{
  @override
  List<ElectricDevicesUsageLog>build(){
    return[];
  }

  addUsageLog(ElectricDevicesUsageLog newUsage){
    final newId = (state.isEmpty ? 0 : state.map((usageLog) => usageLog.usageId).reduce((a,b) => a > b ? a: b) + 1);

    final updatedUsageLog = newUsage.copyWith(usageId: newId);
    
    state = [...state,updatedUsageLog];

  }
}

final electricUsagesListProvider = NotifierProvider<Electricusageslist,List<ElectricDevicesUsageLog>>(() => Electricusageslist(),);


class WeeklyUsageAggregator extends Notifier<List<double>> {
  @override
  List<double> build(){
    final logs = ref.watch(electricUsagesListProvider);
    aggregateWeeklyUsage(logs);
    return state;
  }

  void aggregateWeeklyUsage(List<ElectricDevicesUsageLog> logs){
    final now = DateTime.now();
    final currentWeekStart = now.subtract(Duration(days: now.weekday - 1));

    state = List.filled(7, 0.0);

    for(final log in logs){
      final logDate = DateTime(log.timestamp.year, log.timestamp.month, log.timestamp.day);

      if (logDate.isAfter(currentWeekStart.subtract(const Duration(days: 1))) && logDate.isBefore(currentWeekStart.add(const Duration(days: 7)))){
          final dayIndex = log.timestamp.weekday - 1;
          state[dayIndex] += log.usage;
      }
    }
  }
}

final weeklyUsageAggregatorProvider = NotifierProvider<WeeklyUsageAggregator,List<double>>(
  WeeklyUsageAggregator.new,
);

final electricDevicesWeeklyUsageProvider = Provider<List<Map<String, dynamic>>>((ref) {
  final usageLogs = ref.watch(electricUsagesListProvider); 
  final devices = ref.watch(electricDevicesListProvider); 

  
  final Map<int, double> deviceUsageMap = {};

  
  for (var device in devices) {
    deviceUsageMap[device.id] = 0.0;
  }

  for (var log in usageLogs) {
    if (deviceUsageMap.containsKey(log.deviceid)) {
      deviceUsageMap[log.deviceid] = deviceUsageMap[log.deviceid]! + log.usage;
    }
  }

  final List<Map<String, dynamic>> weeklyUsage = devices.map((device) {
    return {
      'title': device.title,
      'color': device.color,
      'value': deviceUsageMap[device.id] ?? 0.0, 
    };
  }).toList();

  return weeklyUsage;
});
