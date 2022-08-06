import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:full_chat_application/provider/my_provider.dart';
import 'package:full_chat_application/screens/home_screen.dart';
import 'package:full_chat_application/screens/chat_screen.dart';
import 'package:full_chat_application/screens/splash_screen.dart';
import 'package:provider/provider.dart';
import 'notifications/notifications.dart';
import 'userAuthentication/login.dart';
import 'userAuthentication/register.dart';

void main()  async{
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await notificationInitialization();
  FirebaseMessaging.onBackgroundMessage(messageHandler);
  firebaseMessagingListener();
  runApp(const MyApp());
}


class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => MyProvider(),
      child: MaterialApp(
          debugShowCheckedModeBanner: false,
          initialRoute: 'start',
          routes: {
            'start': (context) => const SplashScreen(),
            'login': (context) => const Login(),
            'register': (context) => const Register(),
            'all_users': (context) => const HomeScreen(),
            'chat': (context) =>  const ChatScreen(),
          }
      ),
    );
  }
}