import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../../../core/utils/failures.dart';
import '../../data/repo/home_repo_impl.dart';
import 'users_state.dart';

class UsersCubit extends Cubit<UsersState> {
  UsersCubit(this.homeRepo, this.user) : super(UsersState.initial());

  final HomeRepoImpl homeRepo;
  final FirebaseAuth user;
  late StreamSubscription _usersSubscription;

  User? getCurrentUser() {
    return user.currentUser;
  }

  QuerySnapshot<Map<String, dynamic>>? get peerUserData => state.peerUserData;

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
        emit(state.copyWith(
            status: UsersStatus.navigateToChat, peerUserData: value));
      });
    } catch (e) {
      emit(state.copyWith(
          failure: ServerFailure("An error occurred: $e"),
          status: UsersStatus.error));
    }
  }
}
