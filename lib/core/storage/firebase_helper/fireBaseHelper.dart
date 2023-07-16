import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../features/chat_screen/manager/chat_cubit.dart';

class FireBaseHelper {
  void updateCallStatus(BuildContext context, status) {
    FirebaseFirestore.instance
        .collection("users")
        .doc(context.read<ChatCubit>().getCurrentUser()!.uid)
        .update({"chatWith": status});
  }
}
