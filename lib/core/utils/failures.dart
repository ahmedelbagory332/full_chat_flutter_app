import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';

class Failure {
  final String errMessage;

  const Failure(this.errMessage);
}

class ServerFailure extends Failure {
  ServerFailure(super.errMessage);

  factory ServerFailure.fromDioError(DioError dioError) {
    switch (dioError.type) {
      case DioErrorType.connectTimeout:
        return ServerFailure('Connection timeout with ApiServer');

      case DioErrorType.sendTimeout:
        return ServerFailure('Send timeout with ApiServer');

      case DioErrorType.receiveTimeout:
        return ServerFailure('Receive timeout with ApiServer');

      case DioErrorType.response:
        return ServerFailure.fromResponse(
            dioError.response!.statusCode, dioError.response!.data);
      case DioErrorType.cancel:
        return ServerFailure('Request to ApiServer was canceld');

      case DioErrorType.other:
        if (dioError.message.contains('SocketException')) {
          return ServerFailure('No Internet Connection');
        }
        return ServerFailure('Unexpected Error, Please try again!');
      default:
        return ServerFailure('Opps There was an Error, Please try again');
    }
  }

  factory ServerFailure.fromResponse(int? statusCode, dynamic response) {
    if (statusCode == 400 || statusCode == 401 || statusCode == 403) {
      return ServerFailure(response['error']['message']);
    } else if (statusCode == 404) {
      return ServerFailure('Your request not found, Please try later!');
    } else if (statusCode == 500) {
      return ServerFailure('Internal Server error, Please try later');
    } else {
      return ServerFailure('Opps There was an Error, Please try again');
    }
  }

  factory ServerFailure.fromFireBase(FirebaseAuthException e) {
    if (e.code == 'invalid-email') {
      return ServerFailure(
          'Invalid email. Please enter a valid email address.');
    } else if (e.code == 'user-disabled') {
      return ServerFailure('User account has been disabled.');
    } else if (e.code == 'user-not-found') {
      return ServerFailure(
          'User not found. Please check your email and try again.');
    } else if (e.code == 'wrong-password') {
      return ServerFailure(
          'Wrong password. Please check your password and try again.');
    } else if (e.code == 'email-already-in-use') {
      return ServerFailure(
          'Email already in use. Please use a different email address.');
    } else if (e.code == 'weak-password') {
      return ServerFailure(
          'Password is not strong enough. Please choose a stronger password.');
    } else if (e.code == 'operation-not-allowed') {
      return ServerFailure(
          'Email/password accounts are not enabled. Please enable email/password accounts in the Firebase Console.');
    } else if (e.code == 'invalid-credential') {
      return ServerFailure('Invalid credential. Please try again.');
    } else if (e.code == 'account-exists-with-different-credential') {
      return ServerFailure(
          'Account already exists with a different credential. Please sign in using that provider.');
    } else if (e.code == 'invalid-verification-code') {
      return ServerFailure(
          'Invalid verification code. Please check the code and try again.');
    } else if (e.code == 'invalid-verification-id') {
      return ServerFailure('Invalid verification ID. Please try again.');
    } else if (e.code == 'invalid-recipient') {
      return ServerFailure(
          'Invalid phone number. Please enter a valid phone number.');
    } else if (e.code == 'quota-exceeded') {
      return ServerFailure('Quota exceeded. Please try again later.');
    } else if (e.code == 'missing-phone-number') {
      return ServerFailure(
          'Phone number is missing. Please enter a valid phone number.');
    } else if (e.code == 'provider-already-linked') {
      return ServerFailure('Provider is already linked to the user account.');
    } else if (e.code == 'network-request-failed') {
      return ServerFailure(
          'Network request failed. Please check your internet connection and try again.');
    } else {
      return ServerFailure('Oops! There was an error. Please try again later.');
    }
  }
}
