import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:matchbox/app/utils/app_colors.dart';

class NotificationPage extends StatelessWidget {
  final notificationController = Get.put(NotificationController());

  @override
  Widget build(BuildContext context) {
    final gradientBackground = BoxDecoration(
      gradient: LinearGradient(
        colors: [Color(0xFF0F2027), Color(0xFF203A43), Color(0xFF2C5364)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
    );
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(
          "Notifications",
          style: TextStyle(color: Colors.white),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Container(
        decoration: gradientBackground,
        child: Obx(() {
          final todayNotifs = notificationController.todayNotifications;
          return todayNotifs.length > 0
              ? StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('events')
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData)
                      return const Center(child: CircularProgressIndicator());
                    final events = snapshot.data!.docs;
                    if (events.isEmpty) {
                      return const Center(
                        child: Text(
                          "No events available",
                          style: TextStyle(color: Colors.white, fontSize: 18),
                        ),
                      );
                    }
                    return ListView.builder(
                      itemCount: events.length,
                      itemBuilder: (context, index) {
                        final notif = events[index];
                        print(DateFormat('dd MMM yyyy').format(DateTime.parse(notif['createdAt'])));
                        print(DateFormat('dd MMM yyyy').format(DateTime.now()));
                        return DateFormat('dd MMM yyyy').format(DateTime.parse(notif['createdAt']))==DateFormat('dd MMM yyyy').format(DateTime.now())?Container(
                          margin: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: Colors.white24),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: ListTile(
                              title: Row(
                                children: [
                                  Text("Event :",
                                      style: TextStyle(color: AppColors.xwhite)),
                                  Text(notif['title'],
                                      style: TextStyle(color: AppColors.xwhite)),
                                ],
                              ),
                              subtitle: Text(
                                "Date: ${DateFormat('dd MMM yyyy').format(DateTime.parse(notif['date']))}",
                                style: TextStyle(color: AppColors.xwhite),
                              ),
                            ),
                          ),
                        ):SizedBox();
                      },
                    );
                  })
              : Center(
                  child: Text(
                  "Empty Notification",
                  style: TextStyle(color: Colors.white),
                ));
        }),
      ),
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
    final formattedDate = DateFormat('dd/MM/yyyy').format(now);
    print(formattedDate); // example output: 30/06/2025
    return notifications
        .where((n) =>
            n.date.year == now.year &&
            n.date.month == now.month &&
            n.date.day == now.day)
        .toList();
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
