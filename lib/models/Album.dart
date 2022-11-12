class Album {
  int? id;
  String? uid;
  String? name;
  bool? isPublic;
  String? url;
  String? image;
  String? date;
  bool? status;

  Album(
      {this.id,
      this.uid,
      this.name,
      this.isPublic,
      this.url,
      this.image,
      this.date,
      this.status});

  insertData(String name, String uid) {
    this.name = name;
    var now = new DateTime.now();
    int ay = now.month;
    int gun = now.day;
    int yil = now.year;
    int saat = now.hour;
    int dakika = now.minute;
    int saniye = now.second;
    String tarih =
        "${gun.toString()}/${ay.toString()}/${yil.toString()} ${saat.toString()}:${dakika.toString()}:${saniye.toString()}";
    this.date = tarih;
    this.uid = uid;
    this.isPublic = false;
    this.url = '';
    this.image = '';
    this.status = true;
    return this;
  }

  Album.fromJson(json) {
    id = json['id'];
    uid = json['uid'];
    name = json['name'];
    isPublic = json['isPublic'] == 1 ? true : false;
    url = json['url'];
    image = json['image'];
    date = json['date'];
    status = json['status'] == 1 ? true : false;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['uid'] = this.uid;
    data['name'] = this.name;
    data['isPublic'] = this.isPublic == 1 ? true : false;
    data['url'] = this.url;
    data['image'] = this.image;
    data['date'] = this.date;
    data['status'] = this.status == 1 ? true : false;
    return data;
  }
}

class Files {
  int? id;
  int? album_id;
  String? name;
  String? fileType;
  String? path;
  bool? isPublic;
  String? url;
  int? api_id;
  String? date;
  bool? status;

  Files(
      {this.id,
      this.album_id,
      this.name,
      this.fileType,
      this.path,
      this.isPublic,
      this.url,
      this.api_id,
      this.date,
      this.status});

  Files.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    album_id = json['album_id'];
    name = json['name'];
    fileType = json['fileType'];
    path = json['path'];
    isPublic = json['isPublic'];
    url = json['url'];
    api_id = json['api_id'];
    date = json['date'];
    status = json['status'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['album_id'] = this.album_id;
    data['name'] = this.name;
    data['fileType'] = this.fileType;
    data['path'] = this.path;
    data['isPublic'] = this.isPublic;
    data['url'] = this.url;
    data['api_id'] = this.api_id;
    data['date'] = this.date;
    data['status'] = this.status;
    return data;
  }
}
