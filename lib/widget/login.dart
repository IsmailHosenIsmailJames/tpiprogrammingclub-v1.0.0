// ignore_for_file: use_build_context_synchronously

import 'package:email_validator/email_validator.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final email = TextEditingController();
  final pass = TextEditingController();
  final key = GlobalKey<FormState>();
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        height: MediaQuery.of(context).size.height -
            MediaQuery.of(context).size.height / 5,
        width: MediaQuery.of(context).size.width -
            MediaQuery.of(context).size.width / 5,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
        ),
        child: Center(
          child: Scaffold(
            backgroundColor: Colors.transparent,
            body: Center(
              child: Form(
                key: key,
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    children: [
                      const SizedBox(
                        height: 30,
                      ),
                      TextFormField(
                        autovalidateMode: AutovalidateMode.onUserInteraction,
                        autofocus: true,
                        controller: email,
                        validator: (value) {
                          if (!EmailValidator.validate(value!)) {
                            return "Please enter a valid email.";
                          }
                          return null;
                        },
                        decoration: InputDecoration(
                          hintText: "Email",
                          labelText: "type your email...",
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(5),
                          ),
                        ),
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      TextFormField(
                        autovalidateMode: AutovalidateMode.onUserInteraction,
                        controller: pass,
                        validator: (value) {
                          if (value!.length <= 5) {
                            return "Password is too short";
                          }
                          return null;
                        },
                        decoration: InputDecoration(
                          hintText: "Password",
                          labelText: "type your password...",
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(5),
                          ),
                        ),
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      ElevatedButton(
                        onPressed: () async {
                          if (key.currentState!.validate()) {
                            try {
                              await FirebaseAuth.instance
                                  .signInWithEmailAndPassword(
                                      email: email.text, password: pass.text);
                              Navigator.pop(context);
                              showModalBottomSheet(
                                context: context,
                                builder: (context) => const Center(
                                  child: Text(
                                    'Login Successfull',
                                    style: TextStyle(fontSize: 24),
                                  ),
                                ),
                              );
                            } on FirebaseAuthException catch (e) {
                              showModalBottomSheet(
                                context: context,
                                builder: (context) => Center(
                                  child: Text(
                                    e.message!,
                                    style: const TextStyle(fontSize: 20),
                                  ),
                                ),
                              );
                            }
                          }
                        },
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: const [
                            Text('Login'),
                            SizedBox(
                              width: 10,
                            ),
                            Icon(Icons.login)
                          ],
                        ),
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      const Text('Haven\'t account ?'),
                      ElevatedButton(
                        onPressed: () async {
                          if (key.currentState!.validate()) {
                            try {
                              await FirebaseAuth.instance
                                  .createUserWithEmailAndPassword(
                                      email: email.text, password: pass.text);
                              Navigator.pop(context);
                              showModalBottomSheet(
                                context: context,
                                builder: (context) => const Center(
                                  child: Text(
                                    "SignUp Successfull",
                                    style: TextStyle(fontSize: 24),
                                  ),
                                ),
                              );
                            } on FirebaseAuthException catch (e) {
                              showModalBottomSheet(
                                context: context,
                                builder: (context) => Center(
                                  child: Text(
                                    e.message!,
                                    style: const TextStyle(fontSize: 20),
                                  ),
                                ),
                              );
                            }
                          }
                        },
                        child: const Text("Sign Up"),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
