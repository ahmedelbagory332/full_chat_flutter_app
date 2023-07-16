import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:full_chat_application/features/chat_screen/view/widget/message_compose.dart';
import 'package:full_chat_application/features/chat_screen/view/widget/sub_title_app_bar.dart';
import 'package:get/get.dart';

import 'manager/chat_cubit.dart';
import 'view/widget/messages_list.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({Key? key}) : super(key: key);

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> with WidgetsBindingObserver {
  late ChatCubit _appProvider;

  @override
  void initState() {
    WidgetsBinding.instance.addObserver(this);
    context.read<ChatCubit>().updateUserStatus(
        "Online", context.read<ChatCubit>().getCurrentUser()!.uid);

    context.read<ChatCubit>().updatePeerDevice(
        context.read<ChatCubit>().getPeerUserData()["userId"]);

    context.read<ChatCubit>().peerUserChanged();

    context.read<ChatCubit>().getMessages();

    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _appProvider = BlocProvider.of<ChatCubit>(context);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _appProvider.updateUserStatus(
        FieldValue.serverTimestamp(), _appProvider.getCurrentUser()!.uid);
    _appProvider.updatePeerDevice("0");
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.paused:
        context.read<ChatCubit>().updateUserStatus(FieldValue.serverTimestamp(),
            context.read<ChatCubit>().getCurrentUser()!.uid);
        context.read<ChatCubit>().updatePeerDevice("0");
        break;
      case AppLifecycleState.inactive:
        context.read<ChatCubit>().updateUserStatus(FieldValue.serverTimestamp(),
            context.read<ChatCubit>().getCurrentUser()!.uid);
        context.read<ChatCubit>().updatePeerDevice("0");
        break;
      case AppLifecycleState.detached:
        context.read<ChatCubit>().updateUserStatus(FieldValue.serverTimestamp(),
            context.read<ChatCubit>().getCurrentUser()!.uid);
        context.read<ChatCubit>().updatePeerDevice("0");
        break;
      case AppLifecycleState.resumed:
        context.read<ChatCubit>().updateUserStatus(
            "Online", context.read<ChatCubit>().getCurrentUser()!.uid);
        context.read<ChatCubit>().updatePeerDevice("1");
        break;
    }
    super.didChangeAppLifecycleState(state);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              Get.back();
            },
          ),
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(context.read<ChatCubit>().getPeerUserData()["name"],
                  style: const TextStyle(
                      fontSize: 18.5, fontWeight: FontWeight.bold)),
              const SubTitleAppBar(),
            ],
          ),
          actions: [
            IconButton(
                onPressed: () {
                  context.read<ChatCubit>().notifyUserWithCall(
                      "Calling from ${context.read<ChatCubit>().getCurrentUser()!.displayName}",
                      context.read<ChatCubit>().getPeerUserData()["email"],
                      context.read<ChatCubit>().getPeerUserData()["userId"],
                      context.read<ChatCubit>().getPeerUserData()["name"],
                      "video");
                  Navigator.pushNamed(context, 'video_call');
                },
                icon: const Icon(Icons.videocam)),
            IconButton(
                onPressed: () {
                  context.read<ChatCubit>().notifyUserWithCall(
                      "Calling from ${context.read<ChatCubit>().getCurrentUser()!.displayName}",
                      context.read<ChatCubit>().getPeerUserData()["email"],
                      context.read<ChatCubit>().getPeerUserData()["userId"],
                      context.read<ChatCubit>().getPeerUserData()["name"],
                      "audio");
                  Navigator.pushNamed(context, 'audio_call');
                },
                icon: const Icon(Icons.call)),
          ],
        ),
        body: const Column(
          children: [
            Expanded(
              child: Messages(),
            ),
            MessagesCompose(),
          ],
        ));
  }
}
