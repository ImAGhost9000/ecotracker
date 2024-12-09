import 'package:ecotracker/Providers/date_provider.dart';
import 'package:ecotracker/Providers/electricdevices_provider.dart';
import 'package:ecotracker/SnackBar/snack_bar.dart';
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
  final GlobalKey<FormState> _formkey = GlobalKey<FormState>();
  final GlobalKey<FormState> _diaglogkey = GlobalKey<FormState>();

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
            key: _formkey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                const Padding(
                  padding: EdgeInsets.only(right: 16.0),
                  child: DateContainer(),
                ),
            
                Bargraph(
                  weeklyUsage: electricalWeeklyUsages, 
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
                                      return "enter a positive number";
                                    }

                                    if( num >= 25){
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
                                    () => ref.read(electricDevicesListProvider.notifier).removeDevice(device.id), 
                                    "Removing Device Deletes their Usage Logs"
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
                                onPressed: (){
                                  editDialog(context,device);
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
                      onPressed: (){
                        if(_formkey.currentState!.validate()){
                          showConfirmationDialog(context, () => submitUsage(), "Recorded usages cannot be removed");
                        }

                        else{
                          showErrorSnackbar(context, "Invalid Input");
                        }
                      },
                      
                      style: ElevatedButton.styleFrom(
                        foregroundColor: Colors.white,
                        backgroundColor: Colors.green[800],
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
      backgroundColor: Colors.green[800],
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
        ElectricDevicesUsageLog(usageId: 0,deviceid: device.id, timestamp: now, usage: usage),
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
            key: _diaglogkey,
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
                  decoration: const InputDecoration(labelText: "Usage per Use (kWh)"),
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
                if(_diaglogkey.currentState!.validate()){
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
    final usageController = TextEditingController(text: device.usagePerUse.toString());

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Edit Device'),
          content: Form(
            key: _diaglogkey,
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
                  decoration: const InputDecoration(labelText: "Usage per Use (kWh)"),
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

                if(_diaglogkey.currentState!.validate()){
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

Color getRandomColor() {
  final Random random = Random();
  const int minBrightness = 100;

  int red = minBrightness + random.nextInt(256 - minBrightness);
  int green = minBrightness + random.nextInt(256 - minBrightness);
  int blue = minBrightness + random.nextInt(256 - minBrightness);

  return Color.fromARGB(255, red, green, blue);
}

void showConfirmationDialog(BuildContext context, Function onConfirm, String content) {
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

String? validateDeviceName(String? value, {String emptyMessage = "Device Name cannot be blank"}){
  if(value == null || value.isEmpty){
    return emptyMessage;
  }

  return null;
}


String? validateUsagePerUse(String? value, {String emptyMessage = "Usage per use cannot be blank", String invalidMessage = "Please enter a positive value"}) {
  if (value == null || value.isEmpty) {
    return emptyMessage;
  }

  final usage = double.tryParse(value);
  if (usage == null || usage <= 0) {
    return invalidMessage;
  }

  return null;
}
