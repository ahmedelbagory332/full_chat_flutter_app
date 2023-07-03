import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

import '../../../../core/utils/api_service.dart';
import '../../../../core/utils/failures.dart';
import 'home_repo.dart';

class HomeRepoImpl implements HomeRepo {
  HomeRepoImpl(this.apiService, this.user);
  final ApiService apiService;
  final FirebaseAuth user;

  @override
  Future<String?> getDeviceToken() async {
    return await FirebaseMessaging.instance.getToken();
  }

  @override
  void onTokenRefresh() {
    FirebaseMessaging.instance.onTokenRefresh.listen((fcmToken) {
      updateUserToken(user.currentUser!.email, fcmToken);
    }).onError((err) {});
  }

  @override
  Future<Either<Failure, ApiData>> updateUserToken(userEmail, userToken) async {
    try {
      final formData = FormData.fromMap({
        'email': userEmail,
        'token': userToken,
      });

      var response = await apiService.post(
          endPoint: 'bego/updatePeerDevice.php', rawData: formData);

      if (response.success) {
        return right(response);
      } else {
        return left(ServerFailure(response.errorMessage));
      }
    } catch (e) {
      if (e is DioError) {
        return left(ServerFailure.fromDioError(e));
      }
      return left(ServerFailure(e.toString()));
    }
  }

  @override
  Stream<Either<Failure, QuerySnapshot<Map<String, dynamic>>>>
      getAllUsers() async* {
    try {
      yield* FirebaseFirestore.instance
          .collection('users')
          .snapshots()
          .map((users) => right(users));
    } catch (e) {
      yield left(ServerFailure("An error occurred: ${e.toString()}"));
    }
  }

  @override
  Stream<Either<Failure, QuerySnapshot<Map<String, dynamic>>>>
      getLastMessages() async* {
    try {
      yield* FirebaseFirestore.instance
          .collection('lastMessages')
          .doc(user.currentUser!.uid)
          .collection(user.currentUser!.uid)
          .orderBy("msgTime", descending: true)
          .snapshots()
          .map((messages) => right(messages));
    } catch (e) {
      yield left(ServerFailure("An error occurred: ${e.toString()}"));
    }
  }
}
