import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:provider/provider.dart';
import 'theme/app_theme.dart';
import 'services/auth_provider.dart';
import 'services/api_service.dart';
import 'services/language_provider.dart';
import 'screens/login_screen.dart';
import 'screens/home_screen.dart';

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

Future<void> _setupLocalNotifications() async {
  const AndroidInitializationSettings initializationSettingsAndroid =
      AndroidInitializationSettings('@mipmap/ic_launcher');
  const InitializationSettings initializationSettings = InitializationSettings(
    android: initializationSettingsAndroid,
  );
  await flutterLocalNotificationsPlugin.initialize(
    settings: initializationSettings,
  );
}

Future<void> _showNotification(String title, String body) async {
  const AndroidNotificationDetails androidPlatformChannelSpecifics =
      AndroidNotificationDetails(
    'samaki_orders',
    'Samaki Orders',
    channelDescription: 'Notifications for fish orders',
    importance: Importance.high,
    priority: Priority.high,
  );
  const NotificationDetails platformChannelSpecifics = NotificationDetails(
    android: androidPlatformChannelSpecifics,
  );
  await flutterLocalNotificationsPlugin.show(
    id: 0,
    title: title,
    body: body,
    notificationDetails: platformChannelSpecifics,
  );
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await _setupLocalNotifications();

  FirebaseMessaging messaging = FirebaseMessaging.instance;
  await messaging.requestPermission();
  String? fcmToken = await messaging.getToken();
  debugPrint("FCM Token: $fcmToken");

  FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    _showNotification(
      message.notification?.title ?? 'New Order',
      message.notification?.body ?? 'You have a new fish order',
    );
  });

  FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
    debugPrint('Message opened: ${message.data}');
  });

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => LanguageProvider()),
        Provider(create: (_) => ApiService()),
      ],
      child: const SamakiApp(),
    ),
  );
}

class SamakiApp extends StatelessWidget {
  const SamakiApp({super.key});

  @override
  Widget build(BuildContext context) {
    final langProvider = context.watch<LanguageProvider>();
    return MaterialApp(
      title: 'Samaki Smart AI',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      locale: langProvider.locale,
      home: Consumer<AuthProvider>(
        builder: (context, auth, _) {
          if (auth.isLoggedIn) return const HomeScreen();
          return const LoginScreen();
        },
      ),
    );
  }
}