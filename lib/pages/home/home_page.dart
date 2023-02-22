import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_syntax_view/flutter_syntax_view.dart';
import 'package:tpiprogrammingclub/widget/stram_builder.dart';
import '../../theme/change_button_theme.dart';
import '../community/community.dart';
import '../contributors/contributors.dart';
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
            ],
          ),
          const Icon(Icons.dark_mode),
          IconButton(
            onPressed: () {},
            icon: const Icon(
              Icons.search,
            ),
          ),
          const SizedBox(
            width: 5,
          ),
          IconButton(
              onPressed: () {},
              icon: const Icon(
                Icons.help_outline,
              )),
          const SizedBox(
            width: 5,
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
                              color: Colors.greenAccent,
                              borderRadius: BorderRadius.circular(100),
                            ),
                            child: profileLink != null
                                ? ClipRRect(
                                    borderRadius: BorderRadius.circular(100),
                                    child: CachedNetworkImage(
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
                                      fit: BoxFit.contain,
                                    ),
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
              height: 5,
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(shape: elevatedStyle),
              onPressed: () {
                setState(() {
                  currentPage = const MyStramBuilder(
                      language: 'home', syntax: Syntax.DART);
                  title = const Text('Home');
                  Navigator.pop(context);
                });
              },
              child: const Text('Home'),
            ),
            const SizedBox(
              height: 5,
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(shape: elevatedStyle),
              onPressed: () {
                setState(() {
                  currentPage = const MyStramBuilder(
                      language: 'blog', syntax: Syntax.DART);
                  title = const Text('Blogs');
                  Navigator.pop(context);
                });
              },
              child: const Text('Blogs'),
            ),
            const SizedBox(
              height: 5,
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(shape: elevatedStyle),
              onPressed: () {
                setState(() {
                  currentPage = const MyStramBuilder(
                      language: 'python', syntax: Syntax.DART);
                  title = const Text('Python');
                  Navigator.pop(context);
                });
              },
              child: const Text('Python'),
            ),
            const SizedBox(
              height: 5,
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(shape: elevatedStyle),
              onPressed: () {
                setState(() {
                  currentPage = const MyStramBuilder(
                      language: 'java', syntax: Syntax.JAVA);
                  title = const Text('Java');
                  Navigator.pop(context);
                });
              },
              child: const Text('Java'),
            ),
            const SizedBox(
              height: 5,
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(shape: elevatedStyle),
              onPressed: () {
                setState(() {
                  currentPage =
                      const MyStramBuilder(language: 'c++', syntax: Syntax.CPP);
                  title = const Text('C++');
                  Navigator.pop(context);
                });
              },
              child: const Text('C++'),
            ),
            const SizedBox(
              height: 5,
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(shape: elevatedStyle),
              onPressed: () {
                setState(() {
                  currentPage =
                      const MyStramBuilder(language: 'c#', syntax: Syntax.JAVA);
                  title = const Text('C#');
                  Navigator.pop(context);
                });
              },
              child: const Text('C#'),
            ),
            const SizedBox(
              height: 5,
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(shape: elevatedStyle),
              onPressed: () {
                setState(() {
                  currentPage = const MyStramBuilder(
                      language: 'html', syntax: Syntax.JAVASCRIPT);
                  title = const Text('HTML');
                  Navigator.pop(context);
                });
              },
              child: const Text('HTML'),
            ),
            const SizedBox(
              height: 5,
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(shape: elevatedStyle),
              onPressed: () {
                setState(() {
                  currentPage = const MyStramBuilder(
                      language: 'css', syntax: Syntax.DART);
                  title = const Text('CSS');
                  Navigator.pop(context);
                });
              },
              child: const Text('CSS'),
            ),
            const SizedBox(
              height: 5,
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(shape: elevatedStyle),
              onPressed: () {
                setState(() {
                  currentPage = const MyStramBuilder(
                      language: 'doc', syntax: Syntax.DART);
                  title = const Text('Docs');
                  Navigator.pop(context);
                });
              },
              child: const Text('Docs'),
            ),
            const SizedBox(
              height: 5,
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
              height: 5,
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
              height: 5,
            ),
          ],
        ),
      ),
      body: currentPage,
    );
  }
}
