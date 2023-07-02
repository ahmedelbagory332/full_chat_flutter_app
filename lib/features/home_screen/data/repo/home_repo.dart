import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';

import '../../../../core/utils/api_service.dart';
import '../../../../core/utils/failures.dart';

abstract class HomeRepo {
  Future<String?> getDeviceToken();

  void onTokenRefresh();

  Stream<Either<Failure, QuerySnapshot<Map<String, dynamic>>>> getAllUsers();

  Future<Either<Failure, ApiData>> updateUserToken(userEmail, userToken);

  Future<Either<Failure, QuerySnapshot<Map<String, dynamic>>>>
      usersClickListener(String userId);

  Stream<Either<Failure, QuerySnapshot<Map<String, dynamic>>>>
      getLastMessages();

  Future<Either<Failure, QuerySnapshot<Map<String, dynamic>>>>
      recentChatClickListener(
          QueryDocumentSnapshot<Map<String, dynamic>> clickedUser);
}
