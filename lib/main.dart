import 'package:camera/camera.dart';
import 'package:feature_discovery/feature_discovery.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:multi_ml/app/values/theme_service.dart';
import 'package:multi_ml/app/values/themes.dart';
import 'package:multi_ml/data/local/alarm_helper.dart';
import 'package:multi_ml/data/local/db_helper.dart';
import 'package:multi_ml/pages/HomePage.dart';
import 'package:multi_ml/pages/SignupPage.dart';
import 'package:multi_ml/pages/addTodo.dart';
import 'package:multi_ml/pages/currencyConvertor.dart';
import 'package:multi_ml/pages/faceDetector.dart';
import 'package:multi_ml/pages/fruitDetector.dart';
import 'package:multi_ml/pages/maskDetector.dart';
import 'package:multi_ml/pages/speechToText.dart';
import 'package:multi_ml/pages/stopWatch.dart';
import 'package:multi_ml/pages/textToSpeech.dart';
import 'package:multi_ml/pages/toDoList.dart';
import 'package:multi_ml/service/auth_service.dart';

import 'package:workmanager/workmanager.dart';

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

final FlutterTts flutterTts = FlutterTts();

List<CameraDescription>? cameras;

speak(String text) async {
  await flutterTts.setLanguage("en-US");
  await flutterTts.setPitch(1);
  await flutterTts.speak(text);
}

@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((taskName, inputData) {
    try {
      speak(taskName);
      print(taskName);
    } catch (err) {
      print(err);
    }
    return Future.value(true);
  });
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await GetStorage.init();
  await DBHelper.initDb();
  AlarmHelper.alarmHelper.initializeDatabase();
  Workmanager().initialize(callbackDispatcher, isInDebugMode: true);
  cameras = await availableCameras();

  var initializationSettingsAndroid = const AndroidInitializationSettings('@mipmap/ic_launcher');
  var initializationSettingsIOS = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
      onDidReceiveLocalNotification: (int id, String? title, String? body, String? payload) async {});

  var initializationSettings =
      InitializationSettings(android: initializationSettingsAndroid, iOS: initializationSettingsIOS);
  await flutterLocalNotificationsPlugin.initialize(
    initializationSettings,
    onDidReceiveNotificationResponse: (details) {
      if (details.payload != null) {
        debugPrint("message payload " + details.payload!);
      }
    },
  );
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  AuthClass authClass = AuthClass();
  // Widget currentPage = SignUpPage();

  @override
  void initState() {
    super.initState();
    // checkLogin();
  }

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      themeMode: ThemeServices().theme,
      theme: Themes.light,
      darkTheme: Themes.dark,
      debugShowCheckedModeBanner: false,
      home: FeatureDiscovery(
        recordStepsInSharedPreferences: false,
        child: homePage(),
      ),
      initialRoute: '/',
      routes: {
        '/todoList': (context) => toDoList(),
        '/addtodo': (context) => addTodo(),
        '/stopwatch': (context) => stopWatch(),
        '/face': (context) => faceDetector(),
        '/fruit': (context) => fruitDetector(),
        '/mask': (context) => maskDetector(),
        '/money': (context) => currency(),
        '/stt': (context) => speechToText(),
        '/tts': (context) => textTospeech(),
        '/logout': (context) => SignUpPage(),
      },
    );
  }
}
