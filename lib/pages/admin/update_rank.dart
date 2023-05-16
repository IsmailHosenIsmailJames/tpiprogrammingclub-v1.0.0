import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

class UpdateRank extends StatefulWidget {
  const UpdateRank({super.key});

  @override
  State<UpdateRank> createState() => _UpdateRankState();
}

class _UpdateRankState extends State<UpdateRank> {
  String text = "Relax Untill We Finished Our Work";
  bool oneTileCall = true;

  void task() async {
    setState(() {
      oneTileCall = false;
    });
    final allUserFile = await FirebaseFirestore.instance
        .collection('user')
        .doc('allUser')
        .get();
    List allUser = allUserFile['email'];
    List info = [];
    for (var i = 0; i < allUser.length; i++) {
      final userFile = await FirebaseFirestore.instance
          .collection('user')
          .doc(allUser[i])
          .get();
      String name = userFile['name'];
      String email = allUser[i];
      List post = userFile['post'];
      int like = userFile['like'];
      String profileLink = userFile['profile'];
      String compressText = jsonEncode({
        "name": name,
        "like": like,
        "post": post,
        "email": email,
        "profile": profileLink,
      });
      String rank = "${like + post.length}";
      String fillString = "0" * (5 - rank.length);
      String finalText = "${fillString + rank}$compressText";
      info.add(finalText);
      setState(() {
        text = "Reaceving Files : $i / ${allUser.length}";
      });
    }
    info.sort();

    setState(() {
      text = "Uploding Files";
    });
    await FirebaseFirestore.instance
        .collection('rank')
        .doc('rank')
        .set({"rank": info});

    // ignore: use_build_context_synchronously
    Navigator.pop(context);
    Fluttertoast.showToast(
      msg: "Rank Update Successfull",
      toastLength: Toast.LENGTH_LONG,
      gravity: ToastGravity.BOTTOM,
      backgroundColor: Colors.grey[700],
      textColor: Colors.white,
      timeInSecForIosWeb: 3,
    );
  }

  @override
  Widget build(BuildContext context) {
    if (oneTileCall) task();
    return Scaffold(
      appBar: AppBar(
        title: const Text('Update Rank'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const CircularProgressIndicator(),
            const SizedBox(
              height: 10,
            ),
            Text(
              text,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}
