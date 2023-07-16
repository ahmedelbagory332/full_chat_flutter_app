import 'dart:async';

import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:full_chat_application/core/service_locator.dart';
import 'package:full_chat_application/core/storage/shared_preferences.dart';
import 'package:full_chat_application/features/chat_screen/chat_screen.dart';
import 'package:full_chat_application/features/chat_screen/manager/chat_cubit.dart';
import 'package:full_chat_application/features/home_screen/view/home_screen.dart';
import 'package:full_chat_application/features/logIn/manager/sign_in_cubit.dart';
import 'package:full_chat_application/features/splash_screen/view/splash_screen.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'core/notifications/notifications.dart';
import 'core/storage/firebase_helper/fireBaseHelper.dart';
import 'core/utils/app_utils.dart';
import 'features/call_screen/audio_call_screen.dart';
import 'features/call_screen/call_screen.dart';
import 'features/call_screen/video_call_screen.dart';
import 'features/chat_screen/data/repo/chat_repo_impl.dart';
import 'features/home_screen/data/repo/home_repo_impl.dart';
import 'features/home_screen/manager/homeCubit/home_cubit.dart';
import 'features/home_screen/manager/lastMessagesCubit/last_message_cubit.dart';
import 'features/home_screen/manager/usersCubit/users_cubit.dart';
import 'features/logIn/data/repo/sign_in_repo_impl.dart';
import 'features/logIn/view/logIn.dart';
import 'features/register/data/repo/sign_up_repo_impl.dart';
import 'features/register/manager/sign_up_cubit.dart';
import 'features/register/view/register.dart';
import 'features/splash_screen/manager/splash_screen_cubit.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  setupServiceLocator();
  await Firebase.initializeApp();
  await notificationInitialization();
  FirebaseMessaging.onBackgroundMessage(messageHandler);
  firebaseMessagingListener();
  notificationCallInitialization();
  runApp(const MyApp());
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
        if (action.buttonKeyPressed == "Answer") {
          Get.off(CallScreen(getCallType()));
        } else if (action.buttonKeyPressed == "Cancel") {
          FireBaseHelper().updateCallStatus(context, "false");
          cancelCall(context, "You cancel the call");
        }
      });
      subscribedActionStream = true;
    }
  }

  void listen() async {
    // You can choose to cancel any exiting subscriptions
    await _actionStreamSubscription?.cancel();
    // assign the stream subscription
    _actionStreamSubscription =
        AwesomeNotifications().actionStream.listen((message) {
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
    return MultiBlocProvider(
      providers: [
        BlocProvider(
            create: (context) => SplashScreenCubit(
                  getIt.get<FirebaseAuth>(),
                )..initRoute()),
        BlocProvider(
            create: (context) => SignUpCubit(
                  getIt.get<SignUpRepoImpl>(),
                  getIt.get<FirebaseAuth>(),
                )),
        BlocProvider(
            create: (context) => SigInCubit(
                  getIt.get<SignInRepoImpl>(),
                  getIt.get<FirebaseAuth>(),
                )),
        BlocProvider(
            create: (context) => HomeCubit(
                  getIt.get<HomeRepoImpl>(),
                  getIt.get<FirebaseAuth>(),
                )
                  ..getDeviceToken()
                  ..onTokenRefresh()),
        BlocProvider(
            create: (context) => UsersCubit(
                  getIt.get<HomeRepoImpl>(),
                  getIt.get<SharedPreferences>(),
                  getIt.get<FirebaseAuth>(),
                )..getUsers()),
        BlocProvider(
            create: (context) => LastMessagesCubit(
                  getIt.get<HomeRepoImpl>(),
                  getIt.get<SharedPreferences>(),
                  getIt.get<FirebaseAuth>(),
                )..getLastMessages()),
        BlocProvider(
            create: (context) => ChatCubit(
                  getIt.get<ChatRepoImpl>(),
                  getIt.get<SharedPreferences>(),
                  getIt.get<FirebaseAuth>(),
                )..getPeeredUserStatus()),
      ],
      child: GetMaterialApp(
        debugShowCheckedModeBanner: false,
        initialRoute: '/start',
        getPages: [
          GetPage(name: '/start', page: () => const SplashScreen()),
          GetPage(name: '/login', page: () => const LogIn()),
          GetPage(name: '/register', page: () => const Register()),
          GetPage(name: '/all_users', page: () => const HomeScreen()),
          GetPage(name: '/chat', page: () => const ChatScreen()),
          GetPage(name: '/video_call', page: () => const VideoCallScreen()),
          GetPage(name: '/audio_call', page: () => const AudioCallScreen()),
        ],
      ),
    );
  }
}
