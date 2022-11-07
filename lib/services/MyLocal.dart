import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class MyLocal {
  static getStringData(String key) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? data = prefs.containsKey(key) == true ? prefs.getString(key) : '';
    return data;
  }

  static setStringData(String key, String data) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString(key, data);
  }

  static getIntData(String key) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    int? data = prefs.containsKey(key) == true ? prefs.getInt(key) : -1;
    return data;
  }

  static setIntData(String key, int? data) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setInt(key, data!);
  }

  static getArrayData(String key) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? stringData =
        prefs.containsKey(key) == true ? prefs.getString(key) : '[]';
    List<dynamic> data = json.decode(stringData!);
    return data;
  }

  static getItemFromArrayData(String key, String itemKey) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? stringData =
        prefs.containsKey(key) == true ? prefs.getString(key) : '[]';
    List<dynamic> data = json.decode(stringData!);
    if (data.isNotEmpty) {
      bool check = false;
      dynamic newItem;
      for (int i = 0; i < data.length; i++) {
        var item = data[i];
        if (itemKey == item['key']) {
          newItem = item;
          check = true;
          break;
        }
      }
      if (check) {
        return newItem;
      } else {
        return false;
      }
    } else {
      return false;
    }
  }

  static removeItemFromArrayData(String key, String itemKey) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? stringData =
        prefs.containsKey(key) == true ? prefs.getString(key) : '[]';
    List<dynamic> data = json.decode(stringData!);
    if (data.isNotEmpty) {
      bool check = false;
      List<dynamic> newData = [];
      for (int i = 0; i < data.length; i++) {
        var item = data[i];
        if (itemKey != item['key']) {
          newData.add(item);
        } else {
          check = true;
        }
      }
      String dataString = json.encode(newData);
      prefs.setString(key, dataString);
      return check;
    } else {
      return true;
    }
  }

  static setArrayData(String key, dynamic? arrayItem) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? stringData =
        prefs.containsKey(key) == true ? prefs.getString(key) : '[]';
    List<dynamic> data = json.decode(stringData!);
    if (data.isNotEmpty) {
      String itemKey = arrayItem['key'];
      bool check = false;
      for (int i = 0; i < data.length; i++) {
        var item = data[i];
        if (itemKey == item['key']) {
          check = true;
          break;
        }
      }
      if (check == false) {
        data.add(arrayItem);
        String dataString = json.encode(data);
        prefs.setString(key, dataString);
        return true;
      } else {
        return false;
      }
    } else {
      data.add(arrayItem);
      String dataString = json.encode(data);
      prefs.setString(key, dataString);
      return true;
    }
  }

  static removeKey(String key) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.remove(key);
  }
}
