import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../../core/utils/failures.dart';

enum UsersStatus { initial, loading, success, navigateToChat, error }

class UsersState {
  final UsersStatus status;
  final Failure failure;
  final List<QueryDocumentSnapshot<Map<String, dynamic>>> users;

  const UsersState({
    required this.status,
    required this.failure,
    required this.users,
  });

  factory UsersState.initial() {
    return const UsersState(
      status: UsersStatus.initial,
      failure: Failure(""),
      users: [],
    );
  }

  UsersState copyWith({
    UsersStatus? status,
    Failure? failure,
    List<QueryDocumentSnapshot<Map<String, dynamic>>>? users,
    List<QueryDocumentSnapshot<Map<String, dynamic>>>? lastMessages,
  }) {
    return UsersState(
      status: status ?? this.status,
      failure: failure ?? this.failure,
      users: users ?? this.users,
    );
  }
}
