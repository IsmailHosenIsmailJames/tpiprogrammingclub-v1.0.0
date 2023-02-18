import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:tpiprogrammingclub/pages/java/learn_java.dart';
import '../../theme/change_button_theme.dart';
import '../blogs/blogs.dart';
import '../community/community.dart';
import '../contributors/contributors.dart';
import '../css/learn_css.dart';
import '../docs/docs.dart';
import '../html/learn_html.dart';
import '../c++/learn_c_plus_plus.dart';
import '../c_sharp/learn_c_sharp.dart';
import '../learn_python/learn_python.dart';
import 'home.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

Widget currentPage = const Home();

class _HomePageState extends State<HomePage> {
  Widget title = const Text("Home");
  bool callOneTime = true;
  String? profileLink;
  String? name;

  void getdata() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final json = await FirebaseFirestore.instance
          .collection('user')
          .doc(user.email!)
          .get();
      setState(() {
        profileLink = json['profile'];
        name = json['name'];
        callOneTime = false;
      });
    }
  }

  final elevatedStyle = const RoundedRectangleBorder(
    borderRadius: BorderRadius.only(
      bottomLeft: Radius.circular(100),
      topRight: Radius.circular(100),
    ),
  );
  @override
  Widget build(BuildContext context) {
    if (callOneTime) getdata();
    return Scaffold(
      appBar: AppBar(
        title: title,
        actions: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: const [
              ChangeThemeButtonWidget(),
              Text(' Dark'),
            ],
          ),
          const SizedBox(
            width: 10,
          ),
          IconButton(
            onPressed: () {},
            icon: const Icon(
              Icons.search,
            ),
          ),
          const SizedBox(
            width: 10,
          ),
          IconButton(
              onPressed: () {},
              icon: const Icon(
                Icons.help_outline,
              )),
          const SizedBox(
            width: 10,
          ),
        ],
      ),
      drawer: Drawer(
        width: 300,
        child: ListView(
          padding: const EdgeInsets.all(10),
          children: [
            SizedBox(
              height: 150,
              width: double.infinity,
              child: Column(
                children: [
                  Row(
                    children: [
                      Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            height: 80,
                            width: 80,
                            decoration: BoxDecoration(
                              color: const Color.fromARGB(255, 34, 156, 255),
                              borderRadius: BorderRadius.circular(100),
                            ),
                            child: profileLink != null
                                ? CachedNetworkImage(
                                    imageUrl: profileLink!,
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
                                  )
                                : const Icon(Icons.person),
                          ),
                          const Text(
                            'TPI Programming Club',
                            style: TextStyle(
                                color: Color.fromARGB(255, 34, 156, 255),
                                fontSize: 18,
                                fontWeight: FontWeight.w600),
                          ),
                          const Text('Tangail Polytechnic Institute, Tangail.'),
                        ],
                      )
                    ],
                  ),
                ],
              ),
            ),
            const Divider(
              color: Colors.black,
            ),
            const SizedBox(
              height: 10,
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(shape: elevatedStyle),
              onPressed: () {
                setState(() {
                  currentPage = const Home();
                  title = const Text('Home');
                  Navigator.pop(context);
                });
              },
              child: const Text('Home'),
            ),
            const SizedBox(
              height: 10,
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(shape: elevatedStyle),
              onPressed: () {
                setState(() {
                  currentPage = const Blogs();
                  title = const Text('Blogs');
                  Navigator.pop(context);
                });
              },
              child: const Text('Blogs'),
            ),
            const SizedBox(
              height: 10,
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(shape: elevatedStyle),
              onPressed: () {
                setState(() {
                  currentPage = const Python();
                  title = const Text('Python');
                  Navigator.pop(context);
                });
              },
              child: const Text('Python'),
            ),
            const SizedBox(
              height: 10,
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(shape: elevatedStyle),
              onPressed: () {
                setState(() {
                  currentPage = const Java();
                  title = const Text('Java');
                  Navigator.pop(context);
                });
              },
              child: const Text('Java'),
            ),
            const SizedBox(
              height: 10,
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(shape: elevatedStyle),
              onPressed: () {
                setState(() {
                  currentPage = const CPlusPlus();
                  title = const Text('C++');
                  Navigator.pop(context);
                });
              },
              child: const Text('C++'),
            ),
            const SizedBox(
              height: 10,
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(shape: elevatedStyle),
              onPressed: () {
                setState(() {
                  currentPage = const CSharp();
                  title = const Text('C#');
                  Navigator.pop(context);
                });
              },
              child: const Text('C#'),
            ),
            const SizedBox(
              height: 10,
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(shape: elevatedStyle),
              onPressed: () {
                setState(() {
                  currentPage = const HTML();
                  title = const Text('HTML');
                  Navigator.pop(context);
                });
              },
              child: const Text('HTML'),
            ),
            const SizedBox(
              height: 10,
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(shape: elevatedStyle),
              onPressed: () {
                setState(() {
                  currentPage = const CSS();
                  title = const Text('CSS');
                  Navigator.pop(context);
                });
              },
              child: const Text('CSS'),
            ),
            const SizedBox(
              height: 10,
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(shape: elevatedStyle),
              onPressed: () {
                setState(() {
                  currentPage = const Docs();
                  title = const Text('Docs');
                  Navigator.pop(context);
                });
              },
              child: const Text('Docs'),
            ),
            const SizedBox(
              height: 10,
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(shape: elevatedStyle),
              onPressed: () {
                setState(() {
                  currentPage = const Community();
                  title = const Text('Community');
                  Navigator.pop(context);
                });
              },
              child: const Text('Community'),
            ),
            const SizedBox(
              height: 10,
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(shape: elevatedStyle),
              onPressed: () {
                setState(() {
                  currentPage = const Contributors();
                  title = const Text('Contributors');
                  Navigator.pop(context);
                });
              },
              child: const Text('Contributors'),
            ),
            const SizedBox(
              height: 10,
            ),
          ],
        ),
      ),
      body: currentPage,
    );
  }
}
