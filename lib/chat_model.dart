import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
// import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_emoji/flutter_emoji.dart';

final _firestore = FirebaseFirestore.instance;
final _auth = FirebaseAuth.instance;

User loggedInUser;

const kSendButtonTextStyle = TextStyle(
  color: Colors.lightBlueAccent,
  fontWeight: FontWeight.bold,
  fontSize: 18.0,
);

bool isAllEmoji(String text) {
  if (text != null) {
    for (String s in EmojiParser().unemojify(text).split(" "))
      if (!s.startsWith(":") || !s.endsWith(":")) return false;
    return true;
  }
  return false;
}

const kMessageTextFieldDecoration = InputDecoration(
  contentPadding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
  hintText: 'Type your message here...',
  border: InputBorder.none,
);

const kMessageContainerDecoration = BoxDecoration(
  border: Border(
    top: BorderSide(color: Colors.grey, width: 1.0),
  ),
);

class PmScreen extends StatefulWidget {
  static const String id = 'chat_pm';
  final String selectedUser;

  PmScreen({@required this.selectedUser});
  @override
  _PmScreenState createState() => _PmScreenState();
}

class _PmScreenState extends State<PmScreen> {
  final messageTextController = TextEditingController();

  //initialising firestore

  String messageText;

  @override
  void initState() {
    super.initState();
    getCurrentUser();
  }

  void getCurrentUser() {
    try {
      final user = _auth.currentUser;
      if (user != null) {
        loggedInUser = user;
        print(loggedInUser);
      }
    } catch (e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: Icon(Icons.arrow_back),
          color: Colors.black,
        ),
        title: Text(
          'Chat',
          style: TextStyle(
              color: Colors.black,
              fontFamily: 'Metropolis',
              fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
      ),
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            MessageStream(
              selectedUser: widget.selectedUser,
            ),
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
                        //Do something with the user input.
                      },
                      decoration: kMessageTextFieldDecoration,
                    ),
                  ),
                  TextButton(
                      onPressed: () {
                        messageTextController.clear();
                        _firestore
                            .collection('users')
                            .doc(widget.selectedUser)
                            .collection('messages')
                            .doc(loggedInUser.uid)
                            .collection('pms')
                            .doc()
                            .set({
                          'text': messageText,
                          'sender': loggedInUser.email,
                          'timestamp': FieldValue.serverTimestamp()
                        });
                        _firestore
                            .collection('users')
                            .doc(loggedInUser.uid)
                            .collection('messages')
                            .doc(widget.selectedUser)
                            .collection('pms')
                            .doc()
                            .set({
                          'text': messageText,
                          'sender': loggedInUser.email,
                          'timestamp': FieldValue.serverTimestamp()
                        });
                        // .add({
                        //   'text': messageText,
                        //   'sender': loggedInUser.email,
                        //   'timestamp': FieldValue.serverTimestamp()
                        // });
                        //Implement send functionality.
                      },
                      child: FaIcon(FontAwesomeIcons.arrowRight)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class MessageBubble extends StatelessWidget {
  final String text;
  final String sender;
  final bool isMe;
  MessageBubble(
      {@required this.text, @required this.sender, @required this.isMe});
  @override
  Widget build(BuildContext context) {
    if (isMe) {
      return Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Container(
              constraints: BoxConstraints(minWidth: 0, maxWidth: 200),
              decoration: isAllEmoji(text)
                  ? BoxDecoration(color: Colors.transparent)
                  : BoxDecoration(
                      borderRadius: BorderRadius.only(
                          bottomLeft: Radius.circular(30.0),
                          topLeft: Radius.circular(30.0),
                          bottomRight: Radius.circular(30.0)),
                      gradient: LinearGradient(
                        colors: [
                          Colors.purple,
                          Colors.deepPurple,
                          Colors.blueAccent
                        ],
                        begin: Alignment.bottomRight,
                        end: Alignment.topLeft,
                      ),
                    ),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                    vertical: 15.0, horizontal: 20.0),
                child: RichText(
                  overflow: TextOverflow.clip,
                  strutStyle: StrutStyle(fontSize: 12.0),
                  text: TextSpan(
                    style: isAllEmoji(text)
                        ? TextStyle(
                            fontSize: 25,
                          )
                        : TextStyle(
                            fontSize: 16.0,
                            color: Colors.white,
                            // fontWeight: FontWeight.w500,
                            fontFamily: 'Metropolis'),
                    text: text == null ? '' : text,
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    } else {
      return Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(bottom: 5.0),
              child: Text(
                sender,
                style: TextStyle(color: Colors.black54, fontSize: 12),
              ),
            ),
            Container(
              constraints: BoxConstraints(minWidth: 0, maxWidth: 200),
              // elevation: 5.0,
              decoration: isAllEmoji(text)
                  ? BoxDecoration(
                      color: Colors.transparent,
                    )
                  : BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Colors.pink, Colors.redAccent, Colors.orange],
                        begin: Alignment.bottomRight,
                        end: Alignment.topLeft,
                      ),
                      borderRadius: BorderRadius.only(
                          bottomLeft: Radius.circular(30.0),
                          topRight: Radius.circular(30.0),
                          bottomRight: Radius.circular(30.0)),
                    ),

              child: Padding(
                padding: const EdgeInsets.symmetric(
                    vertical: 15.0, horizontal: 20.0),
                child: Text(
                  text == null ? '' : text,
                  style: isAllEmoji(text)
                      ? TextStyle(
                          fontSize: 25,
                        )
                      : TextStyle(
                          fontSize: 16,
                          color: Colors.white,
                          fontFamily: 'Metropolis',
                        ),
                ),
              ),
            ),
          ],
        ),
      );
    }
  }
}

class MessageStream extends StatelessWidget {
  final selectedUser;

  MessageStream({@required this.selectedUser});
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: _firestore
          .collection('users')
          .doc(loggedInUser.uid)
          .collection('messages')
          .doc(selectedUser)
          .collection('pms')
          .orderBy('timestamp')
          .snapshots(),
      builder: (context, snapshot) {
        List<MessageBubble> messageBubbles = [];
        if (!snapshot.hasData) {
          return Center(
            child: CircularProgressIndicator(
              backgroundColor: Colors.lightBlue,
            ),
          );
        }
        final messages = snapshot.data.docs.reversed;

        for (var message in messages) {
          final messageText = message['text'];
          final messageSender = message['sender'];
          final currentUser = loggedInUser.email;
          final messageBubble = MessageBubble(
            text: messageText,
            sender: messageSender,
            isMe: currentUser == messageSender,
          );
          messageBubbles.add(messageBubble);
        }
        return Expanded(
          child: ListView(
            reverse: true,
            children: messageBubbles,
          ),
        );
      },
    );
  }
}
