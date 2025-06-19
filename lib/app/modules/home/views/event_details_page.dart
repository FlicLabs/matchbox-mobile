import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:qr_flutter_new/qr_flutter.dart';

import 'package:flutter/material.dart';

class EventDetailPage extends StatelessWidget {
  final String eventId;
  EventDetailPage({required this.eventId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Event Details")),
      body: Card(
        elevation: 6,
        color: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        margin: EdgeInsets.symmetric(horizontal: 24, vertical: 40),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Event QR Code',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: 20),
              QrImageView(
                data: eventId,
                version: QrVersions.auto,
                size: 200.0,
              ),
              SizedBox(height: 30),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.push(context, MaterialPageRoute(
                      builder: (context) => EventChatPage(eventId: eventId),
                    ));
                  },
                  icon: Icon(Icons.chat),
                  label: Text("Enter Group Chat"),
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}


///----event Chat Page


class EventChatPage extends StatefulWidget {
  final String eventId;
  EventChatPage({required this.eventId});

  @override
  _EventChatPageState createState() => _EventChatPageState();
}

class _EventChatPageState extends State<EventChatPage> {
  final messageController = TextEditingController();
  FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  Map<String, dynamic> data = {};

  @override
  void initState() {
    getUserdata().then((value) {
      data = value;
      setState(() {});
    });
    super.initState();
  }

  Future<Map<String, dynamic>> getUserdata() async {
    String uid = _auth.currentUser!.uid;
    DocumentSnapshot<Map<String, dynamic>> snapshot =
    await _firestore.collection('users').doc(uid).get();
    return snapshot.data()!;
  }

  void sendMessage() {
    if (messageController.text.isEmpty) return;

    _firestore
        .collection('events')
        .doc(widget.eventId)
        .collection('messages')
        .add({
      'senderId': data["uid"],
      'senderName': data["name"],
      'senderImage': data["photoURL"] ?? "", // optional
      'message': messageController.text,
      'timestamp': DateTime.now().toIso8601String(),
    });

    messageController.clear();
  }

  Widget buildMessageTile(DocumentSnapshot doc) {
    final isMe = doc['senderId'] == _auth.currentUser!.uid;
    final alignment = isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start;
    final color = isMe ? Colors.blue[100] : Colors.grey[200];
    final borderRadius = isMe
        ? BorderRadius.only(
      topLeft: Radius.circular(16),
      topRight: Radius.circular(16),
      bottomLeft: Radius.circular(16),
    )
        : BorderRadius.only(
      topLeft: Radius.circular(16),
      topRight: Radius.circular(16),
      bottomRight: Radius.circular(16),
    );

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: Column(
        crossAxisAlignment: alignment,
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            child: Column(
              crossAxisAlignment: alignment,
              children: [
                Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Text(
                    doc['senderName'] ?? 'Unknown',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey[600],
                    ),
                  ),
                ),
                Row(
                  mainAxisAlignment:
                  isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
                  children: [
                    if (!isMe)
                      CircleAvatar(
                        radius: 18,
                        backgroundImage: NetworkImage(doc['senderImage']),
                      ),
                    SizedBox(width: 8),
                    Flexible(
                      child: Card(
                        color: color,
                        shape: RoundedRectangleBorder(borderRadius: borderRadius),
                        child: Padding(
                          padding:
                          const EdgeInsets.symmetric(vertical: 10, horizontal: 14),
                          child: Text(
                            doc['message'],
                            style: TextStyle(fontSize: 16),
                          ),
                        ),
                      ),
                    ),
                    if (isMe) SizedBox(width: 8),
                    if (isMe)
                      CircleAvatar(
                        radius: 18,
                        backgroundImage: data["photoURL"] != null &&
                            data["photoURL"].toString().isNotEmpty
                            ? NetworkImage(data["photoURL"])
                            : AssetImage('assets/user_placeholder.png')
                        as ImageProvider,
                      ),
                  ],
                ),
              ],
            ),
          ),

        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Event Chat")),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _firestore
                  .collection('events')
                  .doc(widget.eventId)
                  .collection('messages')
                  .orderBy('timestamp')
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData)
                  return Center(child: CircularProgressIndicator());
                final messages = snapshot.data!.docs;
                return ListView.builder(
                  reverse: false,
                  itemCount: messages.length,
                  itemBuilder: (context, index) =>
                      buildMessageTile(messages[index]),
                );
              },
            ),
          ),
          Padding(
            padding: EdgeInsets.all(10),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: messageController,
                    decoration: InputDecoration(
                      hintText: 'Type a message',
                      contentPadding: EdgeInsets.symmetric(horizontal: 16),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24)),
                    ),
                  ),
                ),
                SizedBox(width: 8),
                CircleAvatar(
                  backgroundColor: Colors.blue,
                  child: IconButton(
                    icon: Icon(Icons.send, color: Colors.white),
                    onPressed: sendMessage,
                  ),
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}

