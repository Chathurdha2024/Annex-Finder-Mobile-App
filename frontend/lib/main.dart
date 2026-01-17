// lib/main.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'annex_provider.dart';
import 'screens/i_need_screen.dart';
import 'screens/i_have_screen.dart';
import 'screens/saved_screen.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (ctx) => AnnexProvider(),
      child: MaterialApp(
        title: 'Annex App',
        theme: ThemeData(primarySwatch: Colors.blue, useMaterial3: true),
        home: MainTabs(),
      ),
    );
  }
}

class MainTabs extends StatefulWidget {
  @override
  _MainTabsState createState() => _MainTabsState();
}

class _MainTabsState extends State<MainTabs> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    INeedScreen(), // Index 0
    IHaveScreen(), // Index 1
    SavedScreen(), // Index 2
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_selectedIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (int index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        destinations: const [
          NavigationDestination(icon: Icon(Icons.search), label: 'I Need'),
          NavigationDestination(icon: Icon(Icons.add_box), label: 'I Have'),
          NavigationDestination(icon: Icon(Icons.favorite), label: 'Saved'),
        ],
      ),
    );
  }
}