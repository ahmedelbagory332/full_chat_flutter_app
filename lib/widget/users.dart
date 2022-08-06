import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:full_chat_application/firebase_helper/model/notification_messages.dart';
import 'package:full_chat_application/provider/my_provider.dart';
import 'package:full_chat_application/firebase_helper/fireBaseHelper.dart';
import 'package:full_chat_application/widget/users_card.dart';
import 'package:provider/provider.dart';

import '../Utils.dart';

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
            crossAxisAlignment: CrossAxisAlignment.start,
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
                child: StreamBuilder(
                    stream: FirebaseFirestore.instance.collection('users').snapshots(),
                    builder: (BuildContext context,
                        AsyncSnapshot<QuerySnapshot> snapshot) {
                      if (snapshot.hasError) {
                        return const Text('Something went wrong');
                      }

                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(
                          child: CircularProgressIndicator(),
                        );
                      }
                      return ListView.builder(
                          itemCount: snapshot.data!.docs.length,
                          scrollDirection: Axis.horizontal,
                          itemBuilder: (BuildContext context, int index) {
                            return Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: SizedBox(
                                  width: 60,
                                  child: InkWell(
                                    onTap: (){
                                      if(Provider.of<MyProvider>(context,listen: false).auth.currentUser!.uid
                                          == snapshot.data!.docs[index]['userId'].toString()){
                                        buildShowSnackBar(context, "You can't send message to yourself");
                                      } else {
                                        Provider.of<MyProvider>(context,listen: false)
                                            .usersClickListener(snapshot, index, context);
                                      }
                                    },
                                    child: UsersCard(
                                        Provider.of<MyProvider>(context, listen: false).auth.currentUser!.uid ==
                                            snapshot.data!.docs[index]['userId'].toString() ?
                                            "You" : snapshot.data!.docs[index]['name'].toString()),
                                  ),
                                )
                            );
                          });
                    }),
              )
            ],
          ),
        ),
      ),
    );
  }

}
