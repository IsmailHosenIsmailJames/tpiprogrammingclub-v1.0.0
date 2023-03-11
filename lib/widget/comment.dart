// ignore_for_file: use_build_context_synchronously

import 'dart:convert';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:tpiprogrammingclub/pages/profile/profile.dart';

class AllComment extends StatefulWidget {
  final List comment;
  final String path;
  final String id;
  const AllComment(
      {super.key, required this.comment, required this.id, required this.path});

  @override
  State<AllComment> createState() => _AllCommentState();
}

class _AllCommentState extends State<AllComment> {
  final controller = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showCupertinoModalPopup(
            context: context,
            builder: (context) => Scaffold(
              body: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    TextFormField(
                      controller: controller,
                      autofocus: true,
                      minLines: 1,
                      maxLines: 100,
                      decoration: InputDecoration(
                        hintText: "Type your cooment",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        ElevatedButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          child: const Text('Cancel'),
                        ),
                        ElevatedButton(
                          onPressed: () async {
                            List comment = widget.comment;
                            final temDocOfUser = await FirebaseFirestore
                                .instance
                                .collection('user')
                                .doc(FirebaseAuth.instance.currentUser!.email)
                                .get();
                            String profileLink = temDocOfUser['profile'];
                            comment.add(
                              jsonEncode({
                                'email':
                                    FirebaseAuth.instance.currentUser!.email,
                                'profile': profileLink,
                                'comment': controller.text.trim(),
                              }),
                            );
                            await FirebaseFirestore.instance
                                .collection(widget.path)
                                .doc(widget.id)
                                .update({
                              "comment": comment,
                            });
                            Navigator.pop(context);
                            Navigator.pop(context);
                            Fluttertoast.showToast(
                              msg: "Comment Sent Successfull",
                              toastLength: Toast.LENGTH_LONG,
                              gravity: ToastGravity.BOTTOM,
                              backgroundColor: Colors.grey[700],
                              textColor: Colors.white,
                            );
                          },
                          child: const Icon(Icons.send_outlined),
                        ),
                      ],
                    )
                  ],
                ),
              ),
            ),
          );
        },
        child: const Icon(Icons.message),
      ),
      appBar: AppBar(
        title: const Text('Comment'),
      ),
      body: ListView.builder(
        physics: const BouncingScrollPhysics(),
        itemCount: widget.comment.length,
        itemBuilder: (context, index) {
          String currentComment = widget.comment[index];
          final json = jsonDecode(currentComment);
          String email = json['email'];
          String comment = json['comment'];
          String profile = json['profile'];
          return Padding(
            padding: const EdgeInsets.all(8.0),
            child: Container(
              decoration: BoxDecoration(
                color: const Color.fromARGB(81, 162, 162, 162),
                borderRadius: BorderRadius.circular(5),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  GestureDetector(
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => Profile(email: email),
                      ),
                    ),
                    child: Row(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(100),
                          child: Container(
                            color: Colors.lightBlueAccent,
                            height: 50,
                            width: 50,
                            child: CachedNetworkImage(
                              imageUrl: profile,
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
                          width: 5,
                        ),
                        Text(
                          email,
                          textAlign: TextAlign.center,
                          softWrap: true,
                          style: const TextStyle(
                              fontSize: 14,
                              color: Colors.blue,
                              fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(10),
                    child: Text(
                      comment,
                      softWrap: true,
                      maxLines: 1000,
                      textAlign: TextAlign.start,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
