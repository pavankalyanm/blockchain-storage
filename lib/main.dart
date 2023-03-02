import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:device_preview/device_preview.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sizer/sizer.dart';
import 'package:todo_app/bloc/connectivity/connectivity_cubit.dart';
import 'package:todo_app/bloc/onboarding/onboarding_cubit.dart';
import 'package:todo_app/presentation/screens/login_page.dart';
import 'package:todo_app/presentation/screens/sudent/my_homepage.dart';
import 'package:todo_app/presentation/screens/onboarding.dart';
import 'package:todo_app/presentation/screens/teacher/teachhome.dart';
import 'package:todo_app/presentation/screens/welcome_page.dart';
import 'package:todo_app/presentation/widgets/myindicator.dart';
import 'package:todo_app/shared/constants/consts_variables.dart';
import 'package:todo_app/shared/route.dart';
import 'package:todo_app/shared/styles/themes.dart';
import 'package:todo_app/globals.dart' as globals;
import 'package:todo_app/data/repositories/firestore_crud.dart';

import 'bloc/auth/authentication_cubit.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

  AwesomeNotifications().initialize(
    null,
    [
      NotificationChannel(
        channelKey: 'basic_channel',
        channelName: 'Basic Notifications',
        channelDescription: 'Notification channel for basic tests',
        importance: NotificationImportance.High,
        channelShowBadge: true,
        locked: false,
      ),
    ],
  );

  final prefs = await SharedPreferences.getInstance();
  final bool? seen = prefs.getBool('seen');
  profileimagesindex = prefs.getInt('plogo') ?? 0;
  var uid = prefs.getString('uid') ?? '';

  if (uid != '') {
    globals.uid = uid;

    await FireStoreCrud().checkRole(uid: uid);
    if (globals.role == 'student') {
      await FireStoreCrud().loadDetails(uid: globals.uid);
    }
  }

  runApp(
    MyApp(
      seen: seen,
      approute: AppRoute(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key, required this.approute, required this.seen})
      : super(key: key);

  final AppRoute approute;
  final bool? seen;

  @override
  Widget build(BuildContext context) {
    return Sizer(
      builder: (BuildContext context, Orientation orientation, deviceType) {
        return MultiBlocProvider(
          providers: [
            BlocProvider(
                lazy: false,
                create: (context) =>
                    ConnectivityCubit()..initializeConnectivity()),
            BlocProvider(
              create: (context) => OnboardingCubit(),
            ),
            BlocProvider(create: (context) => AuthenticationCubit()),
          ],
          child: MaterialApp(
            debugShowCheckedModeBanner: false,
            title: 'Smart Attendance',
            themeMode: ThemeMode.light,
            theme: MyTheme.lightTheme,
            darkTheme: MyTheme.darkTheme,
            onGenerateRoute: approute.generateRoute,
            home: StreamBuilder<User?>(
              stream: FirebaseAuth.instance.authStateChanges(),
              builder: (context, snapshot) {
                //debugPrint(snapshot.data!.uid);
                //await globals.role=FireStoreCrud().checkRole(uid: snapshot.data!.uid) as String?;
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const MyCircularIndicator();
                }
                if (snapshot.hasData) {
                  if (globals.role == 'teacher') {
                    return const TeacherHome();
                  } else if (globals.role == 'student') {
                    return const StudentHome();
                  } else {
                    return const LoginPage();
                  }
                }
                if (seen != null) {
                  return const LoginPage();
                }
                return const OnboardingPage();
              },
            ),
          ),
        );
      },
    );
  }
}