// ignore_for_file: use_build_context_synchronously

import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_quill/flutter_quill.dart' hide Text;
import 'package:flutter_syntax_view/flutter_syntax_view.dart';
import 'package:tpiprogrammingclub/pages/profile/profile.dart';
import 'package:url_launcher/url_launcher.dart';

import '../authentication/login.dart';
import '../theme/change_button_theme.dart';
import 'comment.dart';

class SingleDocumentViewer extends StatefulWidget {
  final String path;
  final String id;
  const SingleDocumentViewer({super.key, required this.path, required this.id});

  @override
  State<SingleDocumentViewer> createState() => _SingleDocumentViewerState();
}

class _SingleDocumentViewerState extends State<SingleDocumentViewer> {
  bool callOneTime = true;
  Widget documentView = const Center(child: CircularProgressIndicator());

  void getFile() async {
    setState(() {
      callOneTime = false;
    });
    final documentRef =
        FirebaseFirestore.instance.collection(widget.path).doc(widget.id);
    final document = await documentRef.get();
    if (document.exists) {
      final allDoc = jsonDecode(document['doc']);
      List like = document['like'];
      final user = FirebaseAuth.instance.currentUser;
      List comment = document['comment'];
      final info = allDoc['info'];
      String title = info['title'];
      String shortDes = info['des'];
      int len = int.parse(info['len']);
      String email = info['email'];
      String profilePhoto = info['profile'];
      String name = info['name'];

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
                    errorWidget: (context, url, error) => const Text(
                      'For Image Click Here',
                      style: TextStyle(
                        fontSize: 22,
                        color: Colors.blue,
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
                  syntax: Syntax.JAVASCRIPT,
                  syntaxTheme: isDark
                      ? SyntaxTheme.monokaiSublime()
                      : SyntaxTheme.ayuLight(), // Theme
                  fontSize: 16.0, // Font size
                  withZoom: true, // Enable/Disable zoom icon controls
                  withLinesCount: true, // Enable/Disable line number
                  expanded: false, // Enable/Disable container expansion
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
                              (context, url, downloadProgress) => Center(
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
                      "Rank : ${double.parse(document.id) ~/ 10000000000}",
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
                              fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        SizedBox(
                          width: MediaQuery.of(context).size.width - 70,
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
                              fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        SizedBox(
                          width: MediaQuery.of(context).size.width - 120,
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
                      final temDocRef = FirebaseFirestore.instance
                          .collection(widget.path)
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
                      getFile();
                    } else {
                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const Login(),
                        ),
                      );
                      getFile();
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
                            id: document.id,
                            path: widget.path,
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
                Text("${comment.length}"),
              ],
            )
          ],
        ),
      );
      setState(() {
        documentView = profile;
      });
    } else {
      documentView = const Center(
        child: Text('No data'),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (callOneTime) getFile();
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.path),
      ),
      body: ListView(
        children: [
          documentView,
        ],
      ),
    );
  }
}
