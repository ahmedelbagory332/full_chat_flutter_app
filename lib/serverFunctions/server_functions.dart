import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';

void notifyUserWithCall(
    body, notifyTo, peerUserId, peeredName, callType) async {
  var dio = Dio();
  Response response;
  var formData = FormData.fromMap({
    'title': "",
    'message': body,
    'email': notifyTo,
    'peerUserId': peerUserId,
    'peeredEmail': notifyTo,
    'peeredName': peeredName,
    'callType': callType,
  });
  response = await dio.post(
      'https://fluttertest288.000webhostapp.com/bego/sendSinglePushForCalling.php',
      data: formData);
  debugPrint("Bego(notifyUserWithCall) ${response.data}");
}
