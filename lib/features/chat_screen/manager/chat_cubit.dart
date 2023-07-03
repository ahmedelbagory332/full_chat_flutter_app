import 'dart:async';
import 'dart:io';

import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_sound/public/flutter_sound_recorder.dart';
import 'package:full_chat_application/core/utils/failures.dart';
import 'package:full_chat_application/notifications/notifications.dart';
import 'package:mime/mime.dart';

import '../data/repo/chat_repo_impl.dart';
import 'chat_state.dart';

class ChatCubit extends Cubit<ChatState> {
  ChatCubit(this.peerUserData, this.chatRepo, this.user)
      : super(ChatState.initial()) {
    chatIdChanged(getChatId(peerUserData["userId"]));
  }

  final ChatRepoImpl chatRepo;
  final FirebaseAuth user;
  final QueryDocumentSnapshot<Map<String, dynamic>> peerUserData;
  late StreamSubscription _peeredUserStatusSubscription;
  late StreamSubscription _getMessagesSubscription;
  final _recorder = FlutterSoundRecorder();

  void sendChatButtonChanged(bool value) {
    emit(state.copyWith(sendChatButton: value));
  }

  void isRecorderReadyChanged(bool value) {
    emit(state.copyWith(isRecorderReady: value));
  }

  void startVoiceMessageChanged(bool value) {
    emit(state.copyWith(startVoiceMessage: value));
  }

  void chatIdChanged(String value) {
    emit(state.copyWith(chatId: value, status: ChatStatus.initial));
  }

  bool get startVoiceMessage => state.startVoiceMessage;
  bool get sendChatButton => state.sendChatButton;
  bool get isRecorderReady => state.isRecorderReady;
  FlutterSoundRecorder get recorder => _recorder;

  Future record() async {
    if (!state.isRecorderReady) return;
    await recorder.startRecorder(toFile: "voice.mp4");
  }

  Future stop() async {
    String voiceMessageName = "${DateTime.now().toString()}.mp4";
    if (!isRecorderReady) return;
    final path = await recorder.stopRecorder();
    final audioFile = File(path!);
    getReferenceFromStorage(audioFile, voiceMessageName);
    uploadFile(voiceMessageName, "voice message", state.reference!);
  }

  void cancelRecord() {
    sendChatButtonChanged(false);
    isRecorderReadyChanged(false);
    startVoiceMessageChanged(false);
    recorder.closeRecorder();
  }

  Future<void> initRecording() async {
    await recorder.openRecorder();
    isRecorderReadyChanged(true);
    recorder.setSubscriptionDuration(const Duration(milliseconds: 500));
  }

  User? getCurrentUser() {
    return user.currentUser;
  }

  void updateUserStatus(userStatus, userId) async {
    var result = await chatRepo.updateUserStatus(userStatus, userId);
    result.fold((failure) {
      debugPrint("updateUserStatus ${failure.errMessage}");
    }, (success) {
      debugPrint("updateUserStatus ${success.toString()}");
    });
  }

  void updatePeerDevice(peerUser) async {
    var result =
        await chatRepo.updatePeerDevice(user.currentUser!.email, peerUser);
    result.fold((failure) {
      debugPrint("bego updatePeerDevice failure: ${failure.errMessage}");
    }, (success) {
      debugPrint("bego updatePeerDevice success: ${success.data}");
    });
  }

  @override
  Future<void> close() {
    _peeredUserStatusSubscription.cancel();
    _getMessagesSubscription.cancel();
    return super.close();
  }

  String getChatId(peerUserId) {
    return user.currentUser!.uid.hashCode <= peerUserId.hashCode
        ? "${user.currentUser!.uid} - $peerUserId"
        : "$peerUserId - ${user.currentUser!.uid}";
  }

  Future<void> sendMessage(
      {required chatId,
      required senderId,
      required receiverId,
      required receiverUsername,
      required msgTime,
      required msgType,
      required message,
      required fileName}) async {
    var result = await chatRepo.sendMessage(
        chatId: chatId,
        senderId: senderId,
        receiverId: receiverId,
        msgTime: msgTime,
        msgType: msgType,
        message: message,
        fileName: fileName);
    result.fold((failure) {
      debugPrint("bego sendMessage failure: ${failure.errMessage}");
    }, (success) async {
      debugPrint("bego sendMessage success: $success");
      //updateLastMessage
      var result = await chatRepo.updateLastMessage(
          chatId: chatId,
          senderId: senderId,
          receiverId: receiverId,
          receiverUsername: receiverUsername,
          msgTime: msgTime,
          msgType: msgType,
          message: message);
      result.fold((failure) {
        debugPrint("bego updateLastMessage failure: ${failure.errMessage}");
      }, (success) {
        debugPrint("bego updateLastMessage success: $success");
        //getMessages
        getMessages();
      });
    });
  }

