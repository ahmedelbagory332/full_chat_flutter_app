import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:full_chat_application/firebase_helper/fireBaseHelper.dart';
import 'package:full_chat_application/serverFunctions/server_functions.dart';
import 'package:full_chat_application/widget/message_compose.dart';
import 'package:full_chat_application/widget/sub_title_app_bar.dart';
import 'package:provider/provider.dart';
import '../provider/my_provider.dart';
import '../widget/messages_list.dart';


class ChatScreen extends StatefulWidget {
  const ChatScreen({Key? key}) : super(key: key);


  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> with WidgetsBindingObserver{
  late MyProvider _appProvider;

  @override
  void initState() {
    WidgetsBinding.instance.addObserver(this);
    FireBaseHelper().updateUserStatus("Online",Provider.of<MyProvider>(context,listen: false).auth.currentUser!.uid);
    updatePeerDevice(Provider.of<MyProvider>(context,listen: false).auth.currentUser!.email, Provider.of<MyProvider>(context,listen: false).peerUserData!["email"]);
    super.initState();
  }

  @override
  void didChangeDependencies() {
    _appProvider = Provider.of<MyProvider>(context, listen: false);
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    FireBaseHelper().updateUserStatus(FieldValue.serverTimestamp(),_appProvider.auth.currentUser!.uid);
    updatePeerDevice(_appProvider.auth.currentUser!.email, "0");
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch(state)
    {
      case AppLifecycleState.paused:
        FireBaseHelper().updateUserStatus(FieldValue.serverTimestamp(),Provider.of<MyProvider>(context,listen: false).auth.currentUser!.uid);
        updatePeerDevice(Provider.of<MyProvider>(context,listen: false).auth.currentUser!.email, "0");
        break;
      case AppLifecycleState.inactive:
        FireBaseHelper().updateUserStatus(FieldValue.serverTimestamp(),Provider.of<MyProvider>(context,listen: false).auth.currentUser!.uid);
        updatePeerDevice(Provider.of<MyProvider>(context,listen: false).auth.currentUser!.email, "0");
        break;
      case AppLifecycleState.detached:
        FireBaseHelper().updateUserStatus(FieldValue.serverTimestamp(),Provider.of<MyProvider>(context,listen: false).auth.currentUser!.uid);
        updatePeerDevice(Provider.of<MyProvider>(context,listen: false).auth.currentUser!.email, "0");
        break;
      case AppLifecycleState.resumed:
        FireBaseHelper().updateUserStatus("Online",Provider.of<MyProvider>(context,listen: false).auth.currentUser!.uid);
        updatePeerDevice(Provider.of<MyProvider>(context,listen: false).auth.currentUser!.email, Provider.of<MyProvider>(context,listen: false).peerUserData!["email"]);
        break;
    }    super.didChangeAppLifecycleState(state);
  }
  
  @override
  Widget build(BuildContext context) {
    return  Scaffold(
      appBar: AppBar(
        title: Column(
         crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(Provider.of<MyProvider>(context,listen: false).peerUserData!["name"],
                style: const TextStyle(fontSize: 18.5, fontWeight: FontWeight.bold)),
             const SubTitleAppBar(),
          ],
        ),

        actions: [
          IconButton(onPressed: () {
            notifyUserWithCall("Calling from ${Provider.of<MyProvider>(context,listen: false).auth.currentUser!.displayName}",
              Provider.of<MyProvider>(context,listen: false).peerUserData!["email"],
              Provider.of<MyProvider>(context,listen: false).peerUserData!["userId"],
              Provider.of<MyProvider>(context,listen: false).peerUserData!["name"],
              "video"
            );
            Navigator.pushNamed(context, 'video_call');
          }, icon: const Icon(Icons.videocam)),
          IconButton(onPressed: () {
            notifyUserWithCall("Calling from ${Provider.of<MyProvider>(context,listen: false).auth.currentUser!.displayName}",
                Provider.of<MyProvider>(context,listen: false).peerUserData!["email"],
                Provider.of<MyProvider>(context,listen: false).peerUserData!["userId"],
                Provider.of<MyProvider>(context,listen: false).peerUserData!["name"],
                "audio"
            );
            Navigator.pushNamed(context, 'audio_call');
          }, icon: const Icon(Icons.call)),
        ],
      ),
      body:Column(
        children:  const [
          Expanded(child: Messages(),),
           MessagesCompose(),
        ],
      )

    );
  }

}

