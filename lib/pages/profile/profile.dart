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
    Widget lastWidget = ListView(
      physics: const BouncingScrollPhysics(),
      children: [
        ClipRRect(
          borderRadius: const BorderRadius.only(
            bottomLeft: Radius.circular(30),
            bottomRight: Radius.circular(30),
          ),
          child: CachedNetworkImage(
            imageUrl: profile,
            progressIndicatorBuilder: (context, url, downloadProgress) =>
                Center(
              child: Center(
                child:
                    CircularProgressIndicator(value: downloadProgress.progress),
              ),
            ),
            fit: BoxFit.contain,
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
        )
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
      appBar: AppBar(
        title: Text(appTitle),
      ),
      body: Center(child: myWidget),
    );
  }
}
