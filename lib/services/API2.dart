import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:loko_media/services/Loader.dart';
import 'package:loko_media/services/MyLocal.dart';

class API {
  static Dio dio = Dio();

  static generateStorageFileUrl(String token, String fileId) {
    String url = "";
    final systemMode = dotenv.env['MODE'];
    final String? serverUrl = dotenv.env['API_URL'];
    final String? localUrl = dotenv.env['API_URL'];
    if (systemMode == 'development') {
      url = '$localUrl/api/file/get?file=$fileId&token=$token';
    } else {
      url = '$serverUrl/api/file/get?file=$fileId&token=$token';
    }
    return url.toString();
  }

  static dynamic fileUpload(String path, dynamic body) async {
    /*(dio.httpClientAdapter as DefaultHttpClientAdapter).onHttpClientCreate =
        (HttpClient client) {
      client.badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
      return client;
    };*/
    final String? serverUrl = dotenv.env['API_URL'];
    final String? localUrl = dotenv.env['API_URL'];
    final systemMode = dotenv.env['MODE'];

    String token = await MyLocal.getStringData('token');
    String language = 'tr';

    dio.options.headers['Accept'] = 'application/json; charset=utf-8';
    dio.options.headers['Content-Type'] = 'application/x-www-form-urlencoded';
    dio.options.headers["token"] = token;
    dio.options.headers["language"] = language;
    body['token'] = token;
    body['language'] = language;

    String url = "";
    if (systemMode == 'development') {
      url = '$localUrl/api/file/upload';
    } else {
      url = '$serverUrl/api/v1/upload';
    }
    String fileName = path.split('/').last;
    FormData formData = FormData.fromMap({
      "file": await MultipartFile.fromFile(path, filename: fileName),
      'form': json.encode(body)
    });
    dynamic response = await dio.post(url, data: formData);
    dynamic result = response.data;
    if (result['status'] == true) {
      return {'status': true, 'data': result['data']};
    } else {
      return {'status': false, 'message': 'Dosya Yüklenemedi'};
    }
  }

  static dynamic postRequest(String endPoint, dynamic bodyData) async {
    /* (dio.httpClientAdapter as DefaultHttpClientAdapter).onHttpClientCreate =
        (HttpClient client) {
      client.badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
      return client;
    };*/
    final String? serverUrl = dotenv.env['API_URL'];
    final String? localUrl = dotenv.env['API_URL'];
    final systemMode = dotenv.env['MODE'];

    String token = await MyLocal.getStringData('token');
    String language = 'tr';

    dio.options.headers['Accept'] = 'application/json; charset=utf-8';
    dio.options.headers['Content-Type'] = 'application/x-www-form-urlencoded';
    dio.options.headers["token"] = token;
    dio.options.headers["language"] = language;
    bodyData['token'] = token;
    bodyData['language'] = language;

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
