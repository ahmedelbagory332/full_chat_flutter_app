import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';

import '../../../../core/utils/api_service.dart';
import '../../../../core/utils/failures.dart';
import 'sign_up_repo.dart';

class SignUpRepoImpl implements SignUpRepo {
  final ApiService apiService;
  final FirebaseAuth user;

  SignUpRepoImpl(this.apiService, this.user);

  @override
  Future<Either<Failure, UserCredential>> signUp(
      {required String email,
      required String name,
      required String password}) async {
    try {
      var createUser = await user.createUserWithEmailAndPassword(
          email: email, password: password);
      createUser.user!.updateDisplayName(name.trim().toString());
      addNewUser(createUser.user!.uid, name, email, "Online", "");
      return right(createUser);
    } catch (e) {
      if (e is FirebaseAuthException) {
        return left(ServerFailure.fromFireBase(e));
      }
      return left(ServerFailure(e.toString()));
    }
  }

  @override
  void addNewUser(userId, name, email, userStatus, chatWith) {
    FirebaseFirestore.instance.collection('users').doc(userId).set({
      'name': name,
      'email': email,
      'userId': userId,
      'userStatus': userStatus,
      'chatWith': chatWith,
    });
  }

  @override
  Future<String?> getDeviceToken() async {
    return await FirebaseMessaging.instance.getToken();
  }

  @override
  Future<Either<Failure, ApiData>> registerDevice(
      String userEmail, String userToken) async {
    try {
      final formData = FormData.fromMap({
        'email': userEmail,
        'token': userToken,
      });

      var response = await apiService.post(
          endPoint: 'bego/RegisterDevice.php', rawData: formData);

      if (response.success) {
        debugPrint("bego SignUpRepoImpl registerDevice: ${response}");
        return right(response);
      } else {
        debugPrint(
            "bego SignUpRepoImpl registerDevice: ${response.errorMessage}");
        return left(ServerFailure(response.errorMessage));
      }
    } catch (e) {
      if (e is DioError) {
        debugPrint(
            "bego SignUpRepoImpl registerDevice DioError: ${ServerFailure.fromDioError(e)}");
        return left(ServerFailure.fromDioError(e));
      }
      debugPrint("bego SignUpRepoImpl registerDevice catch: ${e.toString()}");
      return left(ServerFailure(e.toString()));
    }
  }
}
