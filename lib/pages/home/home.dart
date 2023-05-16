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
import '../../widget/editor.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection("home")
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
                  padding: const EdgeInsets.all(8.0),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(shape: elevatedStyle),
                    onPressed: () async {
                      final addminDoc = await FirebaseFirestore.instance
                          .collection('admin')
                          .doc('admin')
                          .get();
                      List adminList = addminDoc['admin'];
                      if (FirebaseAuth.instance.currentUser != null) {
                        if (adminList.contains(
                            FirebaseAuth.instance.currentUser!.email)) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  const Editor(contributionArea: 'home'),
                            ),
                          );
                        } else {
                          Fluttertoast.showToast(
                            msg: "Only admin can Edit this page",
                            toastLength: Toast.LENGTH_LONG,
                            gravity: ToastGravity.BOTTOM,
                            backgroundColor: Colors.grey[700],
                            textColor: Colors.white,
                            timeInSecForIosWeb: 3,
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
                    child: const Text('Edit This Page'),
                  ),
                );
              } else {
                final allDoc = jsonDecode(currentDoc['doc']);
                final info = allDoc['info'];
                int len = int.parse(info['len']);
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
                            errorWidget: (context, url, error) => Center(
                              child: OutlinedButton(
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
                                    fontSize: 22,
                                    color: Colors.blue,
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
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
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

                                            if (!await launchUrl(
                                              Uri.parse(
                                                'https://replit.com/languages/python',
                                              ),
                                            )) {
                                              Fluttertoast.showToast(
                                                msg: "Couldn't launch url!",
                                                toastLength: Toast.LENGTH_LONG,
                                                gravity: ToastGravity.BOTTOM,
                                                backgroundColor:
                                                    Colors.grey[700],
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
                  padding: const EdgeInsets.only(
                      top: 8, bottom: 8, left: 2, right: 2),
                  child: Column(
                    children: [
                      const SizedBox(
                        height: 15,
                      ),
                      Container(
                        decoration: BoxDecoration(
                          color: const Color.fromARGB(82, 120, 120, 120),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(9),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: listOfContent,
                          ),
                        ),
                      ),
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
