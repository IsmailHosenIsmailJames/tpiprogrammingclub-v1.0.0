// ignore_for_file: use_build_context_synchronously

import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:email_validator/email_validator.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'fogetpassword.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final email = TextEditingController();
  final name = TextEditingController();
  final pass = TextEditingController();
  final conpass = TextEditingController();
  final key = GlobalKey<FormState>();
  final key2 = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Center(
        child: Container(
          height: MediaQuery.of(context).size.height -
              MediaQuery.of(context).size.height / 5,
          width: MediaQuery.of(context).size.width -
              MediaQuery.of(context).size.width / 10,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15),
          ),
          child: Center(
            child: Scaffold(
              body: Center(
                child: Padding(
                  padding: const EdgeInsets.all(5),
                  child: ListView(
                    physics: const BouncingScrollPhysics(),
                    children: [
                      Form(
                        key: key,
                        child: Column(
                          children: [
                            const SizedBox(
                              height: 20,
                            ),
                            TextFormField(
                              autocorrect: false,
                              autovalidateMode:
                                  AutovalidateMode.onUserInteraction,
                              controller: email,
                              validator: (value) {
                                if (!EmailValidator.validate(value!)) {
                                  return "Please enter a valid email.";
                                }
                                return null;
                              },
                              decoration: InputDecoration(
                                hintText: "type your email...",
                                labelText: "Email",
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(5),
                                ),
                              ),
                            ),
                            const SizedBox(
                              height: 10,
                            ),
                            TextFormField(
                              autocorrect: false,
                              autovalidateMode:
                                  AutovalidateMode.onUserInteraction,
                              controller: pass,
                              validator: (value) {
                                if (value!.length < 3) {
                                  return "Password is too short";
                                }
                                return null;
                              },
                              decoration: InputDecoration(
                                hintText: "type your password...",
                                labelText: "Password",
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(5),
                                ),
                              ),
                            ),
                            TextButton(
                              onPressed: () {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          const ForgetPassword(),
                                    ));
                              },
                              child: const Text('Forget Password?'),
                            ),
                            ElevatedButton(
                              onPressed: () async {
                                if (key.currentState!.validate()) {
                                  try {
                                    await FirebaseAuth.instance
                                        .signInWithEmailAndPassword(
                                            email: email.text,
                                            password: pass.text);

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
                          ],
                        ),
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      const Text('Haven\'t account ?'),
                      const SizedBox(
                        height: 10,
                      ),
                      Form(
                        key: key2,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            TextFormField(
                              autovalidateMode:
                                  AutovalidateMode.onUserInteraction,
                              controller: conpass,
                              validator: (value) {
                                if (pass.text != value) {
                                  return "Did't massed";
                                }
                                return null;
                              },
                              decoration: InputDecoration(
                                hintText: "Type your password again",
                                labelText: "Confirm password",
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(5),
                                ),
                              ),
                            ),
                            const SizedBox(
                              height: 05,
                            ),
                            TextFormField(
                              autovalidateMode:
                                  AutovalidateMode.onUserInteraction,
                              controller: name,
                              validator: (value) {
                                if (value!.length < 3) {
                                  return "Name is too short";
                                }
                                return null;
                              },
                              decoration: InputDecoration(
                                hintText: "type your name...",
                                labelText: "Name",
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(5),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      ElevatedButton(
                        onPressed: () async {
                          if (key.currentState!.validate() &&
                              key2.currentState!.validate()) {
                            try {
                              if (!kIsWeb) {
                                FilePickerResult? result =
                                    await FilePicker.platform.pickFiles(
                                  allowCompression: true,
                                  type: FileType.custom,
                                  allowMultiple: false,
                                  allowedExtensions: ['jpg', 'png'],
                                );
                                if (result != null) {
                                  showModalBottomSheet(
                                    context: context,
                                    builder: (context) => const Center(
                                      child: CircularProgressIndicator(),
                                    ),
                                  );

                                  final tem = result.files.first;
                                  String? extension = tem.extension;
                                  File imageFile = File(tem.path!);

                                  String uploadePath =
                                      "user/${email.text.trim()}.$extension";
                                  final ref = FirebaseStorage.instance
                                      .ref()
                                      .child(uploadePath);
                                  UploadTask uploadTask;
                                  uploadTask = ref.putFile(imageFile);
                                  final snapshot =
                                      await uploadTask.whenComplete(() {});
                                  String url =
                                      await snapshot.ref.getDownloadURL();
                                  final temRef = FirebaseFirestore.instance
                                      .collection('user')
                                      .doc('allUser');
                                  final allUser = await temRef.get();
                                  List allUserList = allUser['email'];
                                  allUserList.add(email.text.trim());
                                  await temRef.set({'email': allUserList});

                                  await FirebaseAuth.instance
                                      .createUserWithEmailAndPassword(
                                          email: email.text,
                                          password: pass.text);
                                  final json = {
                                    "profile": url,
                                    "name": name.text.trim(),
                                    "like": 0,
                                    'post': [],
                                    'pendingPost': []
                                  };
                                  final firebaseref = FirebaseFirestore.instance
                                      .collection('user')
                                      .doc(email.text.trim());
                                  await firebaseref.set(json);

                                  Navigator.pop(context);
                                  Navigator.pop(context);
                                  showModalBottomSheet(
                                    context: context,
                                    builder: (context) => const Center(
                                      child: Text(
                                        "SignUp Successfull",
                                        textAlign: TextAlign.center,
                                        style: TextStyle(fontSize: 24),
                                      ),
                                    ),
                                  );
                                } else {
                                  showModalBottomSheet(
                                    context: context,
                                    builder: (context) => const Center(
                                      child: Text(
                                        "Please Select A profile Photo",
                                        style: TextStyle(fontSize: 24),
                                      ),
                                    ),
                                  );
                                }
                              }
                              if (kIsWeb) {
                                FilePickerResult? result =
                                    await FilePicker.platform.pickFiles(
                                        type: FileType.custom,
                                        allowMultiple: false,
                                        allowCompression: true,
                                        allowedExtensions: ['jpg', 'png']);

                                if (result != null) {
                                  showModalBottomSheet(
                                    context: context,
                                    builder: (context) => const Center(
                                      child: CircularProgressIndicator(),
                                    ),
                                  );

                                  final tem = result.files.first;
                                  Uint8List? selectedImage = tem.bytes;
                                  String? extension = tem.extension;
                                  String uploadePath =
                                      "user/${email.text.trim()}.$extension";
                                  final ref = FirebaseStorage.instance
                                      .ref()
                                      .child(uploadePath);
                                  UploadTask uploadTask;
                                  final metadata = SettableMetadata(
                                      contentType: 'image/jpeg');
                                  uploadTask =
                                      ref.putData(selectedImage!, metadata);
                                  final snapshot =
                                      await uploadTask.whenComplete(() {});
                                  String url =
                                      await snapshot.ref.getDownloadURL();

                                  final temRef = FirebaseFirestore.instance
                                      .collection('user')
                                      .doc('allUser');
                                  final allUser = await temRef.get();
                                  List allUserList = allUser['email'];
                                  allUserList.add(email.text.trim());
                                  await temRef.set({'email': allUserList});

                                  await FirebaseAuth.instance
                                      .createUserWithEmailAndPassword(
                                          email: email.text,
                                          password: pass.text);

                                  final json = {
                                    "profile": url,
                                    "name": name.text.trim(),
                                    'like': 0,
                                    'post': [],
                                    'pendingPost': []
                                  };
                                  final firebaseref = FirebaseFirestore.instance
                                      .collection('user')
                                      .doc(email.text.trim());

                                  await firebaseref.set(json);
                                  final user =
                                      FirebaseAuth.instance.currentUser;
                                  if (user != null) {
                                    await FirebaseAuth.instance.currentUser!
                                        .sendEmailVerification(
                                      ActionCodeSettings(
                                          url:
                                              "https://tpiprogrammingclub.firebaseapp.com/__/auth/action?mode=action&oobCode=code"),
                                    );
                                  }

                                  Navigator.pop(context);
                                  Navigator.pop(context);
                                  showModalBottomSheet(
                                    context: context,
                                    builder: (context) => const Center(
                                      child: Text(
                                        "SignUp Successfull\nWe have sent a mail to you.\nPlease verify your email address.",
                                        textAlign: TextAlign.center,
                                        style: TextStyle(fontSize: 24),
                                      ),
                                    ),
                                  );
                                } else {
                                  showModalBottomSheet(
                                    context: context,
                                    builder: (context) => const Center(
                                      child: Text(
                                        "Please Select A profile Photo",
                                        style: TextStyle(fontSize: 24),
                                      ),
                                    ),
                                  );
                                }
                              }
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
