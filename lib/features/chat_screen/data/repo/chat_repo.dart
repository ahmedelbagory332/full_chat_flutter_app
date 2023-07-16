import 'package:dartz/dartz.dart';
import 'package:firebase_storage/firebase_storage.dart';

import '../../../../core/utils/api_service.dart';
import '../../../../core/utils/failures.dart';

abstract class ChatRepo {
  Future<Either<Failure, bool>> updateUserStatus(userStatus, userId);

  Future<Either<Failure, bool>> sendMessage(
      {required chatId,
      required senderId,
      required receiverId,
      required msgTime,
      required msgType,
      required message,
      required fileName});

  Future<Either<Failure, bool>> updateLastMessage(
      {required chatId,
      required senderId,
      required receiverId,
      required receiverUsername,
      required msgTime,
      required msgType,
      required message});

  Future<Either<Failure, ApiData>> updatePeerDevice(userEmail, peerUser);

  Future<Either<Failure, ApiData>> notifyUser(
      title, body, notifyTo, senderMail);

  Future<Either<Failure, UploadTask>> getReferenceFromStorage(
      file, chatId, voiceMessageName);

  Future<Either<Failure, ApiData>> notifyUserWithCall(
      body, notifyTo, peerUserId, peeredName, callType);
}
