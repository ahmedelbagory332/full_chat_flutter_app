import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/utils/app_utils.dart';
import '../../../../core/utils/failures.dart';
import '../../data/repo/home_repo.dart';
import 'users_state.dart';

class UsersCubit extends Cubit<UsersState> {
  UsersCubit(this.homeRepo, this.sharedPreferences, this.user)
      : super(UsersState.initial());

  final HomeRepo homeRepo;
  final FirebaseAuth user;
  final SharedPreferences sharedPreferences;

  late StreamSubscription _usersSubscription;

  User? getCurrentUser() {
    return user.currentUser;
  }

  void getUsers() {
    emit(state.copyWith(status: UsersStatus.loading));
    _usersSubscription = homeRepo.getAllUsers().listen((either) {
      either.fold(
        (error) =>
            emit(state.copyWith(failure: error, status: UsersStatus.error)),
        (users) => emit(
            state.copyWith(status: UsersStatus.success, users: users.docs)),
      );
    });
  }

  @override
  Future<void> close() {
    _usersSubscription.cancel();
    return super.close();
  }

  void usersClickListener(String userId) {
    try {
      FirebaseFirestore.instance
          .collection('users')
          .where('userId', isEqualTo: userId)
          .get()
          .then((value) {
        debugPrint("bego usersClickListener1: ${value}");
        debugPrint(
            "bego usersClickListener2: ${convertQuerySnapshotToList(value)}");
        debugPrint(
            "bego usersClickListener3: ${mapListToString(convertQuerySnapshotToList(value))}");

        sharedPreferences.setString(
            "peerUserData", mapListToString(convertQuerySnapshotToList(value)));
        emit(state.copyWith(status: UsersStatus.navigateToChat));
      });
    } catch (e) {
      emit(state.copyWith(
          failure: ServerFailure("An error occurred: $e"),
          status: UsersStatus.error));
    }
  }
}
