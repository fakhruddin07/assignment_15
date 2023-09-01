import 'package:assignment_15/screen/map_screen.dart';
import 'package:flutter/material.dart';

class MyLocationApp extends StatelessWidget {
  const MyLocationApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Real Time Location Tracking App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(),
      home: const MapScreen(),
    );
  }
}
