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
        theme: ThemeData(
          primarySwatch: Colors.blue,
          useMaterial3: true,
          brightness: Brightness.dark,
          scaffoldBackgroundColor: Color(0xFF121212),
          canvasColor: Color(0xFF1E1E1E),
          appBarTheme: AppBarTheme(
            backgroundColor: Color(0xFF1E1E1E),
            foregroundColor: Colors.white,
            iconTheme: IconThemeData(color: Colors.blue),
          ),
          textTheme: TextTheme(
            displayLarge: TextStyle(color: Colors.white),
            displayMedium: TextStyle(color: Colors.white),
            displaySmall: TextStyle(color: Colors.white),
            headlineMedium: TextStyle(color: Colors.white),
            headlineSmall: TextStyle(color: Colors.white),
            titleLarge: TextStyle(color: Colors.white),
            bodyLarge: TextStyle(color: Colors.white),
            bodyMedium: TextStyle(color: Colors.white),
            bodySmall: TextStyle(color: Colors.white70),
            labelLarge: TextStyle(color: Colors.white),
          ),
          iconTheme: IconThemeData(color: Colors.blue),
          bottomNavigationBarTheme: BottomNavigationBarThemeData(
            backgroundColor: Color(0xFF1E1E1E),
            selectedItemColor: Colors.blue,
            unselectedItemColor: Colors.white54,
          ),
          navigationBarTheme: NavigationBarThemeData(
            backgroundColor: Color(0xFF1E1E1E),
            indicatorColor: Colors.blue.withOpacity(0.2),
            labelTextStyle: MaterialStateProperty.all(
              TextStyle(color: Colors.white),
            ),
          ),
          cardTheme: CardThemeData(
            color: Color(0xFF1E1E1E),
            elevation: 2,
          ),
          inputDecorationTheme: InputDecorationTheme(
            filled: true,
            fillColor: Color(0xFF2C2C2C),
            hintStyle: TextStyle(color: Colors.white60),
            labelStyle: TextStyle(color: Colors.white),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.blue),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.blue.withOpacity(0.5)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.blue, width: 2),
            ),
          ),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
            ),
          ),
          textButtonTheme: TextButtonThemeData(
            style: TextButton.styleFrom(
              foregroundColor: Colors.blue,
            ),
          ),
        ),
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

  
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      final provider = Provider.of<AnnexProvider>(context, listen: false);
      provider.fetchAnnexes();
      provider.initializeSavedAnnexes(); 
    });
  }

  final List<Widget> _pages = [
    INeedScreen(), 
    IHaveScreen(), 
    SavedScreen(), 
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
          NavigationDestination(
            icon: Icon(Icons.search),
            label: 'I Need',
          ),
          NavigationDestination(
            icon: Icon(Icons.add_box),
            label: 'I Have',
          ),
          NavigationDestination(
            icon: Icon(Icons.favorite),
            label: 'Saved',
          ),
        ],
      ),
    );
  }
}
