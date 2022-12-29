import 'dart:convert';
import 'dart:io';

import 'package:dio/adapter.dart';
import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:loko_media/services/Loader.dart';
import 'package:loko_media/services/MyLocal.dart';
import 'package:shared_preferences/shared_preferences.dart';

class API {
  static Dio dio = Dio();

  static dynamic fileUpload(String path, dynamic form) async {
    (dio.httpClientAdapter as DefaultHttpClientAdapter).onHttpClientCreate =
        (HttpClient client) {
      client.badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
      return client;
    };
    String jsonstr = json.encode(form);
    dynamic body = json.decode(jsonstr);
    final String? serverUrl = dotenv.env['SERVER_API_URL'];
    final String? localUrl = dotenv.env['LOCAL_API_URL'];
    final systemMode = dotenv.env['MODE'];

    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token =
        prefs.containsKey('token') == true ? prefs.getString('token') : '';
    if (token != '') {
      body['token'] = token.toString();
    }

    String url = "";
    if (systemMode == 'development') {
      url = '$localUrl/api/v1/upload';
    } else {
      url = '$serverUrl/api/v1/upload';
    }

    //File file = new File(path);
    String fileName = path.split('/').last;
    FormData formData = FormData.fromMap({
      "file": await MultipartFile.fromFile(path, filename: fileName),
      'form': json.encode(body)
    });
    dynamic response = await dio.post(url, data: formData);
    if (response.statusCode == 200) {
      return {'status': true, 'data': response.data};
    } else {
      return {'status': false, 'message': 'Dosya Yüklenemedi'};
    }
  }

  static dynamic postRequest(String endPoint, dynamic bodyData) async {
    (dio.httpClientAdapter as DefaultHttpClientAdapter).onHttpClientCreate =
        (HttpClient client) {
      client.badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
      return client;
    };
    final String? serverUrl = dotenv.env['API_URL'];
    final String? localUrl = dotenv.env['API_URL'];
    final systemMode = dotenv.env['MODE'];

    String token = await MyLocal.getStringData('token');
    String language = 'tr';

    dio.options.headers['Accept'] = 'application/json; charset=utf-8';
    dio.options.headers['Content-Type'] = 'application/x-www-form-urlencoded';
    dio.options.headers["token"] = token.toString();
    dio.options.headers["language"] = language;

    String url = "";
    if (systemMode == 'development') {
      url = '$localUrl/$endPoint';
    } else {
      url = '$serverUrl/$endPoint';
    }

    try {
      var response = await dio.post(url, data: bodyData);
      dynamic result = response.data;
      if (result['status'] == true) {
        switch (response.statusCode) {
          case 200:
            {
              return {'status': true, 'data': result['data']};
            }
          case 201:
            {
              return {'status': true, 'data': result['data']};
            }
          case 202:
            {
              return {'status': true, 'data': result['data']};
            }
        }
      } else {
        return {'status': false, 'message': result['err']};
      }
    } on DioError catch (err) {
      Loading.close();
      switch (err.response?.statusCode) {
        case 500:
          {
            String errCode = err.response?.data['message']['errCode'];
            String message = err.response?.data['message']['message'];
            return {'status': false, 'errCode': errCode, 'message': message};
            break;
          }
      }
    }
  }
}
