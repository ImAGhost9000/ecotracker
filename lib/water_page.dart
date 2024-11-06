import 'package:ecotracker/Date/date_container.dart';
import 'package:flutter/material.dart';
import 'device_input_widget.dart';  // Import the reusable widget
import 'home_page.dart';  // Import HomePage for navigation
import 'package:ecotracker/Bar Graph/bar_graph.dart';
import 'package:ecotracker/Bar Graph/bar_data.dart';

class WaterPage extends StatefulWidget {
  const WaterPage({super.key});

  @override
  _WaterPageState createState() => _WaterPageState();
}

class _WaterPageState extends State<WaterPage> {
  List<Device> devices = [
    Device("Shower", 2.5, 0), // Sample devices with initial values
    Device("Tap", 1.5, 0),
    Device("Washing Machine", 10, 0),
  ];

  void updateGraph(List<Device> updatedDevices) {
    setState(() {
      devices = updatedDevices;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Calculate total water consumption based on devices (for future use)
    List<double> consumptionData = devices.map((device) {
      return device.usagePerHour * device.usageDuration; // Total gallons used
    }).toList();

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => HomePage()), // Navigate back to HomePage
            );
          },
        ),
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                const Padding(
                  padding: EdgeInsets.only(right: 16.0),
                  child: Datecontainer(),
                ),
                Bargraph(weeklyUsage: waterUsage, barColor: Colors.blue, unitMeasurement: 'GaL = Gallons Per Liter'),
                const SizedBox(height: 20),
                DeviceInputWidget(
                  boxColor: Colors.blue,
                  deviceType: 'Water',
                  onDataChange: updateGraph,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
