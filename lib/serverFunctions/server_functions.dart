import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';

// void registerDevice(userEmail, userToken) async {
//   var dio = Dio();
//   Response response;
//   var formData = FormData.fromMap({
//     'email': userEmail,
//     'token': userToken,
//   });
//   response = await dio.post(
//       'https://fluttertest288.000webhostapp.com/bego/RegisterDevice.php',
//       data: formData);
//   debugPrint("Bego(registerDevice) ${response.data}");
// }

// Future<String?> getDeviceToken() async {
//   return await FirebaseMessaging.instance.getToken();
// }

// void onTokenRefresh(userEmail) {
//   FirebaseMessaging.instance.onTokenRefresh.listen((fcmToken) {
//     updateUserToken(userEmail, fcmToken);
//   }).onError((err) {});
// }
//
// void updateUserToken(userEmail, userToken) async {
//   var dio = Dio();
//   Response response;
//   var formData = FormData.fromMap({
//     'email': userEmail,
//     'token': userToken,
//   });
//   response = await dio.post(
//       'https://fluttertest288.000webhostapp.com/bego/updateToken.php',
//       data: formData);
//   debugPrint("Bego(updateUserToken) ${response.data}");
// }

void updatePeerDevice(userEmail, peerUser) async {
  var dio = Dio();
  Response response;
  var formData = FormData.fromMap({
    'email': userEmail,
    'isPeered': peerUser,
  });
  response = await dio.post(
      'https://fluttertest288.000webhostapp.com/bego/updatePeerDevice.php',
      data: formData);
  debugPrint("Bego(updatePeerDevice) ${response.data}");
}

void notifyUser(title, body, notifyTo, senderMail) async {
  var dio = Dio();
  Response response;
  var formData = FormData.fromMap({
    'title': title,
    'message': body,
    'email': notifyTo,
    'senderEmail': senderMail,
  });
  response = await dio.post(
      'https://fluttertest288.000webhostapp.com/bego/sendSinglePush.php',
      data: formData);
  debugPrint("Bego(notifyUser) ${response.data}");
}

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
