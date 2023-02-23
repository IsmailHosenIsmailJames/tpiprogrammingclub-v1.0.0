import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../widget/single_document_vewer.dart';

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
            itemCount: document.length,
            itemBuilder: (context, index) {
              List<Widget> searchResult = [];
              DocumentSnapshot currentDoc = document[index];

              List id = currentDoc['id'];
              List title = currentDoc['title'];
              List des = currentDoc['des'];
              for (var i = 0; i < title.length; i++) {
                if ("${title[i]}".contains(toSearch)) {
                  searchResult.add(
                    GestureDetector(
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
                          height: 80,
                          width: MediaQuery.of(context).size.width * 0.95,
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(100),
                              color: const Color.fromARGB(89, 132, 132, 132)),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Container(
                                height: 80,
                                width: 80,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(100),
                                  color:
                                      const Color.fromARGB(102, 255, 255, 255),
                                ),
                                child: Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
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
                                  Text("Title:${title[i]}"),
                                  Text("Des: ${des[i]}"),
                                ],
                              )
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                }
              }
              for (var i = 0; i < des.length; i++) {
                if ("${des[i]}".contains(toSearch)) {
                  searchResult.add(
                    GestureDetector(
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
                          height: 80,
                          width: MediaQuery.of(context).size.width * 0.95,
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(100),
                              color: const Color.fromARGB(89, 132, 132, 132)),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Container(
                                height: 80,
                                width: 80,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(100),
                                  color:
                                      const Color.fromARGB(102, 255, 255, 255),
                                ),
                                child: Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
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
                                  Text("Title:${title[i]}"),
                                  Text("Des: ${des[i]}"),
                                ],
                              )
                            ],
                          ),
                        ),
                      ),
                    ),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
      body: mySearchResult,
    );
  }
}
