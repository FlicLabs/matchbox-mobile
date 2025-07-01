import 'dart:ui';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:qr_flutter_new/qr_flutter.dart';

class EventDetailPage extends StatelessWidget {
  final String eventId;
  EventDetailPage({required this.eventId});

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
        title:  Text("Event Details",style:TextStyle(color: Colors.white),),
        iconTheme: const IconThemeData(color: Colors.white),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Container(
        decoration: gradientBackground,
        child: Center(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(26),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
              child: Container(
                padding: EdgeInsets.all(26),
                margin: EdgeInsets.symmetric(horizontal: 24, vertical: 50),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(26),
                  border: Border.all(color: Colors.white24),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Event QR Code',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(height: 30),
                    QrImageView(
                      data: eventId,
                      version: QrVersions.auto,
                      size: 220.0,
                      backgroundColor: Colors.white,
                    ),
                    SizedBox(height: 30),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) =>
                                      EventChatPage(eventId: eventId)));
                        },
                        icon: Icon(Icons.chat, color: Colors.white),
                        label: Text("Enter Group Chat",
                            style: TextStyle(fontSize: 16, color: Colors.white)),
                        style: ElevatedButton.styleFrom(
                          padding: EdgeInsets.symmetric(vertical: 16),
                          backgroundColor: Color(0xFF0F2027).withOpacity(0.8),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          elevation: 6,
                        ),
                      ),
                    )
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}


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
    super.initState();
    getUserdata().then((value) {
      data = value;
      setState(() {});
    });
  }

  Future<Map<String, dynamic>> getUserdata() async {
    String uid = _auth.currentUser!.uid;
    var snapshot = await _firestore.collection('users').doc(uid).get();
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
      'senderImage': data["photoURL"] ?? "",
      'message': messageController.text,
      'timestamp': DateTime.now().toIso8601String(),
    });
    messageController.clear();
  }

  Widget buildMessageTile(DocumentSnapshot doc) {
    final isMe = doc['senderId'] == _auth.currentUser!.uid;
    final alignment = isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: Column(
        crossAxisAlignment: alignment,
        children: [
          Text(
            doc['senderName'] ?? 'Unknown',
            style: TextStyle(
                fontSize: 13, fontWeight: FontWeight.w500, color: Colors.white70),
          ),
          Row(
            mainAxisAlignment:
            isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
            children: [
              if (!isMe)
                CircleAvatar(
                  radius: 16,
                  backgroundImage: NetworkImage(doc['senderImage']),
                ),
              SizedBox(width: 8),
              Flexible(
                child: Container(
                  padding: EdgeInsets.symmetric(vertical: 15, horizontal: 16),
                  decoration: BoxDecoration(
                    color: isMe
                        ? Color(0xFF0F2027).withOpacity(0.8)
                        : Color(0xFF0F2027).withOpacity(0.8),
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(16),
                      topRight: Radius.circular(16),
                      bottomLeft:
                      isMe ? Radius.circular(16) : Radius.circular(0),
                      bottomRight:
                      isMe ? Radius.circular(0) : Radius.circular(16),
                    ),
                  ),
                  child: Text(
                    doc['message'],
                    style: TextStyle(color: Colors.white, fontSize: 15),
                  ),
                ),
              ),
              if (isMe) SizedBox(width: 8),
              if (isMe)
                CircleAvatar(
                  radius: 16,
                  backgroundImage: NetworkImage(data["photoURL"] ?? ''),
                ),
            ],
          ),
        ],
      ),
    );
  }

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
        title: Text("Event Chat",style: TextStyle(color: Colors.white),),
        backgroundColor: Colors.transparent,
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
      ),
      body: Container(
        decoration: gradientBackground,
        child: Column(
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
              padding: EdgeInsets.all(12),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: messageController,
                      style: TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        hintText: 'Type a message',
                        hintStyle: TextStyle(color: Colors.white54),
                        filled: true,
                        fillColor: Colors.white.withOpacity(0.1),
                        contentPadding: EdgeInsets.symmetric(horizontal: 16),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(26),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 8),
                  CircleAvatar(
                    backgroundColor: Color(0xFF0F2027),
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
      ),
    );
  }
}
