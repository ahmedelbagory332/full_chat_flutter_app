import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:full_chat_application/features/chat_screen/manager/chat_cubit.dart';
import 'package:full_chat_application/features/chat_screen/manager/chat_state.dart';
import 'package:intl/intl.dart';
import 'package:jiffy/jiffy.dart';

class SubTitleAppBar extends StatelessWidget {
  const SubTitleAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    dynamic userStatus;
    return BlocConsumer<ChatCubit, ChatState>(
      listener: (_, state) {},
      builder: (_, state) {
        if (state.peeredUser == null) {
          userStatus = "loading...";
        } else {
          userStatus = state.peeredUser!["userStatus"];
          if (userStatus == "Online") {
            userStatus = state.peeredUser!["userStatus"];
          } else if (userStatus == "typing....") {
            userStatus = state.peeredUser!["userStatus"];
          } else {
            userStatus =
                "last seen : ${Jiffy(DateFormat('dd-MM-yyyy hh:mm a').format(DateTime.parse(state.peeredUser!["userStatus"].toDate().toString())), "dd-MM-yyyy hh:mm a").fromNow()}";
          }
        }

        // userStatus = state.peeredUser!["userStatus"];

        // if (state.status == ChatStatus.gettingPeeredUser) {
        //   return const Text("loading...", style: TextStyle(fontSize: 13));
        // } else if (state.status == ChatStatus.peeredUserError) {
        //   return Text(state.failure.errMessage,
        //       style: const TextStyle(fontSize: 13));
        //  } else if (state.status == ChatStatus.peeredUser) {

        // if (state.peeredUser!["userStatus"] != null) {
        //   if (state.peeredUser!["userStatus"] == "Online") {
        //     userStatus = state.peeredUser!["userStatus"];
        //   } else if (state.peeredUser!["userStatus"] == "typing....") {
        //     userStatus = state.peeredUser!["userStatus"];
        //   } else {
        //     userStatus =
        //         "last seen : ${Jiffy(DateFormat('dd-MM-yyyy hh:mm a').format(DateTime.parse(state.peeredUser!["userStatus"].toDate().toString())), "dd-MM-yyyy hh:mm a").fromNow()}";
        //   }
        // }
        return Text(userStatus, style: const TextStyle(fontSize: 13));
        // } else {
        //   return Container();
        // }
      },
    );
  }
}
