// ignore_for_file: use_build_context_synchronously
import 'package:fluttertoast/fluttertoast.dart';
import 'dart:convert';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_quill/flutter_quill.dart' hide Text;
import 'package:tpiprogrammingclub/pages/profile/settings.dart';
import 'package:url_launcher/url_launcher.dart';
import '../authentication/login.dart';
import 'editor.dart';
import '../pages/home/home_page.dart';
import '../pages/profile/profile.dart';
import 'comment.dart';
import 'modify_post.dart';

class MyStramBuilder extends StatefulWidget {
  final String language;
  const MyStramBuilder({super.key, required this.language});

  @override
  State<MyStramBuilder> createState() => _MyStramBuilderState();
}

class _MyStramBuilderState extends State<MyStramBuilder> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection(widget.language)
            .snapshots(includeMetadataChanges: false),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final userSnapshot = snapshot.data?.docs;
          if (userSnapshot!.isEmpty) {
            return const Center(child: Text("No data"));
          }
          final document = snapshot.data!.docs;
          return ListView.builder(
            physics: const BouncingScrollPhysics(),
            itemCount: document.length,
            itemBuilder: (context, index) {
              DocumentSnapshot currentDoc = document[index];
              if (currentDoc.id == '0') {
                return Padding(
                  padding: const EdgeInsets.all(10),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(shape: elevatedStyle),
                    onPressed: () async {
                      // cheak if the user are loged in or not
                      final user = FirebaseAuth.instance.currentUser;
                      if (user != null) {
                        if (user.emailVerified) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  Editor(contributionArea: widget.language),
                            ),
                          );
                        } else {
                          await FirebaseAuth.instance.currentUser!.reload();
                          showModalBottomSheet(
                            context: context,
                            builder: (context) => Center(
                              child: ElevatedButton(
                                onPressed: !buttonClickable
                                    ? null
                                    : () async {
                                        try {
                                          await FirebaseAuth
                                              .instance.currentUser!
                                              .sendEmailVerification(
                                            ActionCodeSettings(
                                                url:
                                                    "https://tpiprogrammingclub.firebaseapp.com/__/auth/action?mode=action&oobCode=code"),
                                          );
                                          setState(() {
                                            buttonClickable = false;
                                          });
                                          Future.delayed(
                                              const Duration(seconds: 60), () {
                                            setState(() {
                                              buttonClickable = true;
                                            });
                                          });
                                          Navigator.pop(context);
                                          Fluttertoast.showToast(
                                            msg:
                                                "Verification Email sent Successfull\nCheak mail",
                                            toastLength: Toast.LENGTH_LONG,
                                            gravity: ToastGravity.BOTTOM,
                                            backgroundColor: Colors.grey[700],
                                            textColor: Colors.white,
                                          );
                                        } on FirebaseAuthException catch (e) {
                                          Fluttertoast.showToast(
                                            msg: e.message!,
                                            toastLength: Toast.LENGTH_LONG,
                                            gravity: ToastGravity.BOTTOM,
                                            backgroundColor: Colors.grey[700],
                                            textColor: Colors.white,
                                          );
                                        }
                                      },
                                child: const Text(
                                    'You are not verified.\nSend verification email'),
                              ),
                            ),
                          );
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
                    child: Text(currentDoc['message']),
                  ),
                );
              } else {
                final allDoc = jsonDecode(currentDoc['doc']);
                List like = currentDoc['like'];
                final user = FirebaseAuth.instance.currentUser;

                List comment = currentDoc['comment'];
                final info = allDoc['info'];
                String title = info['title'];
                String shortDes = info['des'];
                int len = int.parse(info['len']);
                String email = info['email'];
                String profilePhoto = info['profile'];
                String name = info['name'];
                List<Widget> listOfContent = [];
                for (int i = 0; i < len - 1; i++) {
                  final singleDoc = allDoc['$i'];
                  if (singleDoc != null) {
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
                        GestureDetector(
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
                              errorWidget: (context, url, error) =>
                                  OutlinedButton(
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
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: const [
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
                                          padding:
                                              const EdgeInsets.only(right: 7),
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
                                                backgroundColor:
                                                    Colors.grey[700],
                                                textColor: Colors.white,
                                              );
                                            },
                                            child: Row(
                                              children: const [
                                                Text('Copy'),
                                                Icon(Icons.copy),
                                              ],
                                            ),
                                          ),
                                        ),
                                        Padding(
                                          padding:
                                              const EdgeInsets.only(right: 7),
                                          child: ElevatedButton(
                                            style: ElevatedButton.styleFrom(
                                              shape: elevatedStyle,
                                              backgroundColor: Colors.blueGrey,
                                            ),
                                            onPressed: () async {
                                              Clipboard.setData(
                                                ClipboardData(
                                                    text: singleDoc['doc']),
                                              );
                                              Fluttertoast.showToast(
                                                msg: "Copied Successfull!",
                                                toastLength: Toast.LENGTH_LONG,
                                                gravity: ToastGravity.BOTTOM,
                                                backgroundColor:
                                                    Colors.grey[700],
                                                textColor: Colors.white,
                                              );

                                              if (widget.language == "python") {
                                                if (!await launchUrl(
                                                  Uri.parse(
                                                    'https://replit.com/languages/python3',
                                                  ),
                                                )) {
                                                  Fluttertoast.showToast(
                                                    msg: "Couldn't launch url!",
                                                    toastLength:
                                                        Toast.LENGTH_LONG,
                                                    gravity:
                                                        ToastGravity.BOTTOM,
                                                    backgroundColor:
                                                        Colors.grey[700],
                                                    textColor: Colors.white,
                                                  );
                                                }
                                              } else if (widget.language ==
                                                  "java") {
                                                if (!await launchUrl(
                                                  Uri.parse(
                                                    'https://replit.com/languages/java10',
                                                  ),
                                                )) {
                                                  Fluttertoast.showToast(
                                                    msg: "Couldn't launch url!",
                                                    toastLength:
                                                        Toast.LENGTH_LONG,
                                                    gravity:
                                                        ToastGravity.BOTTOM,
                                                    backgroundColor:
                                                        Colors.grey[700],
                                                    textColor: Colors.white,
                                                  );
                                                }
                                              } else if (widget.language ==
                                                  'javascript') {
                                                if (!await launchUrl(
                                                  Uri.parse(
                                                    'https://replit.com/languages/nodejs',
                                                  ),
                                                )) {
                                                  Fluttertoast.showToast(
                                                    msg: "Couldn't launch url!",
                                                    toastLength:
                                                        Toast.LENGTH_LONG,
                                                    gravity:
                                                        ToastGravity.BOTTOM,
                                                    backgroundColor:
                                                        Colors.grey[700],
                                                    textColor: Colors.white,
                                                  );
                                                }
                                              } else if (widget.language ==
                                                  'c++') {
                                                if (!await launchUrl(
                                                  Uri.parse(
                                                    'https://replit.com/languages/cpp',
                                                  ),
                                                )) {
                                                  Fluttertoast.showToast(
                                                    msg: "Couldn't launch url!",
                                                    toastLength:
                                                        Toast.LENGTH_LONG,
                                                    gravity:
                                                        ToastGravity.BOTTOM,
                                                    backgroundColor:
                                                        Colors.grey[700],
                                                    textColor: Colors.white,
                                                  );
                                                }
                                              } else if (widget.language ==
                                                  'c#') {
                                                if (!await launchUrl(
                                                  Uri.parse(
                                                    'https://replit.com/languages/csharp',
                                                  ),
                                                )) {
                                                  Fluttertoast.showToast(
                                                    msg: "Couldn't launch url!",
                                                    toastLength:
                                                        Toast.LENGTH_LONG,
                                                    gravity:
                                                        ToastGravity.BOTTOM,
                                                    backgroundColor:
                                                        Colors.grey[700],
                                                    textColor: Colors.white,
                                                  );
                                                }
                                              } else if (widget.language ==
                                                  'c') {
                                                if (!await launchUrl(
                                                  Uri.parse(
                                                    'https://replit.com/languages/c',
                                                  ),
                                                )) {
                                                  Fluttertoast.showToast(
                                                    msg: "Couldn't launch url!",
                                                    toastLength:
                                                        Toast.LENGTH_LONG,
                                                    gravity:
                                                        ToastGravity.BOTTOM,
                                                    backgroundColor:
                                                        Colors.grey[700],
                                                    textColor: Colors.white,
                                                  );
                                                }
                                              } else if (widget.language ==
                                                  'dart') {
                                                if (!await launchUrl(
                                                  Uri.parse(
                                                    'https://dartpad.dev/?',
                                                  ),
                                                )) {
                                                  Fluttertoast.showToast(
                                                    msg: "Couldn't launch url!",
                                                    toastLength:
                                                        Toast.LENGTH_LONG,
                                                    gravity:
                                                        ToastGravity.BOTTOM,
                                                    backgroundColor:
                                                        Colors.grey[700],
                                                    textColor: Colors.white,
                                                  );
                                                }
                                              } else if (widget.language ==
                                                      'html' ||
                                                  widget.language == 'css') {
                                                if (!await launchUrl(
                                                  Uri.parse(
                                                    'https://www.programiz.com/html/online-compiler/',
                                                  ),
                                                )) {
                                                  Fluttertoast.showToast(
                                                    msg: "Couldn't launch url!",
                                                    toastLength:
                                                        Toast.LENGTH_LONG,
                                                    gravity:
                                                        ToastGravity.BOTTOM,
                                                    backgroundColor:
                                                        Colors.grey[700],
                                                    textColor: Colors.white,
                                                  );
                                                }
                                              } else {
                                                Fluttertoast.showToast(
                                                  msg:
                                                      "We still working on it!",
                                                  toastLength:
                                                      Toast.LENGTH_LONG,
                                                  gravity: ToastGravity.BOTTOM,
                                                  backgroundColor:
                                                      Colors.grey[700],
                                                  textColor: Colors.white,
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
                }
                Widget profile = Padding(
                  padding: const EdgeInsets.only(top: 8, bottom: 8),
                  child: Column(
                    children: [
                      GestureDetector(
                        onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => Profile(email: email),
                            )),
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(100),
                            color: const Color.fromARGB(84, 153, 153, 153),
                          ),
                          height: 50,
                          width: double.infinity,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(100),
                                child: SizedBox(
                                  height: 50,
                                  width: 50,
                                  child: CachedNetworkImage(
                                    imageUrl: profilePhoto,
                                    fit: BoxFit.cover,
                                    progressIndicatorBuilder:
                                        (context, url, downloadProgress) =>
                                            Center(
                                      child: Center(
                                        child: CircularProgressIndicator(
                                            value: downloadProgress.progress),
                                      ),
                                    ),
                                    errorWidget: (context, url, error) =>
                                        const Icon(Icons.image_outlined),
                                  ),
                                ),
                              ),
                              const SizedBox(
                                width: 20,
                              ),
                              Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  SelectableText(
                                    name,
                                    style: const TextStyle(fontSize: 20),
                                  ),
                                  SelectableText(email),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(
                        height: 5,
                      ),
                      Container(
                        width: MediaQuery.of(context).size.width * 98,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          color: const Color.fromARGB(81, 168, 168, 168),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(10),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SelectableText(
                                "Rank : ${double.parse(currentDoc.id) ~/ 10000000000}",
                                style: const TextStyle(
                                    fontSize: 16, fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(
                                height: 5,
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const SelectableText(
                                    "Title : ",
                                    style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  SizedBox(
                                    width:
                                        MediaQuery.of(context).size.width - 70,
                                    child: SelectableText(title),
                                  ),
                                ],
                              ),
                              const SizedBox(
                                height: 5,
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const SelectableText(
                                    "Description : ",
                                    style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  SizedBox(
                                    width:
                                        MediaQuery.of(context).size.width - 120,
                                    child: Text(shortDes),
                                  ),
                                ],
                              )
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(
                        height: 10,
                      ),
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
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              const SizedBox(
                                width: 15,
                              ),
                              IconButton(
                                onPressed: () async {
                                  final user =
                                      FirebaseAuth.instance.currentUser;

                                  if (user != null) {
                                    final temDocRef = FirebaseFirestore.instance
                                        .collection(widget.language)
                                        .doc(currentDoc.id);
                                    final temUserRef = FirebaseFirestore
                                        .instance
                                        .collection('user')
                                        .doc(email);

                                    final likkeNumberFile =
                                        await temUserRef.get();
                                    int likeNumber = likkeNumberFile['like'];

                                    if (like.contains(user.email)) {
                                      likeNumber--;
                                      await temUserRef
                                          .update({"like": likeNumber});
                                      like.remove(user.email);
                                    } else {
                                      likeNumber++;
                                      await temUserRef
                                          .update({"like": likeNumber});
                                      like.add(user.email);
                                    }

                                    temDocRef.update({"like": like});
                                  } else {
                                    await Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => const Login(),
                                      ),
                                    );
                                  }
                                },
                                icon: Icon(
                                  Icons.thumb_up_alt,
                                  size: 24,
                                  color: (user != null &&
                                          like.contains(user.email))
                                      ? Colors.blue
                                      : Colors.grey,
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
                                  final user =
                                      FirebaseAuth.instance.currentUser;
                                  if (user != null) {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => AllComment(
                                          comment: comment,
                                          id: currentDoc.id,
                                          path: widget.language,
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
                              SelectableText("${comment.length}"),
                            ],
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              ElevatedButton(
                                onPressed: () async {
                                  final user =
                                      FirebaseAuth.instance.currentUser;
                                  if (user != null) {
                                    String useremail = user.email!;
                                    if (useremail == email) {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => ModifyPost(
                                              path: widget.language,
                                              id: currentDoc.id),
                                        ),
                                      );
                                    } else {
                                      final adminRef = await FirebaseFirestore
                                          .instance
                                          .collection('admin')
                                          .doc('admin')
                                          .get();
                                      List adminList = adminRef['admin'];
                                      if (adminList.contains(useremail)) {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) => ModifyPost(
                                                path: widget.language,
                                                id: currentDoc.id),
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
                      )
                    ],
                  ),
                );

                return profile;
              }
            },
          );
        },
      ),
    );
  }
}
