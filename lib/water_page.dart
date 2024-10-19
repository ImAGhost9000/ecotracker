import 'package:flutter/material.dart';
import 'custom_bar_graph.dart';  // Ensure this path is correct
import 'device_input_widget.dart';  // Import the reusable widget
import 'home_page.dart';  // Import HomePage for navigation

class WaterPage extends StatefulWidget {
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
              children: [
                CustomBarGraph(
                  // Use temporary data for visualization
                  data: [75, 115, 100, 60, 60, 110, 50], // Temporary data for visualization
                  labels: ['M', 'T', 'W', 'Th', 'F', 'Sat', 'Sun'],
                  title: 'Water Consumption (Gallons)',
                  barColor: Colors.blue,
                  maxValue: 150, // Adjust max value as needed
                  unit: 'Gal',
                ),
                SizedBox(height: 20),
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
