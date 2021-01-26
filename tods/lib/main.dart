import 'package:flutter/material.dart';
import 'package:tods/screens/home.dart';

import 'package:flutter/foundation.dart'
    show debugDefaultTargetPlatformOverride;

void main() {

  // ADD THIS LINE
  debugDefaultTargetPlatformOverride = TargetPlatform.fuchsia;
  
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: TodoList(),
    );
  }
}
