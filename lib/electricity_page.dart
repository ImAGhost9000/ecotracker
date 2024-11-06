import 'package:flutter/material.dart';
import 'device_input_widget.dart';  // Import the reusable widget
import 'home_page.dart';  // Import HomePage for navigation
import 'package:ecotracker/Bar Graph/bar_graph.dart';
import 'package:ecotracker/Bar Graph/bar_data.dart';
import 'package:ecotracker/Date/date_container.dart';



class ElectricityPage extends StatefulWidget {
  const ElectricityPage({super.key});
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
          icon: const Icon(Icons.arrow_back),
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
                Bargraph(weeklyUsage: electricalUsage,barColor: Colors.yellow, unitMeasurement: 'KwH = Kilowatt per Liter'),
                const SizedBox(height: 20),
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




