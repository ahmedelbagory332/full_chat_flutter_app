import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';

import '../../../../core/utils/api_service.dart';
import '../../../../core/utils/failures.dart';
import 'chat_repo.dart';

class ChatRepoImpl implements ChatRepo {
  ChatRepoImpl(this.apiService, this.user);

  final ApiService apiService;
  final FirebaseAuth user;

  @override
  Future<Either<Failure, bool>> updateUserStatus(userStatus, userId) async {
    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .update({'userStatus': userStatus});
      return right(true);
    } catch (e) {
      return left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, bool>> sendMessage(
      {required chatId,
      required senderId,
      required receiverId,
      required msgTime,
      required msgType,
      required message,
      required fileName}) async {
    try {
      await FirebaseFirestore.instance
          .collection("messages")
          .doc(chatId)
          .collection(chatId)
          .doc("${Timestamp.now().millisecondsSinceEpoch}")
          .set({
        'chatId': chatId,
        'senderId': senderId,
        'receiverId': receiverId,
        'msgTime': msgTime,
        'msgType': msgType,
        'message': message,
        'fileName': fileName,
      });
      return right(true);
    } catch (e) {
      return left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, bool>> updateLastMessage(
      {required chatId,
      required senderId,
      required receiverId,
      required receiverUsername,
      required msgTime,
      required msgType,
      required message}) async {
    try {
      _lastMessageForPeerUser(receiverId, senderId, chatId, receiverUsername,
          msgTime, msgType, message);
      _lastMessageForCurrentUser(receiverId, senderId, chatId, receiverUsername,
          msgTime, msgType, message);
      return right(true);
    } catch (e) {
      return left(ServerFailure(e.toString()));
    }
  }

  void _lastMessageForCurrentUser(receiverId, senderId, chatId,
      receiverUsername, msgTime, msgType, message) {
    FirebaseFirestore.instance
        .collection("lastMessages")
        .doc(senderId)
        .collection(senderId)
        .where('chatId', isEqualTo: chatId)
        .get()
        .then((QuerySnapshot value) {
      if (value.size == 0) {
        FirebaseFirestore.instance
            .collection("lastMessages")
            .doc(senderId)
            .collection(senderId)
            .doc("${Timestamp.now().millisecondsSinceEpoch}")
            .set({
          'chatId': chatId,
          'messageFrom': user.currentUser!.displayName,
          'messageTo': receiverUsername,
          'messageSenderId': senderId,
          'messageReceiverId': receiverId,
          'msgTime': msgTime,
          'msgType': msgType,
          'message': message,
        });
      } else {
        FirebaseFirestore.instance
            .collection("lastMessages")
            .doc(senderId)
            .collection(senderId)
            .doc(value.docs[0].id)
            .update({
          'messageFrom': user.currentUser!.displayName,
          'messageTo': receiverUsername,
          'messageSenderId': senderId,
          'messageReceiverId': receiverId,
          'msgTime': msgTime,
          'msgType': msgType,
          'message': message,
        });
      }
    });
  }

  void _lastMessageForPeerUser(receiverId, senderId, chatId, receiverUsername,
      msgTime, msgType, message) {
    FirebaseFirestore.instance
        .collection("lastMessages")
        .doc(receiverId)
        .collection(receiverId)
        .where('chatId', isEqualTo: chatId)
        .get()
        .then((QuerySnapshot value) {
      if (value.size == 0) {
        FirebaseFirestore.instance
            .collection("lastMessages")
            .doc(receiverId)
            .collection(receiverId)
            .doc("${Timestamp.now().millisecondsSinceEpoch}")
            .set({
          'chatId': chatId,
          'messageFrom': user.currentUser!.displayName,
          'messageTo': receiverUsername,
          'messageSenderId': senderId,
          'messageReceiverId': receiverId,
          'msgTime': msgTime,
          'msgType': msgType,
          'message': message,
        });
      } else {
        FirebaseFirestore.instance
            .collection("lastMessages")
            .doc(receiverId)
            .collection(receiverId)
            .doc(value.docs[0].id)
            .update({
          'messageFrom': user.currentUser!.displayName,
          'messageTo': receiverUsername,
          'messageSenderId': senderId,
          'messageReceiverId': receiverId,
          'msgTime': msgTime,
          'msgType': msgType,
          'message': message,
        });
      }
    });
  }

  @override
  Future<Either<Failure, ApiData>> notifyUser(
      title, body, notifyTo, senderMail) async {
    try {
      var formData = FormData.fromMap({
        'title': title,
        'message': body,
        'email': notifyTo,
        'senderEmail': senderMail,
      });

      var response = await apiService.post(
          endPoint: 'bego/sendSinglePush.php', rawData: formData);

      if (response.success) {
        debugPrint("bego notifyUser: ${response.data}");
        return right(response);
      } else {
        debugPrint("bego notifyUser: ${response.errorMessage}");
        return left(ServerFailure(response.errorMessage));
      }
    } catch (e) {
      if (e is DioError) {
        debugPrint(
            "bego notifyUser DioError: ${ServerFailure.fromDioError(e)}");
        return left(ServerFailure.fromDioError(e));
      }
      debugPrint("bego notifyUser catch: ${e.toString()}");
      return left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, ApiData>> updatePeerDevice(userEmail, peerUser) async {
    try {
      final formData = FormData.fromMap({
        'email': userEmail,
        'isPeered': peerUser,
      });

      var response = await apiService.post(
          endPoint: 'bego/updatePeerDevice.php', rawData: formData);

      if (response.success) {
        debugPrint("bego updatePeerDevice: ${response.data}");
        return right(response);
      } else {
        debugPrint("bego updatePeerDevice: ${response.errorMessage}");
        return left(ServerFailure(response.errorMessage));
      }
    } catch (e) {
      if (e is DioError) {
        debugPrint(
            "bego updatePeerDevice DioError: ${ServerFailure.fromDioError(e)}");
        return left(ServerFailure.fromDioError(e));
      }
      debugPrint("bego updatePeerDevice catch: ${e.toString()}");
      return left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, UploadTask>> getReferenceFromStorage(
      file, chatId, voiceMessageName) async {
    try {
      FirebaseStorage storage = FirebaseStorage.instance;
      Reference ref =
          storage.ref().child("Media").child(chatId).child(file is File
              ? voiceMessageName
              : file.runtimeType == FilePickerResult
                  ? file!.files.single.name
                  : file!.name);
      return right(ref.putFile(file is File
          ? file
          : File(file.runtimeType == FilePickerResult
              ? file!.files.single.path
              : file.path)));
    } catch (e) {
      return left(ServerFailure("An error occurred: ${e.toString()}"));
    }
  }

  @override
  Future<Either<Failure, ApiData>> notifyUserWithCall(
      body, notifyTo, peerUserId, peeredName, callType) async {
    try {
      var formData = FormData.fromMap({
        'title': "",
        'message': body,
        'email': notifyTo,
        'peerUserId': peerUserId,
        'peeredEmail': notifyTo,
        'peeredName': peeredName,
        'callType': callType,
      });

      var response = await apiService.post(
          endPoint: 'bego/sendSinglePushForCalling.php', rawData: formData);

      if (response.success) {
        debugPrint("bego notifyUserWithCall: ${response.data}");
        return right(response);
      } else {
        debugPrint("bego notifyUserWithCall: ${response.errorMessage}");
        return left(ServerFailure(response.errorMessage));
      }
    } catch (e) {
      if (e is DioError) {
        debugPrint(
            "bego notifyUserWithCall DioError: ${ServerFailure.fromDioError(e)}");
        return left(ServerFailure.fromDioError(e));
      }
      debugPrint("bego notifyUserWithCall catch: ${e.toString()}");
      return left(ServerFailure(e.toString()));
    }
  }
}
