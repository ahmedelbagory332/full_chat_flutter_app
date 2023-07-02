import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:full_chat_application/Utils.dart';
import 'package:full_chat_application/core/widget/custom_loading_dialog.dart';
import 'package:full_chat_application/features/home_screen/view/home_screen.dart';
import 'package:full_chat_application/features/logIn/manager/sign_in_cubit.dart';
import 'package:full_chat_application/features/logIn/manager/sign_in_state.dart';
import 'package:get/get.dart';

class LogIn extends StatelessWidget {
  const LogIn({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<SigInCubit, SignInState>(
      listener: (BuildContext context, state) {
        switch (state.status) {
          case SignInStatus.initial:
            {}
            break;
          case SignInStatus.loading:
            {
              customLoadingDialog(context);
            }
            break;
          case SignInStatus.success:
            {
              //To close dialogs
              Get.back();
              // To go to the next screen and cancel all previous routes
              Get.offAll(const HomeScreen());
            }
            break;
          case SignInStatus.error:
            {
              Get.back();
              buildShowSnackBar(context, state.failure.errMessage);
            }
        }
      },
      builder: (BuildContext context, state) {
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
                          onChanged: (value) {
                            context.read<SigInCubit>().emailChanged(value);
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
                          onChanged: (value) {
                            context.read<SigInCubit>().passwordChanged(value);
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
                                  context.read<SigInCubit>().signIn();
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
      },
    );
  }
}
