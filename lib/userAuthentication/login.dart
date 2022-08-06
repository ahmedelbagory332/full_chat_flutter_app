import 'package:flutter/material.dart';
import 'package:full_chat_application/serverFunctions/server_functions.dart';
import 'package:provider/provider.dart';

import '../Utils.dart';
import '../provider/my_provider.dart';
import '../firebase_helper/fireBaseHelper.dart';

class Login extends StatefulWidget {
  const Login({Key? key}) : super(key: key);

  @override
  LoginState createState() => LoginState();
}

class LoginState extends State<Login> {
  String email = "";
  String password = "";
  late BuildContext dialogContext;


  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        image: DecorationImage(
            image: AssetImage('images/login.png'), fit: BoxFit.cover),
      ),
      child: SafeArea(
        child: Scaffold(
          backgroundColor: Colors.transparent,
          body: SingleChildScrollView(
            child: Container(
              padding: const EdgeInsets.only(
                right: 35,
                left: 35,
              ),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: EdgeInsets.only(
                          left: 35,
                          top: MediaQuery.of(context).size.height * 0.1,
                          bottom: MediaQuery.of(context).size.height * 0.2),
                      child: const Text(
                        "Welcome\nBack",
                        style: TextStyle(color: Colors.white, fontSize: 33),
                      ),
                    ),
                    TextField(
                      onChanged: (text) {
                        email = text;
                      },
                      decoration: InputDecoration(
                        labelText: "Email",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 30,
                    ),
                    TextField(
                      onChanged: (text) {
                        password = text;
                      },
                      obscureText: true,
                      decoration: InputDecoration(
                        labelText: 'Password',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 40,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Sign In',
                          style: TextStyle(
                            color: Color(0xff4c505b),
                            fontSize: 27,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        CircleAvatar(
                          radius: 30,
                          backgroundColor: const Color(0xff4c505b),
                          child: IconButton(
                            color: Colors.white,
                            onPressed: () {
                              if(email.isEmpty || password.isEmpty ){
                                buildShowSnackBar(context, "please check your info.");

                              }else {
                                showDialog(
                                    context: context,
                                    barrierDismissible: false,
                                    builder: (context) {
                                      dialogContext = context;
                                      return const Center(
                                        child: CircularProgressIndicator(),
                                      );
                                    }
                                );
                                FireBaseHelper()
                                    .signIn(email: email.trim().toString(), password: password.trim().toString())
                                    .then((result) {
                                  if(result == "Welcome"){
                                     Navigator.of(context).pushNamedAndRemoveUntil(
                                       'all_users', (Route<dynamic> route) => false );
                                    buildShowSnackBar(context,result+" "+ Provider.of<MyProvider>(context,listen: false).auth.currentUser!.displayName);
                                  } else if (result != null) {
                                    buildShowSnackBar(context, result);
                                    Navigator.pop(dialogContext);
                                  }
                                  else {
                                    Navigator.pop(dialogContext);
                                    buildShowSnackBar(context, "Try again.");
                                  }
                                }).catchError((e) {
                                  Navigator.pop(dialogContext);
                                  buildShowSnackBar(context, e.toString());
                                });
                              }
                            },
                            icon: const Icon(Icons.arrow_forward),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(
                      height: 40,
                    ),
                    Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          TextButton(
                            onPressed: () {
                              Navigator.pushReplacementNamed(
                                  context, 'register');
                            },
                            child: const Text(
                              'Sign Up',
                              style: TextStyle(
                                decoration: TextDecoration.underline,
                                fontSize: 18,
                                color: Color(0xff4c505b),
                              ),
                            ),
                          ),
                        ]),
                  ]),
            ),
          ),
        ),
      ),
    );
  }
}
