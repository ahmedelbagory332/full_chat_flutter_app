import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:full_chat_application/provider/my_provider.dart';
import 'package:intl/intl.dart';
import 'package:jiffy/jiffy.dart';
import 'package:provider/provider.dart';


class MessageTile extends StatefulWidget {
 final QueryDocumentSnapshot<Object?> recentMessage;
  const MessageTile(this.recentMessage, {Key? key}) : super(key: key);

  @override
  State<MessageTile> createState() => _MessageTileState();
}

class _MessageTileState extends State<MessageTile> {

  String message = "";
  bool isMe = false ;

  String _message(messageType){
    if(messageType == "text"){
      message =  widget.recentMessage['messageSenderId'].toString() ==
          Provider.of<MyProvider>(context, listen: false).auth.currentUser!.uid ?
      "you : ${widget.recentMessage['message'].toString()}": widget.recentMessage['message'].toString();
    }else if(messageType == "image"){
      message =  widget.recentMessage['messageSenderId'].toString() ==
          Provider.of<MyProvider>(context, listen: false).auth.currentUser!.uid ?
      "you sent image to ${widget.recentMessage['messageTo'].toString()}":
      "${widget.recentMessage['messageFrom'].toString()} sent to you image";
    }else if(messageType == "video"){
      message =  widget.recentMessage['messageSenderId'].toString() ==
          Provider.of<MyProvider>(context, listen: false).auth.currentUser!.uid ?
      "you sent video to ${widget.recentMessage['messageTo'].toString()}":
      "${widget.recentMessage['messageFrom'].toString()} sent to you video";
    }else if(messageType == "document"){
      message =  widget.recentMessage['messageSenderId'].toString() ==
          Provider.of<MyProvider>(context, listen: false).auth.currentUser!.uid ?
      "you sent document to ${widget.recentMessage['messageTo'].toString()}":
      "${widget.recentMessage['messageFrom'].toString()} sent to you document";
    }else if(messageType == "audio"){
      message =  widget.recentMessage['messageSenderId'].toString() ==
          Provider.of<MyProvider>(context, listen: false).auth.currentUser!.uid ?
      "you sent audio file to ${widget.recentMessage['messageTo'].toString()}":
      "${widget.recentMessage['messageFrom'].toString()} sent to you audio file";
    }else if(messageType == "voice message"){
      message =  widget.recentMessage['messageSenderId'].toString() ==
          Provider.of<MyProvider>(context, listen: false).auth.currentUser!.uid ?
      "you sent voice message to ${widget.recentMessage['messageTo'].toString()}":
      "${widget.recentMessage['messageFrom'].toString()} sent to you voice message";
    }

    return message;
  }

  @override
  void initState() {
     isMe = widget.recentMessage['messageSenderId'].toString() ==
        Provider.of<MyProvider>(context, listen: false).auth.currentUser!.uid;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Container(
        margin:const EdgeInsets.only(top: 5.0, bottom: 5.0,),
        padding:const EdgeInsets.symmetric(horizontal: 10.0 , vertical: 10.0),
        decoration: const BoxDecoration(
          color: Colors.white54 ,
          borderRadius:BorderRadius.only(
            topRight:Radius.circular(20.0),
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
                const   SizedBox(width: 10.0,),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isMe ? widget.recentMessage['messageTo'].toString():
                      widget.recentMessage['messageFrom'].toString(),
                      style:const TextStyle(
                        color: Colors.grey,
                        fontSize: 15.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const   SizedBox(height: 5.0,),
                    SizedBox(
                      width: MediaQuery.of(context).size.width * 0.45,
                      child: Text(_message(widget.recentMessage['msgType'].toString()),
                        style:const TextStyle(
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
            Text(Jiffy(
                widget.recentMessage['msgTime']==null?
                DateFormat('dd-MM-yyyy hh:mm a').format(DateTime.parse(Timestamp.now().toDate().toString())):
                DateFormat('dd-MM-yyyy hh:mm a').format(DateTime.parse(widget.recentMessage['msgTime'].toDate().toString()))
                , "dd-MM-yyyy hh:mm a").fromNow(),
              style:const TextStyle(
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
