import 'package:dartz/dartz.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../../../core/utils/failures.dart';

abstract class SignInRepo {
  Future<Either<Failure, UserCredential>> signIn(
      {required String email, required String password});
}
