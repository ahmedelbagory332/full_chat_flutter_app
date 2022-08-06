import 'dart:convert';

class NotificationMessage {
  Data? data;

  NotificationMessage({this.data});

  NotificationMessage.fromJson(Map<String, dynamic> json) {
    data = json['data'] != null ? Data.fromJson(jsonDecode(json['data'])) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (this.data != null) {
      data['data'] = this.data!.toJson();
    }
    return data;
  }
}

class Data {
  String? image;
  String? title;
  String? message;

  Data({this.image, this.title, this.message});

  Data.fromJson(Map<String, dynamic> json) {
    image = json['image'];
    title = json['title'];
    message = json['message'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['image'] = image;
    data['title'] = title;
    data['message'] = message;
    return data;
  }
}