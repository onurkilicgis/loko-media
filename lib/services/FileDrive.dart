import 'dart:io' as ioo;

import 'package:flutter/cupertino.dart';
import 'package:googleapis/drive/v3.dart' as drive;
import "package:googleapis_auth/auth_io.dart";
import 'package:http/http.dart' as http;

class GoogleAuthClient extends http.BaseClient {
  final Map<String, String> _headers;
  final http.Client _client = new http.Client();
  GoogleAuthClient(this._headers);
  Future<http.StreamedResponse> send(http.BaseRequest request) {
    return _client.send(request..headers.addAll(_headers));
  }
}

Future<AccessCredentials> obtainCredentials() async {
  var accountCredentials = ServiceAccountCredentials.fromJson({
    "type": "service_account",
    "project_id": "gislayer-161420",
    "private_key_id": "f6ab66c562bdfd3b6a18b8d54febac300bfac6b5",
    "private_key":
        "-----BEGIN PRIVATE KEY-----\nMIIEvQIBADANBgkqhkiG9w0BAQEFAASCBKcwggSjAgEAAoIBAQCVGg8tKZ5+uq6s\n3Zh1OU1I6ob+tKMM4DdELKQUugiXHWXpS8caWZUdX3vhRjk3P/rQbvXgLo7qI4Xt\ngpToYhxNFk9xoUVgroH/N7157xR3Bmxn3UdsDREgMnS8ybn2y6Mya+vCIrEhdxEZ\nc40t6VPEp3lcjO/5ejVJu9+8Z5CTRZIrmZs6GiiPx3X0NaKTQyjTs/3gmNRKAmfJ\nv1HVEFRxWeqqrCYdqPtWUqnCXSIFZU6rCcMGWfYhJRQLVO4AYJtQ9TFPncY7eTj2\namWh/vrP7QukaCc5RHOPPcKxVZq9ppaxQeML1y1NTxbxruVQUNss3YUNCuCtGG89\nLw8J3OvvAgMBAAECggEACKW4XJut0nBcSH1MZfwOF4NpxrFORYuZco3bCrKxZD/Z\nu1qTcEIV/ykDA8Rkj05AHlq/gTviB2h90EUPz5xx3L/e/3P/FJJ6ZDiYEU+eEofs\nvWdcrykUDBexCopYJTaXpYlGmDDjFtHgS+dJa4pW1LByPiP6y2LDK9Gs5UqyXIzu\n0cb2ahuai+Mmf8bHZePhKKGzz9edsIvSWqJPZJLSanspqpy5Xf2w1NowGVL3aomU\nQgANruTM6rLPc6f2Cve9nE3PC6cNB4yMXyhjzp7WSTUgfQbUGBY0WRJRW49F3XEL\nhtrDSZZrx2xE1CXEwLtoBG12ByG0820QNSoxEgMVIQKBgQDIO1LEqv/2aQZQl3Pz\nW3y49NI1NOpWR/SaQYcko0DpGdHatovapR81VCboGV2wUFBHLU/6P9i3GO/gfDlX\nbArcsUQyQQw8Ftrw552mDL9izqprgvk/UI3oezttOheuEM/Hp4n+VodZT4eHYbVg\n9DpkI5CHbI9dmT0p8zUaRaCgYQKBgQC+oSHNMvFWE+qMZXXCfU+0a9VGCZpN9hkc\nf8aeU96Pk8zHYg2BPnn4mBG8Gk6l4Nkc4jcAGHXgXIt00a9P/EERofkstEvWd4Rn\nPB+1ch1Is3zMUSNJsnKAYKGwFVRdXJFX8gLOhNnla0/HFjAo+dEHKxfKwYzZh2s/\nbWrUarouTwKBgEuJtcvkBvRa4rr8qA2i8gaEtdjEwbMTKkAXgHhd7lsCFp1ASLqP\nmJpxyMu+5g1h/yca/RUXiRZqHfS+aJOGewKPDX838vmoVaiUeHDwVjNcbAZrPsSY\nCzEtbFnklJJiXUCg//ongqA61JJKVjbhbDXjBN9SITPaX6y3x8zFf7eBAoGAZgkL\ndbFp2kAo0GNSZ/r5GcKKUsW7ETXD9SwznPWZcFKVTreeMOrHEJgdDgkqxcEXlU1E\nUUnGdoQypSHDa9XC4nRHUnVjDnXEqhlVg6KEKDDigN6BO+ZHQY33na+dC6gLp/5D\nIFWd6B3Lgu3Oc3BcQTEAuCdng9vnPPkNMIu8AiMCgYEAhULwVjCQu9DTmoq4rllX\nmvvGKhY5Xpph0iuu9tfgYzojwHwId7/baMiaYJlRAFUBCr7gceNkQcL8ZbYfTdAs\n+NHxjkJQg8lgofUNXPwPZibfEpaRTkxE2lJv3evKbn/xzO5OuYDJLQkowdhijm3Y\n3L1Ji7ZndsAva86nbnUwq80=\n-----END PRIVATE KEY-----\n",
    "client_email":
        "gislayergoogledrive@gislayer-161420.iam.gserviceaccount.com",
    "client_id": "103006400149116557952",
    "auth_uri": "https://accounts.google.com/o/oauth2/auth",
    "token_uri": "https://oauth2.googleapis.com/token",
    "auth_provider_x509_cert_url": "https://www.googleapis.com/oauth2/v1/certs",
    "client_x509_cert_url":
        "https://www.googleapis.com/robot/v1/metadata/x509/gislayergoogledrive%40gislayer-161420.iam.gserviceaccount.com"
  });
  var scopes = ['https://www.googleapis.com/auth/drive', 'https://www.googleapis.com/auth/drive.readonly', 'https://www.googleapis.com/auth/drive.file'];
  var client = http.Client();
  AccessCredentials credentials =
      await obtainAccessCredentialsViaServiceAccount(
          accountCredentials, scopes, client);
  client.close();
  return credentials;
}

