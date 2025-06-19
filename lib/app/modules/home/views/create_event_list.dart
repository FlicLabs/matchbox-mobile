import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:matchbox/app/utils/constant.dart';

import '../../../../main.dart';
import '../../../utils/app_colors.dart';
import '../../../utils/background_gradient.dart';
import 'notification_page.dart'; // Add intl package for date formatting
import 'package:http/http.dart' as http;
class CreateEventPage extends StatefulWidget {
  @override
  _CreateEventPageState createState() => _CreateEventPageState();
}

class _CreateEventPageState extends State<CreateEventPage> {
  final titleController = TextEditingController();
  DateTime? selectedDate;
  int guestLimit = 20;
  bool chargeGuests = false;
  final priceController = TextEditingController();
  FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  Map<String, dynamic> data = {};
  NotificationController controller=Get.put(NotificationController());

  void pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: selectedDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );
    if (picked != null) setState(() => selectedDate = picked);
  }

  Future<void> saveEvent() async {
    if (titleController.text.isEmpty || selectedDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please enter title and select a date')),
      );
      return;
    }
    getUserdata().then((value) {
      data= value;
      setState(() {
      });
    },);
    final event = Event(
      title: titleController.text,
      date: selectedDate!,
      guestLimit: guestLimit,
      chargeGuests: chargeGuests,
      userId: data["uid"],
      price: chargeGuests ? double.tryParse(priceController.text) : null,
    );

    final eventData = {
      'title': event.title,
      'date': event.date.toIso8601String(),
      'guestLimit': event.guestLimit,
      'chargeGuests': event.chargeGuests,
      'price': event.price,
      'createdUserId': event.price,
      'createdBy': 'currentUserId', // replace dynamically
      'createdAt': DateTime.now().toIso8601String(),
    };

    await FirebaseFirestore.instance.collection('events').add(eventData);
    // Local notification
    sendNotificationToAllUsers(event.title);
    // Add to NotificationController
    controller.addNotification(
        AppNotification(
          title: "Event: ${event.title}",
          message: "Scheduled for ${event.date.toLocal()}",
          date: DateTime.now(),
        )
    );
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Event Created Successfully ')),
    );
    Get.back();
    print(event.title);
  }



  Future<void> sendNotificationToAllUsers(String messageText) async {
    final usersSnapshot = await FirebaseFirestore.instance.collection('users').get();

    final serverKey = 'BJPl1JV2ngzkPTKUGx1D4dS4roRIeekNVF06AGVrKIqLVZ4kz9qjoE1SrxKyw0Qsrx-sO3m2_vzH2Yc5R_9fJI8'; // your FCM Server key
    final projectId = 'matchbox-fd063'; // replace this

    final url = 'https://fcm.googleapis.com/v1/projects/$projectId/messages:send';
    await http.post(
      Uri.parse(url),
      headers: {
        'Content-Type': 'application/json',
        // 'Authorization': 'key=$serverKey',
      },
      body: jsonEncode({
        "to": "/topics/global",
        "notification": {
          "title": messageText,
          "body": "",
        },
        "data": {
          "click_action": "FLUTTER_NOTIFICATION_CLICK"
        }
      }),
    );
  }
  Future<Map<String, dynamic>> getUserdata() async {
    final User? user = _auth.currentUser;
    String uid = _auth.currentUser!.uid;

    DocumentSnapshot<Map<String, dynamic>> snapshot =
    await _firestore.collection('users').doc(uid).get();
    var userData = snapshot.data();
    return userData!;
  }
  @override
  Widget build(BuildContext context) {
    final dateText = selectedDate == null
        ? 'Select Date'
        : DateFormat('dd MMM yyyy').format(selectedDate!);

    return Scaffold(
      // appBar: AppBar(title: Text('Create Event')),
      body: SafeArea(
        child: Container(
          decoration: AppDecorations.gradientBackground,
          child: Column(
            children: [
              Constant.buildCutomTransparentAppBar("Create Event",false),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Card(
                  elevation: 6,
                  color: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Event Title
                        TextField(
                          controller: titleController,
                          decoration: InputDecoration(
                            labelText: 'Event Title',
                            border: OutlineInputBorder(),
                            contentPadding:
                            EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                          ),
                        ),
                        SizedBox(height: 20),

                        // Date picker row
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                dateText,
                                style: TextStyle(fontSize: 16),
                              ),
                            ),
                            ElevatedButton(
                              onPressed: pickDate,
                              child: Text('Pick Date'),
                            ),
                          ],
                        ),
                        SizedBox(height: 20),

                        // Guest limit slider
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Guest Limit: $guestLimit',
                              style:
                              TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
                            ),
                            Slider(
                              value: guestLimit.toDouble(),
                              min: 0,
                              max: 500,
                              divisions: 25,
                              label: guestLimit.toString(),
                              onChanged: (val) => setState(() => guestLimit = val.toInt()),
                            ),
                          ],
                        ),
                        SizedBox(height: 20),

                        // Charge Guests Switch
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Charge Guests?', style: TextStyle(fontSize: 16)),
                            Switch(
                              value: chargeGuests,
                              onChanged: (val) => setState(() => chargeGuests = val),
                            ),
                          ],
                        ),

                        // Ticket price input (conditional)
                        if (chargeGuests) ...[
                          SizedBox(height: 16),
                          TextField(
                            controller: priceController,
                            keyboardType:
                            TextInputType.numberWithOptions(decimal: true),
                            decoration: InputDecoration(
                              labelText: 'Ticket Price',
                              border: OutlineInputBorder(),
                              prefixText: '₹ ',
                              contentPadding:
                              EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                            ),
                          ),
                        ],

                        SizedBox(height: 30),

                        // Create event button
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: saveEvent,

                            style: ElevatedButton.styleFrom(
                              padding: EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              backgroundColor: AppColors.Xlightflo.withOpacity(0.8)
                            ),
                            child: Text(
                              'Create Event',
                              style: TextStyle(fontSize: 18,color: Colors.white),
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Dummy Event class for reference
class Event {
  final String title;
  final DateTime date;
  final int guestLimit;
  final bool chargeGuests;
  final double? price;
  final String? userId;

  Event({
    required this.title,
    required this.date,
    required this.guestLimit,
    required this.chargeGuests,
    required this.userId,
    this.price,
  });
}
