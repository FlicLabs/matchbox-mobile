import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:matchbox/app/modules/home/views/create_event_list.dart';

import '../../../utils/constant.dart';
import 'event_details_page.dart';

class EventList extends StatelessWidget {
  const EventList({super.key});

  // Gradient background decoration
  BoxDecoration get gradientBackground => BoxDecoration(
    gradient: LinearGradient(
      colors: [Color(0xFF0F2027), Color(0xFF203A43), Color(0xFF2C5364)],

      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
  );

  // Custom gradient button
  Widget buildGradientButton(String text, VoidCallback onPressed) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF0F2027), Color(0xFF203A43)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
      ),
      child: MaterialButton(
        onPressed: onPressed,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        child: Text(
          text,
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: gradientBackground,
        child: Column(
          children: [
            // Custom AppBar
            Constant.buildEventTransparentAppBar(


              "Events",
              true,
                  () {
                Get.to(CreateEventPage());
              },
            ),

            // Event List
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance.collection('events').snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
                  final events = snapshot.data!.docs;
                  deletePastEvents();

                  if (events.isEmpty) {
                    return Center(
                      child: Text(
                        "No events available",
                        style: TextStyle(color: Colors.white, fontSize: 18),
                      ),
                    );
                  }

                  return ListView.builder(
                    padding: EdgeInsets.all(16),
                    itemCount: events.length,
                    itemBuilder: (context, index) {
                      var data = events[index];
                      return Container(
                        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: Colors.white24),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                data['title'],
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              SizedBox(height: 8),
                              Text(
                                "Date: ${DateFormat('dd MMM yyyy').format(DateTime.parse(data['date']))}",
                                style: TextStyle(color: Colors.white),
                              ),
                              SizedBox(height: 16),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  buildGradientButton('Enter', () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => EventDetailPage(eventId: data.id),
                                      ),
                                    );
                                  }),
                                ],
                              )
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void deletePastEvents() async {
    final now = DateTime.now();
    final eventsSnapshot = await FirebaseFirestore.instance.collection('events').get();

    for (var doc in eventsSnapshot.docs) {
      final eventDateField = doc['date'];
      DateTime eventDate;

      if (eventDateField is Timestamp) {
        eventDate = eventDateField.toDate();
      } else if (eventDateField is String) {
        eventDate = DateTime.parse(eventDateField);
      } else {
        continue;
      }

      if (eventDate.isBefore(now)) {
        await FirebaseFirestore.instance.collection('events').doc(doc.id).delete();
        print("Deleted event: ${doc.id}");
      }
    }
  }
}
