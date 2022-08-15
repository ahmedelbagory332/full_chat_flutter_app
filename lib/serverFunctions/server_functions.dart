import 'package:dio/dio.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

 void registerDevice(userEmail,userToken) async{
  var dio = Dio();
  Response response;
  var formData = FormData.fromMap({
    'email': userEmail,
    'token': userToken,

  });
     response = await dio.post('https://bego88.000webhostapp.com/bego/RegisterDevice.php', data: formData);
   print("Bego(registerDevice) ${response.data}");
}

Future<String?> getDeviceToken()  async{
   return await FirebaseMessaging.instance.getToken();
}

void onTokenRefresh(userEmail){
  FirebaseMessaging.instance.onTokenRefresh.listen((fcmToken) {
    updateUserToken(userEmail, fcmToken);
  }).onError((err) {});
}

void updateUserToken(userEmail,userToken) async{
  var dio = Dio();
  Response response;
  var formData = FormData.fromMap({
    'email': userEmail,
    'token': userToken,
  });
  response = await dio.post('https://bego88.000webhostapp.com/bego/updateToken.php', data: formData);
  print("Bego(updateUserToken) ${response.data}");
}

void updatePeerDevice(userEmail,peerUser) async{
  var dio = Dio();
  Response response;
  var formData = FormData.fromMap({
    'email': userEmail,
    'isPeered': peerUser,
  });
  response = await dio.post('https://bego88.000webhostapp.com/bego/updatePeerDevice.php', data: formData);
  print("Bego(updatePeerDevice) ${response.data}");
}

void notifyUser(title,body,notifyTo,senderMail) async{
  var dio = Dio();
  Response response;
  var formData = FormData.fromMap({
    'title': title,
    'message': body,
    'email': notifyTo,
    'senderEmail': senderMail,
  });
  response = await dio.post('https://bego88.000webhostapp.com/bego/sendSinglePush.php', data: formData);
  print("Bego(notifyUser) ${response.data}");
}
void notifyUserWithCall(body,notifyTo,peerUserId,peeredName,callType) async{
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
  response = await dio.post('https://bego88.000webhostapp.com/bego/sendSinglePushForCalling.php', data: formData);
  print("Bego(notifyUserWithCall) ${response.data}");
}