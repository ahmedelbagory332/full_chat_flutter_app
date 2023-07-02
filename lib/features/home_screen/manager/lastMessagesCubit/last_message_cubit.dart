import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../data/repo/home_repo_impl.dart';
import 'last_message_state.dart';

class LastMessagesCubit extends Cubit<LastMessagesState> {
  LastMessagesCubit(this.homeRepo, this.user)
      : super(LastMessagesState.initial());

  final HomeRepoImpl homeRepo;
  final FirebaseAuth user;
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

  Future<void> recentChatClickListener(
      QueryDocumentSnapshot<Map<String, dynamic>> clickedUser) async {
    var user = await homeRepo.recentChatClickListener(clickedUser);
    user.fold((failure) {
      emit(state.copyWith(failure: failure, status: LastMessagesStatus.error));
    }, (peerUserData) async {
      emit(state.copyWith(
          status: LastMessagesStatus.navigateToChat,
          peerUserData: peerUserData));
    });
  }
}
