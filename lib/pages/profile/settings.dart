import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class MySettings extends StatefulWidget {
  const MySettings({super.key});

  @override
  State<MySettings> createState() => _MySettingsState();
}

bool buttonClickable = true;

class _MySettingsState extends State<MySettings> {
  void reload() async {
    await Future.delayed(const Duration(seconds: 10), () {});
    await FirebaseAuth.instance.currentUser!.reload();
  }

  @override
  Widget build(BuildContext context) {
    if (!buttonClickable) reload();
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(10),
        child: ListView(
          children: [
            const SizedBox(
              height: 10,
            ),
            Text(
              'Profile Status : ${FirebaseAuth.instance.currentUser!.emailVerified ? "Verified" : "Not Verified"}',
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(
              height: 10,
            ),
            if (!FirebaseAuth.instance.currentUser!.emailVerified)
              ElevatedButton(
                onPressed: !buttonClickable
                    ? null
                    : () async {
                        await FirebaseAuth.instance.currentUser!
                            .sendEmailVerification(
                          ActionCodeSettings(
                            url:
                                "https://tpiprogrammingclub.firebaseapp.com/__/auth/action?mode=action&oobCode=code",
                          ),
                        );
                        setState(() {
                          buttonClickable = false;
                        });
                        Future.delayed(const Duration(seconds: 60), () {
                          setState(() {
                            buttonClickable = true;
                          });
                        });
                      },
                child: const Text(
                  'Send Verification email',
                ),
              ),
            const Divider(
              color: Colors.black,
            ),
            const Text(
              'If you want to change your password, click here.\nIt will sent a email for reset password to you.',
              textAlign: TextAlign.start,
            ),
            ElevatedButton(
              onPressed: !buttonClickable
                  ? null
                  : () async {
                      await FirebaseAuth.instance.sendPasswordResetEmail(
                        email: FirebaseAuth.instance.currentUser!.email!,
                      );
                      setState(() {
                        buttonClickable = false;
                      });
                      Future.delayed(const Duration(seconds: 60), () {
                        setState(() {
                          buttonClickable = true;
                        });
                      });
                    },
              child: const Text("Send password reset mail"),
            ),
          ],
        ),
      ),
    );
  }
}
