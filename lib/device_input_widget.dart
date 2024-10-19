import 'dart:io'; // Import this for file writing
import 'package:path_provider/path_provider.dart'; // For getting the directory path
import 'package:flutter/material.dart';

class Device {
  String name;
  double usagePerHour;  // kWh for electricity or gallons for water
  int usageDuration;    // hours for electricity or times used for water

  Device(this.name, this.usagePerHour, this.usageDuration);

  // Convert device data to JSON for file storage
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'usagePerHour': usagePerHour,
      'usageDuration': usageDuration,
    };
  }
}

class DeviceInputWidget extends StatefulWidget {
  final Color boxColor;
  final String deviceType; // Electricity or Water
  final Function onDataChange; // Function to call when data changes for graph update

  DeviceInputWidget({required this.boxColor, required this.deviceType, required this.onDataChange});

  @override
  _DeviceInputWidgetState createState() => _DeviceInputWidgetState();
}

class _DeviceInputWidgetState extends State<DeviceInputWidget> {
  List<Device> devices = [
    Device("Tap", 5, 0),
    Device("Shower", 10, 0),
  ];

  void addDevice() {
    setState(() {
      devices.add(Device("New Device", 0, 0));
    });
  }

  void removeDevice(int index) {
    setState(() {
      devices.removeAt(index);
      widget.onDataChange(devices); // Notify parent to update graph
    });
  }

  void updateDevice(int index, String name, double usage, int usageDuration) {
    setState(() {
      devices[index].name = name;
      devices[index].usagePerHour = usage;
      devices[index].usageDuration = usageDuration;
      widget.onDataChange(devices); // Notify parent to update graph
    });
  }

  // Write data to file
  Future<void> saveDataToFile() async {
    final directory = await getApplicationDocumentsDirectory(); 
    final file = File('${directory.path}/${widget.deviceType}_devices.txt');

    List<Map<String, dynamic>> jsonDevices = devices.map((device) => device.toJson()).toList();
    String jsonData = jsonDevices.toString(); // Convert to string format

    await file.writeAsString(jsonData);
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Data saved to file')));
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ListView.builder(
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          itemCount: devices.length,
          itemBuilder: (context, index) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Card(
                color: widget.boxColor,
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Stack(
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          TextFormField(
                            initialValue: devices[index].name,
                            decoration: InputDecoration(
                              labelText: '${widget.deviceType} Device Name',
                              labelStyle: TextStyle(color: Colors.black),
                            ),
                            style: TextStyle(color: Colors.black),
                            cursorColor: Colors.black,
                            onChanged: (value) {
                              updateDevice(index, value, devices[index].usagePerHour, devices[index].usageDuration);
                            },
                          ),
                          TextFormField(
                            initialValue: devices[index].usagePerHour.toString(),
                            decoration: InputDecoration(
                              labelText: widget.deviceType == 'Electricity'
                                  ? 'Usage (kWh per hour)'
                                  : 'Usage (Gallons per hour)',
                              labelStyle: TextStyle(color: Colors.black),
                            ),
                            style: TextStyle(color: Colors.black),
                            cursorColor: Colors.black,
                            keyboardType: TextInputType.number,
                            onChanged: (value) {
                              updateDevice(index, devices[index].name, double.parse(value), devices[index].usageDuration);
                            },
                          ),
                          TextFormField(
                            initialValue: devices[index].usageDuration.toString(),
                            decoration: InputDecoration(
                              labelText: widget.deviceType == 'Electricity'
                                  ? 'Total Hours Used'
                                  : 'Times Used',
                              labelStyle: TextStyle(color: Colors.black),
                            ),
                            style: TextStyle(color: Colors.black),
                            cursorColor: Colors.black,
                            keyboardType: TextInputType.number,
                            onChanged: (value) {
                              updateDevice(index, devices[index].name, devices[index].usagePerHour, int.parse(value));
                            },
                          ),
                        ],
                      ),
                      Positioned(
                        right: 0,
                        top: 0,
                        child: IconButton(
                          icon: Icon(Icons.remove_circle, color: Colors.red),
                          onPressed: () {
                            removeDevice(index);
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
        Center(
          child: ElevatedButton(
            onPressed: addDevice,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.add),
                Text(' Add Device'),
              ],
            ),
          ),
        ),
        SizedBox(height: 20),
        Center(
          child: ElevatedButton(
            onPressed: saveDataToFile,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.save),
                Text(' Submit'),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
