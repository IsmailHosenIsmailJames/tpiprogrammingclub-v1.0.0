// ignore_for_file: use_build_context_synchronously

import 'dart:convert';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:tpiprogrammingclub/pages/profile/profile.dart';

import '../main.dart';
import '../pages/home/home_page.dart';

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
      drawer: const MyDrawer(),
      appBar: AppBar(
        title: const Text("Comments"),
      ),
      body: Container(
        decoration: BoxDecoration(gradient: gradiantOfcontaner),
        child: Column(
          children: [
            Expanded(
              child: ListView.builder(
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
                                  width: 5,
                                ),
                                SelectableText(
                                  email,
                                  textAlign: TextAlign.center,
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
                            child: SelectableText(
                              comment,
                              textAlign: TextAlign.start,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 5),
              child: Container(
                decoration: const BoxDecoration(
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(15),
                    topRight: Radius.circular(15),
                  ),
                  color: Colors.black26,
                ),
                child: Padding(
                  padding: const EdgeInsets.all(5),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: controller,
                          autocorrect: true,
                          minLines: 1,
                          maxLines: 1000,
                          decoration: InputDecoration(
                            hintText: "Type here...",
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                          ),
                        ),
                      ),
                      IconButton(
                        onPressed: () async {
                          if (controller.text.trim().isNotEmpty) {
                            {
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
                              setState(() {
                                comment;
                              });
                              Fluttertoast.showToast(
                                msg: "Comment Sent Successfull",
                                toastLength: Toast.LENGTH_LONG,
                                gravity: ToastGravity.BOTTOM,
                                backgroundColor: Colors.grey[700],
                                textColor: Colors.white,
                                timeInSecForIosWeb: 3,
                              );
                            }
                          }
                        },
                        icon: const Icon(Icons.send),
                      )
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
