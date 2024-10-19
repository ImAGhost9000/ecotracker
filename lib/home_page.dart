import 'package:flutter/material.dart';
import 'custom_bar_graph.dart';  // Ensure this path is correct
import 'settings.dart';          // Import your settings page
import 'usage.dart';             // Import your usage page
import 'electricity_page.dart';  // Import your ElectricityPage
import 'water_page.dart';        // Import your WaterPage

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;

  // Define the different pages to display
  static List<Widget> _widgetOptions = <Widget>[
    HomeContent(),            // Your home content with CustomBarGraph
    ElectricityPage(),        // Page for electricity consumption
    WaterPage(),              // Page for water consumption
    UsagePage(),              // Your Usage page
    SettingsPage(),           // Your Settings page
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Ecotracker.',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.black,
        actions: [
          IconButton(
            icon: Icon(Icons.info_outline, color: Colors.white),
            onPressed: () {
              // Add info action
            },
          ),
        ],
      ),
      body: Center(
        child: _widgetOptions.elementAt(_selectedIndex), // Show the selected page
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
        selectedItemColor: Colors.green,
        unselectedItemColor: Colors.white,
        backgroundColor: Colors.black,
        onTap: _onItemTapped, // Handle the tap to change pages
      ),
    );
  }
}

// HomeContent widget to encapsulate the bar graphs
class HomeContent extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            CustomBarGraph(
              data: [25, 45, 35, 20, 25, 40, 20],
              labels: ['M', 'T', 'W', 'Th', 'F', 'Sat', 'Sun'],
              title: 'Electricity Consumption',
              barColor: Colors.yellow,
              maxValue: 50,
              unit: 'kWh', // Add unit here for electricity
            ),
            SizedBox(height: 20),
            CustomBarGraph(
              data: [75, 115, 100, 60, 60, 110, 50],
              labels: ['M', 'T', 'W', 'Th', 'F', 'Sat', 'Sun'],
              title: 'Water Consumption',
              barColor: Colors.blue,
              maxValue: 125,
              unit: 'Gal', // Add unit here for water
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // Update the selected index to switch to ElectricityPage
                final homeState = context.findAncestorStateOfType<_HomePageState>();
                if (homeState != null) {
                  homeState.setState(() {
                    homeState._selectedIndex = 1; // Switch to ElectricityPage
                  });
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.yellow,
                minimumSize: Size(double.infinity, 50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.flash_on, color: const Color.fromARGB(255, 241, 140, 25)),
                  SizedBox(width: 10),
                  Text(
                    'Electrical Devices',
                    style: TextStyle(fontSize: 18, color: Colors.black),
                  ),
                ],
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // Update the selected index to switch to WaterPage
                final homeState = context.findAncestorStateOfType<_HomePageState>();
                if (homeState != null) {
                  homeState.setState(() {
                    homeState._selectedIndex = 2; // Switch to WaterPage
                  });
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                minimumSize: Size(double.infinity, 50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.water_drop, color: const Color.fromARGB(255, 45, 194, 248)),
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
