import 'dart:io';

import 'package:flutter/material.dart';

ScaffoldFeatureController<SnackBar, SnackBarClosedReason> buildShowSnackBar(BuildContext context,String msg) {
  return ScaffoldMessenger.of(context).showSnackBar(SnackBar(
    content: Text(
      msg,
      style: const TextStyle(fontSize: 16),
    ),
  ));
}

bool isFileDownloaded(directoryPath,fileName){
  List files = Directory(directoryPath).listSync();
  bool isDownloaded = false;
  for(var file in files){
    if(file.path == "$directoryPath/$fileName"){
      isDownloaded = true;
    }
  }

  return isDownloaded;
}