import 'dart:convert';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:full_chat_application/features/chat_screen/manager/chat_cubit.dart';
import 'package:get/get.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../features/home_screen/view/home_screen.dart';
import '../notifications/notifications.dart';
import '../storage/firebase_helper/fireBaseHelper.dart';
import '../storage/shared_preferences.dart';

String APP_ID = ""; //'<Your App ID>'
String Token = ""; //'<Your Token>'

void cancelCall(BuildContext context, msg) {
  if (context.read<ChatCubit>().peerUserData["email"] == null) {
    context.read<ChatCubit>().notifyUser(
        "${context.read<ChatCubit>().getCurrentUser()!.displayName}",
        "${context.read<ChatCubit>().getCurrentUser()!.displayName} called you",
        getEmail(),
        context.read<ChatCubit>().getCurrentUser()!.email);
  } else {
    context.read<ChatCubit>().notifyUser(
        "${context.read<ChatCubit>().getCurrentUser()!.displayName}",
        "${context.read<ChatCubit>().getCurrentUser()!.displayName} called you",
        context.read<ChatCubit>().peerUserData["email"],
        context.read<ChatCubit>().getCurrentUser()!.email);
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

Future<void> downloadFile(context, fileUrl, fileName, fileType) async {
  final appDocDir = await getExternalStorageDirectory();

  final status = await Permission.storage.request();
  if (status == PermissionStatus.granted) {
    Directory(appDocDir!.absolute.path).exists().then((value) async {
      if (value) {
        debugPrint("bego.downloadFile ${appDocDir!.absolute.path}/$fileName}");

        isFileDownloaded(appDocDir!.absolute.path, fileName)
            ? OpenFile.open("${appDocDir!.absolute.path}/$fileName")
            : Dio().download(
                fileUrl,
                "${appDocDir!.absolute.path}/$fileName",
                onReceiveProgress: (count, total) {
                  downloadingNotification(total, count, false);
                },
              ).whenComplete(() {
                downloadingNotification(0, 0, true);
              });
      } else {
        Directory(appDocDir!.absolute.path)
            .create()
            .then((Directory directory) async {
          isFileDownloaded(appDocDir!.absolute.path, fileName)
              ? OpenFile.open("${appDocDir!.absolute.path}/$fileName")
              : Dio().download(
                  fileUrl,
                  "${appDocDir!.absolute.path}/$fileName",
                  onReceiveProgress: (count, total) {
                    downloadingNotification(total, count, false);
                  },
                ).whenComplete(() {
                  downloadingNotification(0, 0, true);
                });
        });
      }
    });
  } else {
    await Permission.storage.request();
  }
}

List<Map<String, dynamic>> convertQuerySnapshotToList(
    QuerySnapshot<Map<String, dynamic>> snapshot) {
  return snapshot.docs.map((doc) => doc.data()).toList();
}

String mapListToString(List<Map<String, dynamic>> mapList) {
  for (var i = 0; i < mapList.length; i++) {
    var map = mapList[i];
    for (var key in map.keys) {
      var value = map[key];
      if (value is Timestamp) {
        // convert Timestamp to string representation
        map[key] = value.toDate().toString();
      }
    }
  }
  return json.encode(mapList);
}

List<Map<String, dynamic>> stringToMapList(String jsonString) {
  List<dynamic> jsonList = json.decode(jsonString);
  return jsonList.map((json) => Map<String, dynamic>.from(json)).toList();
}
