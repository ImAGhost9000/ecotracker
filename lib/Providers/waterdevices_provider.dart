
import 'package:ecotracker/Models/water_devices.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';

class WaterDevicesList extends Notifier<List<WaterDevices>>{
  
  @override
  List<WaterDevices> build(){
    return [
      WaterDevices(id: 1, title: 'Shower', usagePerUse: 2.1, color: Colors.blue),
      WaterDevices(id: 2, title: 'Washing Machine', usagePerUse: 5, color: Colors.red),
      WaterDevices(id: 3, title: 'Toilet', usagePerUse: 3, color: Colors.yellow),
      WaterDevices(id: 4, title: 'Dishwasher', usagePerUse: 4, color: Colors.green),
    ];
  }


  addDevice(WaterDevices newDevice){
    final newId = (state.isEmpty ? 0 : state.map((device) => device.id).reduce((a,b) => a > b ? a: b) + 1); //finds the highest id number and adds 1
    final updatedNewDevice = newDevice.copyWith(id: newId);
    state = [...state,updatedNewDevice];
  }

  removeDevice(int deviceId){
    state = state.where((device) => device.id != deviceId).toList();
  }
  
  updateDevice(WaterDevices updatedDevice) {
    state = [
      for (var device in state)
        if (device.id == updatedDevice.id) updatedDevice else device,
    ];
  }
   //add functions here to handle data
  
}

final waterDevicesListProvider = NotifierProvider<WaterDevicesList,List<WaterDevices>>(
  () => WaterDevicesList()
);


class Waterusageslist extends Notifier<List<WaterDevicesUsageLog>>{
  @override
  List<WaterDevicesUsageLog>build(){
    return[
       
    ];
  }

  addUsageLog(WaterDevicesUsageLog newUsage){
    final newId = (state.isEmpty ? 0 : state.map((usageLog) => usageLog.usageId).reduce((a,b) => a > b ? a: b) + 1);
    final updatedUsageLog = newUsage.copyWith(usageId: newId);
    state = [...state,updatedUsageLog];
  }
}

final waterUsagesListProvider = NotifierProvider<Waterusageslist,List<WaterDevicesUsageLog>>(() => Waterusageslist(),);

class WaterWeeklyUsageAggregator extends Notifier<List<double>> {
  @override
  List<double> build(){
    final logs = ref.watch(waterUsagesListProvider);
    aggregateWeeklyUsage(logs);
    return state;
  }

  void aggregateWeeklyUsage(List<WaterDevicesUsageLog> logs){
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

final waterWeeklyUsageAggregatorProvider = NotifierProvider<WaterWeeklyUsageAggregator,List<double>>(
  WaterWeeklyUsageAggregator.new,
);

final waterDevicesWeeklyUsageProvider = Provider<List<Map<String, dynamic>>>((ref) {
  final usageLogs = ref.watch(waterUsagesListProvider); 
  final devices = ref.watch(waterDevicesListProvider); 

  
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