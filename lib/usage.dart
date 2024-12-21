// ignore_for_file: prefer_const_constructors
import 'package:ecotracker/services/water_seed.dart';
import 'package:ecotracker/Providers/electricdevices_provider.dart';
import 'package:ecotracker/Providers/waterdevices_provider.dart';
import 'package:ecotracker/circleGraph/circle_graph.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'home_page.dart'; // Import the HomePage

class UsagePage extends ConsumerStatefulWidget {
  const UsagePage({super.key});

  @override
  UsagePageState createState() => UsagePageState();
}

/// Function to convert a hex color string to a [Color] object.
Color hexToColor(String hexString) {
  hexString = hexString.replaceAll('#', '');
  if (hexString.length == 6) {
    hexString = 'FF$hexString';
  }
  return Color(int.parse('0x$hexString'));
}

/// If you need to return the hex string of a Color object
String colorToHex(Color color) {
  return '#${color.value.toRadixString(16).substring(2).toUpperCase()}';
}

class UsagePageState extends ConsumerState<UsagePage> {
  final List<Map<String, dynamic>> electricDevices = [
    {
      'title': 'Computer',
      'color': '#0000FF', // Hex String
      'value': 90.0,
    },
    {
      'title': 'Washing Machine',
      'color': '#FF0000',
      'value': 50.0,
    },
    {
      'title': 'Lights',
      'color': '#FFFF00',
      'value': 30.0,
    },
    {
      'title': 'Aircon',
      'color': '#008000',
      'value': 90.0,
    },
  ];

  final List<Map<String, dynamic>> waterDevices = [
    {
      'title': 'Faucet',
      'color': '#0000FF',
      'value': 90.0,
    },
    {
      'title': 'Shower',
      'color': '#FF0000',
      'value': 50.0,
    },
    {
      'title': 'Gardening Hose',
      'color': '#FFFF00',
      'value': 30.0,
    },
    {
      'title': 'Toilet',
      'color': '#008000',
      'value': 90.0,
    },
  ];

  String title = 'Electrical Usage';
  @override
  void initState() {
    super.initState();
    seedPredefinedDevices(); // Optional, to seed data if needed
    ref.read(waterUsagesListProvider.notifier).fetchUsageLogs();
    ref.read(electricUsagesListProvider.notifier).fetchUsageLogs();
  }

  @override
  Widget build(BuildContext context) {
    final electricDevicesUsage = ref.watch(electricDevicesWeeklyUsageProvider);
    final waterDevicesUsage = ref.watch(waterDevicesWeeklyUsageProvider);

    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Titlewidget(title: 'Electric Devices Usage'),
            Piegraph(pieChartSections: electricDevicesUsage, unit: 'Kwh'),
            Titlewidget(title: 'Water Devices Usage'),
            Piegraph(pieChartSections: waterDevicesUsage, unit: 'GpM'),
          ],
        ),
      ),
    );
  }
}

class Titlewidget extends StatelessWidget {
  const Titlewidget({
    super.key,
    required this.title,
  });

  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: Text(
        title,
        style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 20,
        ),
      ),
    );
  }
}
