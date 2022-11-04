import 'package:shared_preferences/shared_preferences.dart';

enum DataType {
  stringList,
  string,
  double,
  bool,
  int
}

Future<dynamic> getValue(DataType _dataType, String _key) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();

  switch (_dataType) {
    case DataType.stringList:
      return prefs.getStringList(_key);
    case DataType.string:
      return prefs.getString(_key);
    case DataType.double:
      return prefs.getDouble(_key);
    case DataType.bool:
      return prefs.getBool(_key);
    case DataType.int:
      return prefs.getInt(_key);
  }
}

void setValue(DataType _dataType, String _key, dynamic _value) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();

  switch (_dataType) {
    case DataType.stringList:
      prefs.setStringList(_key, _value);
      break;
    case DataType.string:
      prefs.setString(_key, _value);
      break;
    case DataType.double:
      prefs.setDouble(_key, _value);
      break;
    case DataType.bool:
      prefs.setBool(_key, _value);
      break;
    case DataType.int:
      prefs.setInt(_key, _value);
      break;
  }
}

void deleteValue(String _key) async {
  SharedPreferences prefs = await SharedPreferences.getInstance(); 
  prefs.remove(_key);
}

Future<bool> keyAvailable(String _key) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  return prefs.containsKey(_key);
}