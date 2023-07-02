import 'dart:io';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:full_chat_application/features/home_screen/view/home_screen.dart';
import 'package:full_chat_application/provider/my_provider.dart';
import 'package:full_chat_application/provider/shared_preferences.dart';
import 'package:full_chat_application/serverFunctions/server_functions.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';

import 'firebase_helper/fireBaseHelper.dart';

String APP_ID = ""; //'<Your App ID>'
String Token = ""; //'<Your Token>'

void cancelCall(BuildContext context, msg) {
  if (Provider.of<MyProvider>(context, listen: false).peerUserData?["email"] ==
      null) {
    getEmail().then((value) {
      notifyUser(
          "${Provider.of<MyProvider>(context, listen: false).auth.currentUser!.displayName}",
          "${Provider.of<MyProvider>(context, listen: false).auth.currentUser!.displayName} called you",
          value,
          Provider.of<MyProvider>(context, listen: false)
              .auth
              .currentUser!
              .email);
    });
  } else {
    notifyUser(
        "${Provider.of<MyProvider>(context, listen: false).auth.currentUser!.displayName}",
        "${Provider.of<MyProvider>(context, listen: false).auth.currentUser!.displayName} called you",
        Provider.of<MyProvider>(context, listen: false).peerUserData!["email"],
        Provider.of<MyProvider>(context, listen: false)
            .auth
            .currentUser!
            .email);
  }
  Get.off(const HomeScreen());

  Fluttertoast.showToast(
      msg: msg,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.CENTER,
      timeInSecForIosWeb: 1,
      fontSize: 16.0);
  FireBaseHelper().updateCallStatus(context, "");
}

ScaffoldFeatureController<SnackBar, SnackBarClosedReason> buildShowSnackBar(
    BuildContext context, String msg) {
  return ScaffoldMessenger.of(context).showSnackBar(SnackBar(
    content: Text(
      msg,
      style: const TextStyle(fontSize: 16),
    ),
  ));
}

bool isFileDownloaded(directoryPath, fileName) {
  List files = Directory(directoryPath).listSync();
  bool isDownloaded = false;
  for (var file in files) {
    if (file.path == "$directoryPath/$fileName") {
      isDownloaded = true;
    }
  }

  return isDownloaded;
}
