import 'package:dartz/dartz.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../../../core/utils/failures.dart';
import 'sign_in_repo.dart';

class SignInRepoImpl implements SignInRepo {
  SignInRepoImpl(this.user);
  final FirebaseAuth user;

  @override
  Future<Either<Failure, UserCredential>> signIn(
      {required String email, required String password}) async {
    try {
      var currentUser = await user.signInWithEmailAndPassword(
          email: email, password: password);
      return right(currentUser);
    } catch (e) {
      if (e is FirebaseAuthException) {
        return left(ServerFailure.fromFireBase(e));
      }
      return left(ServerFailure(e.toString()));
    }
  }
}
