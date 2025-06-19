import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class NotificationPage extends StatelessWidget {
  final notificationController = Get.find<NotificationController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(title: Text('Notifications')),
      body: Obx(() {
        final todayNotifs = notificationController.todayNotifications;
        return todayNotifs.length>0?ListView.builder(
          itemCount: todayNotifs.length,
          itemBuilder: (context, index) {
            final notif = todayNotifs[index];
            return Card(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: ListTile(
                  title: Text(notif.title),
                  subtitle: Text(notif.message),
                  trailing: Text(DateFormat.Hm().format(notif.date)),
                ),
              ),
            );
          },
        ):Center(child: Text("Empty Notification"));
      }),
    );
  }
}

class NotificationController extends GetxController {
  var notifications = <AppNotification>[].obs;

  void addNotification(AppNotification notification) {
    notifications.add(notification);
  }

  List<AppNotification> get todayNotifications {
    final now = DateTime.now();
    return notifications.where((n) =>
    n.date.year == now.year &&
        n.date.month == now.month &&
        n.date.day == now.day
    ).toList();
  }
}
class AppNotification {
  final String title;
  final String message;
  final DateTime date;

  AppNotification({
    required this.title,
    required this.message,
    required this.date,
  });
}
