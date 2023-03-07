// ignore_for_file: use_build_context_synchronously

import 'package:email_validator/email_validator.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../pages/profile/settings.dart';

class ForgetPassword extends StatefulWidget {
  const ForgetPassword({super.key});

  @override
  State<ForgetPassword> createState() => _ForgetPasswordState();
}

class _ForgetPasswordState extends State<ForgetPassword> {
  final key = GlobalKey<FormState>();
  final textController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Forget Password'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Form(
            key: key,
            child: SafeArea(
              child: Column(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(
                    height: 10,
                  ),
                  TextFormField(
                    controller: textController,
                    autocorrect: false,
                    validator: (value) {
                      if (EmailValidator.validate(value!)) {
                        return null;
                      }

                      return "Email is valid.";
                    },
                    decoration: InputDecoration(
                      hintText: "Type your Email...",
                      labelText: "Email",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  ElevatedButton(
                    onPressed: !buttonClickable
                        ? null
                        : () async {
                            if (key.currentState!.validate()) {
                              await FirebaseAuth.instance
                                  .sendPasswordResetEmail(
                                      email: textController.text);
                              Navigator.pop(context);
                              setState(() {
                                buttonClickable = false;
                              });
                              Future.delayed(const Duration(seconds: 60), () {
                                setState(() {
                                  buttonClickable = true;
                                });
                              });

                              showModalBottomSheet(
                                context: context,
                                builder: (context) => const Center(
                                  child: Text(
                                    'Email send successfull',
                                  ),
                                ),
                              );
                            }
                          },
                    child: const Text('Send mail to reset password'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
