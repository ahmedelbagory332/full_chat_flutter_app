import 'dart:async';
import 'dart:io';

import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_sound/public/flutter_sound_recorder.dart';
import 'package:full_chat_application/core/utils/app_utils.dart';
import 'package:full_chat_application/core/utils/failures.dart';
import 'package:mime/mime.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/notifications/notifications.dart';
import '../data/repo/chat_repo.dart';
import 'chat_state.dart';

class ChatCubit extends Cubit<ChatState> {
  ChatCubit(this.chatRepo, this.sharedPreferences, this.user)
      : super(ChatState.initial());

  final ChatRepo chatRepo;
  final FirebaseAuth user;
  final SharedPreferences sharedPreferences;

  final _recorder = FlutterSoundRecorder();

  void sendChatButtonChanged(bool value) {
    emit(state.copyWith(sendChatButton: value));
  }

  void isRecorderReadyChanged(bool value) {
    emit(state.copyWith(
      isRecorderReady: value,
    ));
  }

  void startVoiceMessageChanged(bool value) {
    emit(state.copyWith(
      startVoiceMessage: value,
    ));
  }

  void peerUserChanged() {
    getChatId(getPeerUserData()["userId"]);
    debugPrint("begoa state.peeredUser ${getPeerUserData()["userId"]}");
  }

  bool get startVoiceMessage => state.startVoiceMessage;
  bool get sendChatButton => state.sendChatButton;
  bool get isRecorderReady => state.isRecorderReady;
  QueryDocumentSnapshot<Map<String, dynamic>> get peerUserData =>
      state.peeredUser!;
  FlutterSoundRecorder get recorder => _recorder;

  Future record() async {
    if (!state.isRecorderReady) return;
    await recorder.startRecorder(toFile: "voice.mp4");
    recordTimer();
  }

  Future stop() async {
    startVoiceMessageChanged(false);
    String voiceMessageName = "${DateTime.now().toString()}.mp4";
    if (!isRecorderReady) return;
    final path = await recorder.stopRecorder();
    final audioFile = File(path!);
    getReferenceFromStorage(audioFile, voiceMessageName);
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
    startVoiceMessageChanged(true);
  }

  User? getCurrentUser() {
    return user.currentUser;
  }

  Map<String, dynamic> getPeerUserData() {
    return stringToMapList(sharedPreferences.getString("peerUserData")!)[0];
  }

  void updateUserStatus(userStatus, userId) async {
    var result = await chatRepo.updateUserStatus(userStatus, userId);
    result.fold((failure) {
      debugPrint("updateUserStatus ${failure.errMessage}");
    }, (success) {
      debugPrint("updateUserStatus ${success.toString()}");
    });
  }

  void updatePeerDevice(String status) async {
    var result = await chatRepo.updatePeerDevice(user.currentUser!.email,
        status == "0" ? "0" : getPeerUserData()["email"]);
    result.fold((failure) {
      debugPrint("bego updatePeerDevice failure: ${failure.errMessage}");
    }, (success) {
      debugPrint("bego updatePeerDevice success: ${success.data}");
    });
  }

  @override
  Future<void> close() {
    return super.close();
  }

  void getChatId(peerUserId) {
    emit(state.copyWith(
        chatId: user.currentUser!.uid.hashCode <= peerUserId.hashCode
            ? "${user.currentUser!.uid} - $peerUserId"
            : "$peerUserId - ${user.currentUser!.uid}"));
    debugPrint("begoa chat id ${state.chatId}");
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
        // //getMessages
        // getMessages();
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

  getPeeredUserStatus() {
    try {
      emit(state.copyWith(status: ChatStatus.gettingPeeredUser));

      FirebaseFirestore.instance
          .collection('users')
          .where('userId', isEqualTo: getPeerUserData()["userId"])
          .snapshots()
          .listen((event) {
        emit(state.copyWith(
            status: ChatStatus.peeredUser, peeredUser: event.docs[0]));
      });
    } catch (e) {
      debugPrint("ChatStatus.peeredUserError ${e.toString()}");

      emit(state.copyWith(
          failure: ServerFailure("An error occurred: ${e.toString()}"),
          status: ChatStatus.peeredUserError));
    }
  }

  void getMessages() {
    try {
      emit(state.copyWith(status: ChatStatus.gettingMessages));
      FirebaseFirestore.instance
          .collection('messages')
          .doc(state.chatId)
          .collection(state.chatId)
          .orderBy("msgTime", descending: true)
          .snapshots()
          .listen((event) {
        List<Map<String, dynamic>> list = [];
        for (var element in event.docs) {
          list.add(element.data());
        }
        emit(state.copyWith(status: ChatStatus.getMessages, messages: list));
      });
    } catch (error) {
      emit(state.copyWith(
          failure: ServerFailure("An error occurred: ${error.toString()}"),
          status: ChatStatus.getMessagesError));
    }
  }

  Future<void> getReferenceFromStorage(file, String voiceMessageName) async {
    var getReferenceFromStorage = await chatRepo.getReferenceFromStorage(
        file, state.chatId, voiceMessageName);
    getReferenceFromStorage.fold((failure) {
      debugPrint("bego getReferenceFromStorage failure: ${failure.errMessage}");
    }, (reference) {
      if (voiceMessageName.isNotEmpty) {
        uploadFile(voiceMessageName, "voice message", reference);
      } else {
        if (file.runtimeType == FilePickerResult) {
          /// user upload file from attach button
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
        } else {
          /// user take photo from camera
          uploadFile("", "image", reference);
        }
      }
    });
  }

  void uploadFile(String fileName, String fileType, UploadTask uploadTask) {
    debugPrint("bego uploadFile event: ${uploadTask.snapshot}");

    /// show notification to user
    uploadTask.snapshotEvents.listen((event) {
      debugPrint("bego snapshotEvents event: ${event.totalBytes}");

      uploadingNotification(fileType, getPeerUserData()["name"],
          event.totalBytes, event.bytesTransferred, true);
    });

    /// completed upload
    uploadTask.whenComplete(() => {
          /// show notification to user
          uploadingNotification(
              fileType, getPeerUserData()["name"], 0, 0, false),

          /// notify peer user
          notifyUser(getCurrentUser()!.displayName, "send to you $fileType",
              getPeerUserData()["email"], getCurrentUser()!.email),

          /// upload file url to fireStore
          uploadTask.then((fileUrl) {
            fileUrl.ref.getDownloadURL().then((value) {
              sendMessage(
                  chatId: state.chatId,
                  senderId: getCurrentUser()!.uid,
                  receiverId: getPeerUserData()["userId"],
                  receiverUsername: getPeerUserData()["name"],
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
      emit(state.copyWith(recordTimer: "$twoDigitsMinutes:$twoDigitsSecond"));
      debugPrint("begoa recordTimer ${state.recordTimer}");
    });
  }

  void notifyUserWithCall(
      body, notifyTo, peerUserId, peeredName, callType) async {
    var result = await chatRepo.notifyUserWithCall(
        body, notifyTo, peerUserId, peeredName, callType);
    result.fold((failure) {
      debugPrint("bego notifyUserWithCall failure: ${failure.errMessage}");
    }, (success) {
      debugPrint("bego notifyUserWithCall success: ${success.data}");
    });
  }
}
