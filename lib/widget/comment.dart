// ignore_for_file: use_build_context_synchronously

import 'dart:convert';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

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
          showModalBottomSheet(
            context: context,
            builder: (context) => Center(
              child: TextFormField(
                controller: controller,
                autofocus: true,
                minLines: 1,
                maxLines: 100,
                decoration: InputDecoration(
                  hintText: "Type your cooment",
                  suffix: IconButton(
                    onPressed: () async {
                      List comment = widget.comment;
                      final temDocOfUser = await FirebaseFirestore.instance
                          .collection('user')
                          .doc(FirebaseAuth.instance.currentUser!.email)
                          .get();
                      String profileLink = temDocOfUser['profile'];
                      comment.add(
                        jsonEncode({
                          'email': FirebaseAuth.instance.currentUser!.email,
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
                      showModalBottomSheet(
                        context: context,
                        builder: (context) => const Center(
                          child: Text('Comment sent successful.'),
                        ),
                      );
                    },
                    icon: const Icon(
                      Icons.send,
                      size: 36,
                    ),
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
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
                  Padding(
                    padding: const EdgeInsets.all(5),
                    child: Text(
                      email,
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      style: const TextStyle(
                          fontSize: 20, fontWeight: FontWeight.bold),
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
