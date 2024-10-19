import 'package:flutter/material.dart';
import 'custom_bar_graph.dart';  // Ensure this path is correct
import 'device_input_widget.dart';  // Import the reusable widget
import 'home_page.dart';  // Import HomePage for navigation

class ElectricityPage extends StatefulWidget {
  @override
  _ElectricityPageState createState() => _ElectricityPageState();
}

class _ElectricityPageState extends State<ElectricityPage> {
  List<Device> devices = [
    Device("Computer", 200, 8),    // Sample devices with garbage values
    Device("Mobile", 1.825, 6),
    Device("Fridge", 300, 10),
  ];

  // Function to handle the data change when devices are added/removed or updated
  void updateGraph(List<Device> updatedDevices) {
    setState(() {
      devices = updatedDevices;
    });

    // Logic to update the bar graph based on the new device data
  }

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
                  data: [25, 45, 35, 20, 25, 40, 20], // Use example data for now
                  labels: ['M', 'T', 'W', 'Th', 'F', 'Sat', 'Sun'],
                  title: 'Electricity Consumption (kWh)',
                  barColor: Colors.yellow,
                  maxValue: 50, // Adjust max value as needed
                  unit: 'kWh',
                ),
                SizedBox(height: 20),
                DeviceInputWidget(
                  boxColor: Colors.yellow,
                  deviceType: 'Electricity',
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
