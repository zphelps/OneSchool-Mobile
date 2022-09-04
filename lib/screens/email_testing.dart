import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:twilio_flutter/twilio_flutter.dart';

class EmailTesting extends StatefulWidget {
  const EmailTesting({Key? key}) : super(key: key);

  @override
  State<EmailTesting> createState() => _EmailTestingState();
}

class _EmailTestingState extends State<EmailTesting> {

  final HttpsCallable callable = FirebaseFunctions.instance.httpsCallable(
    'genericEmail',
  );

  final FirebaseAuth auth = FirebaseAuth.instance;

  late User user;

  String emailAddress = 'zach@zachphelps.com';

  late TwilioFlutter twilioFlutter;

  void sendSms() async {
    twilioFlutter.sendSMS(
        toNumber: '+13176008283', messageBody: 'Hii everyone this is a demo of\nflutter twilio sms.');
  }

  @override
  initState() {
    super.initState();
    auth.authStateChanges().listen((u) {
      setState(() => user = u!);
    });
    twilioFlutter = TwilioFlutter(
        accountSid: 'AC6c55b95328b611d109d79f2e6e1a4c04',
        authToken: 'a02311b614934fb6d024d73ce57ed953',
        twilioNumber: '+13866148925');

  }

  sendEmail() {
    return callable.call({
      'text': 'Sending email with Flutter and SendGrid is fun!',
      'subject': 'Email from Flutter'
    }).then((res) => print(res.data));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Send Email with SendGrid and Flutter'),),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            if (user != null) ...[
              Text('$user'),
              FlatButton(child: Text('SignOut'), onPressed: auth.signOut),
              FlatButton(child: Text('Send Email with Callable Function'), onPressed: sendEmail)
            ]

            else ...[
              FlatButton(child: Text('Login'), onPressed: () => auth.createUserWithEmailAndPassword(email: emailAddress, password: 'demoPass23'))
            ]
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: sendSms,
        tooltip: 'Send Sms',
        child: const Icon(Icons.send),
      ),
    );
  }
}
