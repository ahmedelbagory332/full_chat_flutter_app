import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:jiffy/jiffy.dart';

// ignore: must_be_immutable
class MessageTile extends StatelessWidget {
  MessageTile(this.recentMessage, this.isMe, {Key? key}) : super(key: key);
  final QueryDocumentSnapshot<Object?> recentMessage;
  String message = "";
  bool isMe = false;

  String _message(messageType) {
    if (messageType == "text") {
      message = isMe
          ? "you : ${recentMessage['message'].toString()}"
          : recentMessage['message'].toString();
    } else if (messageType == "image") {
      message = isMe
          ? "you sent image to ${recentMessage['messageTo'].toString()}"
          : "${recentMessage['messageFrom'].toString()} sent to you image";
    } else if (messageType == "video") {
      message = isMe
          ? "you sent video to ${recentMessage['messageTo'].toString()}"
          : "${recentMessage['messageFrom'].toString()} sent to you video";
    } else if (messageType == "document") {
      message = isMe
          ? "you sent document to ${recentMessage['messageTo'].toString()}"
          : "${recentMessage['messageFrom'].toString()} sent to you document";
    } else if (messageType == "audio") {
      message = isMe
          ? "you sent audio file to ${recentMessage['messageTo'].toString()}"
          : "${recentMessage['messageFrom'].toString()} sent to you audio file";
    } else if (messageType == "voice message") {
      message = isMe
          ? "you sent voice message to ${recentMessage['messageTo'].toString()}"
          : "${recentMessage['messageFrom'].toString()} sent to you voice message";
    }

    return message;
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Container(
        margin: const EdgeInsets.only(
          top: 5.0,
          bottom: 5.0,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 10.0),
        decoration: const BoxDecoration(
          color: Colors.white54,
          borderRadius: BorderRadius.only(
            topRight: Radius.circular(20.0),
            bottomRight: Radius.circular(20.0),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: <Widget>[
                const CircleAvatar(
                  backgroundColor: Colors.black12,
                  backgroundImage: AssetImage("images/avatar.png"),
                  radius: 25.0, //radius of the circle avatar
                ),
                const SizedBox(
                  width: 10.0,
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isMe
                          ? recentMessage['messageTo'].toString()
                          : recentMessage['messageFrom'].toString(),
                      style: const TextStyle(
                        color: Colors.grey,
                        fontSize: 15.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(
                      height: 5.0,
                    ),
                    SizedBox(
                      width: MediaQuery.of(context).size.width * 0.45,
                      child: Text(
                        _message(recentMessage['msgType'].toString()),
                        style: const TextStyle(
                          color: Colors.blueGrey,
                          fontSize: 15.0,
                          fontWeight: FontWeight.w600,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            Text(
              Jiffy(
                      recentMessage['msgTime'] == null
                          ? DateFormat('dd-MM-yyyy hh:mm a').format(
                              DateTime.parse(
                                  Timestamp.now().toDate().toString()))
                          : DateFormat('dd-MM-yyyy hh:mm a').format(
                              DateTime.parse(recentMessage['msgTime']
                                  .toDate()
                                  .toString())),
                      "dd-MM-yyyy hh:mm a")
                  .fromNow(),
              style: const TextStyle(
                color: Colors.grey,
                fontSize: 15.0,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
