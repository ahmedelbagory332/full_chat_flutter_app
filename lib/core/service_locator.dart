import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:full_chat_application/core/utils/api_service.dart';
import 'package:full_chat_application/features/register/data/repo/sign_up_repo_impl.dart';
import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../features/chat_screen/data/repo/chat_repo_impl.dart';
import '../features/home_screen/data/repo/home_repo_impl.dart';
import '../features/logIn/data/repo/sign_in_repo_impl.dart';

final getIt = GetIt.instance;

Future<void> setupServiceLocator() async {
  await _initSharedPref();

  getIt.registerSingleton<ApiService>(ApiService(Dio()));

  getIt.registerLazySingleton(() => FirebaseAuth.instance);
  getIt.registerLazySingleton(() => SignUpRepoImpl(
        getIt.get<ApiService>(),
        getIt.get<FirebaseAuth>(),
      ));

  getIt.registerLazySingleton(() => SignInRepoImpl(getIt.get<FirebaseAuth>()));

  getIt.registerLazySingleton(() => HomeRepoImpl(
        getIt.get<ApiService>(),
        getIt.get<FirebaseAuth>(),
      ));

  getIt.registerLazySingleton(() => ChatRepoImpl(
        getIt.get<ApiService>(),
        getIt.get<FirebaseAuth>(),
      ));
}

Future<void> _initSharedPref() async {
  final SharedPreferences sharedPref = await SharedPreferences.getInstance();
  getIt.registerSingleton<SharedPreferences>(sharedPref);
}
