import 'dart:convert';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_quill/flutter_quill.dart' hide Text;
import 'package:flutter_syntax_view/flutter_syntax_view.dart';
import '../../theme/change_button_theme.dart';
import '../../widget/login.dart';
import '../editor/editor.dart';

class CPlusPlus extends StatefulWidget {
  const CPlusPlus({super.key});

  @override
  State<CPlusPlus> createState() => _CPlusPlusState();
}

class _CPlusPlusState extends State<CPlusPlus> {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: FirebaseFirestore.instance.collection("c++").snapshots(),
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
          itemCount: document.length,
          itemBuilder: (context, index) {
            DocumentSnapshot currentDoc = document[index];
            if (currentDoc.id == '0') {
              return Padding(
                padding: const EdgeInsets.all(8.0),
                child: ElevatedButton(
                  onPressed: () {
                    if (FirebaseAuth.instance.currentUser != null) {
                      showCupertinoModalPopup(
                        context: context,
                        builder: (context) => Scaffold(
                          appBar: AppBar(
                            toolbarHeight: 35,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(100),
                            ),
                          ),
                          body: const Editor(contributionArea: 'c++'),
                        ),
                      );
                    } else {
                      showCupertinoModalPopup(
                          context: context,
                          builder: (context) => const Login());
                    }
                  },
                  child: const Text('Contribute and Write a C++ Tutorial'),
                ),
              );
            } else {
              final allDoc = jsonDecode(currentDoc['doc']);
              final info = allDoc['info'];
              String title = info['title'];
              String shortDes = info['des'];
              int len = int.parse(info['len']);
              String writer = info['writer'];
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
                      controller: singleContentWidget, readOnly: true);
                  listOfContent.add(myWiget);
                }
                if (type == "image") {
                  listOfContent.add(
                    Padding(
                      padding: const EdgeInsets.all(5),
                      child: SizedBox(
                        height: 500,
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
                              const Icon(Icons.error),
                        ),
                      ),
                    ),
                  );
                }
                if (type == 'code') {
                  listOfContent.add(
                    Padding(
                        padding: const EdgeInsets.all(12),
                        child: Column(
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
                                children: const [
                                  Text('Copy '),
                                  Icon(Icons.copy)
                                ],
                              ),
                            ),
                            SyntaxView(
                              code: singleDoc['doc'], // Code text
                              syntax: Syntax.DART, // Language
                              syntaxTheme: isDark
                                  ? SyntaxTheme.monokaiSublime()
                                  : SyntaxTheme.ayuLight(), // Theme
                              fontSize: 18.0, // Font size
                              withZoom:
                                  true, // Enable/Disable zoom icon controls
                              withLinesCount:
                                  true, // Enable/Disable line number
                              expanded:
                                  false, // Enable/Disable container expansion
                            ),
                          ],
                        )),
                  );
                }
              }
              Widget profile = Padding(
                padding: const EdgeInsets.all(15),
                child: Column(
                  children: [
                    SizedBox(
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
                          ),
                          const SizedBox(
                            width: 20,
                          ),
                          Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Name',
                                style: TextStyle(fontSize: 20),
                              ),
                              Text(writer),
                            ],
                          )
                        ],
                      ),
                    ),
                    const SizedBox(
                      height: 15,
                    ),
                    Center(
                      child: Text(
                        title,
                        style: const TextStyle(
                            fontSize: 30, fontWeight: FontWeight.bold),
                      ),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    Row(
                      children: [
                        const Text(
                          'Descrption :',
                          style: TextStyle(
                              fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                        Text(
                          shortDes,
                          textAlign: TextAlign.left,
                          style: const TextStyle(fontSize: 18),
                        ),
                      ],
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: listOfContent,
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
    );
  }
}
