import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../../core/utils/failures.dart';

enum LastMessagesStatus { initial, loading, success, navigateToChat, error }

class LastMessagesState {
  final LastMessagesStatus status;
  final Failure failure;
  final List<QueryDocumentSnapshot<Map<String, dynamic>>> lastMessages;

  const LastMessagesState({
    required this.status,
    required this.failure,
    required this.lastMessages,
  });

  factory LastMessagesState.initial() {
    return const LastMessagesState(
      status: LastMessagesStatus.initial,
      failure: Failure(""),
      lastMessages: [],
    );
  }

  LastMessagesState copyWith({
    LastMessagesStatus? status,
    Failure? failure,
    List<QueryDocumentSnapshot<Map<String, dynamic>>>? lastMessages,
  }) {
    return LastMessagesState(
      status: status ?? this.status,
      failure: failure ?? this.failure,
      lastMessages: lastMessages ?? this.lastMessages,
    );
  }
}
