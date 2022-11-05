import 'package:flutter/material.dart';

import 'package:lietuvos_orai/screens/weather_app.dart';

void main() {
  runApp(MaterialApp(
    title: 'Lietuvos Orai',
    debugShowCheckedModeBanner: false,
    home: const WeatherApp(),
    theme: ThemeData(
      fontFamily: 'Montserrat',
      useMaterial3: true,
    ),
  ));
}