  void notifyUser(title, body, notifyTo, senderMail) async {
    var result = await chatRepo.notifyUser(title, body, notifyTo, senderMail);
    result.fold((failure) {
      debugPrint("bego notifyUser failure: ${failure.errMessage}");
    }, (success) {
      debugPrint("bego notifyUser success: ${success.data}");
    });
  }

  getPeeredUserStatus(userId) {
    try {
      emit(state.copyWith(
          status: ChatStatus.gettingPeeredUser, peeredUser: peerUserData));

      FirebaseFirestore.instance
          .collection('users')
          .where('userId', isEqualTo: userId)
          .snapshots()
          .listen((event) {
        emit(state.copyWith(
            status: ChatStatus.peeredUser, peeredUser: event.docs[0]));
      });
    } catch (e) {
      emit(state.copyWith(
          failure: ServerFailure("An error occurred: ${e.toString()}"),
          status: ChatStatus.peeredUserError));
    }
  }

  getMessages() {
    try {
      FirebaseFirestore.instance
          .collection('messages')
          .doc(state.chatId)
          .collection(state.chatId)
          .orderBy("msgTime", descending: true)
          .snapshots()
          .listen((event) {
        emit(state.copyWith(status: ChatStatus.getMessages, messages: event));
        debugPrint("bego getMessages success: ${event.docs.length}");
      });
    } catch (error) {
      emit(state.copyWith(
          failure: ServerFailure("An error occurred: ${error.toString()}"),
          status: ChatStatus.getMessagesError));
      debugPrint("bego getMessages error: $error");
    }
  }

  void getReferenceFromStorage(file, voiceMessageName) async {
    var getReferenceFromStorage = await chatRepo.getReferenceFromStorage(
        file, state.chatId, voiceMessageName);
    getReferenceFromStorage.fold((failure) {
      debugPrint("bego getReferenceFromStorage failure: ${failure.errMessage}");
    }, (reference) {
      state.copyWith(reference: reference);
      if (lookupMimeType(file.files.single.path.toString())!
          .contains("video")) {
        uploadFile("", "video", reference);
      } else if (lookupMimeType(file.files.single.path.toString())!
          .contains("application")) {
        uploadFile(file.files.single.name, "document", reference);
      } else if (lookupMimeType(file.files.single.path.toString())!
          .contains("image")) {
        uploadFile("", "image", reference);
      } else if (lookupMimeType(file.files.single.path.toString())!
          .contains("audio")) {
        uploadFile(file.files.single.name, "audio", reference);
      } else {
        state.copyWith(status: ChatStatus.unsupported);
      }
    });
  }

  void uploadFile(String fileName, String fileType, UploadTask uploadTask) {
    /// show notification to user
    uploadTask.snapshotEvents.listen((event) {
      uploadingNotification(fileType, peerUserData["name"], event.totalBytes,
          event.bytesTransferred, true);
    });

    /// completed upload
    uploadTask.whenComplete(() => {
          /// show notification to user
          uploadingNotification(fileType, peerUserData["name"], 0, 0, false),

          /// notify peer user
          notifyUser(getCurrentUser()!.displayName, "send to you $fileType",
              peerUserData["email"], getCurrentUser()!.email),

          /// upload file url to fireStore
          uploadTask.then((fileUrl) {
            fileUrl.ref.getDownloadURL().then((value) {
              sendMessage(
                  chatId: state.chatId,
                  senderId: getCurrentUser()!.uid,
                  receiverId: peerUserData["userId"],
                  receiverUsername: peerUserData["name"],
                  msgTime: FieldValue.serverTimestamp(),
                  msgType: fileType,
                  message: value,
                  fileName: (fileType == "document") ||
                          (fileType == "audio") ||
                          (fileType == "voice message")
                      ? fileName
                      : "");
            });
          })
        });
  }

  void recordTimer() {
    recorder.onProgress!.listen((event) {
      final duration = event.duration;
      String twoDigits(int n) => n.toString().padLeft(2, '0');
      final twoDigitsMinutes = twoDigits(duration.inMinutes.remainder(60));
      final twoDigitsSecond = twoDigits(duration.inSeconds.remainder(60));
      state.copyWith(recordTimer: "$twoDigitsMinutes:$twoDigitsSecond");
    });
  }
}
