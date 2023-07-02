import 'package:flutter/material.dart';
import 'package:full_chat_application/features/home_screen/view/widget/recent_chats.dart';
import 'package:full_chat_application/features/home_screen/view/widget/users.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';

import '../../logIn/view/logIn.dart';
import '../manager/homeCubit/home_cubit.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: const Text("All Users"),
          automaticallyImplyLeading: false,
          actions: [
            IconButton(
                onPressed: () {
                  context.read<HomeCubit>().signOut();
                  Get.offAll(const LogIn());
                },
                icon: const Icon(Icons.logout_sharp))
          ],
        ),
        body: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Users(),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 2.0),
              child: Text(
                'Recent Chats',
                style: TextStyle(
                    fontWeight: FontWeight.w900,
                    fontSize: 15,
                    color: Color(0xFF9899A5)
                    // color: AppColors.textFaded,
                    ),
              ),
            ),
            RecentChats()
          ],
        ),
      ),
    );
  }
}
