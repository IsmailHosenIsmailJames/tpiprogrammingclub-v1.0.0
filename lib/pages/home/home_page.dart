import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_syntax_view/flutter_syntax_view.dart';
import 'package:tpiprogrammingclub/authentication/login.dart';
import 'package:tpiprogrammingclub/pages/admin/admin.dart';
import 'package:tpiprogrammingclub/widget/search.dart';
import 'package:tpiprogrammingclub/widget/stram_builder.dart';
import '../../theme/change_button_theme.dart';
import '../contributors/contributors.dart';
import '../profile/profile.dart';
import 'home.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

Widget currentPage = const Home();

final elevatedStyle =
    RoundedRectangleBorder(borderRadius: BorderRadius.circular(10));

class _HomePageState extends State<HomePage> {
  Widget title = const Text("Home");
  bool callOneTime = true;
  String? name;
  String? profileLink;

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
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const Search(),
                ),
              );
            },
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
        shape: elevatedStyle,
        width: 300,
        child: ListView(
          physics: const BouncingScrollPhysics(),
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
                              width: 280,
                              decoration: BoxDecoration(
                                color: Colors.greenAccent,
                                borderRadius: BorderRadius.circular(100),
                              ),
                              child: Image.asset(
                                'img/logotpi.jpg',
                                fit: BoxFit.cover,
                              )),
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
                if (FirebaseAuth.instance.currentUser != null) {
                  setState(() {
                    currentPage = Profile(
                      email: FirebaseAuth.instance.currentUser!.email!,
                    );
                    title = const Text('My Profile');
                    Navigator.pop(context);
                  });
                } else {
                  showCupertinoModalPopup(
                    context: context,
                    builder: (context) => const Login(),
                  );
                }
              },
              child: const Text('My Profile'),
            ),
            const SizedBox(
              height: 5,
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
                  currentPage = const Home();
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
                      language: 'linux', syntax: Syntax.JAVASCRIPT);
                  title = const Text('Linux System');
                  Navigator.pop(context);
                });
              },
              child: const Text('Linux System'),
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
                  currentPage = const MyStramBuilder(
                      language: 'problemsolved', syntax: Syntax.DART);
                  title = const Text('Problem Solved');
                  Navigator.pop(context);
                });
              },
              child: const Text('Problem Solved'),
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
            ElevatedButton(
              style: ElevatedButton.styleFrom(shape: elevatedStyle),
              onPressed: () async {
                final user = FirebaseAuth.instance.currentUser;
                if (user != null) {
                  final addminDoc = await FirebaseFirestore.instance
                      .collection('admin')
                      .doc('admin')
                      .get();
                  List adminList = addminDoc['admin'];
                  if (adminList.contains(user.email)) {
                    setState(() {
                      Navigator.pop(context);
                      currentPage = const AdminPage();
                      title = const Text('Admin Page');
                    });
                  } else {
                    // ignore: use_build_context_synchronously
                    showModalBottomSheet(
                      context: context,
                      builder: (context) => const Center(
                        child: Text("You are not certify as an admin\n"),
                      ),
                    );
                  }
                } else {
                  Navigator.pop(context);
                  showCupertinoModalPopup(
                    context: context,
                    builder: (context) => const Login(),
                  );
                }
              },
              child: const Text('Admin Page'),
            ),
            const SizedBox(
              height: 5,
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(shape: elevatedStyle),
              onPressed: () {
                if (FirebaseAuth.instance.currentUser != null) {
                  FirebaseAuth.instance.signOut();
                  setState(() {});
                } else {
                  showCupertinoModalPopup(
                    context: context,
                    builder: (logcontext) => const Login(),
                  );
                }
              },
              child: Text(FirebaseAuth.instance.currentUser != null
                  ? "Log Out"
                  : "Sign In"),
            )
          ],
        ),
      ),
      body: currentPage,
    );
  }
}
