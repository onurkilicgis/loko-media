import 'package:geolocator/geolocator.dart';

class GPS {
  static Future<dynamic> getGPSPosition() async {
    bool serviceEnabled;
    LocationPermission permission;
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return {'status': false, 'message': 'Konum Servisi Açık Değil'};
    }
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return {
          'status': false,
          'message': 'Konum kullanım izni olmadan uygulamayı kullanamazsınız'
        };
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return {
        'status': false,
        'message':
            'Konum izinleri kalıcı olarak reddedilmiş, Lütfen ayarlarınızı güncelleyiniz.'
      };
    }

    Position position = await Geolocator.getCurrentPosition();
    dynamic sendData = {
      'status': true,
      'latitude': position.latitude,
      'longitude': position.longitude,
      'accuracy': position.accuracy,
      'speed': position.speed,
      'speedAccuarcy': position.speedAccuracy,
      'altitude': position.altitude,
      'time': position.timestamp
    };

    return sendData;
  }
}
