import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class OneToOneChatPage extends StatefulWidget {
  final String otherUserId;

  OneToOneChatPage({required this.otherUserId});

  @override
  _OneToOneChatPageState createState() => _OneToOneChatPageState();
}

class _OneToOneChatPageState extends State<OneToOneChatPage> {
  final messageController = TextEditingController();
  final currentUser = FirebaseAuth.instance.currentUser;

  String getChatId() {
    List<String> ids = [currentUser!.uid, widget.otherUserId];
    ids.sort(); // so both users get the same chatId
    return ids.join('_');
  }

  void sendMessage() async {
    if (messageController.text.isEmpty) return;

    await FirebaseFirestore.instance
        .collection('chats')
        .doc(getChatId())
        .collection('messages')
        .add({
      'senderId': currentUser!.uid,
      'receiverId': widget.otherUserId,
      'message': messageController.text,
      'timestamp': DateTime.now().toIso8601String(),
    });

    messageController.clear();
  }

  @override
  Widget build(BuildContext context) {
    final chatId = getChatId();

    return Scaffold(
      appBar: AppBar(title: Text("Chat")),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('chats')
                  .doc(chatId)
                  .collection('messages')
                  .orderBy('timestamp')
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData)
                  return Center(child: CircularProgressIndicator());

                final messages = snapshot.data!.docs;

                return ListView.builder(
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final doc = messages[index];
                    final isMe = doc['senderId'] == currentUser!.uid;

                    return Align(
                      alignment:
                      isMe ? Alignment.centerRight : Alignment.centerLeft,
                      child: Card(
                        color: isMe ? Colors.blue[100] : Colors.grey[300],
                        child: Padding(
                          padding: const EdgeInsets.all(10),
                          child: Text(doc['message']),
                        ),
                      ),
                    );
                  },
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
                IconButton(
                  icon: Icon(Icons.send),
                  onPressed: sendMessage,
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}
