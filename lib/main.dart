import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'app.dart';
import 'core/utils/bloc_observer.dart';
import 'firebase_options.dart';
import 'injection_container.dart';

void main() async {
  await runZonedGuarded(
    () async {
      WidgetsFlutterBinding.ensureInitialized();

      // Initialize Firebase
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );

      // Initialize Crashlytics
      if (!kDebugMode) {
        FlutterError.onError =
            FirebaseCrashlytics.instance.recordFlutterFatalError;
        PlatformDispatcher.instance.onError = (error, stack) {
          FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
          return true;
        };
      }

      // Initialize Dependency Injection
      await initDependencies();

      // Set up BLoC observer for debugging
      Bloc.observer = AppBlocObserver();

      runApp(const VitaGuardApp());
    },
    (error, stackTrace) {
      if (!kDebugMode) {
        FirebaseCrashlytics.instance.recordError(error, stackTrace);
      }
    },
  );
}
