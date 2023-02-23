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
import '../theme/change_button_theme.dart';

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
                    onPressed: () {
                      if (FirebaseAuth.instance.currentUser != null) {
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
                              errorWidget: (context, url, error) => const Text(
                                'To See The Image Click Here',
                                style: TextStyle(
                                    fontSize: 26,
                                    backgroundColor: Colors.amber),
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
                      Container(
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
                            Container(
                              height: 50,
                              width: 50,
                              decoration: BoxDecoration(
                                color: Colors.greenAccent,
                                borderRadius: BorderRadius.circular(100),
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(100),
                                child: CachedNetworkImage(
                                  imageUrl: profilePhoto,
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
                      const SizedBox(
                        height: 5,
                      ),
                      Text(
                        'Tutorial Rank : ${int.parse(currentDoc.id) / 10000000000}',
                        style: const TextStyle(fontSize: 18),
                      ),
                      Center(
                        child: Text(
                          title,
                          style: const TextStyle(
                              fontSize: 30, fontWeight: FontWeight.bold),
                        ),
                      ),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          const Text(
                            'Descrption :',
                            style: TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          Text(
                            shortDes,
                            textAlign: TextAlign.center,
                            style: const TextStyle(fontSize: 18),
                          ),
                        ],
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
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Icon(
                            Icons.thumb_up_alt,
                            size: 24,
                          ),
                          SizedBox(
                            width: 20,
                          ),
                          Icon(Icons.comment),
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
