import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';

import '../../manager/lastMessagesCubit/last_message_cubit.dart';
import '../../manager/lastMessagesCubit/last_message_state.dart';
import 'recent_chats_tile.dart';

class RecentChats extends StatelessWidget {
  const RecentChats({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<LastMessagesCubit, LastMessagesState>(
      listener: (BuildContext context, state) {
        if (state.status == LastMessagesStatus.navigateToChat) {
          Get.toNamed('/chat');
        }
      },
      builder: (context, state) {
        switch (state.status) {
          case LastMessagesStatus.navigateToChat:
            {
              Get.toNamed('/chat');
            }
            break;
          case LastMessagesStatus.initial:
            {
              context.read<LastMessagesCubit>().getLastMessages();
            }
            break;
          case LastMessagesStatus.loading:
            {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }
            break;
          case LastMessagesStatus.error:
            {
              return Center(child: Text(state.failure.errMessage));
            }
            break;

          case LastMessagesStatus.success:
            break;
        }
        return Expanded(
          child: ClipRRect(
              borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(5.0),
                  topRight: Radius.circular(5.0)),
              child: state.lastMessages.isEmpty
                  ? const Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Center(
                            child:
                                Text('No messages start to chat with someone')),
                      ],
                    )
                  : ListView.builder(
                      itemCount: state.lastMessages.length,
                      scrollDirection: Axis.vertical,
                      itemBuilder: (BuildContext context, int index) {
                        return InkWell(
                          onTap: () {
                            context
                                .read<LastMessagesCubit>()
                                .recentChatClickListener(
                                    state.lastMessages[index]);
                          },
                          child: MessageTile(
                              state.lastMessages[index],
                              state.lastMessages[index]['messageSenderId']
                                      .toString() ==
                                  context
                                      .read<LastMessagesCubit>()
                                      .getCurrentUser()!
                                      .uid),
                        );
                      })),
        );
      },
    );
  }
}
