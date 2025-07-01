import 'package:flutter/material.dart';
import 'package:chemistry_platform_app/screens/periodic_system_page.dart';
import 'package:chemistry_platform_app/screens/analytical_module_page.dart';
import 'package:chemistry_platform_app/screens/reference_materials_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  int _selectedIndex = 0;

  static const List<Widget> _widgetOptions = <Widget>[
    PeriodicSystemPage(),
    AnalyticalModulePage(),
    ReferenceMaterialsPage(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Химическая платформа',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal),
        useMaterial3: true,
      ),
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Химическая платформа'),
          backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        ),
        body: Center(
          child: _widgetOptions.elementAt(_selectedIndex),
        ),
        bottomNavigationBar: BottomNavigationBar(
          items: const <BottomNavigationBarItem>[
            BottomNavigationBarItem(
              icon: Icon(Icons.science),
              label: 'Периодическая система',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.calculate),
              label: 'Аналитический модуль',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.book),
              label: 'Справочные материалы',
            ),
          ],
          currentIndex: _selectedIndex,
          selectedItemColor: Colors.teal,
          onTap: _onItemTapped,
        ),
      ),
    );
  }
}
