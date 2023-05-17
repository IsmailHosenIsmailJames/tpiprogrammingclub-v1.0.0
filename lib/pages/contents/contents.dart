// ignore_for_file: use_build_context_synchronously

import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_quill/flutter_quill.dart' hide Text;
import 'package:fluttertoast/fluttertoast.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:tpiprogrammingclub/widget/editor.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../authentication/login.dart';
import '../../widget/comment.dart';
import '../../widget/modify_post.dart';
import '../home/home_page.dart';
import '../profile/profile.dart';

class Contents extends StatefulWidget {
  final String path;
  const Contents({super.key, required this.path});

  @override
  State<Contents> createState() => _ContentsState();
}

List supportedContents = [
  "python",
  "java",
  "c",
  "c++",
  "c#",
  "javascript",
  "dart",
  "flutter",
  "html",
  "css",
  "windows",
  "linux",
  "docs",
  "blogs",
];
List listOfIDs = [];
List listOfTitels = [];

class _ContentsState extends State<Contents>
    with SingleTickerProviderStateMixin {
  List listOfIDs = [];
  List listOfTitels = [];
  String? currentDoc;

  bool oneTimeCall = true;
  bool getDocumentOneTime = true;
  Widget documentVew = const Center(child: CircularProgressIndicator());
  List<Widget> listOfTuorialWidget = [];
  Widget allTutorialWidget = const Center(child: CircularProgressIndicator());

  // for animation
  late AnimationController animationController;
  late Animation<double> animator;
  bool isMenuOpen = false;
  @override
  void initState() {
    super.initState();
    animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    animator = CurvedAnimation(
      parent: animationController,
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    animationController.dispose();
    super.dispose();
  }

  void getListOfTutorial() async {
    setState(() {
      oneTimeCall = false;
    });
    String path = widget.path;
    List splitedPath = path.split("/");
    if (splitedPath.length == 1) {
      setState(() {
        documentVew = const Center(
          child: Text("No Data"),
        );
        allTutorialWidget = const Center(
          child: Text("No Data"),
        );
      });
      return;
    }
    String contentName = splitedPath[1];
    if (!supportedContents.contains(contentName)) {
      setState(() {
        documentVew = const Center(
          child: Text("No Data"),
        );
        allTutorialWidget = const Center(
          child: Text("No Data"),
        );
      });
      return;
    }
    final allTutorialJson = await FirebaseFirestore.instance
        .collection("search")
        .doc(contentName)
        .get();
    if (!allTutorialJson.exists) {
      setState(() {
        documentVew = const Center(
          child:
              Text("We Have No Tutrial Right Now. Tutorials are comming soon."),
        );
        allTutorialWidget = const Center(
          child: Text("No Tutorial Avilable"),
        );
      });
      return;
    }
    List ids = allTutorialJson["id"];
    List title = allTutorialJson["title"];

    if (splitedPath.length == 2) {
      try {
        String fullID = ids[0];
        int lenth = fullID.length;
        int needToFill = 20 - lenth;
        String fillString = "0" * needToFill;
        fullID = fillString + fullID;
        makeTheListWidget(ids, title, contentName);
        getSingleDocument(contentName, fullID);
      } catch (e) {}
    }

    if (splitedPath.length == 3) {
      String id = splitedPath[2];
      try {
        double doubleValueOfId = double.parse(id) * 10000000000;
        String fullID = "$doubleValueOfId";
        int lenth = fullID.length;
        int needToFill = 20 - lenth;
        String fillString = "0" * needToFill;
        fullID = fillString + fullID;
        makeTheListWidget(ids, title, contentName);
        getSingleDocument(contentName, fullID);
      } catch (e) {
        return;
      }
    }
  }

  void makeTheListWidget(List ids, List titles, String contentName) {
    setState(() {
      listOfIDs = ids;
      listOfTitels = titles;
    });
    for (int i = 0; i < ids.length; i++) {
      double doubleId = int.parse(ids[i]) / 10000000000;

      listOfTuorialWidget.add(
        Padding(
          padding: const EdgeInsets.only(top: 2, bottom: 2),
          child: ElevatedButton(
            onPressed: () async {
              animationController.reverse();
              setState(() {
                isMenuOpen = !isMenuOpen;
              });
              setState(() {
                documentVew = const Center(child: CircularProgressIndicator());
              });
              String id = (double.parse(ids[i]) / 10000000000).toString();
              await Future.delayed(const Duration(milliseconds: 300));
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => Contents(path: "/$contentName/$id"),
                  settings: RouteSettings(name: "/$contentName/$id"),
                ),
              );
            },
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    "${doubleId.toInt()}: ",
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    "${titles[i]}",
                  ),
                ],
              ),
            ),
          ),
        ),
      );
      setState(() {
        allTutorialWidget = ListView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.all(10),
          children: listOfTuorialWidget,
        );
      });
    }
  }

  void getSingleDocument(String contentName, String id) async {
    setState(() {
      currentDoc = id;
    });
    setState(() {
      getDocumentOneTime = false;
    });
    final documentRef =
        FirebaseFirestore.instance.collection(contentName).doc(id);
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
                    errorWidget: (context, url, error) => OutlinedButton(
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
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                              padding: const EdgeInsets.only(right: 7),
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
                              padding: const EdgeInsets.only(right: 7),
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  shape: elevatedStyle,
                                  backgroundColor: Colors.blueGrey,
                                ),
                                onPressed: () async {
                                  Clipboard.setData(
                                    ClipboardData(text: singleDoc['doc']),
                                  );
                                  Fluttertoast.showToast(
                                    msg: "Copied Successfull!",
                                    toastLength: Toast.LENGTH_LONG,
                                    gravity: ToastGravity.BOTTOM,
                                    backgroundColor: Colors.grey[700],
                                    textColor: Colors.white,
                                    timeInSecForIosWeb: 3,
                                  );

                                  if (contentName == "python") {
                                    if (!await launchUrl(
                                      Uri.parse(
                                        'https://replit.com/languages/python3',
                                      ),
                                    )) {
                                      Fluttertoast.showToast(
                                        msg: "Couldn't launch url!",
                                        toastLength: Toast.LENGTH_LONG,
                                        gravity: ToastGravity.BOTTOM,
                                        backgroundColor: Colors.grey[700],
                                        textColor: Colors.white,
                                        timeInSecForIosWeb: 3,
                                      );
                                    }
                                  } else if (contentName == "java") {
                                    if (!await launchUrl(
                                      Uri.parse(
                                        'https://replit.com/languages/java10',
                                      ),
                                    )) {
                                      Fluttertoast.showToast(
                                        msg: "Couldn't launch url!",
                                        toastLength: Toast.LENGTH_LONG,
                                        gravity: ToastGravity.BOTTOM,
                                        backgroundColor: Colors.grey[700],
                                        textColor: Colors.white,
                                        timeInSecForIosWeb: 3,
                                      );
                                    }
                                  } else if (contentName == 'javascript') {
                                    if (!await launchUrl(
                                      Uri.parse(
                                        'https://replit.com/languages/nodejs',
                                      ),
                                    )) {
                                      Fluttertoast.showToast(
                                        msg: "Couldn't launch url!",
                                        toastLength: Toast.LENGTH_LONG,
                                        gravity: ToastGravity.BOTTOM,
                                        backgroundColor: Colors.grey[700],
                                        textColor: Colors.white,
                                        timeInSecForIosWeb: 3,
                                      );
                                    }
                                  } else if (contentName == 'c++') {
                                    if (!await launchUrl(
                                      Uri.parse(
                                        'https://replit.com/languages/cpp',
                                      ),
                                    )) {
                                      Fluttertoast.showToast(
                                        msg: "Couldn't launch url!",
                                        toastLength: Toast.LENGTH_LONG,
                                        gravity: ToastGravity.BOTTOM,
                                        backgroundColor: Colors.grey[700],
                                        textColor: Colors.white,
                                        timeInSecForIosWeb: 3,
                                      );
                                    }
                                  } else if (contentName == 'c#') {
                                    if (!await launchUrl(
                                      Uri.parse(
                                        'https://replit.com/languages/csharp',
                                      ),
                                    )) {
                                      Fluttertoast.showToast(
                                        msg: "Couldn't launch url!",
                                        toastLength: Toast.LENGTH_LONG,
                                        gravity: ToastGravity.BOTTOM,
                                        backgroundColor: Colors.grey[700],
                                        textColor: Colors.white,
                                        timeInSecForIosWeb: 3,
                                      );
                                    }
                                  } else if (contentName == 'c') {
                                    if (!await launchUrl(
                                      Uri.parse(
                                        'https://replit.com/languages/c',
                                      ),
                                    )) {
                                      Fluttertoast.showToast(
                                        msg: "Couldn't launch url!",
                                        toastLength: Toast.LENGTH_LONG,
                                        gravity: ToastGravity.BOTTOM,
                                        backgroundColor: Colors.grey[700],
                                        textColor: Colors.white,
                                        timeInSecForIosWeb: 3,
                                      );
                                    }
                                  } else if (contentName == 'dart') {
                                    if (!await launchUrl(
                                      Uri.parse(
                                        'https://dartpad.dev/?',
                                      ),
                                    )) {
                                      Fluttertoast.showToast(
                                        msg: "Couldn't launch url!",
                                        toastLength: Toast.LENGTH_LONG,
                                        gravity: ToastGravity.BOTTOM,
                                        backgroundColor: Colors.grey[700],
                                        textColor: Colors.white,
                                        timeInSecForIosWeb: 3,
                                      );
                                    }
                                  } else if (contentName == 'html' ||
                                      contentName == 'css') {
                                    if (!await launchUrl(
                                      Uri.parse(
                                        'https://www.programiz.com/html/online-compiler/',
                                      ),
                                    )) {
                                      Fluttertoast.showToast(
                                        msg: "Couldn't launch url!",
                                        toastLength: Toast.LENGTH_LONG,
                                        gravity: ToastGravity.BOTTOM,
                                        backgroundColor: Colors.grey[700],
                                        textColor: Colors.white,
                                        timeInSecForIosWeb: 3,
                                      );
                                    }
                                  } else {
                                    Fluttertoast.showToast(
                                      msg: "We still working on it!",
                                      toastLength: Toast.LENGTH_LONG,
                                      gravity: ToastGravity.BOTTOM,
                                      backgroundColor: Colors.grey[700],
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
                        SelectableText(
                          name,
                          style: const TextStyle(fontSize: 20),
                        ),
                        SelectableText(email),
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
                    SelectableText(
                      "Rank : ${double.parse(document.id) ~/ 10000000000}",
                      style: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(
                      height: 5,
                    ),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SelectableText(
                            "Title : ",
                            style: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                          SizedBox(
                            width: MediaQuery.of(context).size.width - 70,
                            child: SelectableText(title),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(
                      height: 5,
                    ),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SelectableText(
                            "Description : ",
                            style: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                          SizedBox(
                            width: MediaQuery.of(context).size.width - 120,
                            child: SelectableText(shortDes),
                          ),
                        ],
                      ),
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
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    IconButton(
                      onPressed: () async {
                        final user = FirebaseAuth.instance.currentUser;

                        if (user != null) {
                          final temDocRef = FirebaseFirestore.instance
                              .collection(contentName)
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
                          getSingleDocument(contentName, id);
                        } else {
                          await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const Login(),
                            ),
                          );
                          getSingleDocument(contentName, id);
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
                    SelectableText("${like.length}"),
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
                                path: contentName,
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
                    Text(
                      "${comment.length}",
                    ),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    ElevatedButton(
                      onPressed: () async {
                        final user = FirebaseAuth.instance.currentUser;
                        if (user != null) {
                          String useremail = user.email!;
                          if (useremail == email) {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    ModifyPost(path: contentName, id: id),
                              ),
                            );
                          } else {
                            final adminRef = await FirebaseFirestore.instance
                                .collection('admin')
                                .doc('admin')
                                .get();
                            List adminList = adminRef['admin'];
                            if (adminList.contains(useremail)) {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      ModifyPost(path: contentName, id: id),
                                ),
                              );
                            } else {
                              showModalBottomSheet(
                                context: context,
                                builder: (context) => const Center(
                                  child: Text(
                                    'You are not an Admin\nYou are not the owner/creator of this post.',
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              );
                            }
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
                      child: const Text('Modify'),
                    ),
                    const SizedBox(
                      width: 15,
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      );
      setState(() {
        documentVew = profile;
      });
    } else {
      setState(() {
        documentVew = const Center(
          child: Text('No data'),
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (oneTimeCall) getListOfTutorial();
    return Scaffold(
      drawer: const MyDrawer(),
      appBar: AppBar(
        title: Text(
          widget.path.split("/")[1],
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.all(2),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      List splitedPath = widget.path.split("/");

                      if (splitedPath.length < 2) return;
                      if (currentDoc == null) {
                        Fluttertoast.showToast(
                          msg: "No tutorial avilable",
                          toastLength: Toast.LENGTH_LONG,
                          gravity: ToastGravity.BOTTOM,
                          backgroundColor: Colors.grey[700],
                          textColor: Colors.white,
                          timeInSecForIosWeb: 3,
                        );

                        return;
                      } else {
                        int len = listOfIDs.length;
                        int index = listOfIDs.indexOf(currentDoc);

                        if (len > 0 && index > 0) {
                          String id = ((double.parse(listOfIDs[index - 1])) /
                                  10000000000)
                              .toString();
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  Contents(path: "/${splitedPath[1]}/$id"),
                              settings: RouteSettings(
                                  name: "/${splitedPath[1]}/$id}"),
                            ),
                          );
                        } else {
                          Fluttertoast.showToast(
                            msg: "No previous avilable",
                            toastLength: Toast.LENGTH_LONG,
                            gravity: ToastGravity.BOTTOM,
                            backgroundColor: Colors.grey[700],
                            textColor: Colors.white,
                            timeInSecForIosWeb: 3,
                          );
                        }
                      }
                    },
                    child: const Icon(Icons.arrow_back_ios),
                  ),
                  ElevatedButton(
                    onPressed: () async {
                      if (isMenuOpen) {
                        animationController.reverse();
                        setState(() {
                          isMenuOpen = !isMenuOpen;
                        });
                      } else {
                        animationController.forward();
                        setState(() {
                          isMenuOpen = !isMenuOpen;
                        });
                      }
                    },
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const Text(
                          "All Tutoriall",
                        ),
                        const SizedBox(
                          width: 5,
                        ),
                        Icon(isMenuOpen ? Icons.close : Icons.menu),
                      ],
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      String contributeArea = widget.path.split("/")[1];
                      if (supportedContents.contains(contributeArea)) {
                        if (FirebaseAuth.instance.currentUser != null) {
                          bool isVerifided =
                              FirebaseAuth.instance.currentUser!.emailVerified;
                          if (isVerifided) {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => Editor(
                                  contributionArea: contributeArea,
                                ),
                              ),
                            );
                          } else {
                            Fluttertoast.showToast(
                              msg: "First verify your account. Go to settings",
                              toastLength: Toast.LENGTH_LONG,
                              gravity: ToastGravity.BOTTOM,
                              backgroundColor: Colors.grey[700],
                              textColor: Colors.white,
                              timeInSecForIosWeb: 3,
                            );
                          }
                        } else {
                          Fluttertoast.showToast(
                            msg: "Log or create account first",
                            toastLength: Toast.LENGTH_LONG,
                            gravity: ToastGravity.BOTTOM,
                            backgroundColor: Colors.grey[700],
                            textColor: Colors.white,
                            timeInSecForIosWeb: 3,
                          );
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const Login(),
                            ),
                          );
                        }
                      } else {
                        Fluttertoast.showToast(
                          msg: "This not a Valid Area",
                          toastLength: Toast.LENGTH_LONG,
                          gravity: ToastGravity.BOTTOM,
                          backgroundColor: Colors.grey[700],
                          textColor: Colors.white,
                          timeInSecForIosWeb: 3,
                        );
                      }
                    },
                    child: const Icon(FontAwesomeIcons.filePen),
                  ),
                  ElevatedButton(
                      onPressed: () {
                        List splitedPath = widget.path.split("/");
                        if (splitedPath.length < 2) return;
                        if (currentDoc == null) {
                          Fluttertoast.showToast(
                            msg: "No tutorial avilable",
                            toastLength: Toast.LENGTH_LONG,
                            gravity: ToastGravity.BOTTOM,
                            backgroundColor: Colors.grey[700],
                            textColor: Colors.white,
                            timeInSecForIosWeb: 3,
                          );
                          return;
                        } else {
                          int len = listOfIDs.length;
                          int index = listOfIDs.indexOf(currentDoc) + 1;
                          if (len > index) {
                            String id =
                                ((double.parse(listOfIDs[index])) / 10000000000)
                                    .toString();
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    Contents(path: "/${splitedPath[1]}/$id"),
                                settings: RouteSettings(
                                    name: "/${splitedPath[1]}/$id"),
                              ),
                            );
                          } else {
                            Fluttertoast.showToast(
                              msg: "No more avilable",
                              toastLength: Toast.LENGTH_LONG,
                              gravity: ToastGravity.BOTTOM,
                              backgroundColor: Colors.grey[700],
                              textColor: Colors.white,
                              timeInSecForIosWeb: 3,
                            );
                          }
                        }
                      },
                      child: const Icon(Icons.arrow_forward_ios)),
                ],
              ),
            ),
            SizeTransition(
              sizeFactor: animator,
              child: Padding(
                padding: const EdgeInsets.only(
                  left: 30,
                  right: 30,
                  bottom: 10,
                ),
                child: Container(
                  decoration: const BoxDecoration(
                    color: Color.fromARGB(80, 182, 182, 182),
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(15),
                      bottomRight: Radius.circular(15),
                    ),
                  ),
                  height: 300,
                  child: allTutorialWidget,
                ),
              ),
            ),
            const SizedBox(
              height: 10,
            ),
            documentVew,
          ],
        ),
      ),
    );
  }
}
