import 'dart:math';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import '../firebase_helper/model/notification_messages.dart';

Future<void> notificationInitialization() async {
    FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
    const AndroidInitializationSettings initializationSettingsAndroid =
    AndroidInitializationSettings('@mipmap/ic_launcher');
    const InitializationSettings initializationSettings =  InitializationSettings(
        android: initializationSettingsAndroid,);
    await flutterLocalNotificationsPlugin.initialize(initializationSettings, onSelectNotification: null);
}


Future<void> uploadingNotification(fileType,receiverName ,maxProgress, progress , isUploading) async {
    FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
    if(isUploading){
        final AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
            "uploading files",
            "Uploading Files Notifications",
            channelDescription: "show to user progress for uploading files",
            channelShowBadge: false,
            importance: Importance.max,
            priority: Priority.high,
            onlyAlertOnce: true,
            showProgress: true,
            maxProgress: maxProgress,
            progress: progress,
            autoCancel: false
        );


        NotificationDetails platformChannelSpecifics = NotificationDetails(android: androidPlatformChannelSpecifics);
        await flutterLocalNotificationsPlugin.show(
           5,
            'Sending $fileType to $receiverName',
            '',
            platformChannelSpecifics,
        );
    }else{

        flutterLocalNotificationsPlugin.cancel(5);
         AndroidNotificationDetails androidPlatformChannelSpecifics =
        const AndroidNotificationDetails(
            "files",
            "Files Notifications",
            channelDescription: "Inform user files uploaded",
            channelShowBadge: false,
            importance: Importance.max,
            priority: Priority.high,
            onlyAlertOnce: true,
        );


        NotificationDetails platformChannelSpecifics = NotificationDetails(android: androidPlatformChannelSpecifics);
        await flutterLocalNotificationsPlugin.show(
            Random().nextInt(1000000),
            '$fileType sent to $receiverName',
            '',
            platformChannelSpecifics,
        );
    }



}

Future<void> downloadingNotification(maxProgress, progress , isDownloaded) async {
    FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
    if(!isDownloaded){
        final AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
            "downloading files",
            "downloading Files Notifications",
            channelDescription: "show to user progress for downloading files",
            channelShowBadge: false,
            importance: Importance.max,
            priority: Priority.high,
            onlyAlertOnce: true,
            showProgress: true,
            maxProgress: maxProgress,
            progress: progress,
            autoCancel: false
        );


        NotificationDetails platformChannelSpecifics = NotificationDetails(android: androidPlatformChannelSpecifics);
        await flutterLocalNotificationsPlugin.show(
            6,
            'Downloading file',
            '',
            platformChannelSpecifics,
        );
    }else{

        flutterLocalNotificationsPlugin.cancel(6);
        AndroidNotificationDetails androidPlatformChannelSpecifics =
        const AndroidNotificationDetails(
            "files",
            "Files Notifications",
            channelDescription: "Inform user files downloaded",
            channelShowBadge: false,
            importance: Importance.max,
            priority: Priority.high,
            onlyAlertOnce: true,
        );


        NotificationDetails platformChannelSpecifics = NotificationDetails(android: androidPlatformChannelSpecifics);
        await flutterLocalNotificationsPlugin.show(
            Random().nextInt(1000000),
            'File Downloaded',
            '',
            platformChannelSpecifics,
        );
    }



}


Future<void> messageHandler(RemoteMessage message) async {
    NotificationMessage notificationMessage = NotificationMessage.fromJson(message.data);
    messageNotification(notificationMessage.data!.title,notificationMessage.data!.message);

}
void firebaseMessagingListener(){
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        NotificationMessage notificationMessage = NotificationMessage.fromJson(message.data);
        messageNotification(notificationMessage.data!.title,notificationMessage.data!.message);
    });
}

Future<void> messageNotification(title, body) async {
    FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();


    const AndroidNotificationDetails androidPlatformChannelSpecifics =
     AndroidNotificationDetails(
        "message notification",
        "Messages Notifications",
        channelDescription: "show message to user",
        channelShowBadge: false,
        importance: Importance.max,
        priority: Priority.high,
        onlyAlertOnce: true,
        showProgress: true,
        autoCancel: false
    );


    NotificationDetails platformChannelSpecifics = const NotificationDetails(android: androidPlatformChannelSpecifics);
    await flutterLocalNotificationsPlugin.show(
        Random().nextInt(1000000000),
        title,
        body,
        platformChannelSpecifics,
    );


}


