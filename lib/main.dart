import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'message.dart';
import 'message_list_entry.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  final String appTitle = 'ESTG instant messaging';
  @override
  Widget build(BuildContext context) => MaterialApp(
        title: appTitle,
        home: MainPage(appTitle),
      );
}

class MainPage extends StatelessWidget {
  final String appTitle;
  const MainPage(this.appTitle);
  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: Text(appTitle)),
        body: MessagingWidget(),
      );
}

class MessagingWidget extends StatefulWidget {
  @override
  _MessagingWidgetState createState() => _MessagingWidgetState();
}

class _MessagingWidgetState extends State<MessagingWidget> {
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging();
  final List<Message> messages = [];
  final ScrollController listScrollController = ScrollController();
  final TextEditingController _msgController = TextEditingController();

  String _token =
      "AAAAesu7sc0:APA91bFJ08Q55bv4xt1T8AphBMesbH_dwAjJCMUxANTSrODq49feVNdp0Q3HG9Cjd4j27koFLeV5h6Ix_AcsjWr8jAo0EGDaGaLNfbCzfyc-gWpMU4oT7wpvA4de5syWFO3dMMcBM55s";

  @override
  void initState() {
    super.initState();
    _firebaseMessaging.configure(
      onMessage: (Map<String, dynamic> message) async {
        final notification = message['notification'];
        setState(() {
          messages.add(Message(notification['title'], notification['body']));
        });
      },
      onLaunch: (Map<String, dynamic> message) async {
        final notification = message['data'];
        setState(() {
          messages.add(Message(
            '${notification['title']}',
            '${notification['body']}',
          ));
        });
      },
      onResume: (Map<String, dynamic> message) async {},
    );
    _firebaseMessaging.requestNotificationPermissions(
        const IosNotificationSettings(sound: true, badge: true, alert: true));
    // Subscribe a topic called 'all'
    _firebaseMessaging.subscribeToTopic("all");
    _firebaseMessaging.getToken().then((token) => _token = token);
  }

  @override
  Widget build(BuildContext context) {
    var mensagem = "";
    _msgController.text = "";

    final List<MessageListEntry> list = messages.map((_message) {
      String who = (_token == _message.title) ? "eu disse:" : "alguém disse:";
      return MessageListEntry(who, _message.body, _message.title == _token);
    }).toList();
    return SafeArea(
        child: Column(children: <Widget>[
      Flexible(
          child: ListView(
              padding: const EdgeInsets.all(12.0),
              controller: listScrollController,
              children: list)),
      TextFormField(
        controller: _msgController,
        decoration: InputDecoration(
            border: OutlineInputBorder(),
            labelText: "Escreva a sua mensagem...",
            suffixIcon: IconButton(
                onPressed: () => {
                      if (mensagem != "")
                        {
                          _sendNotification(mensagem, _token),
                          _msgController.clear()
                        }
                    },
                icon: Icon(Icons.send))),
        onChanged: (texto) {
          mensagem = texto;
        },
        onFieldSubmitted: (String _message) {
          _sendNotification(_message, _token);
          _msgController.clear();
        },
      ),
    ]));
  }

  void _sendNotification(body, title) async {
// Replace with server token from firebase console settings. final String serverToken = '<Server-Token>';
    await http.post(
      'https://fcm.googleapis.com/fcm/send',
      headers: <String, String>{
        'Content-Type': 'application/json',
        'Authorization':
            'key=AAAAesu7sc0:APA91bFJ08Q55bv4xt1T8AphBMesbH_dwAjJCMUxANTSrODq49feVNdp0Q3HG9Cjd4j27koFLeV5h6Ix_AcsjWr8jAo0EGDaGaLNfbCzfyc-gWpMU4oT7wpvA4de5syWFO3dMMcBM55s',
      },
      body: jsonEncode(
        <String, dynamic>{
          'notification': <String, dynamic>{'body': body, 'title': title},
          'priority': 'high',
          'data': <String, dynamic>{
            'click_action': 'FLUTTER_NOTIFICATION_CLICK',
            'id': '1',
            'status': 'done'
          },
          'to': '/topics/all',
        },
      ),
    );
  }
}
