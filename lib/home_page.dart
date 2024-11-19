import 'package:ecotracker/Bar%20Graph/bar_data.dart';
import 'package:ecotracker/Bar%20Graph/bar_graph.dart';
import 'package:flutter/material.dart';
import 'settings.dart';          
import 'usage.dart';             
import 'electricity_page.dart';  
import 'water_page.dart';        

class HomePage extends StatefulWidget {
  const HomePage({super.key});
  @override
  HomePageState createState() => HomePageState();
}

class HomePageState extends State<HomePage> {
  int _selectedIndex = 0;

  // Define the different pages to display
  static final List<Widget> _widgetOptions = <Widget>[
    // ignore: prefer_const_constructors
    HomeContent(),            
    // ignore: prefer_const_constructors
    ElectricityPage(),        
    // ignore: prefer_const_constructors
    WaterPage(),              
    UsagePage(),              
    // ignore: prefer_const_constructors
    SettingsPage(),           
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
        onTap: _onItemTapped, 
      ),
    );
  }
}


class HomeContent extends StatefulWidget {
  const HomeContent({super.key}); 

  @override
  State<HomeContent> createState() => _HomeContentState();
}

class _HomeContentState extends State<HomeContent> {
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Bargraph(weeklyUsage: electricalUsage,barColor: Colors.yellow, unitMeasurement: 'KwH = Kilowatt per Liter'),
            Bargraph(weeklyUsage: waterUsage, barColor: Colors.blue, unitMeasurement: 'GaL = Gallons Per Liter'),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // Update the selected index to switch to ElectricityPage
                final homeState = context.findAncestorStateOfType<HomePageState>();
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
                  Icon(Icons.flash_on, color: Color.fromARGB(255, 241, 140, 25)),
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
                final homeState = context.findAncestorStateOfType<HomePageState>();
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
                  Icon(Icons.water_drop, color:  Color.fromARGB(255, 45, 194, 248)),
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
