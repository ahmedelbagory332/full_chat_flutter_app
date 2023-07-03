import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:full_chat_application/core/utils/app_utils.dart';
import 'package:full_chat_application/core/widget/custom_loading_dialog.dart';
import 'package:full_chat_application/features/logIn/view/logIn.dart';
import 'package:full_chat_application/features/register/manager/sign_up_cubit.dart';
import 'package:full_chat_application/features/register/manager/sign_up_state.dart';
import 'package:get/get.dart';

class Register extends StatelessWidget {
  const Register({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<SignUpCubit, SignUpState>(
      listener: (BuildContext context, state) {
        switch (state.status) {
          case SignUpStatus.initial:
            {}
            break;
          case SignUpStatus.loading:
            {
              customLoadingDialog(context);
            }
            break;
          case SignUpStatus.success:
            {
              //To close dialogs
              Get.back();
              // To go to the next screen and cancel all previous routes
              Get.offAll(const LogIn());
              buildShowSnackBar(context, "Now you can login");
            }
            break;
          case SignUpStatus.error:
            {
              Get.back();
              buildShowSnackBar(context, state.failure.errMessage);
            }
            break;
          case SignUpStatus.registerDevice:
            {
              context.read<SignUpCubit>().registerDevice();
            }
            break;
        }
      },
      builder: (BuildContext context, state) {
        return Container(
          decoration: const BoxDecoration(
            image: DecorationImage(
                image: AssetImage('images/register.png'), fit: BoxFit.cover),
          ),
          child: SafeArea(
            child: Scaffold(
              appBar: AppBar(
                backgroundColor: Colors.transparent,
                elevation: 0,
              ),
              backgroundColor: Colors.transparent,
              body: SingleChildScrollView(
                child: Container(
                  padding: const EdgeInsets.only(right: 35, left: 35),
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: EdgeInsets.only(
                              left: 35,
                              top: 10,
                              bottom: MediaQuery.of(context).size.height * 0.2),
                          child: const Text(
                            "Create\nAccount",
                            style: TextStyle(color: Colors.white, fontSize: 33),
                          ),
                        ),
                        TextField(
                          onChanged: (value) {
                            context.read<SignUpCubit>().nameChanged(value);
                          },
                          decoration: InputDecoration(
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: const BorderSide(color: Colors.black),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: const BorderSide(color: Colors.white),
                            ),
                            labelText: "Name",
                            labelStyle: const TextStyle(color: Colors.white),
                          ),
                        ),
                        const SizedBox(
                          height: 30,
                        ),
                        TextField(
                          onChanged: (value) {
                            context.read<SignUpCubit>().emailChanged(value);
                          },
                          decoration: InputDecoration(
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: const BorderSide(color: Colors.black),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: const BorderSide(color: Colors.white),
                            ),
                            labelText: "Email",
                            labelStyle: const TextStyle(color: Colors.white),
                          ),
                        ),
                        const SizedBox(
                          height: 30,
                        ),
                        TextField(
                          onChanged: (value) {
                            context.read<SignUpCubit>().passwordChanged(value);
                          },
                          obscureText: true,
                          decoration: InputDecoration(
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: const BorderSide(color: Colors.black),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: const BorderSide(color: Colors.white),
                            ),
                            labelText: 'Password',
                            labelStyle: const TextStyle(color: Colors.white),
                          ),
                        ),
                        const SizedBox(
                          height: 40,
                        ),
                        Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Sign Up',
                                style: TextStyle(
                                  color: Colors.white,
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
                                    context.read<SignUpCubit>().signUp();
                                  },
                                  icon: const Icon(Icons.arrow_forward),
                                ),
                              ),
                            ]),
                        const SizedBox(
                          height: 40,
                        ),
                        Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              TextButton(
                                onPressed: () {
                                  Get.offAll(const LogIn());
                                },
                                child: const Text(
                                  'Login',
                                  style: TextStyle(
                                    decoration: TextDecoration.underline,
                                    fontSize: 18,
                                    color: Colors.white,
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
