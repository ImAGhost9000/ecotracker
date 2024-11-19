import 'package:ecotracker/Providers/electricdevices_provider.dart';
import 'package:flutter/material.dart';
import 'package:ecotracker/Bar Graph/bar_graph.dart';
import 'package:ecotracker/Bar Graph/bar_data.dart';
import 'package:ecotracker/Date/date_container.dart';
import 'Models/electric_devices.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:math';

class ElectricityPage extends ConsumerStatefulWidget {
  const ElectricityPage({super.key});

  @override
  ElectricityPageState createState() => ElectricityPageState();
}

class ElectricityPageState extends ConsumerState<ElectricityPage> {
  final Map<int, TextEditingController> deviceInputControllers = {};

  @override
  void dispose() {
    for (var controller in deviceInputControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    
    final electricDevices = ref.watch(electricDevicesListProvider); 
    

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
              Bargraph(
                weeklyUsage: electricalUsage, 
                barColor: Colors.yellow,
                unitMeasurement: 'KwH = Kilowatt per Hour',
              ),
              const SizedBox(height: 10),
              
              Flexible(
                child: ListView.builder(
                  itemCount: electricDevices.length,
                  itemBuilder: (context, index) {
                    final device = electricDevices[index];
                    deviceInputControllers.putIfAbsent(
                      device.id,
                      () => TextEditingController(),
                    );
                    return Card(
                      color: Colors.yellow,
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
                                controller: deviceInputControllers[device.id],
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
                                ref.read(electricDevicesListProvider.notifier).removeDevice(device.id);
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
                  padding: const EdgeInsets.all(6.0),
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
    final devices = ref.read(electricDevicesListProvider);
    final usagesNotifier = ref.read(electricUsagesListProvider.notifier);
    final now = DateTime.now();

    for (var device in devices) {
      final controller = deviceInputControllers[device.id];

      if (controller == null || controller.text.isEmpty) {
        continue;
      }

      final inputNumber = double.tryParse(controller.text) ?? 0;
      final usage = calculateDeviceUsage(device.usagePerUse, inputNumber);

      usagesNotifier.addUsageLog(
        ElectricDevicesUsageLog(deviceid: device.id, timestamp: now, usage: usage),
      );
    }
  }

  void showAddDeviceDialog(BuildContext context) {
    final devicesNotifier = ref.read(electricDevicesListProvider.notifier);
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
                decoration: const InputDecoration(labelText: "Usage per Use (kWh)"),
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
                    ElectricDevices(
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

  void editDialog(BuildContext context, ElectricDevices device) {
    final devicesNotifier = ref.read(electricDevicesListProvider.notifier);

    
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
                decoration: const InputDecoration(labelText: "Usage per Use (kWh)"),
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
                  
                  devicesNotifier.updateDevice(
                    ElectricDevices(
                      id: device.id,
                      title: title,    
                      usagePerUse: usage, 
                      color: device.color,  
                    ),
                  );
                  Navigator.of(context).pop(); // Closes Dialog
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
