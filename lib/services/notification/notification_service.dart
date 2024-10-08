import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:notification_permissions/notification_permissions.dart';
import 'package:permission_handler/permission_handler.dart' as ph;

import '../../common/constants.dart';
import '../../models/entities/fstore_notification_item.dart';

abstract class NotificationService {
  bool _isInitialized = false;

  bool get isInitialized => _isInitialized;

  void setIsInitialized() {
    _isInitialized = true;
  }

  NotificationService() {
    // var initSetting = const InitializationSettings(
    //   android: AndroidInitializationSettings('@drawable/ic_stat_onesignal_default'),
    //   iOS: IOSInitializationSettings(),
    // );
    //
    // flutterLocalNotificationsPlugin.initialize(initSetting,
    //     onSelectNotification: (String? payload) async {
    //   /// Handle payload here
    // });

    flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);
  }

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  final channel = const AndroidNotificationChannel(
    'high_importance_channel', // id
    'High Importance Notifications', // title
    description:
        'This channel is used for important notifications.', // description
    importance: Importance.max,
  );

  late final NotificationDelegate delegate;

  void init({
    /// OneSignal only
    String? externalUserId,
    required NotificationDelegate notificationDelegate,
  });

  Future<bool> requestPermission() async {
    if (kIsWeb) {
      return false;
    }

    /// Case unknown - First time open the app
    var granted = (await NotificationPermissions.requestNotificationPermissions(
          iosSettings: const NotificationSettingsIos(
            sound: true,
            badge: true,
            alert: true,
          ),
        )) ==
        PermissionStatus.granted;

    /// To support POST_NOTIFICATION on Android 13.
    /// Requires permission_handler 10+.
    if (isAndroid) {
      granted = (await ph.Permission.notification.request()) ==
          ph.PermissionStatus.granted;
    }

    return granted;
  }

  Future<bool> isGranted() async {
    if (kIsWeb) return false;
    final status =
        await NotificationPermissions.getNotificationPermissionStatus();
    if (status == PermissionStatus.granted) {
      return true;
    }
    return false;
  }

  void disableNotification();

  void enableNotification();

  void setExternalId(String? userId);

  void removeExternalId();
}

mixin NotificationDelegate {
  void onMessage(FStoreNotificationItem notification);

  void onMessageOpenedApp(FStoreNotificationItem notification);
}
