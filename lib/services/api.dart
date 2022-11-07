import 'dart:convert';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:loko_media/services/utils.dart';
import 'package:shared_preferences/shared_preferences.dart';

class apiResult {
  String? status;
  var message;
  dynamic? data;
  String? code;

  apiResult({this.status, this.message, this.data, this.code});

  apiResult.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    message = json['message'];
    data = jsonEncode(json['data']);
    code = json['code'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['status'] = this.status;
    data['message'] = this.message;
    data['data'] = this.data;
    data['code'] = this.code;
    return data;
  }
}

class apiError {
  String? status;
  String? message;
  String? code;

  apiError({this.status, this.message, this.code});

  apiError.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    message = json['message'];
    code = json['code'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['status'] = this.status;
    data['message'] = this.message;
    data['code'] = this.code;
    return data;
  }
}

class API {
  final String? url = dotenv.env['API_URL'];
  final system_mode = dotenv.env['MODE'];

  Future postRequest(String endPoint, dynamic bodyData) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token =
        prefs.containsKey('token') == true ? prefs.getString('token') : '';
    String? language = prefs.containsKey('language') == true
        ? prefs.getString('language')
        : '';
    dynamic header = {
      "token": token.toString(),
      "language": language.toString(),
      "Accept": "application/json",
      "Content-Type": "application/x-www-form-urlencoded"
    };
    var lastUrl;
    if (url == null) {
      SBBildirim.uyari('API Url Bilgisi Bulunamadı');
    }
    if (system_mode == 'development') {
      lastUrl = Uri.http(url!, endPoint);
    } else {
      lastUrl = Uri.https(url!, endPoint);
    }
    final response = await http
        .post(lastUrl,
            body: bodyData,
            headers: header,
            encoding: Encoding.getByName("utf-8"))
        .timeout(
      const Duration(seconds: 10),
      onTimeout: () {
        // Time has run out, do what you wanted to do.
        SBBildirim.hata(
            'Bu iştek 10 saniyeyi aştığı için iptal edilmiştir. API çalışmıyor olabilir');
        return http.Response(
            'Error', 408); // Request Timeout response status code
      },
    );
    apiResult result = apiResult.fromJson(jsonDecode(response.body));
    switch (response.statusCode) {
      case 500:
        {
          SBBildirim.uyari(result.message['message']);
          return {
            'status': false,
            'errCode': result.message['errCode'],
            'message': result.message['message']
          };
          break;
        }
      case 200:
        {
          return {'status': true, 'data': result.data};
        }
      case 201:
        {
          return {'status': true, 'data': result.data};
        }
      case 202:
        {
          return {'status': true, 'data': result.data};
        }
    }
    /*try {

    } on SocketException {
      print('No Internet connection 😑');
    } on HttpException {
      print("Couldn't find the post 😱");
    } on FormatException {
      print("Bad response format 👎");
    }*/
  }
}
