import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class MyProvider with ChangeNotifier {
  final FirebaseAuth auth = FirebaseAuth.instance;
  QueryDocumentSnapshot<Object?>? peerUserData;

  String getChatId(BuildContext context) {
    return Provider.of<MyProvider>(context, listen: false)
                .auth
                .currentUser!
                .uid
                .hashCode <=
            Provider.of<MyProvider>(context, listen: false)
                .peerUserData!["userId"]
                .hashCode
        ? "${Provider.of<MyProvider>(context, listen: false).auth.currentUser!.uid} - ${Provider.of<MyProvider>(context, listen: false).peerUserData!["userId"]}"
        : "${Provider.of<MyProvider>(context, listen: false).peerUserData!["userId"]} - ${Provider.of<MyProvider>(context, listen: false).auth.currentUser!.uid}";
  }
}
