import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:full_chat_application/core/utils/app_utils.dart';
import 'package:full_chat_application/features/home_screen/view/widget/users_card.dart';
import 'package:get/get.dart';

import '../../manager/usersCubit/users_cubit.dart';
import '../../manager/usersCubit/users_state.dart';

class Users extends StatelessWidget {
  const Users({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Card(
        elevation: 0,
        child: SizedBox(
          height: 140,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'People',
                style: TextStyle(
                    fontWeight: FontWeight.w900,
                    fontSize: 15,
                    color: Color(0xFF9899A5)
                    // color: AppColors.textFaded,
                    ),
              ),
              Expanded(
                child: BlocConsumer<UsersCubit, UsersState>(
                  listener: (BuildContext context, state) {
                    if (state.status == UsersStatus.navigateToChat) {
                      Get.toNamed('/chat');
                    }
                  },
                  builder: (BuildContext context, state) {
                    switch (state.status) {
                      case UsersStatus.navigateToChat:
                        {
                          Get.toNamed('/chat');
                        }
                        break;
                      case UsersStatus.initial:
                        {
                          context.read<UsersCubit>().getUsers();
                        }
                        break;
                      case UsersStatus.loading:
                        {
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        }
                        break;
                      case UsersStatus.error:
                        {
                          return Center(child: Text(state.failure.errMessage));
                        }
                        break;
                      case UsersStatus.success:
                        {}
                        break;
                    }
                    return ListView.builder(
                        itemCount: state.users.length,
                        scrollDirection: Axis.horizontal,
                        itemBuilder: (BuildContext context, int index) {
                          return Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: SizedBox(
                                width: 60,
                                child: InkWell(
                                  onTap: () {
                                    if (context
                                            .read<UsersCubit>()
                                            .getCurrentUser()!
                                            .uid ==
                                        state.users[index]['userId']
                                            .toString()) {
                                      buildShowSnackBar(context,
                                          "You can't send message to yourself");
                                    } else {
                                      context
                                          .read<UsersCubit>()
                                          .usersClickListener(state.users[index]
                                                  ['userId']
                                              .toString());
                                    }
                                  },
                                  child: UsersCard(context
                                              .read<UsersCubit>()
                                              .getCurrentUser()!
                                              .uid ==
                                          state.users[index]['userId']
                                              .toString()
                                      ? "You"
                                      : state.users[index]['name'].toString()),
                                ),
                              ));
                        });
                  },
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
