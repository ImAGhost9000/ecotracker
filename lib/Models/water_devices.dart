import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class WaterDevices {
  final int id;
  final String title;
  final double usagePerUse;
  final String color; // Stored as a hex string

  WaterDevices({
    required this.id,
    required this.title,
    required this.usagePerUse,
    required this.color,
  });

  // Convert a Firestore JSON document to an ElectricDevices object
  factory WaterDevices.fromJson(Map<String, dynamic> json) {
    return WaterDevices(
      id: json['id'] as int,
      title: json['title'] as String,
      usagePerUse: (json['usagePerUse'] as num).toDouble(),
      color: json['color'] as String, // Hex string
    );
  }

  // Convert an ElectricDevices object to a Firestore JSON document
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'usagePerUse': usagePerUse,
      'color': color, // Hex string
    };
  }

  // Utility to convert hex to Flutter Color object
  Color getColorObject() {
    String hexString = color.replaceAll('#', '');
    if (hexString.length == 6) {
      hexString = 'FF$hexString'; // Add alpha if not present
    }
    return Color(int.parse('0x$hexString'));
  }

  // Copy with a new Color object
  WaterDevices copyWithColorObject(Color newColor) {
    final newHex =
        '#${newColor.value.toRadixString(16).padLeft(8, '0').toUpperCase()}';
    return copyWith(color: newHex);
  }

  // Generic copyWith
  WaterDevices copyWith({
    int? id,
    String? title,
    double? usagePerUse,
    String? color,
  }) {
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
  final int deviceId;
  final DateTime timestamp;
  final double usage;

  WaterDevicesUsageLog({
    required this.usageId,
    required this.deviceId,
    required this.timestamp,
    required this.usage,
  });

  WaterDevicesUsageLog.fromJson(Map<String, Object?> json)
      : this(
          usageId: json["usageId"] != null
              ? json["usageId"] as int
              : 0, // Default to 0 if null
          deviceId: json["deviceId"] != null ? json["deviceId"] as int : 0,
          timestamp: json["timestamp"] != null
              ? (json["timestamp"] as Timestamp).toDate()
              : DateTime.now(), // Default to current time if null
          usage: json["usage"] != null ? json["usage"] as double : 0.0,
        );

  factory WaterDevicesUsageLog.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return WaterDevicesUsageLog.fromJson(data); // Use the fromJson method here
  }

  WaterDevicesUsageLog copyWith({
    int? usageId,
    int? deviceId,
    DateTime? timestamp,
    double? usage,
  }) {
    return WaterDevicesUsageLog(
      usageId: usageId ?? this.usageId,
      deviceId: deviceId ?? this.deviceId,
      timestamp: timestamp ?? this.timestamp,
      usage: usage ?? this.usage,
    );
  }

  Map<String, Object?> toJson() {
    return {
      "usageId": usageId,
      "deviceid": deviceId,
      "timestamp": Timestamp.fromDate(timestamp),
      "usage": usage,
    };
  }
}
