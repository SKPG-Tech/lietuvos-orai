import 'dart:convert';

import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart';

Future<dynamic> getPossibleLocations() async {
  Response response = await get(Uri.parse('https://api.meteo.lt/v1/places'));

  if (response.statusCode == 200) {
    return json.decode(response.body);
  } else {
    throw Exception('Nepavyko gauti galimų vietovių.');
  }
}

List<String> convertToASaveableList(dynamic _data) {
  List<String> list = [];

  _data.where((item) => item['countryCode'] == 'LT').forEach((item) => 
    list.add('${item['code']};${item['name']};${item['administrativeDivision']}')
  );

  return list;
}

dynamic convertToDynamicForm(String _data) {
  List<String> values = _data.split(';');
  dynamic newValue = {'code': '', 'name': '', 'administrativeDivision': ''};

  newValue['code'] = values[0];
  newValue['name'] = values[1];
  newValue['administrativeDivision'] = values[2];

  return newValue;
}

Future<String> getPlaceName(String _location) async {
  Response response = await get(Uri.parse('https://api.meteo.lt/v1/places/$_location'));

  if (response.statusCode == 200) {
    return json.decode(response.body)['name'];
  } else {
    throw Exception('Nepavyko gauti vietovės pavadinimo.');
  }
}

Future<Position> getCurrentLocation() async {
  bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
  LocationPermission permission;

  serviceEnabled = await Geolocator.isLocationServiceEnabled();
  if (!serviceEnabled) {
    return Future.error('Location services are disabled.');
  }

  permission = await Geolocator.checkPermission();
  if (permission == LocationPermission.denied) {
    permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.denied) {
      return Future.error('Location permissions are denied');
    }
  }
  
  if (permission == LocationPermission.deniedForever) {
    return Future.error(
      'Location permissions are permanently denied, we cannot request permissions.');
  } 

  return await Geolocator.getCurrentPosition();
}