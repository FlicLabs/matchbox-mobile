import 'dart:convert';
import 'dart:ui';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:matchbox/app/utils/constant.dart';
import 'package:http/http.dart' as http;
import 'notification_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
class CreateEventPage extends StatefulWidget {
  @override
  _CreateEventPageState createState() => _CreateEventPageState();
}

class _CreateEventPageState extends State<CreateEventPage> {
  final titleController = TextEditingController();
  final priceController = TextEditingController();
  DateTime? selectedDate;
  FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  int guestLimit = 20;
  NotificationController controller=Get.put(NotificationController());
  bool chargeGuests = false;
  Map<String, dynamic> data = {};
  void pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: selectedDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );
    if (picked != null) setState(() => selectedDate = picked);
  }

  // App primary gradient
  LinearGradient get primaryGradient => LinearGradient(
    colors: [Color(0xFF0F2027), Color(0xFF203A43), Color(0xFF2C5364)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  BoxDecoration get gradientBackground => BoxDecoration(
    gradient: LinearGradient(
      colors: [Color(0xFF0F2027), Color(0xFF203A43), Color(0xFF2C5364)],

      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
  );
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
      // extendBodyBehindAppBar: true,
      body: Container(
        decoration: gradientBackground,

        child: Column(
          children: [
            Constant.buildCutomTransparentAppBar("Create Event", false),
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.all(20),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(26),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
                    child: Container(
                      padding:
                      EdgeInsets.symmetric(vertical: 26, horizontal: 24),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(26),
                        border: Border.all(color: Colors.white.withOpacity(0.2)),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          buildTextField("Event Title", titleController),
                          SizedBox(height: 22),
                          buildDatePicker(dateText),
                          SizedBox(height: 22),
                          buildGuestSlider(),
                          SizedBox(height: 20),
                          buildChargeSwitch(),
                          if (chargeGuests) ...[
                            SizedBox(height: 20),
                            buildTextField(
                              "Ticket Price",
                              priceController,
                              prefixText: '₹ ',
                              keyboardType: TextInputType.number,
                            ),
                          ],
                          SizedBox(height: 40),
                          buildGradientButton("Create Event", () {
                            saveEvent();
                          }),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildTextField(String label, TextEditingController controller,
      {TextInputType? keyboardType, String? prefixText}) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      style: TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: Colors.white70),
        prefixText: prefixText,
        prefixStyle: TextStyle(color: Colors.white),
        filled: true,
        fillColor: Colors.white.withOpacity(0.12),
        contentPadding: EdgeInsets.symmetric(vertical: 16, horizontal: 20),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  Widget buildDatePicker(String dateText) {
    return Row(
      children: [
        Expanded(
          child: Text(
            dateText,
            style: TextStyle(fontSize: 16, color: Colors.white),
          ),
        ),
        buildGradientButton("Pick Date", pickDate, horizontalPadding: 22),
      ],
    );
  }

  Widget buildGuestSlider() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Guest Limit: $guestLimit',
          style: TextStyle(fontSize: 16, color: Colors.white70),
        ),
        Slider(
          value: guestLimit.toDouble(),
          min: 0,
          max: 500,
          divisions: 25,
          label: guestLimit.toString(),
          activeColor: Color(0xFFFFC371),
          inactiveColor: Colors.white24,
          onChanged: (val) => setState(() => guestLimit = val.toInt()),
        ),
      ],
    );
  }

  Widget buildChargeSwitch() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text('Charge Guests?', style: TextStyle(fontSize: 16, color: Colors.white70)),
        Switch(
          value: chargeGuests,
          onChanged: (val) => setState(() => chargeGuests = val),
          activeColor: Color(0xFFFFC371),
        ),
      ],
    );
  }

  Widget buildGradientButton(String text, VoidCallback onPressed,
      {double horizontalPadding = 24, double verticalPadding = 14}) {
    return Container(
      decoration: BoxDecoration(
        gradient: primaryGradient,
        borderRadius: BorderRadius.circular(26),
        boxShadow: [
          BoxShadow(
            color: Colors.black26,
            offset: Offset(0, 3),
            blurRadius: 8,
          )
        ],
      ),
      child: MaterialButton(
        onPressed: onPressed,
        padding: EdgeInsets.symmetric(
            horizontal: horizontalPadding, vertical: verticalPadding),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(26)),
        child: Text(
          text,
          style: TextStyle(
              fontSize: 16, color: Colors.white, fontWeight: FontWeight.w600),
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
