import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:full_chat_application/core/utils/app_utils.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/utils/failures.dart';
import '../../data/repo/home_repo.dart';
import 'last_message_state.dart';

class LastMessagesCubit extends Cubit<LastMessagesState> {
  LastMessagesCubit(this.homeRepo, this.sharedPreferences, this.user)
      : super(LastMessagesState.initial());

  final HomeRepo homeRepo;
  final FirebaseAuth user;
  final SharedPreferences sharedPreferences;

  late StreamSubscription _lastMessagesSubscription;

  User? getCurrentUser() {
    return user.currentUser;
  }

  @override
  Future<void> close() {
    _lastMessagesSubscription.cancel();
    return super.close();
  }

  void getLastMessages() {
    emit(state.copyWith(status: LastMessagesStatus.loading));
    _lastMessagesSubscription = homeRepo.getLastMessages().listen((either) {
      either.fold(
        (error) => emit(
            state.copyWith(failure: error, status: LastMessagesStatus.error)),
        (lastMessages) => emit(state.copyWith(
            status: LastMessagesStatus.success,
            lastMessages: lastMessages.docs)),
      );
    });
  }

  recentChatClickListener(
      QueryDocumentSnapshot<Map<String, dynamic>> clickedUser) {
    if (clickedUser['messageSenderId'].toString() == user.currentUser!.uid) {
      try {
        FirebaseFirestore.instance
            .collection('users')
            .where('userId',
                isEqualTo: clickedUser['messageReceiverId'].toString())
            .get()
            .then((value) {
          sharedPreferences.setString("peerUserData",
              mapListToString(convertQuerySnapshotToList(value)));
          emit(state.copyWith(status: LastMessagesStatus.navigateToChat));
        });
      } catch (e) {
        emit(state.copyWith(
            failure: ServerFailure("An error occurred: $e"),
            status: LastMessagesStatus.error));
      }
    } else {
      try {
        FirebaseFirestore.instance
            .collection('users')
            .where('userId',
                isEqualTo: clickedUser['messageSenderId'].toString())
            .get()
            .then((value) {
          sharedPreferences.setString("peerUserData",
              mapListToString(convertQuerySnapshotToList(value)));
          emit(state.copyWith(status: LastMessagesStatus.navigateToChat));
        });
      } catch (e) {
        emit(state.copyWith(
            failure: ServerFailure("An error occurred: $e"),
            status: LastMessagesStatus.error));
      }
    }
  }
}
