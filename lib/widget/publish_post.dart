// ignore_for_file: use_build_context_synchronously

import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

import 'editor.dart';

class PublishPost extends StatefulWidget {
  final String contributionArea;
  final String name;
  final String profile;
  const PublishPost(
      {super.key,
      required this.contributionArea,
      required this.name,
      required this.profile});

  @override
  State<PublishPost> createState() => _PublishPostState();
}

class _PublishPostState extends State<PublishPost> {
  final key = GlobalKey<FormState>();
  final docNumber = TextEditingController();
  final titel = TextEditingController();
  final shortDes = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Text('Publish Post'),
            SizedBox(
              width: 10,
            ),
            Icon(Icons.public)
          ],
        ),
      ),
      body: Center(
        child: Form(
          key: key,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                TextFormField(
                  maxLength: 10,
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  controller: docNumber,
                  validator: (value) {
                    try {
                      double x = double.parse(value!);
                      if (x < 1) {
                        return "Tutorial ID must be > 1";
                      }
                    } catch (e) {
                      return "Tutorial ID must be a number.";
                    }
                    return null;
                  },
                  decoration: InputDecoration(
                    hintText: "Give a Rank of this tutorial.",
                    labelText: "Tutorial Rank",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(5),
                    ),
                  ),
                ),
                const SizedBox(
                  height: 10,
                ),
                TextFormField(
                  maxLength: 120,
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  controller: titel,
                  validator: (value) {
                    if (value!.length < 5) {
                      return "Titel is too short";
                    }
                    return null;
                  },
                  decoration: InputDecoration(
                    hintText: "give a titele",
                    labelText: "Titel",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(5),
                    ),
                  ),
                ),
                const SizedBox(
                  height: 10,
                ),
                TextFormField(
                  maxLength: 400,
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  controller: shortDes,
                  validator: (value) {
                    if (value!.length < 10) {
                      return "Description is too short";
                    }
                    return null;
                  },
                  decoration: InputDecoration(
                    hintText: "Short description about tutorial.",
                    labelText: "Description",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(5),
                    ),
                  ),
                ),
                const SizedBox(
                  height: 10,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    ElevatedButton(
                      onPressed: () async {
                        int len = json.length;
                        json.addAll({
                          "info": {
                            "len": "$len",
                            "title": titel.text.trim(),
                            "des": shortDes.text.trim(),
                            "email": FirebaseAuth.instance.currentUser!.email!,
                            "name": widget.name,
                            "profile": widget.profile,
                          }
                        });

                        double doubleId = double.parse(docNumber.text);

                        int id = (doubleId * 10000000000).toInt();
                        String sId = "$id";
                        int lenth = sId.length;
                        int needToFill = 20 - lenth;
                        String fillString = "0" * needToFill;
                        sId = fillString + sId;
                        final cheakRef = FirebaseFirestore.instance
                            .collection(widget.contributionArea)
                            .doc(sId);
                        final temdoc = await cheakRef.get();
                        if (temdoc.exists) {
                          Fluttertoast.showToast(
                            msg:
                                "This Document Rank is allready exits. Try to change the Rank",
                            toastLength: Toast.LENGTH_LONG,
                            gravity: ToastGravity.BOTTOM,
                            backgroundColor: Colors.grey[700],
                            textColor: Colors.white,
                          );
                        } else {
                          final ref = FirebaseFirestore.instance
                              .collection(widget.contributionArea)
                              .doc(sId);
                          final myEncodedJson = jsonEncode(json);
                          await ref.set({
                            'doc': myEncodedJson,
                            'like': [],
                            'comment': []
                          });
                          final searchRef = FirebaseFirestore.instance
                              .collection('search')
                              .doc(widget.contributionArea);
                          final searchFile = await searchRef.get();
                          if (searchFile.exists) {
                            List des = searchFile['des'];
                            List id = searchFile['id'];
                            List tle = searchFile['title'];
                            des.add(shortDes.text.trim());
                            id.add(sId);
                            tle.add(titel.text.trim());
                            await searchRef.set({
                              "id": id,
                              "title": tle,
                              "des": des,
                            });
                          } else {
                            final searchRef = FirebaseFirestore.instance
                                .collection('search')
                                .doc(widget.contributionArea);
                            await searchRef.set({
                              "id": [sId],
                              "title": [titel.text.trim()],
                              "des": [shortDes.text.trim()],
                            });
                          }
                        }
                        final ref = FirebaseFirestore.instance
                            .collection('user')
                            .doc(FirebaseAuth.instance.currentUser!.email);
                        final file = await ref.get();
                        List post = file['post'];
                        post.add("${widget.contributionArea}/$sId");
                        await ref.update({"post": post});

                        Navigator.pop(context);
                        Navigator.pop(context);
                        Fluttertoast.showToast(
                          msg: "Published Successfully",
                          toastLength: Toast.LENGTH_LONG,
                          gravity: ToastGravity.BOTTOM,
                          backgroundColor: Colors.grey[700],
                          textColor: Colors.white,
                        );
                      },
                      child: const Text("Publish"),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: const Text('Cancel'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
