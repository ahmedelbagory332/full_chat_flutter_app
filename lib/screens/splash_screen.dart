import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../provider/my_provider.dart';


class SplashScreen extends StatefulWidget{
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
@override
  void initState() {
    // TODO: implement initState
    super.initState();
    Timer(const Duration(seconds: 2),(){
      if(Provider.of<MyProvider>(context,listen: false).auth.currentUser != null){
        Navigator.pushReplacementNamed(
            context, 'all_users');
      }else{
        Navigator.pushReplacementNamed(
            context, 'login');
      }
    });

  }

  @override
  Widget build(BuildContext context) {
    return  SafeArea(
      child: Scaffold(
        body: SizedBox(
          width: double.infinity,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset('images/chat_icon.png'),
              const Text(
                'Bego Chat',
                style:  TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 40.0,
                    color: Colors.black87
                ),
              ),
              const CircularProgressIndicator()
            ],
          ),
        )
      ),
    );
  }
}
