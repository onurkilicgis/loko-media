class UserRegistration {
  int? id;
  String? uid;
  String? name;
  String? mail;
  dynamic settings;
  String? token;
  bool? status;

  UserRegistration(this.id, this.uid, this.name, this.mail, this.settings,
      this.token, this.status);

  UserRegistration.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    uid = json['uid'];
    name = json['name'];
    mail = json['mail'];
    settings = json['settings'];
    token = json['token'];
    status = json['status'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['uid'] = this.uid;
    data['name'] = this.name;
    data['mail'] = this.mail;
    data['settings'] = this.settings;
    data['token'] = this.token;
    data['status'] = this.status;
    return data;
  }
}
