import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flash_chat/constants.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

final fireStore = FirebaseFirestore.instance;
late User loggedInUser;

class ChatScreen extends StatefulWidget {
  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  String messageText = '';
  final auth = FirebaseAuth.instance;
  final messageTextController = TextEditingController();
  // User? UserData() {
  //   return loggedInuser;
  // }

  void getCurrentUser() async {
    try {
      var user = await auth.currentUser!;

      loggedInUser = user;
    } catch (e) {
      print(e);
    }
  }

  // void getMessages() {
  //   final messages = fireStore
  //       .collection('messages')
  //       .get()
  //       .then((QuerySnapshot querySnapshot) {
  //     querySnapshot.docs.forEach((doc) {
  //       print(doc);
  //     });
  //   });
  // }

  // void messagesStream() async {
  //   await for (var snapshot in fireStore.collection('messages').snapshots()) {
  //     for (var message in snapshot.docs) {
  //       print(message.data());
  //     }
  //   }
  // }

  @override
  void initState() {
    super.initState();
    getCurrentUser();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: null,
        actions: <Widget>[
          IconButton(
              icon: Icon(Icons.close),
              onPressed: () {
                auth.signOut();
                Navigator.pop(context);
                // messagesStream();
              }),
        ],
        title: Text('⚡️Chat'),
        backgroundColor: Colors.lightBlueAccent,
      ),
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            MessageStream(),
            Container(
              decoration: kMessageContainerDecoration,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Expanded(
                    child: TextField(
                      controller: messageTextController,
                      onChanged: (value) {
                        messageText = value;
                      },
                      decoration: kMessageTextFieldDecoration,
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      fireStore.collection('messages').add(
                          {'text': messageText, 'sender': loggedInUser.email});
                      messageTextController.clear();
                    },
                    child: Text(
                      'Send',
                      style: kSendButtonTextStyle,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class MessageStream extends StatelessWidget {
  const MessageStream({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      child: StreamBuilder<QuerySnapshot>(
        builder: ((context, snapshot) {
          if (!snapshot.hasData) {
            return Center(
              child: CircularProgressIndicator(
                  backgroundColor: Colors.lightBlueAccent),
            );
          }
          final messages = snapshot.data!.docs.reversed;
          print(messages);
          List<MessageBubble> messageWidgets = [];

          messages.forEach((doc) {
            final mText = doc['text'];
            final mSender = doc['sender'];
            print('$mText from $mSender');
            final currentUser = loggedInUser.email;
            final mWidget =
                MessageBubble(mSender, mText, currentUser == mSender);

            messageWidgets.add(mWidget);
          });
          return Expanded(
            child: ListView(
              reverse: true,
              padding: EdgeInsets.symmetric(horizontal: 10, vertical: 20),
              children: messageWidgets,
            ),
          );
        }),
        stream: fireStore.collection('messages').snapshots(),
      ),
    );
  }
}

class MessageBubble extends StatelessWidget {
  MessageBubble(this.mSender, this.mText, this.isMe);
  String mText;
  String mSender;
  final bool isMe;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: Column(
        crossAxisAlignment:
            isMe ? CrossAxisAlignment.start : CrossAxisAlignment.end,
        children: <Widget>[
          Text(mSender, style: TextStyle(fontSize: 12, color: Colors.black54)),
          Material(
            color: isMe ? Colors.white : Colors.lightBlueAccent,
            borderRadius: isMe
                ? BorderRadius.only(
                    topRight: Radius.circular(30),
                    bottomLeft: Radius.circular(30),
                    bottomRight: Radius.circular(30),
                  )
                : BorderRadius.only(
                    topLeft: Radius.circular(30),
                    bottomLeft: Radius.circular(30),
                    bottomRight: Radius.circular(30),
                  ),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
              child: Text(mText,
                  style: isMe
                      ? TextStyle(
                          fontSize: 15,
                          color: Colors.black,
                        )
                      : TextStyle(
                          fontSize: 15,
                          color: Colors.white,
                        )),
            ),
          ),
        ],
      ),
    );
  }
}
