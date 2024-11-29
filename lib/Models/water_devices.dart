import 'package:flutter/material.dart';

class WaterDevices {
  
  final int id;
  final String title;
  final double usagePerUse;
  final Color color;

  
  WaterDevices({
    required this.id,
    required this.title,
    required this.usagePerUse,
    required this.color,
  });

  WaterDevices copyWith({
    final int? id,
    final String? title,
    final double? usagePerUse,
    final Color? color,
  }){
    return WaterDevices(
      id: id ?? this.id,
      title: title ?? this.title,
      usagePerUse: usagePerUse ?? this.usagePerUse,
      color: color ?? this.color,
    );
  }

}

class WaterDevicesUsageLog {
  final int usageId;
  final int deviceid;
  final DateTime timestamp;
  final double usage;

  WaterDevicesUsageLog({
    required this.usageId,
    required this.deviceid,
    required this.timestamp,
    required this.usage,
  });

  WaterDevicesUsageLog copyWith({
    int? usageId,
    int? deviceid,
    DateTime? timestamp,
    double? usage,
  }) {
    return WaterDevicesUsageLog(
      usageId: usageId ?? this.usageId,
      deviceid: deviceid ?? this.deviceid,
      timestamp: timestamp ?? this. timestamp,
      usage: usage ?? this.usage,
    );
  }
}

