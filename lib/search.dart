import 'package:flutter/material.dart';
import 'package:lietuvos_orai/utils/location_utilities.dart';
import 'package:lietuvos_orai/utils/storage_utilities.dart';
import 'package:lietuvos_orai/utils/widget_utilities.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({Key? key}) : super(key: key);

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  dynamic possibleLocations;
  dynamic matchingLocations;
  bool fetchingData = true;

  @override
  void initState() {
    super.initState();

    initApp();
  }
  
  void initApp() async {
    if (!await keyAvailable('possible_locations')) {
      setValue(DataType.stringList, 'possible_locations', convertToASaveableList(await getPossibleLocations()));
    }

    possibleLocations = await getValue(DataType.stringList, 'possible_locations');
    possibleLocations = possibleLocations.map((item) => convertToDynamicForm(item)).toList();

    matchingLocations = possibleLocations;

    setState(() {
      fetchingData = false;
    });
  }

  @override
  void dispose() {
    super.dispose();
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
        child: Column(children: [
          Text('Paieška', style: textTheme.headline4?.copyWith(
            color: Colors.black, 
            fontWeight: FontWeight.w500
          )),
          addVerticalGap(10),
          TextField(
            decoration: InputDecoration(
              prefixIcon: const Icon(Icons.search_rounded),
              hintText: 'Įveskite vietą',
              hintStyle: textTheme.titleMedium,
              border: const OutlineInputBorder(),
            ),
            onChanged: (changedValue) => setState(() {
              matchingLocations = List.from(possibleLocations);
              matchingLocations.retainWhere((item) => item['name'].toString().toLowerCase().contains(changedValue.toLowerCase()));
            })
          ),
          addVerticalGap(10),
          if (fetchingData) const Expanded(child: Center(
            child: CircularProgressIndicator(strokeWidth: 5)
          ))
          else Expanded(
            child: CustomScrollView(slivers: [
              SliverList(
                delegate: SliverChildBuilderDelegate(
                  (BuildContext context, int index) {
                    return LocationListTile(location: matchingLocations[index]);
                  },
                  childCount: matchingLocations.length,
                )
              )]
            )
          )]
        ),
      ),
    );
  }
}

class LocationListTile extends StatelessWidget {
  final dynamic location;

  const LocationListTile({Key? key, required this.location}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    TextTheme textTheme = Theme.of(context).textTheme;

    return GestureDetector(
      onTap: () {
        Navigator.pop(context, location['code']);
      },
      child: Padding(padding: const EdgeInsets.all(10),
        child: Row(children: [
          const Icon(Icons.location_pin, size: 45, color: Colors.red),
          addHorizontalGap(10),
          Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(location['name'], style: textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
                fontSize: 16
              )),
              addVerticalGap(2),
              Text(location['administrativeDivision'], style: textTheme.subtitle2?.copyWith(
                fontWeight: FontWeight.w600,
                color: Colors.black54
              )),
            ],
          )
        ]),
      )
    );
  }
}

class SearchButton extends StatelessWidget {
  final Function onPressed;

  const SearchButton({Key? key, required this.onPressed}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: const Alignment(0, 1),
      margin: const EdgeInsets.only(bottom: 10),
      child: FittedBox(
        fit: BoxFit.fill,
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15), 
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50)),
            foregroundColor: Colors.white,
            backgroundColor: Colors.blue,
            elevation: 5
          ),
          onPressed: () => onPressed(),
          child: Row(children: [
            const Icon(Icons.search_rounded),
            addHorizontalGap(5),
            const Text("Ieškoti", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w400))
          ])
        ),
      ),
    );
  }
}

/*
SearchButton(onPressed: () async {
            final result = await Navigator.push(context, PageRouteBuilder(
              opaque: false,
              transitionDuration: const Duration(milliseconds: 500),
              reverseTransitionDuration: const Duration(milliseconds: 500),
              pageBuilder: ((context, animation, _) => const SearchPage()),
              transitionsBuilder: (context, animation, _, child) {
                return SlideTransition(
                  position: animation.drive(Tween(begin: const Offset(0.0, -1.0), end: const Offset(0.0, 0.0)).chain(CurveTween(curve: Curves.fastLinearToSlowEaseIn))),
                  child: child,
                );
              }
            ));

            if (result != null) {
              _currentLocation = result;

              getWeatherForecast(_currentLocation).then((receivedForecast) {
                _weatherForecastData = receivedForecast;
              });
            }
          })
          */