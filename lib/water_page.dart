import 'package:ecotracker/Date/date_container.dart';
import 'package:ecotracker/Models/water_devices.dart';
import 'package:ecotracker/Providers/waterdevices_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:math';
import 'package:ecotracker/Bar Graph/bar_graph.dart';
import 'package:ecotracker/Bar Graph/bar_data.dart';

class WaterPage extends ConsumerStatefulWidget {
  const WaterPage({super.key});

  @override
  WaterPageState createState() => WaterPageState();
}

class WaterPageState extends ConsumerState<WaterPage> {
  final Map<int, TextEditingController> deviceInputControllers2 = {};

  @override
  void dispose() {
    for (var controller in deviceInputControllers2.values) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    //MaterialPageRoute(builder: (context) => const HomePage()), // Navigate back to HomePage
    final waterDevices = ref.watch(waterDevicesListProvider);


    return Scaffold(
      
      body: Center(
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

              const SizedBox(height: 10),

              Flexible(
                child: ListView.builder(
                  itemCount: waterDevices.length,
                  itemBuilder: (context, index) {
                    final device = waterDevices[index];
                    deviceInputControllers2.putIfAbsent(
                      device.id,
                      () => TextEditingController(),
                    );

                    return Card(
                      color: Colors.blue,
                      margin: const EdgeInsets.symmetric(vertical: 8.0),
                      child: Stack(
                        children: [
                          ListTile(
                            title: Text(
                                device.title,
                                style: const TextStyle(
                                  color: Colors.black
                                ),
                              ),
                            subtitle: Text("Usage: ${device.usagePerUse} kWh", style: const TextStyle(color: Colors.black),),
                            trailing: SizedBox(
                              width: 160,
                              child: TextFormField(
                                style: const TextStyle(color: Colors.black),
                                controller: deviceInputControllers2[device.id],
                                decoration: InputDecoration(
                                  labelText: 'Hours Used?', labelStyle: const TextStyle(color: Colors.black),
                                  border: const OutlineInputBorder(),
                                  enabledBorder: OutlineInputBorder(
                                    borderSide: const BorderSide(color: Colors.black),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderSide: const BorderSide(color: Colors.black),
                                    borderRadius: BorderRadius.circular(10), 
                                  ),
                                ),
                                
                                keyboardType: TextInputType.number,
                              ),
                            ),
                          ),


                          Positioned(
                            top: 28,
                            right: -12,
                            child: IconButton(
                              onPressed: () {
                                ref.read(waterDevicesListProvider.notifier).removeDevice(device.id);
                              },

                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(),
                              icon: const Icon(
                                Icons.close,
                                color: Colors.black,
                                size: 15,
                              ),
                            ),
                          ),

                          Positioned(
                            top: -3,
                            right: -12,
                            child: IconButton(
                              onPressed: () => editDialog(context,device),                             
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(),
                              icon: const Icon(
                                Icons.edit,
                                color: Colors.black,
                                size: 15,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),

              Center( 
                child: Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: ElevatedButton(
                    onPressed: () => submitUsage(),
                    child: const Text('Submit'),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),

    floatingActionButton: FloatingActionButton(
      onPressed: () => showAddDeviceDialog(context),
      child: const Icon(Icons.add),
    ),

    );
  }

  void submitUsage() {
    final devices = ref.read(waterDevicesListProvider);
    final usagesNotifier = ref.read(waterUsagesListProvider.notifier);
    final now = DateTime.now();

    for (var device in devices) {
      final controller = deviceInputControllers2[device.id];

      if (controller == null || controller.text.isEmpty) {
        continue;
      }

      final inputNumber = double.tryParse(controller.text) ?? 0;
      final usage = calculateDeviceUsage(device.usagePerUse, inputNumber);

      usagesNotifier.addUsageLog(
        WaterDevicesUsageLog(deviceid: device.id, timestamp: now, usage: usage),
      );
    }
  }

  void showAddDeviceDialog(BuildContext context) {
    final devicesNotifier = ref.read(waterDevicesListProvider.notifier);
    final titleController = TextEditingController();
    final usageController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Add New Device'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleController,
                decoration: const InputDecoration(labelText: "Device Name"),
              ),
              TextField(
                controller: usageController,
                decoration: const InputDecoration(labelText: "Usage per Use (GpM)"),
                keyboardType: TextInputType.number,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                final title = titleController.text;
                final usage = double.tryParse(usageController.text) ?? 0;
                final color = getRandomColor();

                if (title.isNotEmpty && usage > 0) {
                  devicesNotifier.addDevice(
                    WaterDevices(
                      id: DateTime.now().millisecondsSinceEpoch,
                      title: title,
                      usagePerUse: usage,
                      color: color,
                    ),
                  );
                  Navigator.of(context).pop();
                }
              },
              child: const Text('Add'),
            ),
          ],
        );
      },
    );
  }

  void editDialog(BuildContext context, WaterDevices device) {
    final devicesNotifier = ref.read(waterDevicesListProvider.notifier);

    
    final titleController = TextEditingController(text: device.title);
    final usageController = TextEditingController(text: device.usagePerUse.toString());

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Edit Device'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleController,
                decoration: const InputDecoration(labelText: "Device Name"),
              ),
              TextField(
                controller: usageController,
                decoration: const InputDecoration(labelText: "Usage per Use (GpM)"),
                keyboardType: TextInputType.number,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                final title = titleController.text;
                final usage = double.tryParse(usageController.text) ?? 0;

                if (title.isNotEmpty && usage > 0) {
                  // Update the device with new title and usage values
                  devicesNotifier.updateDevice(
                    WaterDevices(
                      id: device.id,  // Keep the same ID to identify the device
                      title: title,    // New title from text field
                      usagePerUse: usage,  // New usage from text field
                      color: device.color,  // Retain the current color
                    ),
                  );
                  Navigator.of(context).pop(); // Close the dialog
                }
              },
              child: const Text('Edit'),
            ),
          ],
        );
      },
    );
  }
}

double calculateDeviceUsage(double baseUsage, double numHours) {
  if (numHours <= 0 || numHours > 24) return 0;
  return baseUsage * numHours;
}

Color getRandomColor() {
  final Random random = Random();
  const int minBrightness = 100;

  int red = minBrightness + random.nextInt(256 - minBrightness);
  int green = minBrightness + random.nextInt(256 - minBrightness);
  int blue = minBrightness + random.nextInt(256 - minBrightness);

  return Color.fromARGB(255, red, green, blue);
}