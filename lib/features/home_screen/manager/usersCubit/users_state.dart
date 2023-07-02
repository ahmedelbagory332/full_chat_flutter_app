import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../../core/utils/failures.dart';

enum UsersStatus { initial, loading, success, navigateToChat, error }

class UsersState {
  final UsersStatus status;
  final Failure failure;
  final List<QueryDocumentSnapshot<Map<String, dynamic>>> users;
  final QuerySnapshot<Map<String, dynamic>>? peerUserData;

  const UsersState({
    required this.status,
    required this.failure,
    required this.users,
    required this.peerUserData,
  });

  factory UsersState.initial() {
    return const UsersState(
      status: UsersStatus.initial,
      failure: Failure(""),
      users: [],
      peerUserData: null,
    );
  }

  UsersState copyWith(
      {UsersStatus? status,
      Failure? failure,
      List<QueryDocumentSnapshot<Map<String, dynamic>>>? users,
      List<QueryDocumentSnapshot<Map<String, dynamic>>>? lastMessages,
      QuerySnapshot<Map<String, dynamic>>? peerUserData}) {
    return UsersState(
      status: status ?? this.status,
      failure: failure ?? this.failure,
      users: users ?? this.users,
      peerUserData: peerUserData ?? this.peerUserData,
    );
  }
}
