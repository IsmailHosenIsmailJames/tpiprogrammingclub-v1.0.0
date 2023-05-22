import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../main.dart';
import '../pages/home/home_page.dart';
import 'single_document_vewer.dart';

class Search extends StatefulWidget {
  const Search({super.key});

  @override
  State<Search> createState() => _SearchState();
}

class _SearchState extends State<Search> {
  final controller = TextEditingController();
  Widget mySearchResult = Container();
  void perfromSearch(String toSearch) {
    setState(() {
      mySearchResult = StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection('search')
            .snapshots(includeMetadataChanges: false),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final userSnapshot = snapshot.data?.docs;
          if (userSnapshot!.isEmpty) {
            return const Center(child: Text("No data"));
          }
          final document = snapshot.data!.docs;

          return ListView.builder(
            physics: const BouncingScrollPhysics(),
            itemCount: document.length,
            itemBuilder: (context, index) {
              List<Widget> searchResult = [];
              DocumentSnapshot currentDoc = document[index];

              List id = currentDoc['id'];
              List title = currentDoc['title'];
              List des = currentDoc['des'];
              for (var i = 0; i < id.length; i++) {
                if ("${id[i]}".contains(toSearch)) {
                  searchResult.add(
                    newGestorSearchResult(
                        context, id, i, currentDoc, title, des),
                  );
                  continue;
                }
                if ("${title[i]}".contains(toSearch)) {
                  searchResult.add(
                    newGestorSearchResult(
                        context, id, i, currentDoc, title, des),
                  );
                  continue;
                }
                if ("${des[i]}".contains(toSearch)) {
                  searchResult.add(
                    newGestorSearchResult(
                        context, id, i, currentDoc, title, des),
                  );
                }
              }

              return Column(
                children: searchResult,
              );
            },
          );
        },
      );
    });
  }

  GestureDetector newGestorSearchResult(
      BuildContext context,
      List<dynamic> id,
      int i,
      DocumentSnapshot<Object?> currentDoc,
      List<dynamic> title,
      List<dynamic> des) {
    return GestureDetector(
      behavior: HitTestBehavior.deferToChild,
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => SingleDocumentViewer(
              id: id[i],
              path: currentDoc.id,
            ),
          ),
        );
      },
      child: Padding(
        padding: const EdgeInsets.all(2),
        child: Container(
          width: MediaQuery.of(context).size.width * 0.98,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            color: const Color.fromARGB(89, 132, 132, 132),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                height: 100,
                width: 100,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  color: const Color.fromARGB(102, 255, 255, 255),
                ),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        "${double.parse(id[i]) / 10000000000}",
                        style: const TextStyle(fontSize: 24),
                      ),
                      Text(
                        currentDoc.id,
                        style: const TextStyle(fontSize: 20),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(
                width: 5,
              ),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    color: const Color.fromARGB(104, 255, 255, 255),
                    height: 30,
                    width: MediaQuery.of(context).size.width - 120,
                    child: Text(
                      "Title: ${title[i]}",
                      softWrap: true,
                      style: const TextStyle(
                        fontSize: 14,
                        overflow: TextOverflow.ellipsis,
                      ),
                      textAlign: TextAlign.start,
                    ),
                  ),
                  Container(
                    color: const Color.fromARGB(104, 255, 255, 255),
                    height: 70,
                    width: MediaQuery.of(context).size.width - 120,
                    child: Text(
                      "Description: ${des[i]}",
                      softWrap: true,
                      maxLines: 10,
                      style: const TextStyle(
                        fontSize: 13,
                        overflow: TextOverflow.ellipsis,
                      ),
                      textAlign: TextAlign.start,
                    ),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const MyDrawer(),
      appBar: AppBar(
        toolbarHeight: 70,
        title: Padding(
          padding: const EdgeInsets.all(2),
          child: TextFormField(
            controller: controller,
            cursorColor: Colors.white,
            autofocus: true,
            decoration: InputDecoration(
              fillColor: const Color.fromARGB(56, 255, 255, 255),
              filled: true,
              hintText: "Type here...",
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(100),
              ),
            ),
          ),
        ),
        actions: [
          IconButton(
            onPressed: () {
              perfromSearch(controller.text.trim());
            },
            icon: const Icon(Icons.search, size: 36),
          ),
        ],
      ),
      body: Container(
          decoration: BoxDecoration(gradient: gradiantOfcontaner),
          child: mySearchResult),
    );
  }
}
