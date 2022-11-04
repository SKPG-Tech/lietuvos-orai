import 'package:intl/intl.dart';

List<DateTime> convertResponseToDateList(dynamic _responseToConvert) {
  List<DateTime> resultList = [];

  _responseToConvert.forEach((item) {
    resultList.add(DateFormat('yyyy-MM-dd HH:mm:ss').parseUTC(item['forecastTimeUtc']));
  });

  return resultList;
}

DateTime convertToLocalTimezone(String _dateToConvert) {
  return DateFormat('yyyy-MM-dd HH:mm:ss').parseUTC(_dateToConvert).toLocal();
}

int getCurrentTimeIndex(List<DateTime> _dateList) {
  DateTime currentTime = DateTime.now().toUtc();

  for (int i = 0; i < _dateList.length; i++) {
    if (_dateList[i].hour == currentTime.hour) {
      if (currentTime.minute >= _dateList[i].minute + 45) {
        return i + 1;
      } else {
        return i;
      }
    } else {
      continue;
    }
  }

  return -1;
}

String getWeekdayNameFromDate(DateTime _currentDate) {
  switch (_currentDate.weekday) {
    case 1:
      return 'Pirmadienis';
    case 2:
      return 'Antradienis';
    case 3:
      return 'Trečiadienis';
    case 4:
      return 'Ketvirtadiens';
    case 5:
      return 'Penktadienis';
    case 6:
      return 'Šeštadienis';
    case 7:
      return 'Sekmadienis';
    default:
      return '?';
  }
}

String extractCurrentTime(DateTime _currentDate) {
  return '${_currentDate.hour}'.padLeft(2,'0') + ':' + '${_currentDate.minute}'.padLeft(2,'0');
}