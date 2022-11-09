class Album {
  int? id;
  String? uid;
  String? albumName;
  bool? isPublic;
  String? url;
  String? image;
  bool? status;

  Album(
      {this.id,
      this.uid,
      this.albumName,
      this.isPublic,
      this.url,
      this.image,
      this.status});

  Album.fromJson(json) {
    id = json['id'];
    uid = json['uid'];
    albumName = json['albumName'];
    isPublic = json['isPublic'];
    url = json['url'];
    image = json['image'];
    status = json['status'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['uid'] = this.uid;
    data['albumName'] = this.albumName;
    data['isPublic'] = this.isPublic;
    data['url'] = this.url;
    data['image'] = this.image;
    data['status'] = this.status;
    return data;
  }
}

class File {
  int? id;
  int? albumId;
  String? fileName;
  String? fileType;
  String? path;
  bool? isPublic;
  String? url;
  int? apiId;
  String? date;
  bool? status;

  File(
      {this.id,
      this.albumId,
      this.fileName,
      this.fileType,
      this.path,
      this.isPublic,
      this.url,
      this.apiId,
      this.date,
      this.status});

  File.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    albumId = json['album_id'];
    fileName = json['fileName'];
    fileType = json['fileType'];
    path = json['path'];
    isPublic = json['isPublic'];
    url = json['url'];
    apiId = json['api_id'];
    date = json['date'];
    status = json['status'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['album_id'] = this.albumId;
    data['fileName'] = this.fileName;
    data['fileType'] = this.fileType;
    data['path'] = this.path;
    data['isPublic'] = this.isPublic;
    data['url'] = this.url;
    data['api_id'] = this.apiId;
    data['date'] = this.date;
    data['status'] = this.status;
    return data;
  }
}
