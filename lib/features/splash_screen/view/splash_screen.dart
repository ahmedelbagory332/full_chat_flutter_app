import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:full_chat_application/features/logIn/view/logIn.dart';
import 'package:full_chat_application/features/splash_screen/manager/splash_screen_cubit.dart';
import 'package:full_chat_application/features/splash_screen/manager/splash_screen_state.dart';
import 'package:get/get.dart';

import '../../home_screen/view/home_screen.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: BlocListener<SplashScreenCubit, SplashScreenState>(
        listener: (BuildContext context, state) {
          if (state.status == SplashScreenStatus.home) {
            Get.offAll(const HomeScreen());
          } else if (state.status == SplashScreenStatus.auth) {
            Get.offAll(const LogIn());
          }
        },
        child: Scaffold(
            body: SizedBox(
          width: double.infinity,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset('images/chat_icon.png'),
              const Text(
                'Bego Chat',
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 40.0,
                    color: Colors.black87),
              ),
              const CircularProgressIndicator()
            ],
          ),
        )),
      ),
    );
  }
}
