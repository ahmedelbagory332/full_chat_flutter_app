// ignore_for_file: use_build_context_synchronously
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:full_chat_application/core/utils/app_utils.dart';
import 'package:full_chat_application/features/chat_screen/manager/chat_cubit.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../../home_screen/manager/lastMessagesCubit/last_message_cubit.dart';
import '../../../home_screen/manager/usersCubit/users_cubit.dart';
import '../../manager/chat_state.dart';

class MessagesCompose extends StatefulWidget {
  const MessagesCompose({Key? key}) : super(key: key);

  @override
  State<MessagesCompose> createState() => _MessagesComposeState();
}

class _MessagesComposeState extends State<MessagesCompose>
    with WidgetsBindingObserver {
  final TextEditingController _textController = TextEditingController();
  late ChatCubit _appProvider;

  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    WidgetsBinding.instance.addObserver(this);
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
    _appProvider.cancelRecord();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.paused:
        context.read<ChatCubit>().cancelRecord();
        break;
      case AppLifecycleState.inactive:
        context.read<ChatCubit>().cancelRecord();
        break;
      case AppLifecycleState.detached:
        context.read<ChatCubit>().cancelRecord();
        break;
      case AppLifecycleState.resumed:
        break;
    }
    super.didChangeAppLifecycleState(state);
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ChatCubit, ChatState>(
      listener: (BuildContext context, state) {
        if (state.status == ChatStatus.unsupported) {
          buildShowSnackBar(context, "unsupported format");
        }
      },
      builder: (BuildContext context, state) {
        return Row(
          children: [
            state.startVoiceMessage == true
                ? SizedBox(
                    width: MediaQuery.of(context).size.width - 55,
                    child: Card(
                      color: Colors.blueAccent,
                      margin:
                          const EdgeInsets.only(left: 5, right: 5, bottom: 8),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(25)),
                      child: Center(
                          child: Padding(
                        padding: const EdgeInsets.all(10),
                        child: Text(
                          state.recordTimer,
                          style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              fontSize: 15),
                        ),
                      )),
                    ))
                : SizedBox(
                    width: MediaQuery.of(context).size.width - 55,
                    child: Card(
                      color: Colors.blueAccent,
                      margin:
                          const EdgeInsets.only(left: 5, right: 5, bottom: 8),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(25)),
                      child: TextField(
                          style: const TextStyle(
                            color: Colors.white,
                          ),
                          controller: _textController,
                          textAlignVertical: TextAlignVertical.center,
                          keyboardType: TextInputType.multiline,
                          maxLines: 5,
                          minLines: 1,
                          onChanged: (value) {
                            if (value.isNotEmpty) {
                              context.read<ChatCubit>().updateUserStatus(
                                  "typing....",
                                  context
                                      .read<ChatCubit>()
                                      .getCurrentUser()!
                                      .uid);
                              context
                                  .read<ChatCubit>()
                                  .sendChatButtonChanged(true);
                            } else {
                              context.read<ChatCubit>().updateUserStatus(
                                  "Online",
                                  context
                                      .read<ChatCubit>()
                                      .getCurrentUser()!
                                      .uid);
                              context
                                  .read<ChatCubit>()
                                  .sendChatButtonChanged(false);
                            }
                          },
                          decoration: InputDecoration(
                            border: InputBorder.none,
                            hintText: "Type your message",
                            hintStyle: const TextStyle(
                              color: Colors.white,
                            ),
                            suffixIcon: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                    onPressed: () async {
                                      final status =
                                          await Permission.storage.request();
                                      if (status == PermissionStatus.granted) {
                                        FilePickerResult? result =
                                            await FilePicker.platform
                                                .pickFiles();
                                        context
                                            .read<ChatCubit>()
                                            .getReferenceFromStorage(
                                                result, "");
                                      } else {
                                        await Permission.storage.request();
                                      }
                                    },
                                    icon: const Icon(
                                      Icons.attach_file,
                                      color: Colors.white,
                                    )),
                                IconButton(
                                    onPressed: () async {
                                      final status =
                                          await Permission.storage.request();
                                      if (status == PermissionStatus.granted) {
                                        final XFile? photo =
                                            await _picker.pickImage(
                                                source: ImageSource.camera);
                                        context
                                            .read<ChatCubit>()
                                            .getReferenceFromStorage(photo, "");
                                        context.read<ChatCubit>().uploadFile(
                                            "", "image", state.reference!);
                                      } else {
                                        await Permission.storage.request();
                                      }
                                    },
                                    icon: const Icon(
                                      Icons.camera,
                                      color: Colors.white,
                                    ))
                              ],
                            ),
                            contentPadding: const EdgeInsets.all(5),
                          )),
                    )),
            Padding(
              padding: const EdgeInsets.only(bottom: 8.0, right: 2),
              child: CircleAvatar(
                radius: 25,
                backgroundColor: Colors.blueAccent,
                child: IconButton(
                    onPressed: () async {
                      if (state.sendChatButton) {
                        //txt message

                        context.read<ChatCubit>().sendMessage(
                            chatId: state.chatId,
                            senderId:
                                context.read<ChatCubit>().getCurrentUser()!.uid,
                            receiverId:
                                context.read<UsersCubit>().peerUserData == null
                                    ? context
                                        .read<LastMessagesCubit>()
                                        .peerUserData!
                                        .docs[0]["userId"]
                                    : context
                                        .read<UsersCubit>()
                                        .peerUserData!
                                        .docs[0]["userId"],
                            receiverUsername:
                                context.read<UsersCubit>().peerUserData == null
                                    ? context
                                        .read<LastMessagesCubit>()
                                        .peerUserData!
                                        .docs[0]["name"]
                                    : context
                                        .read<UsersCubit>()
                                        .peerUserData!
                                        .docs[0]["name"],
                            msgTime: FieldValue.serverTimestamp(),
                            msgType: "text",
                            message: _textController.text.toString(),
                            fileName: "");

                        context.read<ChatCubit>().notifyUser(
                            context
                                .read<ChatCubit>()
                                .getCurrentUser()!
                                .displayName,
                            _textController.text.toString(),
                            context.read<UsersCubit>().peerUserData == null
                                ? context
                                    .read<LastMessagesCubit>()
                                    .peerUserData!
                                    .docs[0]["email"]
                                : context
                                    .read<UsersCubit>()
                                    .peerUserData!
                                    .docs[0]["email"],
                            context.read<ChatCubit>().getCurrentUser()!.email);

                        _textController.clear();

                        context.read<ChatCubit>().sendChatButtonChanged(false);
                        context.read<ChatCubit>().updateUserStatus("Online",
                            context.read<ChatCubit>().getCurrentUser()!.uid);
                      } else {
                        final status = await Permission.microphone.request();
                        if (status == PermissionStatus.granted) {
                          await context.read<ChatCubit>().initRecording();
                          context.read<ChatCubit>().recordTimer();
                          if (context.read<ChatCubit>().recorder.isRecording) {
                            await context.read<ChatCubit>().stop();
                            context
                                .read<ChatCubit>()
                                .startVoiceMessageChanged(false);
                          } else {
                            await context.read<ChatCubit>().record();
                            context
                                .read<ChatCubit>()
                                .startVoiceMessageChanged(true);
                          }
                        } else {
                          buildShowSnackBar(
                              context, "You must enable record permission");
                        }
                        // voice message
                      }
                    },
                    icon: Icon(
                      state.sendChatButton
                          ? Icons.send
                          : state.startVoiceMessage == true
                              ? Icons.stop
                              : Icons.mic,
                      color: Colors.white,
                    )),
              ),
            ),
          ],
        );
      },
    );
  }
}
