import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:full_chat_application/widget/receiver_message_card.dart';
import 'package:full_chat_application/widget/sender_message_card.dart';
import 'package:intl/intl.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import '../Utils.dart';
import '../notifications/notifications.dart';
import '../provider/my_provider.dart';
import '../firebase_helper/fireBaseHelper.dart';

class Messages extends StatefulWidget {
  const Messages({Key? key}) : super(key: key);

  @override
  State<Messages> createState() => _MessagesState();
}

class _MessagesState extends State<Messages> {


  Future<void> downloadFile(context,fileUrl,fileName,fileType) async {
    Directory? appDocDir = await getApplicationDocumentsDirectory();
    final status = await Permission.storage.request();
    if(status == PermissionStatus.granted) {
      Directory(appDocDir.path).exists().then((value) async {
        if (value) {
          isFileDownloaded(appDocDir.path, fileName) ?
          OpenFile.open("${appDocDir.path}/$fileName")
              : Dio().download(
            fileUrl, "${appDocDir.path}/$fileName", onReceiveProgress: (count, total) {
           downloadingNotification(total, count, false);
          },).whenComplete(() {
            downloadingNotification(0, 0, true);
          });
        }
        else {
          Directory(appDocDir.path).create()
              .then((Directory directory) async {
            isFileDownloaded(appDocDir.path, fileName) ?
            OpenFile.open("${appDocDir.path}/$fileName")
                : Dio().download(
              fileUrl, "${appDocDir.path}/$fileName", onReceiveProgress: (count, total) {
              downloadingNotification(total, count, false);
            },)
                .whenComplete(() {
              downloadingNotification(0, 0, true);
            });
          });
        }
      });
    }else{
      await Permission.storage.request();
    }

  }

   @override
  Widget build(BuildContext context) {
     return StreamBuilder(
      stream:FireBaseHelper().getMessages(context,chatId: Provider.of<MyProvider>(context,listen: false).getChatId(context)),
      builder:(BuildContext context,
          AsyncSnapshot<QuerySnapshot> snapshot) {
        if (snapshot.hasError) {
          return const Text('Something went wrong try again');
        }
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        return snapshot.data!.size == 0?
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Center(child: Text('No messages')),
          ],
        ):
          ListView.builder(
              reverse: true,
              shrinkWrap: true ,
              itemCount: snapshot.data!.docs.length,
              itemBuilder: (context, index) {
                if (Provider.of<MyProvider>(context,listen: false).auth.currentUser!.uid
                    == snapshot.data!.docs[index]['senderId'].toString()) {
                  return InkWell(
                     onTap: (){
                       if(snapshot.data!.docs[index]['msgType'].toString() == "document"||snapshot.data!.docs[index]['msgType'].toString() == "voice message"){
                         downloadFile(context,snapshot.data!.docs[index]['message'].toString(),snapshot.data!.docs[index]['fileName'].toString(),snapshot.data!.docs[index]['msgType'].toString());
                       }
                     },
                    child: SenderMessageCard(
                        snapshot.data!.docs[index]['fileName'].toString(),
                        snapshot.data!.docs[index]['msgType'].toString(),
                        snapshot.data!.docs[index]['message'].toString(),
                        snapshot.data!.docs[index]['msgTime']==null?
                        DateFormat('dd-MM-yyyy hh:mm a').format(DateTime.parse(Timestamp.now().toDate().toString())):
                        DateFormat('dd-MM-yyyy hh:mm a').format(DateTime.parse(snapshot.data!.docs[index]['msgTime'].toDate().toString()))
                    ),
                  );
                } else {
                  return InkWell(
                    onTap: (){
                      if(snapshot.data!.docs[index]['msgType'].toString() == "document"||snapshot.data!.docs[index]['msgType'].toString() == "voice message"){
                        downloadFile(context,snapshot.data!.docs[index]['message'].toString(),snapshot.data!.docs[index]['fileName'].toString(),snapshot.data!.docs[index]['msgType'].toString());
                      }
                    },
                    child: ReceiverMessageCard(
                        snapshot.data!.docs[index]['fileName'].toString(),
                        snapshot.data!.docs[index]['msgType'].toString(),
                        snapshot.data!.docs[index]['message'].toString(),
                        snapshot.data!.docs[index]['msgTime']==null?
                        DateFormat('dd-MM-yyyy hh:mm a').format(DateTime.parse(Timestamp.now().toDate().toString())):
                        DateFormat('dd-MM-yyyy hh:mm a').format(DateTime.parse(snapshot.data!.docs[index]['msgTime'].toDate().toString()))
                    ),
                  );
                }
              });
      },
    );
  }
}