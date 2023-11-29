import 'package:firebase_messaging/firebase_messaging.dart';

void showFlutterNotification(RemoteMessage message) {
  RemoteNotification? notification = message.notification;
  // AndroidNotification? android = message.notification?.android;
}

Future<String> getToken() async {
  String? deviceToken = await FirebaseMessaging.instance.getToken(
      vapidKey:
          "BGK6-fqWfPVz91179wu_DEP-kXQgaQwVfVcRGVIlE007-f4BJFrWTDjdPmedJia7bxsUNuz4VAUFMJt5-ygXMZM");

  return deviceToken!;
}