class FileDrive {
  late final driveApi;
  late String token;
  FileDrive() {}

  ready() async {
    AccessCredentials cre = await obtainCredentials();
    token = cre.accessToken.data;
    final authenticateClient = GoogleAuthClient({
      "Authorization": "Bearer ${cre.accessToken.data}",
      "X-Goog-AuthUser": "0"
    });
    driveApi = drive.DriveApi(authenticateClient);
  }

  uploadImage(String path) async {
    List<String> parts = path.split('.');
    List<String> parts2 = path.split('/');
    String ext = parts[parts.length - 1];
    String fileName = parts2[parts2.length - 1];
    ext = ext.toLowerCase();
    var driveFile = new drive.File();
    driveFile.name = fileName;
    driveFile.mimeType = 'image/${ext}';
    final file = ioo.File(path);
    final permission = drive.Permission(role: 'reader', type: 'anyone');
    final result = await driveApi.files.create(
      driveFile,
      uploadMedia: drive.Media(file.openRead(), file.lengthSync()),
    );
    await driveApi.permissions.create(permission, result.id);
    print("Upload result: https://drive.google.com/uc?id=${result.id}");
  }

  uploadVideo(String path) async {
    List<String> parts = path.split('.');
    List<String> parts2 = path.split('/');
    String ext = parts[parts.length - 1];
    ext = ext.toLowerCase();
    String fileName = parts2[parts2.length - 1];
    var driveFile = new drive.File();
    driveFile.name = fileName;
    final file = ioo.File(path);
    final permission = drive.Permission(role: 'reader', type: 'anyone');
    final result = await driveApi.files.create(
      driveFile,
      uploadMedia: drive.Media(file.openRead(), file.lengthSync()),
    );
    await driveApi.permissions.create(permission, result.id);
    print("Upload result: https://drive.google.com/uc?id=${result.id}");
  }

  uploadAudio(String path) async {
    List<String> parts = path.split('.');
    List<String> parts2 = path.split('/');
    String ext = parts[parts.length - 1];
    ext = ext.toLowerCase();
    String fileName = parts2[parts2.length - 1];
    var driveFile = new drive.File();
    driveFile.name = fileName;
    final file = ioo.File(path);
    final permission = drive.Permission(role: 'reader', type: 'anyone');
    final result = await driveApi.files.create(
      driveFile,
      uploadMedia: drive.Media(file.openRead(), file.lengthSync()),
    );
    await driveApi.permissions.create(permission, result.id);
    print("Upload result: https://drive.google.com/uc?id=${result.id}");
  }

  uploadFile(String path) async {
    List<String> parts = path.split('.');
    List<String> parts2 = path.split('/');
    String ext = parts[parts.length - 1];
    ext = ext.toLowerCase();
    String fileName = parts2[parts2.length - 1];
    var driveFile = new drive.File();
    driveFile.name = fileName;
    final file = ioo.File(path);
    final permission = drive.Permission(role: 'reader', type: 'anyone');
    try {
      final result = await driveApi.files.create(
        driveFile,
        uploadMedia: drive.Media(file.openRead(), file.lengthSync()),
      );
      await driveApi.permissions.create(permission, result.id);
      return result.id;
    } catch (error) {
      print(error);
      return false;
    }
  }

  getAImage(String id) async {
    ioo.File file = await driveApi.files.get(id);
    if(file!=null){
      FileImage imageFile = FileImage(file);
      if(imageFile.file != null){
        DecorationImage image = DecorationImage(
          image: FileImage(file),
        );
        return image;
      }
    }else{
      DecorationImage image = DecorationImage(
        image: NetworkImage('https://media.licdn.com/dms/image/C4E03AQEC4rr4JABRDA/profile-displayphoto-shrink_400_400/0/1586246399901?e=1678924800&v=beta&t=D-oIi6tz29J09p0WLmMko--3UmbprIMU60dujbpxdIs'),
      );
    }
  }
}
