import 'package:flutter/material.dart';


class ElectricDevices {
  
  final int id;
  final String title;
  final double usagePerUse;
  final Color color;

  ElectricDevices({
    required this.id,
    required this.title,
    required this.usagePerUse,
    required this.color,
  });

  ElectricDevices copyWith({
    final int? id,
    final String? title,
    final double? usagePerUse,
    final Color? color,
  }){
    return ElectricDevices(
      id: id ?? this.id,
      title: title ?? this.title,
      usagePerUse: usagePerUse ?? this.usagePerUse,
      color: color ?? this.color,
    );
  }

  
}

class ElectricDevicesUsageLog {
  final int usageId;
  final int deviceid;
  final DateTime timestamp;
  final double usage;

  ElectricDevicesUsageLog({
    required this.usageId,
    required this.deviceid,
    required this.timestamp,
    required this.usage,
  });

  ElectricDevicesUsageLog copyWith({
    int? usageId,
    int? deviceid,
    DateTime? timestamp,
    double? usage,
  }) {
    return ElectricDevicesUsageLog(
      usageId: usageId ?? this.usageId,
      deviceid: deviceid ?? this.deviceid,
      timestamp: timestamp ?? this. timestamp,
      usage: usage ?? this.usage,
    );
  }
}





