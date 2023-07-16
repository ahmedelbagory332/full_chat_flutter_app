import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

import '../../../core/utils/failures.dart';

enum ChatStatus {
  initial,
  loading,
  gettingMessages,
  getMessages,
  getMessagesError,
  gettingPeeredUser,
  peeredUser,
  peeredUserError,
  unsupported
}

class ChatState {
  final ChatStatus status;
  final Failure failure;
  final QueryDocumentSnapshot<Map<String, dynamic>>? peeredUser;
  final List<Map<String, dynamic>>? messages;
  final bool sendChatButton;
  final bool isRecorderReady;
  final bool startVoiceMessage;
  final String chatId;
  final String recordTimer;
  final UploadTask? reference;
  const ChatState({
    required this.status,
    required this.failure,
    required this.peeredUser,
    required this.messages,
    required this.sendChatButton,
    required this.isRecorderReady,
    required this.startVoiceMessage,
    required this.chatId,
    required this.reference,
    required this.recordTimer,
  });

  factory ChatState.initial() {
    return const ChatState(
        status: ChatStatus.initial,
        peeredUser: null,
        messages: null,
        reference: null,
        sendChatButton: false,
        isRecorderReady: false,
        startVoiceMessage: false,
        chatId: "",
        recordTimer: "",
        failure: Failure(""));
  }

  ChatState copyWith({
    ChatStatus? status,
    QueryDocumentSnapshot<Map<String, dynamic>>? peeredUser,
    List<Map<String, dynamic>>? messages,
    bool? sendChatButton,
    bool? isRecorderReady,
    bool? startVoiceMessage,
    String? chatId,
    UploadTask? reference,
    String? recordTimer,
    Failure? failure,
  }) {
    return ChatState(
        status: status ?? this.status,
        peeredUser: peeredUser ?? this.peeredUser,
        messages: messages ?? this.messages,
        reference: reference ?? this.reference,
        sendChatButton: sendChatButton ?? this.sendChatButton,
        startVoiceMessage: startVoiceMessage ?? this.startVoiceMessage,
        isRecorderReady: isRecorderReady ?? this.isRecorderReady,
        chatId: chatId ?? this.chatId,
        recordTimer: recordTimer ?? this.recordTimer,
        failure: failure ?? this.failure);
  }
}
