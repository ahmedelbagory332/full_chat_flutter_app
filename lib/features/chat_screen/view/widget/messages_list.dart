import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:full_chat_application/core/utils/app_utils.dart';
import 'package:full_chat_application/features/chat_screen/manager/chat_cubit.dart';
import 'package:full_chat_application/features/chat_screen/manager/chat_state.dart';
import 'package:full_chat_application/features/chat_screen/view/widget/receiver_message_card.dart';
import 'package:full_chat_application/features/chat_screen/view/widget/sender_message_card.dart';
import 'package:intl/intl.dart';

class Messages extends StatelessWidget {
  const Messages({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ChatCubit, ChatState>(
      listener: (BuildContext context, state) {},
      builder: (BuildContext context, state) {
        debugPrint("ChatStatus.Messages ${state.status}");

        if (state.status == ChatStatus.getMessagesError) {
          return const Text('Something went wrong try again');
        }

        if (state.status == ChatStatus.gettingMessages) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        if (state.status == ChatStatus.getMessages) {
          return state.messages!.isEmpty
              ? const Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Center(child: Text('No messages')),
                  ],
                )
              : ListView.builder(
                  reverse: true,
                  shrinkWrap: true,
                  itemCount: state.messages!.length,
                  itemBuilder: (context, index) {
                    if (context.read<ChatCubit>().getCurrentUser()!.uid ==
                        state.messages![index]['senderId'].toString()) {
                      return InkWell(
                        onTap: () {
                          if (state.messages![index]['msgType'].toString() ==
                                  "document" ||
                              state.messages![index]['msgType'].toString() ==
                                  "audio" ||
                              state.messages![index]['msgType'].toString() ==
                                  "voice message") {
                            downloadFile(
                                context,
                                state.messages![index]['message'].toString(),
                                state.messages![index]['fileName'].toString(),
                                state.messages![index]['msgType'].toString());
                          }
                        },
                        child: SenderMessageCard(
                            state.messages![index]['fileName'].toString(),
                            state.messages![index]['msgType'].toString(),
                            state.messages![index]['message'].toString(),
                            state.messages![index]['msgTime'] == null
                                ? DateFormat('dd-MM-yyyy hh:mm a').format(
                                    DateTime.parse(
                                        Timestamp.now().toDate().toString()))
                                : DateFormat('dd-MM-yyyy hh:mm a').format(
                                    DateTime.parse(state.messages![index]
                                            ['msgTime']
                                        .toDate()
                                        .toString()))),
                      );
                    } else {
                      return InkWell(
                        onTap: () {
                          if (state.messages![index]['msgType'].toString() ==
                                  "document" ||
                              state.messages![index]['msgType'].toString() ==
                                  "audio" ||
                              state.messages![index]['msgType'].toString() ==
                                  "voice message") {
                            downloadFile(
                                context,
                                state.messages![index]['message'].toString(),
                                state.messages![index]['fileName'].toString(),
                                state.messages![index]['msgType'].toString());
                          }
                        },
                        child: ReceiverMessageCard(
                            state.messages![index]['fileName'].toString(),
                            state.messages![index]['msgType'].toString(),
                            state.messages![index]['message'].toString(),
                            state.messages![index]['msgTime'] == null
                                ? DateFormat('dd-MM-yyyy hh:mm a').format(
                                    DateTime.parse(
                                        Timestamp.now().toDate().toString()))
                                : DateFormat('dd-MM-yyyy hh:mm a').format(
                                    DateTime.parse(state.messages![index]
                                            ['msgTime']
                                        .toDate()
                                        .toString()))),
                      );
                    }
                  });
        } else {
          return Container();
        }
      },
    );
  }
}
