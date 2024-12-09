import 'package:ecotracker/Date/date_container.dart';
import 'package:ecotracker/Models/water_devices.dart';
import 'package:ecotracker/Providers/date_provider.dart';
import 'package:ecotracker/Providers/waterdevices_provider.dart';
import 'package:ecotracker/SnackBar/snack_bar.dart';
import 'package:ecotracker/electricity_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:math';
import 'package:ecotracker/Bar Graph/bar_graph.dart';


class WaterPage extends ConsumerStatefulWidget {
  const WaterPage({super.key});

  @override
  WaterPageState createState() => WaterPageState();
}

class WaterPageState extends ConsumerState<WaterPage> {
  final Map<int, TextEditingController> deviceInputControllers2 = {};
  final GlobalKey<FormState> _formkey2 = GlobalKey<FormState>();
  final GlobalKey<FormState> _dialogKey = GlobalKey<FormState>();

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
    final waterWeeklyUsage = ref.watch(waterWeeklyUsageAggregatorProvider);

    return Scaffold(
      
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formkey2,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                const Padding(
                  padding: EdgeInsets.only(right: 16.0),
                  child: DateContainer(),
                ),
            
                Bargraph(weeklyUsage: waterWeeklyUsage, barColor: Colors.blue, unitMeasurement: 'GpM = Gallons per Minute'),
            
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
                        color: const Color.fromARGB(255, 62, 159, 238),
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
                              subtitle: Text("Usage: ${device.usagePerUse} Gal", style: const TextStyle(color: Colors.black),),
                              trailing: SizedBox(
                                width: 160,
                                child: TextFormField(
                                  style: const TextStyle(color: Colors.black),
                                  controller: deviceInputControllers2[device.id],
                                  decoration: InputDecoration(
                                    labelText: 'Minutes Used?', labelStyle: const TextStyle(color: Colors.black),
                                    border: const OutlineInputBorder(),
                                    enabledBorder: OutlineInputBorder(
                                      borderSide: const BorderSide(color: Colors.black),
                                      borderRadius: BorderRadius.circular(10),
                                    ),

                                    focusedBorder: OutlineInputBorder(
                                      borderSide: const BorderSide(color: Colors.black),
                                      borderRadius: BorderRadius.circular(10), 
                                    ),

                                    errorBorder: const OutlineInputBorder(
                                      borderSide: BorderSide(color: Colors.red), 
                                    ),

                                    focusedErrorBorder: const OutlineInputBorder(
                                      borderSide: BorderSide(color: Colors.red),
                                    ),

                                    errorStyle: const TextStyle(
                                      color: Colors.red,
                                      fontSize: 8,
                                    ),
                                  ),
                                  
                                  keyboardType: TextInputType.number,

                                  validator: (value){
                                    if(value == null || value.isEmpty){
                                      return null;
                                    }

                                    final num = double.tryParse(value);
                                    
                                    if(num == null || num <= 0){
                                      return  "Enter a positive number";
                                    }

                                    if ( num >= 1441){
                                      return "Input cannot exceed 1440 mins";
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
                                    () => ref.read(waterDevicesListProvider.notifier).removeDevice(device.id), 
                                    "Removing Device will delete their usage logs",
                                  );
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
                      onPressed: (){
                        if(_formkey2.currentState!.validate()){
                          showConfirmationDialog(context,() => submitUsage(), "Recorded Usages cannot be removed");    
                        }

                        else {
                          showErrorSnackbar(context, "Invalid Input");
                        }
                      },
                      
                      style: ElevatedButton.styleFrom(
                        foregroundColor: Colors.white,
                        backgroundColor: Colors.green[700],
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
      backgroundColor: Colors.green[700],
      foregroundColor: Colors.white,
      child: const Icon(Icons.add),
    ),

    );
  }

  void submitUsage() {
    final devices = ref.read(waterDevicesListProvider);
    final usagesNotifier = ref.read(waterUsagesListProvider.notifier);
    final now = ref.read(selectedDateNotifierProvider);

    for (var device in devices) {
      final controller = deviceInputControllers2[device.id];

      if (controller == null || controller.text.isEmpty) {
        continue;
      }

      final inputNumber = double.tryParse(controller.text) ?? 0;
      final usage = calculateDeviceUsage(device.usagePerUse, inputNumber);

      usagesNotifier.addUsageLog(
        WaterDevicesUsageLog(
          usageId: 0,
          deviceid: device.id, 
          timestamp: now, 
          usage: usage,
        ),
      );
    }
    
    deviceInputControllers2.clear();
    showConfirmedSnackbar(context, "Usage Updated");
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
                  decoration: const InputDecoration(labelText: "Usage per Use (GpM)"),
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
                if(_dialogKey.currentState!.validate()){
                  final title = titleController.text;
                  final usage = double.tryParse(usageController.text) ?? 0;
                  final color = getRandomColor();

                  if (title.isNotEmpty && usage > 0) {
                    devicesNotifier.addDevice(
                      WaterDevices(
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

  void editDialog(BuildContext context, WaterDevices device) {
    final devicesNotifier = ref.read(waterDevicesListProvider.notifier);

    
    final titleController = TextEditingController(text: device.title);
    final usageController = TextEditingController(text: device.usagePerUse.toString());

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
                  decoration: const InputDecoration(labelText: "Usage per Use (GpM)"),
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
                if(_dialogKey.currentState!.validate()){
                  final title = titleController.text;
                  final usage = double.tryParse(usageController.text) ?? 0;

                  if (title.isNotEmpty && usage > 0) {
                    
                    devicesNotifier.updateDevice(
                      WaterDevices(
                        id: device.id,  
                        title: title,    
                        usagePerUse: usage,  
                        color: device.color,  
                      ),
                    );
                    Navigator.of(context).pop(); 
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

double calculateDeviceUsage(double baseUsage, double numMin) {
  if (numMin <= 0 || numMin > 1440) return 0;
  return baseUsage * numMin;
}

Color getRandomColor() {
  final Random random = Random();
  const int minBrightness = 100;

  int red = minBrightness + random.nextInt(256 - minBrightness);
  int green = minBrightness + random.nextInt(256 - minBrightness);
  int blue = minBrightness + random.nextInt(256 - minBrightness);

  return Color.fromARGB(255, red, green, blue);
}