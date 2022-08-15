
import 'package:shared_preferences/shared_preferences.dart';

final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();

setId(peerUserId) async {
  await _prefs.then((value){
    value.setString("id", peerUserId);
  });
}
setEmail(peeredEmail) async {
  await _prefs.then((value){
    value.setString("email", peeredEmail);
  });
}

setName(peeredName) async {
  await _prefs.then((value){
    value.setString("name", peeredName);
  });
}

setCallType(callType) async {
  await _prefs.then((value){
    value.setString("callType", callType);
  });
}

Future<String> getId() async {
  String id = "";
  await _prefs.then((value){
   id =  value.getString("id")!;
  });
  return id;
}


Future<String> getEmail() async {
  String email = "";
  await _prefs.then((value){
    email =  value.getString("email")!;
  });
  return email;
}

Future<String> getName() async {
  String name = "";
  await _prefs.then((value){
    name =  value.getString("name")!;
  });
  return name;
}

Future<String> getCallType() async {
  String callType = "";
  await _prefs.then((value){
    callType =  value.getString("callType")!;
  });
  return callType;
}