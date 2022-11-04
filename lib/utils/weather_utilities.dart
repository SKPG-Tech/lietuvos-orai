import 'dart:convert';

import 'package:http/http.dart';

Future<dynamic> getWeatherForecast(String _locationCode) async {
  Response response = await get(Uri.parse('https://api.meteo.lt/v1/places/$_locationCode/forecasts/long-term'));

  if (response.statusCode == 200) {
    return json.decode(response.body);
  } else {
    throw Exception('Nepavyko gauti oro prognozės.');
  }
}

String getConditionName(String _conditionCode) {
  switch (_conditionCode) {
    case 'clear':
      return 'Giedra';
    case 'isolated-clouds':
      return 'Mažai debesuota';
    case 'scattered-clouds':
      return 'Debesuota su pragiedruliais';
    case 'overcast':
      return 'Debesuota';
    case 'light-rain':
      return 'Nedidelis lietus';
    case 'moderate-rain':
      return 'Lietus';
    case 'heavy-rain':
      return 'Smarkus lietus';
    case 'sleet':
      return 'Šlapdriba';
    case 'light-snow':
      return 'Nedidelis sniegas';
    case 'moderate-snow':
      return 'Sniegas';
    case 'heavy-snow':
      return 'Smarkus sniegas';
    case 'fog':
      return 'Rūkas';
    case 'na':
    default:
      return 'Oro sąlygos nenustatytos';
  }
}