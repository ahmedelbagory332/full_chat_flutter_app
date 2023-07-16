import 'dart:convert';

class NotificationMessage {
  Data? data;

  NotificationMessage({this.data});

  NotificationMessage.fromJson(Map<String, dynamic> json) {
    data = json['data'] != null ? Data.fromJson(jsonDecode(json['data'])) : null;
  }

}

class Data {
  String? image;
  String? title;
  String? message;
  String? peerUserId;
  String? peeredEmail;
  String? peeredName;
  String? callType;

  Data({this.image, this.title, this.message, this.peerUserId, this.peeredEmail, this.peeredName, this.callType});

  Data.fromJson(Map<String, dynamic> json) {
    image = json['image'];
    title = json['title'];
    message = json['message'];
    peerUserId = json['peerUserId'];
    peeredEmail = json['peeredEmail'];
    peeredName = json['peeredName'];
    callType = json['callType'];
  }

}