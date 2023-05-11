import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:tpiprogrammingclub/authentication/login.dart';
import 'package:tpiprogrammingclub/pages/admin/admin.dart';
import 'package:tpiprogrammingclub/widget/search.dart';
import 'package:tpiprogrammingclub/widget/stram_builder.dart';
import '../../theme/change_button_theme.dart';
import '../contributors/contributors.dart';
import '../profile/profile.dart';
import 'home.dart';
import '../profile/settings.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

Widget currentPage = const Home();

final elevatedStyle =
    RoundedRectangleBorder(borderRadius: BorderRadius.circular(10));
String? chatID;

class _HomePageState extends State<HomePage>
    with SingleTickerProviderStateMixin {
  Widget title = const Text("Home");
  bool callOneTime = true;
  String? name;
  String? profileLink;

  // for animation
  late AnimationController animationController;
  late Animation<double> animator;
  bool menu1 = false, menu2 = false, menu3 = false, menu4 = false;
  double perSubItemHight = 55;
  int menuItemNumber1 = 6,
      menuItemNumber2 = 3,
      menuItemNumber3 = 2,
      menuItemNumber4 = 3;
  double hight1 = 55 * 6, hight2 = 55 * 3, hight3 = 55 * 2, hight4 = 55 * 3;
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
        chatID = json['chatID'];
        callOneTime = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (callOneTime) getdata();
    Widget loginSignIn = FirebaseAuth.instance.currentUser != null
        ? Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              Icon(Icons.logout),
              SizedBox(
                width: 15,
              ),
              Text('Log Out')
            ],
          )
        : Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              Icon(Icons.login),
              SizedBox(
                width: 15,
              ),
              Text('LogIn/SignUp')
            ],
          );
    setState(() {
      loginSignIn;
    });

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
              thickness: 2,
              color: Colors.blueGrey,
            ),
            const SizedBox(
              height: 5,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
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
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const Login(),
                        ),
                      );
                    }
                  },
                  child: const Text('Profile'),
                ),
                const SizedBox(
                  width: 10,
                ),
                IconButton(
                  onPressed: () async {
                    if (FirebaseAuth.instance.currentUser != null) {
                      await FirebaseAuth.instance.currentUser!.reload();
                      // ignore: use_build_context_synchronously
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const MySettings(),
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
                  icon: const Icon(
                    Icons.settings,
                    size: 28,
                  ),
                ),
              ],
            ),
            const SizedBox(
              height: 5,
            ),
            const Divider(
              thickness: 2,
              color: Colors.blueGrey,
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
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Icon(FontAwesomeIcons.houseUser),
                  SizedBox(
                    width: 15,
                  ),
                  Text('Home'),
                ],
              ),
            ),
            const Divider(
              thickness: 2,
              color: Colors.blueGrey,
            ),
            ElevatedButton(
              onPressed: () async {
                final list = [menu1, menu2, menu3, menu4];
                int countTrue = 0;
                for (var element in list) {
                  if (element == true) countTrue++;
                }
                if (countTrue > 0) {
                  animationController.reverse();
                  await Future.delayed(
                    const Duration(milliseconds: 300),
                  );
                }
                if (menu1 == false) {
                  setState(() {
                    hight1 = perSubItemHight * menuItemNumber1;
                    hight2 = 0;
                    hight3 = 0;
                    hight4 = 0;
                    menu1 = true;
                  });
                  animationController.forward();
                } else {
                  setState(() {
                    menu1 = false;
                    menu2 = false;
                    menu3 = false;
                    menu4 = false;
                  });
                  animationController.reverse();
                  await Future.delayed(
                    const Duration(milliseconds: 300),
                  );
                  setState(() {
                    hight1 = perSubItemHight * menuItemNumber1;
                    hight2 = perSubItemHight * menuItemNumber2;
                    hight3 = perSubItemHight * menuItemNumber3;
                    hight4 = perSubItemHight * menuItemNumber4;
                  });
                }
              },
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Text(
                    "Programming",
                  ),
                  const SizedBox(
                    width: 20,
                  ),
                  Icon(menu1 ? Icons.close : Icons.menu),
                ],
              ),
            ),
            SizeTransition(
              sizeFactor: animator,
              child: Padding(
                padding: const EdgeInsets.only(left: 30),
                child: Container(
                  decoration: const BoxDecoration(
                    color: Color.fromARGB(80, 182, 182, 182),
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(15),
                      bottomRight: Radius.circular(15),
                    ),
                  ),
                  height: hight1,
                  child: ListView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.all(10),
                    children: [
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(shape: elevatedStyle),
                        onPressed: () {
                          setState(() {
                            currentPage =
                                const MyStramBuilder(language: 'python');
                            title = const Text('Python');
                            Navigator.pop(context);
                          });
                        },
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: const [
                            Icon(FontAwesomeIcons.python),
                            SizedBox(
                              width: 15,
                            ),
                            Text('Python'),
                          ],
                        ),
                      ),
                      const SizedBox(
                        height: 5,
                      ),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(shape: elevatedStyle),
                        onPressed: () {
                          setState(() {
                            currentPage =
                                const MyStramBuilder(language: 'java');
                            title = const Text('Java');
                            Navigator.pop(context);
                          });
                        },
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: const [
                            Icon(FontAwesomeIcons.java),
                            SizedBox(
                              width: 15,
                            ),
                            Text('Java'),
                          ],
                        ),
                      ),
                      const SizedBox(
                        height: 5,
                      ),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(shape: elevatedStyle),
                        onPressed: () {
                          setState(() {
                            currentPage =
                                const MyStramBuilder(language: 'dart');
                            title = const Text(
                              'Dart',
                            );
                            Navigator.pop(context);
                          });
                        },
                        child: const Text(
                          'Dart',
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                      ),
                      const SizedBox(
                        height: 5,
                      ),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(shape: elevatedStyle),
                        onPressed: () {
                          setState(() {
                            currentPage = const MyStramBuilder(language: 'c#');
                            title = const Text('C#');
                            Navigator.pop(context);
                          });
                        },
                        child: const Text(
                          'C#',
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                      ),
                      const SizedBox(
                        height: 5,
                      ),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(shape: elevatedStyle),
                        onPressed: () {
                          setState(() {
                            currentPage = const MyStramBuilder(language: 'c++');
                            title = const Text('C++');
                            Navigator.pop(context);
                          });
                        },
                        child: const Text(
                          'C++',
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                      ),
                      const SizedBox(
                        height: 5,
                      ),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(shape: elevatedStyle),
                        onPressed: () {
                          setState(() {
                            currentPage = const MyStramBuilder(language: 'c');
                            title = const Text('C');
                            Navigator.pop(context);
                          });
                        },
                        child: const Text(
                          'C',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const Divider(
              thickness: 2,
              color: Colors.blueGrey,
            ),
            ElevatedButton(
              onPressed: () async {
                final list = [menu1, menu2, menu3, menu4];
                int countTrue = 0;
                for (var element in list) {
                  if (element == true) countTrue++;
                }
                if (countTrue > 0) {
                  animationController.reverse();
                  await Future.delayed(
                    const Duration(milliseconds: 300),
                  );
                }
                if (menu2 == false) {
                  setState(() {
                    hight1 = 0;
                    hight2 = perSubItemHight * menuItemNumber2;
                    hight3 = 0;
                    hight4 = 0;
                    menu2 = true;
                  });
                  animationController.forward();
                } else {
                  setState(() {
                    menu1 = false;
                    menu2 = false;
                    menu3 = false;
                    menu4 = false;
                  });
                  animationController.reverse();
                  await Future.delayed(
                    const Duration(milliseconds: 300),
                  );
                  setState(() {
                    hight1 = perSubItemHight * menuItemNumber1;
                    hight2 = perSubItemHight * menuItemNumber2;
                    hight3 = perSubItemHight * menuItemNumber3;
                    hight4 = perSubItemHight * menuItemNumber4;
                  });
                }
              },
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Text(
                    "Design",
                  ),
                  const SizedBox(
                    width: 20,
                  ),
                  Icon(menu2 ? Icons.close : Icons.menu),
                ],
              ),
            ),
            SizeTransition(
              sizeFactor: animator,
              child: Padding(
                padding: const EdgeInsets.only(left: 30),
                child: Container(
                  decoration: const BoxDecoration(
                    color: Color.fromARGB(80, 182, 182, 182),
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(15),
                      bottomRight: Radius.circular(15),
                    ),
                  ),
                  height: hight2,
                  child: ListView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.all(10),
                    children: [
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(shape: elevatedStyle),
                        onPressed: () {
                          setState(() {
                            currentPage =
                                const MyStramBuilder(language: 'html');
                            title = const Text('HTML');
                            Navigator.pop(context);
                          });
                        },
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: const [
                            Icon(FontAwesomeIcons.html5),
                            SizedBox(
                              width: 15,
                            ),
                            Text('HTML'),
                          ],
                        ),
                      ),
                      const SizedBox(
                        height: 5,
                      ),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(shape: elevatedStyle),
                        onPressed: () {
                          setState(() {
                            currentPage = const MyStramBuilder(language: 'css');
                            title = const Text('CSS');
                            Navigator.pop(context);
                          });
                        },
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: const [
                            Icon(FontAwesomeIcons.css3),
                            SizedBox(
                              width: 15,
                            ),
                            Text('CSS'),
                          ],
                        ),
                      ),
                      const SizedBox(
                        height: 5,
                      ),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(shape: elevatedStyle),
                        onPressed: () {
                          setState(() {
                            currentPage =
                                const MyStramBuilder(language: 'flutter');
                            title = const Text('Flutter');
                            Navigator.pop(context);
                          });
                        },
                        child: const Text(
                          'Flutter',
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const Divider(
              thickness: 2,
              color: Colors.blueGrey,
            ),
            ElevatedButton(
              onPressed: () async {
                final list = [menu1, menu2, menu3, menu4];
                int countTrue = 0;
                for (var element in list) {
                  if (element == true) countTrue++;
                }
                if (countTrue > 0) {
                  animationController.reverse();
                  await Future.delayed(
                    const Duration(milliseconds: 300),
                  );
                }
                if (menu3 == false) {
                  setState(() {
                    hight1 = 0;
                    hight2 = 0;
                    hight3 = perSubItemHight * menuItemNumber3;
                    hight4 = 0;
                    menu3 = true;
                  });
                  animationController.forward();
                } else {
                  setState(() {
                    menu1 = false;
                    menu2 = false;
                    menu3 = false;
                    menu4 = false;
                  });
                  animationController.reverse();
                  await Future.delayed(
                    const Duration(milliseconds: 300),
                  );
                  setState(() {
                    hight1 = perSubItemHight * menuItemNumber1;
                    hight2 = perSubItemHight * menuItemNumber2;
                    hight3 = perSubItemHight * menuItemNumber3;
                    hight4 = perSubItemHight * menuItemNumber4;
                  });
                }
              },
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Text(
                    "Operating System",
                  ),
                  const SizedBox(
                    width: 20,
                  ),
                  Icon(menu3 ? Icons.close : Icons.menu),
                ],
              ),
            ),
            SizeTransition(
              sizeFactor: animator,
              child: Padding(
                padding: const EdgeInsets.only(left: 30),
                child: Container(
                  decoration: const BoxDecoration(
                    color: Color.fromARGB(80, 182, 182, 182),
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(15),
                      bottomRight: Radius.circular(15),
                    ),
                  ),
                  height: hight3,
                  child: ListView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.all(10),
                    children: [
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(shape: elevatedStyle),
                        onPressed: () {
                          setState(() {
                            currentPage =
                                const MyStramBuilder(language: 'linux');
                            title = const Text('Linux Operating System');
                            Navigator.pop(context);
                          });
                        },
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: const [
                            Icon(FontAwesomeIcons.linux),
                            SizedBox(
                              width: 15,
                            ),
                            Text('Linux System'),
                          ],
                        ),
                      ),
                      const SizedBox(
                        height: 5,
                      ),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(shape: elevatedStyle),
                        onPressed: () {
                          setState(() {
                            currentPage =
                                const MyStramBuilder(language: 'windows');
                            title = const Text('Windows Operating System');
                            Navigator.pop(context);
                          });
                        },
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: const [
                            Icon(FontAwesomeIcons.windows),
                            SizedBox(
                              width: 15,
                            ),
                            Text('Windows System'),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const Divider(
              thickness: 2,
              color: Colors.blueGrey,
            ),
            ElevatedButton(
              onPressed: () async {
                final list = [menu1, menu2, menu3, menu4];
                int countTrue = 0;
                for (var element in list) {
                  if (element == true) countTrue++;
                }
                if (countTrue > 0) {
                  animationController.reverse();
                  await Future.delayed(
                    const Duration(milliseconds: 300),
                  );
                }
                if (menu4 == false) {
                  setState(() {
                    hight1 = 0;
                    hight2 = 0;
                    hight3 = 0;
                    hight4 = perSubItemHight * menuItemNumber4;
                    menu4 = true;
                  });
                  animationController.forward();
                } else {
                  setState(() {
                    menu1 = false;
                    menu2 = false;
                    menu3 = false;
                    menu4 = false;
                  });
                  animationController.reverse();
                  await Future.delayed(
                    const Duration(milliseconds: 300),
                  );
                  setState(() {
                    hight1 = perSubItemHight * menuItemNumber1;
                    hight2 = perSubItemHight * menuItemNumber2;
                    hight3 = perSubItemHight * menuItemNumber3;
                    hight4 = perSubItemHight * menuItemNumber4;
                  });
                }
              },
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Text(
                    "Blogs",
                  ),
                  const SizedBox(
                    width: 20,
                  ),
                  Icon(menu4 ? Icons.close : Icons.menu),
                ],
              ),
            ),
            SizeTransition(
              sizeFactor: animator,
              child: Padding(
                padding: const EdgeInsets.only(left: 30),
                child: Container(
                  decoration: const BoxDecoration(
                    color: Color.fromARGB(80, 182, 182, 182),
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(15),
                      bottomRight: Radius.circular(15),
                    ),
                  ),
                  height: hight4,
                  child: ListView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.all(10),
                    children: [
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(shape: elevatedStyle),
                        onPressed: () {
                          setState(() {
                            currentPage =
                                const MyStramBuilder(language: 'problemsolved');
                            title = const Text('Problem Solved');
                            Navigator.pop(context);
                          });
                        },
                        child: const Text(
                          'Problem Solved',
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                      ),
                      const SizedBox(
                        height: 5,
                      ),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(shape: elevatedStyle),
                        onPressed: () {
                          setState(() {
                            currentPage =
                                const MyStramBuilder(language: 'blog');
                            title = const Text('Blogs');
                            Navigator.pop(context);
                          });
                        },
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: const [
                            Icon(FontAwesomeIcons.blog),
                            SizedBox(
                              width: 15,
                            ),
                            Text('Blogs'),
                          ],
                        ),
                      ),
                      const SizedBox(
                        height: 5,
                      ),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(shape: elevatedStyle),
                        onPressed: () {
                          setState(() {
                            currentPage = const MyStramBuilder(language: 'doc');
                            title = const Text('Docs');
                            Navigator.pop(context);
                          });
                        },
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: const [
                            Icon(Icons.document_scanner),
                            SizedBox(
                              width: 15,
                            ),
                            Text('Docs'),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const Divider(
              thickness: 2,
              color: Colors.blueGrey,
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
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Icon(Icons.code),
                  SizedBox(
                    width: 15,
                  ),
                  Text('Contributors'),
                ],
              ),
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
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const Login(),
                    ),
                  );
                }
              },
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Icon(Icons.admin_panel_settings),
                  SizedBox(
                    width: 15,
                  ),
                  Text('Admin Page'),
                ],
              ),
            ),
            const Divider(
              thickness: 2,
              color: Colors.blueGrey,
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(shape: elevatedStyle),
              onPressed: () {
                if (FirebaseAuth.instance.currentUser != null) {
                  FirebaseAuth.instance.signOut();
                  setState(() {});
                } else {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const Login(),
                    ),
                  );
                }
              },
              child: loginSignIn,
            ),
          ],
        ),
      ),
      body: currentPage,
    );
  }
}
