// ignore_for_file: use_build_context_synchronously

import 'dart:convert';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_quill/flutter_quill.dart' hide Text;
import 'package:flutter_syntax_view/flutter_syntax_view.dart';
import 'package:url_launcher/url_launcher.dart';
import '../authentication/login.dart';
import '../pages/editor/editor.dart';
import '../pages/home/home_page.dart';
import '../pages/profile/profile.dart';
import '../theme/change_button_theme.dart';
import 'comment.dart';

class MyStramBuilder extends StatefulWidget {
  final String language;
  final Syntax syntax;
  const MyStramBuilder(
      {super.key, required this.language, required this.syntax});

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
                      final ref = FirebaseAuth.instance.currentUser;
                      if (ref != null) {
                        final contributorsFile = await FirebaseFirestore
                            .instance
                            .collection('user')
                            .doc('contributor')
                            .get();
                        List contrbutorList = contributorsFile['list'];
                        if (contrbutorList.contains(ref.email) ||
                            widget.language == 'blog' ||
                            widget.language == 'problemsolved') {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => Scaffold(
                                appBar: AppBar(
                                  toolbarHeight: 35,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(100),
                                  ),
                                ),
                                body: Editor(contributionArea: widget.language),
                              ),
                            ),
                          );
                        } else {
                          showModalBottomSheet(
                            context: context,
                            builder: (context) => Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  const Text(
                                    "You are not the part of Contributor.\nApply to became a contributor.",
                                    style: TextStyle(fontSize: 24),
                                  ),
                                  ElevatedButton(
                                    onPressed: () async {
                                      // aply for make you Contributor.
                                      final temref = FirebaseFirestore.instance
                                          .collection('admin')
                                          .doc('application');
                                      final applicationFile =
                                          await temref.get();
                                      List applicationList =
                                          applicationFile['list'];
                                      applicationList.add(FirebaseAuth
                                          .instance.currentUser!.email);
                                      temref.set({"list": applicationList});
                                      Navigator.pop(context);
                                      showModalBottomSheet(
                                        context: context,
                                        builder: (context) => const Center(
                                          child: Text(
                                              "Application Submit Successfull"),
                                        ),
                                      );
                                    },
                                    child: const Text('Apply now'),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }
                      } else {
                        showCupertinoModalPopup(
                            context: context,
                            builder: (context) => const Login());
                      }
                    },
                    child: Text(currentDoc['message']),
                  ),
                );
              } else {
                final allDoc = jsonDecode(currentDoc['doc']);
                List like = currentDoc['like'];
                final user = FirebaseAuth.instance.currentUser;
                bool liked = false;
                if (user != null) {
                  if (like.contains(user.email)) {
                    liked = true;
                  }
                }
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
                            height: 300,
                            width: MediaQuery.of(context).size.width -
                                MediaQuery.of(context).size.width / 10,
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
                      ),
                    );
                  }
                  if (type == 'code') {
                    listOfContent.add(
                      Column(
                        children: [
                          OutlinedButton(
                            onPressed: () {
                              Clipboard.setData(
                                ClipboardData(text: singleDoc['doc']),
                              );
                            },
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: const [Text('Copy '), Icon(Icons.copy)],
                            ),
                          ),
                          SyntaxView(
                            code: singleDoc['doc'], // Code text
                            syntax: widget.syntax, // Language
                            syntaxTheme: isDark
                                ? SyntaxTheme.monokaiSublime()
                                : SyntaxTheme.ayuLight(), // Theme
                            fontSize: 16.0, // Font size
                            withZoom: true, // Enable/Disable zoom icon controls
                            withLinesCount: true, // Enable/Disable line number
                            expanded:
                                false, // Enable/Disable container expansion
                          ),
                        ],
                      ),
                    );
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
                                  Text(
                                    name,
                                    style: const TextStyle(fontSize: 20),
                                  ),
                                  Text(email),
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
                              Text(
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
                                  const Text(
                                    "Title : ",
                                    style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  SizedBox(
                                    width:
                                        MediaQuery.of(context).size.width - 70,
                                    child: Text(title),
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
                                  const Text(
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
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          IconButton(
                            onPressed: () async {
                              final user = FirebaseAuth.instance.currentUser;
                              if (user != null) {
                                if (liked) {
                                  like.remove(user.email);
                                } else {
                                  like.add(user.email);
                                }
                                final temRef = FirebaseFirestore.instance
                                    .collection(widget.language)
                                    .doc(currentDoc.id);
                                temRef.update({"like": like});
                                await FirebaseFirestore.instance
                                    .collection('user')
                                    .doc(email)
                                    .update({"like": like.length});
                              } else {
                                showCupertinoModalPopup(
                                  context: context,
                                  builder: (context) => const Login(),
                                );
                              }
                            },
                            icon: Icon(
                              Icons.thumb_up_alt,
                              size: 24,
                              color: liked == true ? Colors.blue : Colors.black,
                            ),
                          ),
                          const SizedBox(
                            width: 10,
                          ),
                          Text("${like.length}"),
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
                                      id: currentDoc.id,
                                      path: widget.language,
                                    ),
                                  ),
                                );
                              } else {
                                showCupertinoModalPopup(
                                  context: context,
                                  builder: (context) => const Login(),
                                );
                              }
                            },
                            icon: const Icon(Icons.comment),
                          ),
                          const SizedBox(
                            width: 10,
                          ),
                          Text("${comment.length}"),
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
