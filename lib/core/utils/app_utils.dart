import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:full_chat_application/features/home_screen/view/home_screen.dart';
import 'package:full_chat_application/notifications/notifications.dart';
import 'package:full_chat_application/provider/shared_preferences.dart';
import 'package:get/get.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';

import '../../features/chat_screen/manager/chat_cubit.dart';
import '../../firebase_helper/fireBaseHelper.dart';

String APP_ID = ""; //'<Your App ID>'
String Token = ""; //'<Your Token>'

void cancelCall(BuildContext context, msg) {
  if (context.read<ChatCubit>().peerUserData["email"] == null) {
    getEmail().then((value) {
      context.read<ChatCubit>().notifyUser(
          "${context.read<ChatCubit>().getCurrentUser()!.displayName}",
          "${context.read<ChatCubit>().getCurrentUser()!.displayName} called you",
          value,
          context.read<ChatCubit>().getCurrentUser()!.email);
    });
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
  Directory? appDocDir = await getApplicationDocumentsDirectory();
  final status = await Permission.storage.request();
  if (status == PermissionStatus.granted) {
    Directory(appDocDir.path).exists().then((value) async {
      if (value) {
        isFileDownloaded(appDocDir.path, fileName)
            ? OpenFile.open("${appDocDir.path}/$fileName")
            : Dio().download(
                fileUrl,
                "${appDocDir.path}/$fileName",
                onReceiveProgress: (count, total) {
                  downloadingNotification(total, count, false);
                },
              ).whenComplete(() {
                downloadingNotification(0, 0, true);
              });
      } else {
        Directory(appDocDir.path).create().then((Directory directory) async {
          isFileDownloaded(appDocDir.path, fileName)
              ? OpenFile.open("${appDocDir.path}/$fileName")
              : Dio().download(
                  fileUrl,
                  "${appDocDir.path}/$fileName",
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
