import 'package:ecotracker/Providers/date_provider.dart';
import 'package:ecotracker/Providers/electricdevices_provider.dart';
import 'package:ecotracker/SnackBar/snack_bar.dart';
import 'package:ecotracker/services/firebase_seed.dart';
import 'package:flutter/material.dart';
import 'package:ecotracker/Bar Graph/bar_graph.dart';
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
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final GlobalKey<FormState> _dialogKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    seedPredefinedDevices(); // Optional, to seed data if needed
    ref.read(electricUsagesListProvider.notifier).fetchUsageLogs();
    ref.read(electricDevicesListProvider.notifier).fetchDevices();
  }

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
    final electricalWeeklyUsages = ref.watch(weeklyUsageAggregatorProvider);

    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                const Padding(
                  padding: EdgeInsets.only(right: 16.0),
                  child: DateContainer(),
                ),
                Bargraph(
                  weeklyUsage: electricalWeeklyUsages,
                  barColor: const Color(0xFFF6FB7A),
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
                        color: const Color(0xFFF6FB7A), // Pastel Yellow
                        margin: const EdgeInsets.symmetric(vertical: 8.0),
                        child: Stack(
                          children: [
                            ListTile(
                              title: Text(
                                device.title,
                                style: const TextStyle(
                                  color: Colors.black,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              subtitle: Text(
                                "Usage: ${device.usagePerUse} kW",
                                style: const TextStyle(
                                  color: Colors.black,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              trailing: SizedBox(
                                width: 160,
                                child: TextFormField(
                                  style: const TextStyle(color: Colors.black),
                                  controller: deviceInputControllers[device.id],
                                  decoration: InputDecoration(
                                    labelText: 'Hours Used?',
                                    labelStyle: const TextStyle(
                                      color: Colors.black,
                                      fontWeight: FontWeight.w500,
                                    ),
                                    border: const OutlineInputBorder(),
                                    enabledBorder: OutlineInputBorder(
                                      borderSide:
                                          const BorderSide(color: Colors.black),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderSide:
                                          const BorderSide(color: Colors.black),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    errorBorder: const OutlineInputBorder(
                                      borderSide: BorderSide(color: Colors.red),
                                    ),
                                    focusedErrorBorder:
                                        const OutlineInputBorder(
                                      borderSide: BorderSide(color: Colors.red),
                                    ),
                                    errorStyle: const TextStyle(
                                      color: Colors.red,
                                      fontSize: 8,
                                    ),
                                  ),
                                  keyboardType: TextInputType.number,
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return null;
                                    }

                                    final num = double.tryParse(value);

                                    if (num == null || num <= 0) {
                                      return "enter a positive number";
                                    }

                                    if (num >= 25) {
                                      return "input cannot exceed 24 hours";
                                    }
                                    return null;
                                  },
                                ),
                              ),
                            ),
                            Positioned(
                              top: 28,
                              right: -12,
                              child: IconButton(
                                onPressed: () {
                                  showConfirmationDialog(
                                      context,
                                      () => ref
                                          .read(electricDevicesListProvider
                                              .notifier)
                                          .removeDevice(device.id),
                                      "Removing Device Deletes their Usage Logs");
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
                                onPressed: () {
                                  editDialog(context, device);
                                },
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
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          showConfirmationDialog(context, () => submitUsage(),
                              "Recorded usages cannot be removed");
                        } else {
                          showErrorSnackbar(context, "Invalid Input");
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        foregroundColor: Colors.white,
                        backgroundColor: const Color(0xFF06D001),
                      ),
                      child: const Text('Submit'),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => showAddDeviceDialog(context),
        backgroundColor: const Color(0xFF06D001),
        foregroundColor: Colors.white,
        child: const Icon(Icons.add),
      ),
    );
  }

  void submitUsage() {
    final devices = ref.read(electricDevicesListProvider);
    final usagesNotifier = ref.read(electricUsagesListProvider.notifier);
    final now = ref.read(selectedDateNotifierProvider);

    for (var device in devices) {
      final controller = deviceInputControllers[device.id];

      if (controller == null || controller.text.isEmpty) {
        continue;
      }

      final inputNumber = double.tryParse(controller.text) ?? 0;
      final usage = calculateDeviceUsage(device.usagePerUse, inputNumber);

      usagesNotifier.addUsageLog(
        ElectricDevicesUsageLog(
            usageId: 0, deviceId: device.id, timestamp: now, usage: usage),
      );

      controller.clear();
    }

    showConfirmedSnackbar(context, "Usage Recorded");
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
          content: Form(
            key: _dialogKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: titleController,
                  decoration: const InputDecoration(
                    labelText: "Device Name",
                  ),
                  validator: (value) => validateDeviceName(value),
                ),
                TextFormField(
                  controller: usageController,
                  decoration:
                      const InputDecoration(labelText: "Usage per Use (kWh)"),
                  keyboardType: TextInputType.number,
                  validator: (value) => validateUsagePerUse(value),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                if (_dialogKey.currentState!.validate()) {
                  final title = titleController.text;
                  final usage = double.tryParse(usageController.text) ?? 0;
                  final color = getRandomColor();

                  if (title.isNotEmpty && usage > 0) {
                    devicesNotifier.addDevice(
                      ElectricDevices(
                        id: 0,
                        title: title,
                        usagePerUse: usage,
                        color: color,
                      ),
                    );
                    Navigator.of(context).pop();
                  }
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
    final usageController =
        TextEditingController(text: device.usagePerUse.toString());

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Edit Device'),
          content: Form(
            key: _dialogKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: titleController,
                  decoration: const InputDecoration(labelText: "Device Name"),
                  validator: (value) => validateDeviceName(value),
                ),
                TextFormField(
                  controller: usageController,
                  decoration:
                      const InputDecoration(labelText: "Usage per Use (kWh)"),
                  keyboardType: TextInputType.number,
                  validator: (value) => validateUsagePerUse(value),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                if (_dialogKey.currentState!.validate()) {
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

String getRandomColor() {
  final Random random = Random();
  const int minBrightness = 100;

  int red = minBrightness + random.nextInt(256 - minBrightness);
  int green = minBrightness + random.nextInt(256 - minBrightness);
  int blue = minBrightness + random.nextInt(256 - minBrightness);

  return '#${red.toRadixString(16).padLeft(2, '0')}${green.toRadixString(16).padLeft(2, '0')}${blue.toRadixString(16).padLeft(2, '0')}';
}

void showConfirmationDialog(
    BuildContext context, Function onConfirm, String content) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text("Are you sure?"),
        content: Text(content),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text("No"),
          ),
          TextButton(
            onPressed: () {
              onConfirm();
              Navigator.of(context).pop();
            },
            child: const Text("Yes"),
          ),
        ],
      );
    },
  );
}

String? validateDeviceName(String? value) {
  if (value == null || value.isEmpty) {
    return 'Device Name cannot be empty';
  }
  return null;
}

String? validateUsagePerUse(String? value) {
  if (value == null || value.isEmpty) {
    return 'Usage must be a positive number';
  }
  final num = double.tryParse(value);
  if (num == null || num <= 0) {
    return 'Invalid usage value';
  }
  return null;
}
