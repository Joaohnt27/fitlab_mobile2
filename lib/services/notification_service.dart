import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  // Padrão Singleton: Garante que só exista 1 instância dessa classe no app todo
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin plugin = FlutterLocalNotificationsPlugin();

  Future<void> init() async {
    const AndroidInitializationSettings androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
    const DarwinInitializationSettings iosInit = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );
    const InitializationSettings initSettings = InitializationSettings(android: androidInit, iOS: iosInit);
    
    await plugin.initialize(settings: initSettings);

    // Dispara a permissão no Android 13+ e iOS
    await plugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()?.requestNotificationsPermission();
    await plugin.resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>()?.requestPermissions(alert: true, badge: true, sound: true);
  }

  // Função global que qualquer tela pode chamar
  Future<void> showNotification({required String title, required String body}) async {
    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'fitlab_channel', 
      'FitLab Alerts',
      channelDescription: 'Notificações de sistema e treino',
      importance: Importance.max, 
      priority: Priority.high, 
      playSound: true,
    );
    const NotificationDetails details = NotificationDetails(android: androidDetails);

    await plugin.show(
      id: DateTime.now().millisecond, 
      title: title, 
      body: body, 
      notificationDetails: details,
    );
  }
}