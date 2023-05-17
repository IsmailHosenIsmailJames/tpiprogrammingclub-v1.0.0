// ignore_for_file: use_build_context_synchronously

import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:tpiprogrammingclub/pages/home/home_page.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../widget/single_document_vewer.dart';

class Profile extends StatefulWidget {
  final String email;
  const Profile({super.key, required this.email});

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  bool getOneTime = true;
  String appTitle = "";
  Widget myWidget = const Center(
    child: CircularProgressIndicator(),
  );
  void get() async {
    setState(() {
      getOneTime = false;
    });
    final file = await FirebaseFirestore.instance
        .collection('user')
        .doc(widget.email)
        .get();
    String name = file['name'];
    setState(() {
      appTitle = name;
    });
    String profile = file['profile'];
    List post = file['post'];
    int like = file['like'];
    List pendingPost = file['pendingPost'];
    List<Widget> postwidget = [];

    for (int i = 0; i < post.length; i++) {
      if ("${post[i]}".length < 3) continue;
      postwidget.add(
        GestureDetector(
          behavior: HitTestBehavior.deferToChild,
          onTap: () {
            String path = post[i];
            List pathId = path.split('/');
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => SingleDocumentViewer(
                  path: pathId[0],
                  id: pathId[1],
                ),
              ),
            );
          },
          child: Container(
            height: 50,
            width: MediaQuery.of(context).size.width,
            decoration: BoxDecoration(
              color: const Color.fromARGB(86, 145, 145, 145),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Center(
              child: Text(
                "${post[i].toString().split('/')[0]} / ${double.parse(post[i].toString().split('/')[1]) ~/ 10000000000}",
                style:
                    const TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ),
      );
      postwidget.add(
        const SizedBox(
          height: 10,
        ),
      );
    }
    List<Widget> pendingWidget = [];
    for (int i = 0; i < pendingPost.length; i++) {
      if ('${pendingPost[i]}'.length < 2) continue;
      pendingWidget.add(
        GestureDetector(
          behavior: HitTestBehavior.deferToChild,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => SingleDocumentViewer(
                  path: "pending",
                  id: pendingPost[i],
                ),
              ),
            );
          },
          child: Padding(
            padding: const EdgeInsets.all(3.0),
            child: Container(
              height: 50,
              width: MediaQuery.of(context).size.width,
              decoration: BoxDecoration(
                color: const Color.fromARGB(86, 145, 145, 145),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Center(
                child: Text(
                  "${pendingPost[i]}",
                  style: const TextStyle(
                      fontSize: 26, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ),
        ),
      );
    }

    Widget lastWidget = ListView(
      physics: const BouncingScrollPhysics(),
      children: [
        const SizedBox(
          height: 5,
        ),
        Center(
          child: SizedBox(
            height: 300,
            width: 300,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(1000),
              child: CachedNetworkImage(
                imageUrl: profile,
                progressIndicatorBuilder: (context, url, downloadProgress) =>
                    Center(
                  child: Center(
                    child: CircularProgressIndicator(
                        value: downloadProgress.progress),
                  ),
                ),
                fit: BoxFit.cover,
                errorWidget: (context, url, error) => Center(
                  child: OutlinedButton(
                    onPressed: () async {
                      if (!await launchUrl(Uri.parse(profile))) {
                        throw Exception('Could not launch $profile');
                      }
                    },
                    child: const Text(
                      'For Image Click Here',
                      style: TextStyle(
                        fontSize: 24,
                        color: Colors.blue,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(3),
          child: ElevatedButton(
            onPressed: () async {
              String email = FirebaseAuth.instance.currentUser!.email!;
              try {
                if (!kIsWeb) {
                  FilePickerResult? result =
                      await FilePicker.platform.pickFiles(
                    allowCompression: true,
                    type: FileType.custom,
                    allowMultiple: false,
                    allowedExtensions: ['jpg', 'png'],
                  );
                  if (result != null) {
                    showModalBottomSheet(
                      context: context,
                      builder: (context) => const Center(
                        child: CircularProgressIndicator(),
                      ),
                    );

                    final tem = result.files.first;
                    String? extension = tem.extension;
                    File imageFile = File(tem.path!);

                    String uploadePath = "user/$email.$extension";
                    final ref =
                        FirebaseStorage.instance.ref().child(uploadePath);
                    UploadTask uploadTask;
                    uploadTask = ref.putFile(imageFile);
                    final snapshot = await uploadTask.whenComplete(() {});
                    String url = await snapshot.ref.getDownloadURL();
                    final dataModifyLoc = FirebaseFirestore.instance
                        .collection("user")
                        .doc(email);
                    await dataModifyLoc.update({"profile": url});
                    Navigator.pop(context);
                    Fluttertoast.showToast(
                      msg: "SignUp Successfull !",
                      toastLength: Toast.LENGTH_LONG,
                      gravity: ToastGravity.BOTTOM,
                      backgroundColor: Colors.grey[700],
                      textColor: Colors.white,
                      timeInSecForIosWeb: 3,
                    );
                  } else {
                    Fluttertoast.showToast(
                      msg: "Please Select a Profile Picture",
                      toastLength: Toast.LENGTH_LONG,
                      gravity: ToastGravity.BOTTOM,
                      backgroundColor: Colors.grey[700],
                      textColor: Colors.white,
                      timeInSecForIosWeb: 3,
                    );
                  }
                }
                if (kIsWeb) {
                  FilePickerResult? result = await FilePicker.platform
                      .pickFiles(
                          type: FileType.custom,
                          allowMultiple: false,
                          allowCompression: true,
                          allowedExtensions: ['jpg', 'png']);

                  if (result != null) {
                    showModalBottomSheet(
                      context: context,
                      builder: (context) => const Center(
                        child: CircularProgressIndicator(),
                      ),
                    );

                    final tem = result.files.first;
                    Uint8List? selectedImage = tem.bytes;
                    String? extension = tem.extension;
                    String uploadePath = "user/$email.$extension";
                    final ref =
                        FirebaseStorage.instance.ref().child(uploadePath);
                    UploadTask uploadTask;
                    final metadata =
                        SettableMetadata(contentType: 'image/jpeg');
                    uploadTask = ref.putData(selectedImage!, metadata);
                    final snapshot = await uploadTask.whenComplete(() {});
                    String url = await snapshot.ref.getDownloadURL();
                    final dataModifyLoc = FirebaseFirestore.instance
                        .collection("user")
                        .doc(email);
                    await dataModifyLoc.update({"profile": url});
                    Navigator.pop(context);
                    Fluttertoast.showToast(
                      msg: "SignUp Successfull !",
                      toastLength: Toast.LENGTH_LONG,
                      gravity: ToastGravity.BOTTOM,
                      backgroundColor: Colors.grey[700],
                      textColor: Colors.white,
                      timeInSecForIosWeb: 3,
                    );
                  } else {
                    Fluttertoast.showToast(
                      msg: "Please Select a Profile Picture",
                      toastLength: Toast.LENGTH_LONG,
                      gravity: ToastGravity.BOTTOM,
                      backgroundColor: Colors.grey[700],
                      textColor: Colors.white,
                      timeInSecForIosWeb: 3,
                    );
                  }
                }
                get();
              } catch (e) {}
            },
            child: const Text("Update Profile"),
          ),
        ),
        const SizedBox(
          height: 10,
        ),
        Text(
          "Total Like : $like",
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(
          height: 10,
        ),
        const Divider(
          color: Colors.black,
        ),
        const SizedBox(
          height: 10,
        ),
        Text(
          "Name : $name",
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(
          height: 5,
        ),
        Text(
          'Eamil : ${widget.email}',
          style: const TextStyle(fontSize: 16),
        ),
        const SizedBox(
          height: 15,
        ),
        const Divider(
          color: Colors.black,
        ),
        const Text(
          "All the Contribution:",
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(
          height: 5,
        ),
        Container(
          decoration: BoxDecoration(
            color: const Color.fromARGB(88, 194, 194, 194),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Padding(
            padding: const EdgeInsets.all(15),
            child: Column(
              children: postwidget,
            ),
          ),
        ),
        const SizedBox(
          height: 15,
        ),
        const Divider(
          color: Colors.black,
        ),
        const Text(
          "All Pending Post:",
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(
          height: 5,
        ),
        Container(
          decoration: BoxDecoration(
            color: const Color.fromARGB(88, 194, 194, 194),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Padding(
            padding: const EdgeInsets.all(15),
            child: Column(
              children: pendingWidget,
            ),
          ),
        ),
        const SizedBox(
          height: 15,
        ),
      ],
    );

    setState(() {
      myWidget = lastWidget;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (getOneTime) get();
    return Scaffold(
      drawer: const MyDrawer(),
      appBar: AppBar(
        title: Text(appTitle),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: myWidget,
        ),
      ),
    );
  }
}
