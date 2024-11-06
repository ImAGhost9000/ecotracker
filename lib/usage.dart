// ignore_for_file: prefer_const_constructors

import 'package:ecotracker/circleGraph/circle_graph.dart';
import 'package:flutter/material.dart';
import 'home_page.dart'; // Import the HomePage

// ignore: use_key_in_widget_constructors
class UsagePage extends StatefulWidget {

  @override
  State<UsagePage> createState() => _UsagePageState();
}

class _UsagePageState extends State<UsagePage> {
  final List<Map<String, dynamic>> electricDevices = [
    {
      'title': 'Computer',
      'color': Colors.blue,
      'value': 90.0,
    },
    {
      'title': 'Washing Machine',
      'color': Colors.red,
      'value': 50.0,
    },
    {
      'title': 'Lights',
      'color': Colors.yellow,
      'value': 30.0,
    },
    {
      'title': 'Aircon',
      'color': Colors.green,
      'value': 90.0,
    },
  ];

  final List<Map<String, dynamic>> waterDevices = [
    {
      'title': 'Faucet',
      'color': Colors.blue,
      'value': 90.0,
    },
    {
      'title': 'Shower',
      'color': Colors.red,
      'value': 50.0,
    },
    {
      'title': 'Gardening Hose',
      'color': Colors.yellow,
      'value': 30.0,
    },
    {
      'title': 'Toilet',
      'color': Colors.green,
      'value': 90.0,
    },
  ];
  String title = 'Electrical Usage';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => HomePage()), // Navigate to HomePage
            );
          },
        ),
      ),
      body:  SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Titlewidget(title: 'Electric Devices Usage'),
            Piegraph(pieChartSections: electricDevices, unit: 'Kwh'),
            Titlewidget(title: 'Water Devices Usage'),
            Piegraph(pieChartSections: waterDevices, unit: 'GaL'),
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

