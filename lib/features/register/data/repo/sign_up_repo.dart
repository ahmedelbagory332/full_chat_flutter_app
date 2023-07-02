import 'package:dartz/dartz.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../../../core/utils/api_service.dart';
import '../../../../core/utils/failures.dart';

abstract class SignUpRepo {
  Future<Either<Failure, UserCredential>> signUp(
      {required String email, required String name, required String password});

  void addNewUser(userId, name, email, userStatus, chatWith);

  Future<String?> getDeviceToken();

  Future<Either<Failure, ApiData>> registerDevice(
      String userEmail, String userToken);
}
