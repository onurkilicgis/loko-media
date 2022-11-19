import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class MyLocal {
  // SharedPreferences'da var olan bir string veriyi key aracılığı ile almak için.
  static getStringData(String key) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? data = prefs.containsKey(key) == true ? prefs.getString(key) : '';
    return data;
  }

  // SharedPreferences'a string bir veriyi key üzerinden kayıt ediyor
  static setStringData(String key, String data) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString(key, data);
  }

  // SharedPreferences'da var olan bir integer veriyi key aracılığı ile almak için.
  static getIntData(String key) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    int? data = prefs.containsKey(key) == true ? prefs.getInt(key) : -1;
    return data;
  }

  // SharedPreferences'a integer bir veriyi key üzerinden kayıt ediyor
  static setIntData(String key, int? data) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setInt(key, data!);
  }

  // SharedPreferences'da bulunan bir json dizisini key üzerinden alıyor.
  static getArrayData(String key) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? stringData =
        prefs.containsKey(key) == true ? prefs.getString(key) : '[]';
    List<dynamic> data = json.decode(stringData!);
    return data;
  }

  // SharedPreferences'da bulunan bir json dizi içerisinde itemKey'i bilinen bir item'i bize geri verir
  // Örnek : SharedPreferences'da Kişiler(key) json listesinden itemKey(TC Kimlik No)
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

  // SharedPreferences'da bulunan bir json dizi içerisinde itemKey'i bilinen bir item'i siler
  // Örnek : SharedPreferences'da Kişiler(key) json listesinden itemKey(TC Kimlik No)
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

  // Sharedpreferences'ta json listesi oluşturur
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

  // Sharedpreferences'ta her ne kayıt var ise key üzerinden kayıt altına alınmış olanı siler.
  // yukarıdakilerin hepsi için çalışır pref'ten temelli siler.
  static removeKey(String key) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.remove(key);
  }
}
