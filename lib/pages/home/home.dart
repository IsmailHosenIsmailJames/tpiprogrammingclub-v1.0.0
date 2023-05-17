// ignore_for_file: use_build_context_synchronously

import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_quill/flutter_quill.dart' hide Text;
import 'package:fluttertoast/fluttertoast.dart';
import 'package:tpiprogrammingclub/pages/home/home_page.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../authentication/login.dart';
import '../../widget/comment.dart';
import '../../widget/modify_post.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  bool oneTimeCall = true;
  bool getDocumentOneTime = true;
  Widget documentVew = const Center(child: CircularProgressIndicator());
  List<Widget> listOfTuorialWidget = [];
  Widget allTutorialWidget = const Center(child: CircularProgressIndicator());

  void getSingleDocument(String contentName, String id) async {
    setState(() {
      getDocumentOneTime = false;
    });
    final documentRef =
        FirebaseFirestore.instance.collection(contentName).doc(id);
    final document = await documentRef.get();
    if (document.exists) {
      final allDoc = jsonDecode(document['doc']);
      List like = document['like'];
      final user = FirebaseAuth.instance.currentUser;
      List comment = document['comment'];
      final info = allDoc['info'];
      int len = int.parse(info['len']);
      String email = info['email'];

      List<Widget> listOfContent = [];
      for (var i = 0; i < len - 1; i++) {
        final singleDoc = allDoc['$i'];
        String type = singleDoc['type'];

        if (type == "quill") {
          QuillController singleContentWidget = QuillController(
            document: Document.fromJson(
              jsonDecode(singleDoc['doc']),
            ),
            selection: const TextSelection.collapsed(offset: 0),
          );
          Widget myWiget = QuillEditor.basic(
            controller: singleContentWidget,
            readOnly: true,
          );
          listOfContent.add(myWiget);
        }
        if (type == "image") {
          listOfContent.add(
            Padding(
              padding: const EdgeInsets.only(top: 10, bottom: 10),
              child: GestureDetector(
                onTap: () async {
                  if (!await launchUrl(
                    Uri.parse(
                      singleDoc['doc'],
                    ),
                  )) {
                    throw Exception(
                      'Could not launch ${singleDoc['doc']}',
                    );
                  }
                },
                child: SizedBox(
                  height: MediaQuery.of(context).size.width * 0.60,
                  width: MediaQuery.of(context).size.width,
                  child: CachedNetworkImage(
                    imageUrl: singleDoc['doc'],
                    progressIndicatorBuilder:
                        (context, url, downloadProgress) => Center(
                      child: Center(
                        child: CircularProgressIndicator(
                            value: downloadProgress.progress),
                      ),
                    ),
                    errorWidget: (context, url, error) => OutlinedButton(
                      onPressed: () async {
                        if (!await launchUrl(
                          Uri.parse(
                            singleDoc['doc'],
                          ),
                        )) {
                          throw Exception(
                            'Could not launch ${singleDoc['doc']}',
                          );
                        }
                      },
                      child: const Text(
                        'For Image Click Here',
                        style: TextStyle(
                          color: Colors.blue,
                          fontSize: 22,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          );
        }
        if (type == 'code') {
          listOfContent.add(
            Padding(
              padding: const EdgeInsets.all(3),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15),
                  color: Colors.black,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(
                              width: 10,
                            ),
                            CircleAvatar(
                              radius: 4,
                              backgroundColor: Colors.red,
                            ),
                            SizedBox(
                              width: 5,
                            ),
                            CircleAvatar(
                              radius: 4,
                              backgroundColor: Colors.yellow,
                            ),
                            SizedBox(
                              width: 5,
                            ),
                            CircleAvatar(
                              radius: 4,
                              backgroundColor: Colors.green,
                            )
                          ],
                        ),
                        Row(
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(right: 7),
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  shape: elevatedStyle,
                                  backgroundColor: Colors.blueGrey,
                                ),
                                onPressed: () {
                                  Clipboard.setData(
                                    ClipboardData(
                                      text: singleDoc['doc'],
                                    ),
                                  );
                                  Fluttertoast.showToast(
                                    msg: "Copied Successfull!",
                                    toastLength: Toast.LENGTH_LONG,
                                    gravity: ToastGravity.BOTTOM,
                                    backgroundColor: Colors.grey[700],
                                    textColor: Colors.white,
                                    timeInSecForIosWeb: 3,
                                  );
                                },
                                child: const Row(
                                  children: [
                                    Text('Copy'),
                                    Icon(Icons.copy),
                                  ],
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(right: 7),
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  shape: elevatedStyle,
                                  backgroundColor: Colors.blueGrey,
                                ),
                                onPressed: () async {
                                  Clipboard.setData(
                                    ClipboardData(text: singleDoc['doc']),
                                  );
                                  Fluttertoast.showToast(
                                    msg: "Copied Successfull!",
                                    toastLength: Toast.LENGTH_LONG,
                                    gravity: ToastGravity.BOTTOM,
                                    backgroundColor: Colors.grey[700],
                                    textColor: Colors.white,
                                    timeInSecForIosWeb: 3,
                                  );

                                  if (contentName == "python") {
                                    if (!await launchUrl(
                                      Uri.parse(
                                        'https://replit.com/languages/python3',
                                      ),
                                    )) {
                                      Fluttertoast.showToast(
                                        msg: "Couldn't launch url!",
                                        toastLength: Toast.LENGTH_LONG,
                                        gravity: ToastGravity.BOTTOM,
                                        backgroundColor: Colors.grey[700],
                                        textColor: Colors.white,
                                        timeInSecForIosWeb: 3,
                                      );
                                    }
                                  } else if (contentName == "java") {
                                    if (!await launchUrl(
                                      Uri.parse(
                                        'https://replit.com/languages/java10',
                                      ),
                                    )) {
                                      Fluttertoast.showToast(
                                        msg: "Couldn't launch url!",
                                        toastLength: Toast.LENGTH_LONG,
                                        gravity: ToastGravity.BOTTOM,
                                        backgroundColor: Colors.grey[700],
                                        textColor: Colors.white,
                                        timeInSecForIosWeb: 3,
                                      );
                                    }
                                  } else if (contentName == 'javascript') {
                                    if (!await launchUrl(
                                      Uri.parse(
                                        'https://replit.com/languages/nodejs',
                                      ),
                                    )) {
                                      Fluttertoast.showToast(
                                        msg: "Couldn't launch url!",
                                        toastLength: Toast.LENGTH_LONG,
                                        gravity: ToastGravity.BOTTOM,
                                        backgroundColor: Colors.grey[700],
                                        textColor: Colors.white,
                                        timeInSecForIosWeb: 3,
                                      );
                                    }
                                  } else if (contentName == 'c++') {
                                    if (!await launchUrl(
                                      Uri.parse(
                                        'https://replit.com/languages/cpp',
                                      ),
                                    )) {
                                      Fluttertoast.showToast(
                                        msg: "Couldn't launch url!",
                                        toastLength: Toast.LENGTH_LONG,
                                        gravity: ToastGravity.BOTTOM,
                                        backgroundColor: Colors.grey[700],
                                        textColor: Colors.white,
                                        timeInSecForIosWeb: 3,
                                      );
                                    }
                                  } else if (contentName == 'c#') {
                                    if (!await launchUrl(
                                      Uri.parse(
                                        'https://replit.com/languages/csharp',
                                      ),
                                    )) {
                                      Fluttertoast.showToast(
                                        msg: "Couldn't launch url!",
                                        toastLength: Toast.LENGTH_LONG,
                                        gravity: ToastGravity.BOTTOM,
                                        backgroundColor: Colors.grey[700],
                                        textColor: Colors.white,
                                        timeInSecForIosWeb: 3,
                                      );
                                    }
                                  } else if (contentName == 'c') {
                                    if (!await launchUrl(
                                      Uri.parse(
                                        'https://replit.com/languages/c',
                                      ),
                                    )) {
                                      Fluttertoast.showToast(
                                        msg: "Couldn't launch url!",
                                        toastLength: Toast.LENGTH_LONG,
                                        gravity: ToastGravity.BOTTOM,
                                        backgroundColor: Colors.grey[700],
                                        textColor: Colors.white,
                                        timeInSecForIosWeb: 3,
                                      );
                                    }
                                  } else if (contentName == 'dart') {
                                    if (!await launchUrl(
                                      Uri.parse(
                                        'https://dartpad.dev/?',
                                      ),
                                    )) {
                                      Fluttertoast.showToast(
                                        msg: "Couldn't launch url!",
                                        toastLength: Toast.LENGTH_LONG,
                                        gravity: ToastGravity.BOTTOM,
                                        backgroundColor: Colors.grey[700],
                                        textColor: Colors.white,
                                        timeInSecForIosWeb: 3,
                                      );
                                    }
                                  } else if (contentName == 'html' ||
                                      contentName == 'css') {
                                    if (!await launchUrl(
                                      Uri.parse(
                                        'https://www.programiz.com/html/online-compiler/',
                                      ),
                                    )) {
                                      Fluttertoast.showToast(
                                        msg: "Couldn't launch url!",
                                        toastLength: Toast.LENGTH_LONG,
                                        gravity: ToastGravity.BOTTOM,
                                        backgroundColor: Colors.grey[700],
                                        textColor: Colors.white,
                                        timeInSecForIosWeb: 3,
                                      );
                                    }
                                  } else {
                                    Fluttertoast.showToast(
                                      msg: "We still working on it!",
                                      toastLength: Toast.LENGTH_LONG,
                                      gravity: ToastGravity.BOTTOM,
                                      backgroundColor: Colors.grey[700],
                                      textColor: Colors.white,
                                      timeInSecForIosWeb: 3,
                                    );
                                  }
                                },
                                child: const Icon(Icons.play_arrow),
                              ),
                            ),
                          ],
                        )
                      ],
                    ),
                    const SizedBox(
                      height: 2,
                    ),
                    SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      scrollDirection: Axis.horizontal,
                      child: Padding(
                        padding: const EdgeInsets.all(5),
                        child: SelectableText(
                          singleDoc['doc'],
                          textAlign: TextAlign.start,
                          style: const TextStyle(
                            fontFamily: 'monospace',
                            fontSize: 16.0,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }
      }
      Widget profile = Padding(
        padding: const EdgeInsets.only(top: 8, bottom: 8),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(1.5),
              child: Container(
                decoration: BoxDecoration(
                  color: const Color.fromARGB(82, 150, 150, 150),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Padding(
                  padding: const EdgeInsets.only(
                      bottom: 10, top: 10, left: 1, right: 1),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: listOfContent,
                  ),
                ),
              ),
            ),
            const SizedBox(
              height: 15,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    IconButton(
                      onPressed: () async {
                        final user = FirebaseAuth.instance.currentUser;

                        if (user != null) {
                          final temDocRef = FirebaseFirestore.instance
                              .collection(contentName)
                              .doc(document.id);
                          final temUserRef = FirebaseFirestore.instance
                              .collection('user')
                              .doc(email);

                          final likkeNumberFile = await temUserRef.get();
                          int likeNumber = likkeNumberFile['like'];

                          if (like.contains(user.email)) {
                            likeNumber--;
                            await temUserRef.update({"like": likeNumber});
                            like.remove(user.email);
                          } else {
                            likeNumber++;
                            await temUserRef.update({"like": likeNumber});
                            like.add(user.email);
                          }

                          temDocRef.update({"like": like});
                          getSingleDocument(contentName, id);
                        } else {
                          await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const Login(),
                            ),
                          );
                          getSingleDocument(contentName, id);
                        }
                      },
                      icon: Icon(
                        Icons.thumb_up_alt,
                        size: 24,
                        color: (user != null && like.contains(user.email))
                            ? Colors.blue
                            : Colors.black,
                      ),
                    ),
                    const SizedBox(
                      width: 10,
                    ),
                    SelectableText("${like.length}"),
                    const SizedBox(
                      width: 40,
                    ),
                    IconButton(
                      onPressed: () {
                        final user = FirebaseAuth.instance.currentUser;
                        if (user != null) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => AllComment(
                                comment: comment,
                                id: document.id,
                                path: contentName,
                              ),
                            ),
                          );
                        } else {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const Login(),
                            ),
                          );
                        }
                      },
                      icon: const Icon(Icons.comment),
                    ),
                    const SizedBox(
                      width: 10,
                    ),
                    Text(
                      "${comment.length}",
                    ),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    ElevatedButton(
                      onPressed: () async {
                        final user = FirebaseAuth.instance.currentUser;
                        if (user != null) {
                          String useremail = user.email!;
                          if (useremail == email) {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    ModifyPost(path: contentName, id: id),
                              ),
                            );
                          } else {
                            final adminRef = await FirebaseFirestore.instance
                                .collection('admin')
                                .doc('admin')
                                .get();
                            List adminList = adminRef['admin'];
                            if (adminList.contains(useremail)) {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      ModifyPost(path: contentName, id: id),
                                ),
                              );
                            } else {
                              showModalBottomSheet(
                                context: context,
                                builder: (context) => const Center(
                                  child: Text(
                                    'You are not an Admin\nYou are not the owner/creator of this post.',
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              );
                            }
                          }
                        } else {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const Login(),
                            ),
                          );
                        }
                      },
                      child: const Text('Modify'),
                    ),
                    const SizedBox(
                      width: 15,
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      );
      setState(() {
        documentVew = profile;
      });
    } else {
      setState(() {
        documentVew = const Center(
          child: Text('No data'),
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (getDocumentOneTime) getSingleDocument("home", "00000000050000000000");
    return Scaffold(
      body: SingleChildScrollView(
          child: Padding(
        padding: const EdgeInsets.all(3.0),
        child: documentVew,
      )),
    );
  }
}
