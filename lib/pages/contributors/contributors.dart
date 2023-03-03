// ignore_for_file: use_build_context_synchronously

import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:tpiprogrammingclub/pages/home/home_page.dart';
import 'package:tpiprogrammingclub/pages/profile/profile.dart';
import 'package:url_launcher/url_launcher.dart';

class Contributors extends StatefulWidget {
  const Contributors({super.key});

  @override
  State<Contributors> createState() => _ContributorsState();
}

class _ContributorsState extends State<Contributors> {
  Widget mywidget = const CircularProgressIndicator();
  bool onetimeCall = true;
  void getRankList() async {
    setState(() {
      onetimeCall = false;
    });
    final file =
        await FirebaseFirestore.instance.collection('rank').doc('rank').get();
    List allList = file['rank'];
    allList = allList.reversed.toList();

    List<Widget> widgetList = [];
    for (int i = 0; i < allList.length; i++) {
      String details = allList[i];
      int points = int.parse(details.substring(0, 5));
      final json = jsonDecode(details.substring(5));
      String name = json['name'];
      String email = json['email'];
      String profile = json['profile'];
      List allPost = json['post'];
      int like = json['like'];
      if (points > 0) {
        Widget avatar = ClipRRect(
          borderRadius: BorderRadius.circular(1000),
          child: Container(
            height: 300,
            width: 300,
            color: const Color.fromARGB(80, 170, 170, 170),
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
                    if (!await launchUrl(
                      Uri.parse(
                        profile,
                      ),
                    )) {
                      throw Exception(
                        'Could not launch',
                      );
                    }
                  },
                  child: const Text(
                    'For Image Click Here',
                    style: TextStyle(
                      fontSize: 23,
                      color: Colors.blue,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ),
          ),
        );
        widgetList.add(
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              color: const Color.fromARGB(81, 153, 153, 153),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                avatar,
                const SizedBox(
                  height: 10,
                ),
                const Divider(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      'Total Point : $points',
                      style: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      'Like : $like',
                      style: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      'Post : ${allPost.length}',
                      style: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                const Divider(),
                Text(
                  'Name : $name',
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const Divider(),
                Text(
                  'Email : $email',
                  style: const TextStyle(fontSize: 14),
                ),
                const Divider(),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    shape: elevatedStyle,
                    minimumSize:
                        Size(MediaQuery.of(context).size.width * 0.95, 35),
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => Profile(email: email),
                      ),
                    );
                  },
                  child: const Text('Visit Profile'),
                ),
                const SizedBox(
                  height: 10,
                ),
              ],
            ),
          ),
        );
        widgetList.add(
          const Divider(
            color: Colors.black,
          ),
        );
      }
    }

    setState(() {
      mywidget = Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: widgetList,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    if (onetimeCall) getRankList();
    return ListView(
      addAutomaticKeepAlives: true,
      physics: const BouncingScrollPhysics(),
      children: [
        const SizedBox(
          height: 10,
        ),
        Center(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(1000),
            child: Container(
              height: 300,
              width: 300,
              color: const Color.fromARGB(80, 170, 170, 170),
              child: CachedNetworkImage(
                imageUrl:
                    "https://scontent.fdac24-1.fna.fbcdn.net/v/t39.30808-6/257764352_421357696128525_3923772872302578932_n.jpg?_nc_cat=102&ccb=1-7&_nc_sid=09cbfe&_nc_eui2=AeEk28nnx2EaxvIbYoua520YhnIBAGJbQyuGcgEAYltDK9FpyaWJ5ZLcILRiIH6wL5ooDCvdIxrRLRuEzpR2PL-l&_nc_ohc=9wIUOX1ivlAAX-U0kh8&_nc_ht=scontent.fdac24-1.fna&oh=00_AfB7bn7M9bVakeVGWqT6lhJzZK0FUSMONFAQuvXYJhaZtQ&oe=64064D87",
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
                      if (!await launchUrl(
                        Uri.parse(
                          "https://scontent.fdac24-1.fna.fbcdn.net/v/t39.30808-6/257764352_421357696128525_3923772872302578932_n.jpg?_nc_cat=102&ccb=1-7&_nc_sid=09cbfe&_nc_eui2=AeEk28nnx2EaxvIbYoua520YhnIBAGJbQyuGcgEAYltDK9FpyaWJ5ZLcILRiIH6wL5ooDCvdIxrRLRuEzpR2PL-l&_nc_ohc=9wIUOX1ivlAAX-U0kh8&_nc_ht=scontent.fdac24-1.fna&oh=00_AfB7bn7M9bVakeVGWqT6lhJzZK0FUSMONFAQuvXYJhaZtQ&oe=64064D87",
                        ),
                      )) {
                        throw Exception(
                          'Could not launch',
                        );
                      }
                    },
                    child: const Text(
                      'For Image Click Here',
                      style: TextStyle(
                        fontSize: 22,
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
        const SizedBox(
          height: 10,
        ),
        const Center(
          child: Text(
            'Developer of this WebApp and Android App',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(
          height: 5,
        ),
        const Divider(
          height: 2,
          color: Colors.black,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Text(
              'Follow me :',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            IconButton(
              onPressed: () async {
                if (!await launchUrl(
                  Uri.parse(
                    "https://github.com/IsmailHosenIsmailJames",
                  ),
                )) {
                  throw Exception(
                    'Could not launch "https://github.com/IsmailHosenIsmailJames"',
                  );
                }
              },
              icon: const Icon(FontAwesomeIcons.github,
                  size: 30.0, color: Colors.blue),
            ),
            IconButton(
              onPressed: () async {
                if (!await launchUrl(
                  Uri.parse(
                    "https://www.facebook.com/mdismailhosen.james",
                  ),
                )) {
                  throw Exception(
                    'Could not launch "https://www.facebook.com/mdismailhosen.james"',
                  );
                }
              },
              icon: const Icon(FontAwesomeIcons.facebook,
                  size: 30.0, color: Colors.blue),
            ),
            IconButton(
              onPressed: () async {
                if (!await launchUrl(
                  Uri.parse(
                    "https://www.linkedin.com/in/ismail-hosen-3756a4211/",
                  ),
                )) {
                  throw Exception(
                    'Could not launch "https://www.linkedin.com/in/ismail-hosen-3756a4211/"',
                  );
                }
              },
              icon: const Icon(FontAwesomeIcons.linkedin,
                  size: 30.0, color: Colors.blue),
            ),
            IconButton(
              onPressed: () async {
                if (!await launchUrl(
                  Uri.parse(
                    "https://stackoverflow.com/users/20796524/md-ismail-hosen-james",
                  ),
                )) {
                  throw Exception(
                    'Could not launch "https://stackoverflow.com/users/20796524/md-ismail-hosen-james"',
                  );
                }
              },
              icon: const Icon(FontAwesomeIcons.stackOverflow,
                  size: 30.0, color: Colors.blue),
            ),
          ],
        ),
        const Divider(
          height: 2,
          color: Colors.black,
        ),
        const SizedBox(
          height: 10,
        ),
        Center(
          child: mywidget,
        ),
      ],
    );
  }
}
