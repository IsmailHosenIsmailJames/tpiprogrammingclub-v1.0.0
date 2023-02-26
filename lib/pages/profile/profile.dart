// ignore_for_file: use_build_context_synchronously

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
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
  Widget myWidget = const Center(
    child: CircularProgressIndicator(),
  );
  void get() async {
    final file = await FirebaseFirestore.instance
        .collection('user')
        .doc(widget.email)
        .get();
    String name = file['name'];
    String profile = file['profile'];
    List post = file['post'];
    double like = file['like'];
    List<Widget> postwidget = [];

    for (int i = 0; i < post.length; i++) {
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
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Container(
              height: 50,
              width: MediaQuery.of(context).size.width,
              decoration: BoxDecoration(
                color: const Color.fromARGB(89, 155, 155, 155),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Center(
                child: Text(
                  post[i],
                  style: const TextStyle(
                      fontSize: 26, fontWeight: FontWeight.bold),
                ),
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
    Widget lastWidget = ListView(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(100),
          child: Container(
            color: const Color.fromARGB(83, 150, 150, 150),
            height: 100,
            width: 100,
            child: GestureDetector(
              onTap: () async {
                if (!await launchUrl(
                  Uri.parse(
                    profile,
                  ),
                )) {
                  throw Exception(
                    'Could not launch $profile',
                  );
                }
              },
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
                errorWidget: (context, url, error) => const Center(
                  child: Text(
                    'To See The Image Click Here',
                    style:
                        TextStyle(fontSize: 26, backgroundColor: Colors.amber),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(
          height: 10,
        ),
        Text(
          "Total Like : $like",
          style: const TextStyle(fontSize: 40, fontWeight: FontWeight.bold),
        ),
        const SizedBox(
          height: 10,
        ),
        Text(
          "Name : $name",
          style: const TextStyle(fontSize: 36, fontWeight: FontWeight.bold),
        ),
        const SizedBox(
          height: 10,
        ),
        Text(
          'Eamil : ${widget.email}',
          style: const TextStyle(fontSize: 30),
        ),
        const SizedBox(
          height: 10,
        ),
        Column(
          children: postwidget,
        )
      ],
    );

    setState(() {
      getOneTime = false;
      myWidget = lastWidget;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (getOneTime) get();
    return Scaffold(
      body: Center(child: myWidget),
    );
  }
}
