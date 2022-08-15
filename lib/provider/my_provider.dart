import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../screens/chat_screen.dart';

class MyProvider with ChangeNotifier {
  final FirebaseAuth auth = FirebaseAuth.instance;
  QueryDocumentSnapshot<Object?>? peerUserData;



  void usersClickListener(AsyncSnapshot<QuerySnapshot<Object?>> snapshot, int index, BuildContext context){
    FirebaseFirestore.instance
        .collection('users')
        .where('userId',
        isEqualTo: snapshot.data!.docs[index]['userId'].toString())
        .get()
        .then((QuerySnapshot value) {
      peerUserData = value.docs[0];
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const ChatScreen(),
        ),
      );
    });
    notifyListeners();
  }

  void recentChatClickListener(AsyncSnapshot<QuerySnapshot<Object?>> snapshot, int index, BuildContext context){
    if(snapshot.data!.docs[index]['messageSenderId'].toString() ==
        Provider.of<MyProvider>(context, listen: false).auth.currentUser!.uid){
      FirebaseFirestore.instance
          .collection('users')
          .where('userId',
          isEqualTo: snapshot.data!.docs[index]['messageReceiverId'].toString())
          .get()
          .then((QuerySnapshot value) {
        peerUserData = value.docs[0];
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const ChatScreen(),
          ),
        );
      });
      notifyListeners();
    }else{
      FirebaseFirestore.instance
          .collection('users')
          .where('userId',
          isEqualTo: snapshot.data!.docs[index]['messageSenderId'].toString())
          .get()
          .then((QuerySnapshot value) {
        peerUserData = value.docs[0];
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const ChatScreen(),
          ),
        );
      });
      notifyListeners();
    }

  }



  String getChatId(BuildContext context){
    return Provider.of<MyProvider>(context,listen: false).auth.currentUser!.uid.hashCode <=
        Provider.of<MyProvider>(context,listen: false).peerUserData!["userId"].hashCode ?
    "${Provider.of<MyProvider>(context,listen: false).auth.currentUser!.uid} - ${Provider.of<MyProvider>(context,listen: false).peerUserData!["userId"]}" :
    "${Provider.of<MyProvider>(context,listen: false).peerUserData!["userId"]} - ${Provider.of<MyProvider>(context,listen: false).auth.currentUser!.uid}";
  }




}
