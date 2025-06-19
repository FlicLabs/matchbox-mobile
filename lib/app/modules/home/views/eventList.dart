


import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:matchbox/app/modules/home/views/create_event_list.dart';

import '../../../utils/background_gradient.dart';
import '../../../utils/constant.dart';
import 'event_details_page.dart';

class EventList extends StatelessWidget {
  const EventList({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: AppDecorations.gradientBackground,
        child: Column(
          children: [
            Constant.buildEventTransparentAppBar("Events",true,() {
              Get.to(CreateEventPage());
            },),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance.collection('events').snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) return CircularProgressIndicator();
                  final events = snapshot.data!.docs;
                  deletePastEvents();
                  return ListView.builder(
                    itemCount: events.length,
                    itemBuilder: (context, index) {
                      var data = events[index];
                      return Card(
                        child: ListTile(
                          title: Text(data['title']),
                          subtitle: Text(DateFormat('dd MMM yyyy').format(DateTime.parse(data['date']))),
                          trailing: ElevatedButton(
                            child: Text('Enter'),
                            onPressed: () {
                              Navigator.push(context, MaterialPageRoute(
                                builder: (context) => EventDetailPage(eventId: data.id),
                              ));
                            },
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
    final eventsSnapshot =
    await FirebaseFirestore.instance.collection('events').get();

    for (var doc in eventsSnapshot.docs) {
      final eventDateField = doc['date'];
      DateTime eventDate;

      // Handle both Timestamp and String formats
      if (eventDateField is Timestamp) {
        eventDate = eventDateField.toDate();
      } else if (eventDateField is String) {
        eventDate = DateTime.parse(eventDateField);
      } else {
        continue;
      }

      if (eventDate.isBefore(now)) {
        await FirebaseFirestore.instance
            .collection('events')
            .doc(doc.id)
            .delete();
        print("Deleted event: ${doc.id}");
      }
    }
  }

}
