// ignore_for_file: use_build_context_synchronously

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:tpiprogrammingclub/pages/profile/profile.dart';

class Aplication extends StatefulWidget {
  const Aplication({super.key});

  @override
  State<Aplication> createState() => _AplicationState();
}

class _AplicationState extends State<Aplication> {
  bool onetimeCall = true;
  Widget myWiget = const CircularProgressIndicator();
  void get() async {
    final ref = await FirebaseFirestore.instance
        .collection('admin')
        .doc('application')
        .get();
    List list = ref['list'];
    List<Widget> widgetList = [];
    for (int i = 0; i < list.length; i++) {
      widgetList.add(
        GestureDetector(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(5),
                color: const Color.fromARGB(95, 143, 143, 143),
              ),
              height: 50,
              width: MediaQuery.of(context).size.width * 0.95,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(list[i]),
                  ElevatedButton(
                    onPressed: () async {
                      final ref = FirebaseFirestore.instance
                          .collection('user')
                          .doc('contributor');
                      final file = await ref.get();
                      List approvedList = file['list'];
                      approvedList.add(list[i]);
                      await ref.set({'list': approvedList});

                      list.removeAt(i);
                      await FirebaseFirestore.instance
                          .collection('admin')
                          .doc('application')
                          .update({'list': list});
                      get();
                    },
                    child: const Text('Approve'),
                  ),
                ],
              ),
            ),
          ),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => Profile(email: list[i]),
              ),
            );
          },
        ),
      );
    }
    setState(() {
      if (list.isEmpty) {
        myWiget = const Text('Found no aplication');
      } else {
        myWiget = Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: widgetList,
        );
      }
      onetimeCall = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (onetimeCall) get();
    return Scaffold(
      appBar: AppBar(
        title: const Text('Aplication'),
      ),
      body: Center(
        child: myWiget,
      ),
    );
  }
}
