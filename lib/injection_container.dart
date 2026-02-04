import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get_it/get_it.dart';
import 'package:http/http.dart' as http;
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:local_auth/local_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'core/constants/app_constants.dart';
import 'core/network/api_client.dart';
import 'core/network/network_info.dart';
import 'core/security/biometric_auth.dart';
import 'core/security/encryption_service.dart';
import 'core/security/secure_storage.dart';
import 'core/services/tflite_service.dart';
import 'core/utils/bloc_observer.dart';
import 'features/auth/data/datasources/auth_local_datasource.dart';
import 'features/auth/data/datasources/auth_remote_datasource.dart';
import 'features/auth/data/repositories/auth_repository_impl.dart';
import 'features/auth/domain/repositories/auth_repository.dart';
import 'features/auth/domain/usecases/get_current_user.dart';
import 'features/auth/domain/usecases/login_usecase.dart';
import 'features/auth/domain/usecases/logout_usecase.dart';
import 'features/auth/domain/usecases/register_usecase.dart';
import 'features/auth/presentation/bloc/auth_bloc.dart';
import 'features/patient/data/repositories/analysis_repository_impl.dart';
import 'features/patient/data/repositories/vital_repository_impl.dart'; // IoT
import 'features/patient/domain/repositories/analysis_repository.dart';
import 'features/patient/domain/repositories/vital_repository.dart';
import 'features/patient/presentation/bloc/scan_bloc.dart';
import 'features/chat/data/repositories/chat_repository_impl.dart';
import 'features/chat/domain/repositories/chat_repository.dart';

import 'core/services/websocket_service.dart'; // IoT Service
import 'core/services/report_service.dart'; // Report Service
import 'core/services/notification_service.dart'; // Notification Service

/// Service locator instance
final sl = GetIt.instance;

/// Initialize all dependencies
Future<void> initDependencies() async {
  // ==================== External ====================
  sl.registerLazySingleton<FirebaseAuth>(() => FirebaseAuth.instance);
  sl.registerLazySingleton<FirebaseFirestore>(() => FirebaseFirestore.instance);
  sl.registerLazySingleton<FirebaseStorage>(() => FirebaseStorage.instance);
  sl.registerLazySingleton<http.Client>(() => http.Client());
  sl.registerLazySingleton<InternetConnectionChecker>(
      () => InternetConnectionChecker());
  sl.registerLazySingleton<LocalAuthentication>(() => LocalAuthentication());
  final sharedPreferences = await SharedPreferences.getInstance();
  sl.registerLazySingleton<SharedPreferences>(() => sharedPreferences);

  const secureStorage = FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
    iOptions: IOSOptions(
      accessibility: KeychainAccessibility.first_unlock_this_device,
    ),
  );
  sl.registerLazySingleton<FlutterSecureStorage>(() => secureStorage);

  // ==================== Core ====================
  sl.registerLazySingleton<NetworkInfo>(
      () => NetworkInfoImpl(sl<InternetConnectionChecker>()));
  sl.registerLazySingleton<EncryptionService>(() => EncryptionServiceImpl());
  sl.registerLazySingleton<SecureStorageService>(
    () => SecureStorageServiceImpl(sl<FlutterSecureStorage>()),
  );
  sl.registerLazySingleton<ApiClient>(
    () => ApiClient(client: sl<http.Client>()),
  );
  sl.registerLazySingleton<BiometricAuthService>(
      () => BiometricAuthServiceImpl(sl<LocalAuthentication>()));
  sl.registerLazySingleton<TfliteService>(() => TfliteService());

  // ==================== Features - Auth ====================
  // BLoC
  sl.registerFactory<AuthBloc>(
    () => AuthBloc(
      loginUseCase: sl(),
      registerUseCase: sl(),
      logoutUseCase: sl(),
      getCurrentUser: sl(),
    ),
  );

  // Use Cases
  sl.registerLazySingleton(() => LoginUseCase(sl()));
  sl.registerLazySingleton(() => RegisterUseCase(sl()));
  sl.registerLazySingleton(() => LogoutUseCase(sl()));
  sl.registerLazySingleton(() => GetCurrentUser(sl()));

  // Repository
  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(
      remoteDataSource: sl(),
      localDataSource: sl(),
      networkInfo: sl(),
    ),
  );

  // Data Sources
  sl.registerLazySingleton<AuthRemoteDataSource>(
    () => AuthRemoteDataSourceImpl(
      firebaseAuth: sl(),
      firestore: sl(),
    ),
  );
  sl.registerLazySingleton<AuthLocalDataSource>(
    () => AuthLocalDataSourceImpl(secureStorage: sl()),
  );

  // ==================== Features - Patient Analysis ====================
  sl.registerLazySingleton<AnalysisRepository>(
    () => AnalysisRepositoryImpl(
      tfliteService: sl(),
      firestore: sl(),
      storage: sl(),
      networkInfo: sl(),
    ),
  );

  // ==================== Features - IoT Vitals ====================
  sl.registerLazySingleton(() => WebSocketService());
  sl.registerLazySingleton<VitalRepository>(
    () => VitalRepositoryImpl(sl()),
  );

  // ==================== Features - Chat ====================
  sl.registerLazySingleton<ChatRepository>(
    () => ChatRepositoryImpl(firestore: sl()),
  );

  // ==================== Features - Reports & Notifications ====================
  sl.registerLazySingleton(() => ReportService());
  sl.registerLazySingleton(() => NotificationService());
}
