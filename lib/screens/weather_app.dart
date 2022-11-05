import 'package:flutter/material.dart';

import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';

import 'package:lietuvos_orai/utils/location_utilities.dart';
import 'package:lietuvos_orai/utils/storage_utilities.dart';
import 'package:lietuvos_orai/utils/time_utilities.dart';
import 'package:lietuvos_orai/utils/widget_utilities.dart';
import 'package:lietuvos_orai/utils/weather_utilities.dart';
import 'package:lietuvos_orai/screens/search.dart';

class WeatherApp extends StatefulWidget {
  const WeatherApp({Key? key}) : super(key: key);

  @override
  State<WeatherApp> createState() => _WeatherAppState();
}

class _WeatherAppState extends State<WeatherApp> {
  dynamic weatherForecastData;
  dynamic currentLocation;
  String locationPlaceName = "";
  bool fetchingData = true;

  @override
  void initState() {
    super.initState();

    fetchData();
  }

  void fetchData() async {
    if (!await keyAvailable('location_code')) {
      setValue(DataType.string, 'location_code', 'vilnius');
    }
    
    if (!await keyAvailable('possible_locations')) {
      setValue(DataType.stringList, 'possible_locations', convertToASaveableList(await getPossibleLocations()));
      setValue(DataType.string, 'last_cache', DateFormat('yyyy-MM-dd').format(DateTime.now()).toString());
    } else {
      if (await keyAvailable('last_cache')) {
        DateTime lastCache = DateFormat('yyyy-MM-dd').parse(await getValue(DataType.string, 'last_cache'));
        if (lastCache.difference(DateTime.now()).inDays > 30) {
          setValue(DataType.stringList, 'possible_locations', convertToASaveableList(await getPossibleLocations()));
          setValue(DataType.string, 'last_cache', DateFormat('yyyy-MM-dd').format(DateTime.now()).toString());
        } 
      }
    }

    currentLocation = await getValue(DataType.string, 'location_code');
    locationPlaceName = await getPlaceName(currentLocation);
    weatherForecastData = await getWeatherForecast(currentLocation);

    setState(() {
      fetchingData = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    TextTheme textTheme = Theme.of(context).textTheme;

    return Scaffold(
      body: Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        padding: EdgeInsets.only(
          left: 20, 
          top: MediaQuery.of(context).viewPadding.top + 20, 
          right: 20, 
          bottom: MediaQuery.of(context).viewPadding.bottom + 20
        ),
        child: currentLocation != null ?
          Column(children: [
            addVerticalGap(5),
            LocationAndTime(
              locationName: locationPlaceName, 
              weekdayName: getWeekdayNameFromDate(DateTime.now()),
              currentTime: extractCurrentTime(DateTime.now())
            ),
            addVerticalGap(50),
            if (!fetchingData) WeatherStatus(weatherForecastData: weatherForecastData) 
            else const Center(child: CircularProgressIndicator(strokeWidth: 5)),
            SearchButton(onPressed: () async {
              final result = await Navigator.push(context, PageRouteBuilder(
                opaque: false,
                transitionDuration: const Duration(milliseconds: 500),
                reverseTransitionDuration: const Duration(milliseconds: 500),
                pageBuilder: (context, animation, _) => const SearchPage(),
                transitionsBuilder: (context, animation, _, child) {
                  return SlideTransition(
                    position: animation.drive(Tween(begin: const Offset(0.0, 1.0), end: const Offset(0.0, 0.0)).chain(CurveTween(curve:  Curves.linearToEaseOut))),
                    child: child,
                  );
                }
              ));

              if (result != null) {
                setValue(DataType.string, 'location_code', result);

                setState(() {
                  fetchingData = true;
                  fetchData();
                });
              }
            })
          ])
          : const Center(child: CircularProgressIndicator(strokeWidth: 5))
      ),
    );
  }
}

class LocationAndTime extends StatelessWidget {
  final String locationName;
  final String weekdayName;
  final String currentTime;

  const LocationAndTime({
    Key? key, 
    required this.locationName, 
    required this.weekdayName, 
    required this.currentTime}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    TextTheme textTheme = Theme.of(context).textTheme;

    return Row(
      mainAxisAlignment: MainAxisAlignment.end, 
      children: <Widget>[
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(locationName, style: textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w400)),
            Text(weekdayName + ', ' + currentTime, style: textTheme.subtitle2)
          ],
        )
      ]
    );
  }
}

class WeatherStatus extends StatefulWidget {
  final dynamic weatherForecastData;

  const WeatherStatus({Key? key, this.weatherForecastData}) : super(key: key);

  @override
  State<WeatherStatus> createState() => _WeatherStatusState();
}

class _WeatherStatusState extends State<WeatherStatus>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  int currentIndex = -1;
  
  @override
  void initState() {
    super.initState();
    currentIndex = getCurrentTimeIndex(convertResponseToDateList(widget.weatherForecastData['forecastTimestamps']));
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    TextTheme textTheme = Theme.of(context).textTheme;
    dynamic weatherData = widget.weatherForecastData['forecastTimestamps'][currentIndex];

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Column(children: [
        SvgPicture.asset('assets/icons/weather_icons/flat/${weatherData['conditionCode']}.svg',
          width: 100,
          height: 100,
          allowDrawingOutsideViewBox: true,
          clipBehavior: Clip.antiAlias,
        ),
        addVerticalGap(5),
        Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          Text(weatherData['airTemperature'].round().toString(), 
            style: const TextStyle(
              fontWeight: FontWeight.w500,
              fontSize: 48,
            ),
          ),
          const Text('°', style: TextStyle(
              fontFamily: 'Arial',
              fontWeight: FontWeight.w600,
              fontSize: 48,
            ),
          ),
        ]),
        addVerticalGap(5),
        Text(getConditionName(weatherData['conditionCode']), 
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 20,
            )
          )
      ]),
    );
  }
}