import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:notif_app/services/notification_service.dart';
import 'package:notif_app/firebase_options.dart';

//pages
import 'package:notif_app/screens/home.dart';
// import 'package:notif_app/screens/second_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await NotificationService.initializeNotification();
  // await NotificationService.initializeFirebaseMessaging();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  static GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,

      title: 'Tugas Notif',
      routes: {
        'home': (context) => const Home(),
      },
      initialRoute: 'home',
      navigatorKey: navigatorKey,
    );
  }
}

