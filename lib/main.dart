import 'dart:async';

import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:full_chat_application/provider/my_provider.dart';
import 'package:full_chat_application/provider/shared_preferences.dart';
import 'package:full_chat_application/screens/audio_call_screen.dart';
import 'package:full_chat_application/screens/call_screen.dart';
import 'package:full_chat_application/screens/home_screen.dart';
import 'package:full_chat_application/screens/chat_screen.dart';
import 'package:full_chat_application/screens/splash_screen.dart';
import 'package:full_chat_application/screens/video_call_screen.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'Utils.dart';
import 'firebase_helper/fireBaseHelper.dart';
import 'notifications/notifications.dart';
import 'userAuthentication/login.dart';
import 'userAuthentication/register.dart';


void main()  async{
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await notificationInitialization();
  FirebaseMessaging.onBackgroundMessage(messageHandler);
  firebaseMessagingListener();
  notificationCallInitialization();

  runApp( ChangeNotifierProvider(
      create: (_) => MyProvider(),
      child: const MyApp()));

}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  StreamSubscription<ReceivedAction>? _actionStreamSubscription;
  bool subscribedActionStream = false;

  @override
  void initState() {
    super.initState();
    listen();
    if (!subscribedActionStream) {
      AwesomeNotifications().actionStream.listen((action) {
        if(action.buttonKeyPressed == "Answer"){
          getCallType().then((value) {
            Get.off(CallScreen(value));

          });
        }else if(action.buttonKeyPressed == "Cancel"){
          FireBaseHelper().updateCallStatus(context,"false");
          cancelCall(context,"You cancel the call");

        }
      });
      subscribedActionStream = true;
    }
   }
  void listen() async {
    // You can choose to cancel any exiting subscriptions
    await _actionStreamSubscription?.cancel();
    // assign the stream subscription
    _actionStreamSubscription = AwesomeNotifications().actionStream.listen((message) {
      // handle stuff here
    });
  }
  @override
  void dispose() async {
    Future.delayed(Duration.zero, () async {
      await _actionStreamSubscription?.cancel();
    });
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {

    return  GetMaterialApp(
        debugShowCheckedModeBanner: false,
        initialRoute: '/start',
        getPages: [
          GetPage(name: '/start', page: () => const SplashScreen()),
          GetPage(name: '/login', page: () => const Login()),
          GetPage(name: '/register', page: () => const Register()),
          GetPage(name: '/all_users', page: () => const HomeScreen()),
          GetPage(name: '/chat', page: () => const ChatScreen()),
          GetPage(name: '/video_call', page: () => const VideoCallScreen()),
          GetPage(name: '/audio_call', page: () => const AudioCallScreen()),
        ],
    );
  }


}