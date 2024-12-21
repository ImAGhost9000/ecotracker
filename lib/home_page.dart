import 'package:ecotracker/Bar%20Graph/bar_graph.dart';
import 'package:ecotracker/Providers/electricdevices_provider.dart';
import 'package:ecotracker/Providers/waterdevices_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';
import 'settings.dart';
import 'usage.dart';
import 'electricity_page.dart';
import 'water_page.dart';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  HomePageState createState() => HomePageState();
}

class HomePageState extends ConsumerState<HomePage> {
  int _selectedIndex = 0;

  // Define the different pages to display
  static final List<Widget> _widgetOptions = <Widget>[
    const HomeContent(),
    const ElectricityPage(),
    const WaterPage(),
    const UsagePage(),
    const SettingsPage(),
  ];

  @override
  void initState() {
    super.initState();
    ref.read(waterUsagesListProvider.notifier).fetchUsageLogs();
    ref.read(electricUsagesListProvider.notifier).fetchUsageLogs();
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Image.asset(
              'images/ecotracker_logo.png',
              height: 48,
            ),
          ],
        ),
        backgroundColor: Colors.black,
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline, color: Colors.white),
            onPressed: () {
              // Show the dialog when the icon is pressed
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: const Text('About EcoTracker App'),
                    content: const Text(
                      'EcoTracker helps users monitor and reduce their environmental footprint '
                      'by tracking energy and water usage. Make more sustainable choices with ease.',
                    ),
                    actions: <Widget>[
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).pop(); // Close the dialog
                        },
                        child: const Text('Close'),
                      ),
                    ],
                  );
                },
              );
            },
          ),
        ],
      ),
      body: Center(
        child:
            _widgetOptions.elementAt(_selectedIndex), // Show the selected page
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.flash_on),
            label: 'Electricity',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.water_drop),
            label: 'Water',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.bar_chart),
            label: 'Usage',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: const Color(0xFF06D001),
        unselectedItemColor: Colors.white,
        backgroundColor: Colors.black,
        onTap: _onItemTapped,
        selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold),
      ),
    );
  }
}

class HomeContent extends ConsumerStatefulWidget {
  const HomeContent({super.key});

  @override
  HomeContentState createState() => HomeContentState();
}

class HomeContentState extends ConsumerState<HomeContent> {
  @override
  Widget build(BuildContext context) {
    final electricalWeeklyUsages = ref.watch(weeklyUsageAggregatorProvider);
    final waterWeeklyUsages = ref.watch(waterWeeklyUsageAggregatorProvider);

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Animated Text - "Track. Reduce. Sustain."
            TweenAnimationBuilder(
              tween: Tween<double>(begin: 0.0, end: 1.0),
              duration: const Duration(seconds: 2),
              builder: (context, opacity, child) {
                return Opacity(
                  opacity: opacity,
                  child: const Text(
                    'Track. Reduce. Sustain.',
                    style: TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 20),
            Bargraph(
              weeklyUsage: electricalWeeklyUsages,
              barColor: Colors.yellow,
              unitMeasurement: 'KwH = Kilowatt per Hour',
            ),
            const SizedBox(height: 20),
            Bargraph(
              weeklyUsage: waterWeeklyUsages,
              barColor: Colors.blue,
              unitMeasurement: 'GpM = Gallons Per Minute',
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // Update the selected index to switch to ElectricityPage
                final homeState =
                    context.findAncestorStateOfType<HomePageState>();
                if (homeState != null) {
                  homeState.setState(() {
                    homeState._selectedIndex = 1; // Switch to ElectricityPage
                  });
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.yellow,
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25),
                ),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.flash_on,
                      color: Color.fromARGB(255, 241, 140, 25)),
                  SizedBox(width: 10),
                  Text(
                    'Electrical Devices',
                    style: TextStyle(fontSize: 18, color: Colors.black),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // Update the selected index to switch to WaterPage
                final homeState =
                    context.findAncestorStateOfType<HomePageState>();
                if (homeState != null) {
                  homeState.setState(() {
                    homeState._selectedIndex = 2; // Switch to WaterPage
                  });
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25),
                ),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.water_drop,
                      color: Color.fromARGB(255, 45, 194, 248)),
                  SizedBox(width: 10),
                  Text(
                    'Water Utilities',
                    style: TextStyle(fontSize: 18, color: Colors.white),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
