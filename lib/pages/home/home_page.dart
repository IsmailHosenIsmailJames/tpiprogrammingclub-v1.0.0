import 'package:flutter/material.dart';
import '../../theme/change_button_theme.dart';
import '../blogs/blogs.dart';
import '../community/community.dart';
import '../contributors/contributors.dart';
import '../docs/docs.dart';
import '../learn_c_plus_plus/learn_c_plus_plus.dart';
import '../learn_c_sharp/learn_c_sharp.dart';
import '../learn_python/learn_python.dart';
import 'home.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

Widget currentPage = const Home();

class _HomePageState extends State<HomePage> {
  Widget title = Row(
    children: const [Text("Home "), Icon(Icons.home)],
  );

  final elevatedStyle = const RoundedRectangleBorder(
    borderRadius: BorderRadius.only(
      bottomLeft: Radius.circular(100),
      topRight: Radius.circular(100),
    ),
  );
  @override
  Widget build(BuildContext context) {
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
                            child: const Center(
                              child: Text(
                                'TPI',
                                style: TextStyle(
                                    color: Color.fromARGB(255, 15, 79, 132),
                                    fontSize: 40,
                                    fontWeight: FontWeight.bold),
                              ),
                            ),
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
              child: const Text('Learn Python'),
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
              child: const Text('Learn C++'),
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
              child: const Text('Learn C#'),
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
