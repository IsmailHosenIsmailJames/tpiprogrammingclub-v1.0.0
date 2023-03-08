// ignore_for_file: use_build_context_synchronously

import 'dart:math';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:convert';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart' hide Text;
import 'package:flutter_syntax_view/flutter_syntax_view.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../theme/change_button_theme.dart';

class Editor extends StatefulWidget {
  final String contributionArea;
  const Editor({super.key, required this.contributionArea});

  @override
  State<Editor> createState() => _EditorState();
}

QuillController _controller = QuillController.basic();

class _EditorState extends State<Editor> {
  List<Widget> listOfContent = [];
  final json = {
    "count": {"doc": "doc", "type": "type"},
  };
  int count = 0;

  void add(singleContentJson) {
    setState(() {
      final temJsonEncode = jsonEncode(singleContentJson);
      json.addAll({
        "$count": {"doc": temJsonEncode, "type": "quill"},
      });
      count++;
      QuillController singleContentWidget = QuillController(
        document: Document.fromJson(singleContentJson),
        selection: const TextSelection.collapsed(offset: 0),
      );
      Widget myWiget =
          QuillEditor.basic(controller: singleContentWidget, readOnly: true);
      listOfContent.add(myWiget);
    });
  }

  String profile = "";
  String name = "";
  bool callOneTime = true;

  void get() async {
    String email = FirebaseAuth.instance.currentUser!.email!;
    final json =
        await FirebaseFirestore.instance.collection('user').doc(email).get();
    setState(() {
      profile = json['profile'];
      name = json['name'];
      callOneTime = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (callOneTime) get();
    return Scaffold(
      appBar: AppBar(
        title: const Text('Editor'),
      ),
      body: ListView(
        reverse: true,
        children: [
          const SizedBox(
            height: 10,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    final json = _controller.document.toDelta().toJson();
                    add(json);
                    _controller.clear();
                  });
                },
                child: const Text('Add'),
              ),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    if (count > 0) {
                      listOfContent.removeLast();
                      json.remove("${count - 1}");
                      count--;
                    }
                  });
                },
                child: Row(
                  children: const [
                    Icon(Icons.undo),
                    Text('Undo'),
                  ],
                ),
              ),
              ElevatedButton(
                onPressed: () async {
                  final key = GlobalKey<FormState>();
                  final docNumber = TextEditingController();
                  final titel = TextEditingController();
                  final shortDes = TextEditingController();
                  showCupertinoModalPopup(
                    context: context,
                    builder: (context) => Center(
                      child: SizedBox(
                        height: MediaQuery.of(context).size.height -
                            MediaQuery.of(context).size.height / 10,
                        width: MediaQuery.of(context).size.width -
                            MediaQuery.of(context).size.width / 10,
                        child: Padding(
                          padding: const EdgeInsets.all(15),
                          child: Scaffold(
                            body: Center(
                              child: Form(
                                key: key,
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      TextFormField(
                                        maxLength: 10,
                                        autovalidateMode:
                                            AutovalidateMode.onUserInteraction,
                                        controller: docNumber,
                                        validator: (value) {
                                          try {
                                            double x = double.parse(value!);
                                            if (x < 1) {
                                              return "Tutorial ID must be > 1";
                                            }
                                          } catch (e) {
                                            return "Tutorial ID must be a number.";
                                          }
                                          return null;
                                        },
                                        decoration: InputDecoration(
                                          hintText:
                                              "Give a Rank of this tutorial.",
                                          labelText: "Tutorial Rank",
                                          border: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(5),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(
                                        height: 10,
                                      ),
                                      TextFormField(
                                        maxLength: 50,
                                        autovalidateMode:
                                            AutovalidateMode.onUserInteraction,
                                        controller: titel,
                                        validator: (value) {
                                          if (value!.length < 5) {
                                            return "Titel is too short";
                                          }
                                          return null;
                                        },
                                        decoration: InputDecoration(
                                          hintText: "give a titele",
                                          labelText: "Titel",
                                          border: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(5),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(
                                        height: 10,
                                      ),
                                      TextFormField(
                                        maxLength: 200,
                                        autovalidateMode:
                                            AutovalidateMode.onUserInteraction,
                                        controller: shortDes,
                                        validator: (value) {
                                          if (value!.length < 10) {
                                            return "Description is too short";
                                          }
                                          return null;
                                        },
                                        decoration: InputDecoration(
                                          hintText:
                                              "Short description about tutorial.",
                                          labelText: "Description",
                                          border: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(5),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(
                                        height: 10,
                                      ),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceAround,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        children: [
                                          ElevatedButton(
                                            onPressed: () async {
                                              int len = json.length;
                                              json.addAll({
                                                "info": {
                                                  "len": "$len",
                                                  "title": titel.text.trim(),
                                                  "des": shortDes.text.trim(),
                                                  "email": FirebaseAuth.instance
                                                      .currentUser!.email!,
                                                  "name": name,
                                                  "profile": profile,
                                                }
                                              });

                                              double doubleId =
                                                  double.parse(docNumber.text);

                                              int id = (doubleId * 10000000000)
                                                  .toInt();
                                              String sId = "$id";
                                              int lenth = sId.length;
                                              int needToFill = 20 - lenth;
                                              String fillString =
                                                  "0" * needToFill;
                                              sId = fillString + sId;
                                              final cheakRef = FirebaseFirestore
                                                  .instance
                                                  .collection(
                                                      widget.contributionArea)
                                                  .doc(sId);
                                              final temdoc =
                                                  await cheakRef.get();
                                              if (temdoc.exists) {
                                                Fluttertoast.showToast(
                                                  msg:
                                                      "This Document Rank is allready exits. Try to change the Rank",
                                                  toastLength:
                                                      Toast.LENGTH_LONG,
                                                  gravity: ToastGravity.BOTTOM,
                                                  backgroundColor:
                                                      Colors.grey[700],
                                                  textColor: Colors.white,
                                                );
                                              } else {
                                                final ref = FirebaseFirestore
                                                    .instance
                                                    .collection(
                                                        widget.contributionArea)
                                                    .doc(sId);
                                                final myEncodedJson =
                                                    jsonEncode(json);
                                                await ref.set({
                                                  'doc': myEncodedJson,
                                                  'like': [],
                                                  'comment': []
                                                });
                                                final searchRef =
                                                    FirebaseFirestore.instance
                                                        .collection('search')
                                                        .doc(widget
                                                            .contributionArea);
                                                final searchFile =
                                                    await searchRef.get();
                                                if (searchFile.exists) {
                                                  List des = searchFile['des'];
                                                  List id = searchFile['id'];
                                                  List tle =
                                                      searchFile['title'];
                                                  des.add(shortDes.text.trim());
                                                  id.add(sId);
                                                  tle.add(titel.text.trim());
                                                  await searchRef.set({
                                                    "id": id,
                                                    "title": tle,
                                                    "des": des,
                                                  });
                                                } else {
                                                  final searchRef =
                                                      FirebaseFirestore.instance
                                                          .collection('search')
                                                          .doc(widget
                                                              .contributionArea);
                                                  await searchRef.set({
                                                    "id": [sId],
                                                    "title": [
                                                      titel.text.trim()
                                                    ],
                                                    "des": [
                                                      shortDes.text.trim()
                                                    ],
                                                  });
                                                }
                                              }
                                              final ref = FirebaseFirestore
                                                  .instance
                                                  .collection('user')
                                                  .doc(FirebaseAuth.instance
                                                      .currentUser!.email);
                                              final file = await ref.get();
                                              List post = file['post'];
                                              post.add(
                                                  "${widget.contributionArea}/$sId");
                                              await ref.update({"post": post});

                                              Navigator.pop(context);
                                              Navigator.pop(context);
                                              Fluttertoast.showToast(
                                                msg: "Published Successfully",
                                                toastLength: Toast.LENGTH_LONG,
                                                gravity: ToastGravity.BOTTOM,
                                                backgroundColor:
                                                    Colors.grey[700],
                                                textColor: Colors.white,
                                              );
                                            },
                                            child: const Text("Publish"),
                                          ),
                                          ElevatedButton(
                                            onPressed: () {
                                              Navigator.pop(context);
                                            },
                                            child: const Text('Cancel'),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                },
                child: const Text('Publish'),
              ),
            ],
          ),
          QuillToolbar.basic(
            controller: _controller,
            customButtons: [
              QuillCustomButton(
                icon: Icons.image,
                onTap: () async {
                  if (!kIsWeb) {
                    FilePickerResult? result =
                        await FilePicker.platform.pickFiles(
                      allowCompression: true,
                      type: FileType.custom,
                      allowMultiple: false,
                      allowedExtensions: ['jpg', 'png'],
                    );
                    if (result != null) {
                      final tem = result.files.first;
                      String? extension = tem.extension;
                      File imageFile = File(tem.path!);
                      setState(() {
                        listOfContent.add(SizedBox(
                          height: 300,
                          width: MediaQuery.of(context).size.width -
                              MediaQuery.of(context).size.width / 10,
                          child: Image.file(imageFile),
                        ));
                      });
                      String uploadePath =
                          "${widget.contributionArea}/${Random().nextDouble()}.$extension";
                      final ref =
                          FirebaseStorage.instance.ref().child(uploadePath);
                      UploadTask uploadTask;
                      uploadTask = ref.putFile(imageFile);
                      final snapshot = await uploadTask.whenComplete(() {});
                      String url = await snapshot.ref.getDownloadURL();
                      json.addAll({
                        "$count": {"doc": url, "type": "image", "loc": "fire"}
                      });
                      count++;
                    }
                  }
                  if (kIsWeb) {
                    FilePickerResult? result = await FilePicker.platform
                        .pickFiles(
                            type: FileType.custom,
                            allowMultiple: false,
                            allowCompression: true,
                            allowedExtensions: ['jpg', 'png']);

                    if (result != null) {
                      final tem = result.files.first;
                      Uint8List? selectedImage = tem.bytes;
                      String? extension = tem.extension;
                      setState(() {
                        listOfContent.add(Padding(
                          padding: const EdgeInsets.only(top: 10, bottom: 10),
                          child: SizedBox(
                            height: 300,
                            width: MediaQuery.of(context).size.width -
                                MediaQuery.of(context).size.width / 10,
                            child: Image.memory(selectedImage!),
                          ),
                        ));
                      });
                      String uploadePath =
                          "${widget.contributionArea}/${Random().nextDouble()}.$extension";
                      final ref =
                          FirebaseStorage.instance.ref().child(uploadePath);
                      UploadTask uploadTask;
                      final metadata =
                          SettableMetadata(contentType: 'image/jpeg');
                      uploadTask = ref.putData(selectedImage!, metadata);
                      final snapshot = await uploadTask.whenComplete(() {});
                      String url = await snapshot.ref.getDownloadURL();
                      json.addAll({
                        "$count": {"doc": url, "type": "image", "loc": "fire"}
                      });
                      count++;
                    }
                  }
                },
              ),
              QuillCustomButton(
                icon: FontAwesomeIcons.link,
                onTap: () {
                  final temController = TextEditingController();
                  showModalBottomSheet(
                    context: context,
                    builder: (context) => Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: TextFormField(
                              autofocus: true,
                              controller: temController,
                              decoration: InputDecoration(
                                hintText: "Link of image",
                                labelText: "Link",
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(5),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              ElevatedButton(
                                onPressed: () {
                                  setState(() {
                                    listOfContent.add(
                                      Padding(
                                        padding: const EdgeInsets.all(10),
                                        child:
                                            Image.network(temController.text),
                                      ),
                                    );
                                    json.addAll({
                                      "$count": {
                                        "doc": temController.text,
                                        "type": "image"
                                      }
                                    });
                                    count++;
                                  });
                                  Navigator.pop(context);
                                },
                                child: const Text("Done"),
                              ),
                              const SizedBox(
                                width: 30,
                              ),
                              ElevatedButton(
                                onPressed: () {
                                  Navigator.pop(context);
                                },
                                child: const Text('Cancel'),
                              ),
                            ],
                          )
                        ],
                      ),
                    ),
                  );
                },
              ),
              QuillCustomButton(
                icon: FontAwesomeIcons.code,
                onTap: () {
                  final controller = TextEditingController();
                  showCupertinoModalPopup(
                    context: context,
                    builder: (context) => Center(
                      child: SizedBox(
                        height: 500,
                        width: MediaQuery.of(context).size.width -
                            MediaQuery.of(context).size.width / 10,
                        child: Padding(
                          padding: const EdgeInsets.all(20),
                          child: Scaffold(
                            body: ListView(
                              reverse: true,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceAround,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    ElevatedButton(
                                      onPressed: () {
                                        String code = controller.text;
                                        setState(() {
                                          listOfContent.add(
                                            Padding(
                                              padding: const EdgeInsets.only(
                                                  top: 10, bottom: 10),
                                              child: SyntaxView(
                                                code: code, // Code text
                                                syntax: Syntax.DART, // Language
                                                syntaxTheme: isDark
                                                    ? SyntaxTheme
                                                        .monokaiSublime()
                                                    : SyntaxTheme
                                                        .ayuLight(), // Theme
                                                fontSize: 18.0, // Font size
                                                withZoom:
                                                    true, // Enable/Disable zoom icon controls
                                                withLinesCount:
                                                    true, // Enable/Disable line number
                                                expanded:
                                                    false, // Enable/Disable container expansion
                                              ),
                                            ),
                                          );
                                          json.addAll({
                                            "$count": {
                                              "doc": code,
                                              "type": "code"
                                            }
                                          });
                                          count++;
                                        });
                                        Navigator.pop(context);
                                      },
                                      child: const Text("Add"),
                                    ),
                                    ElevatedButton(
                                      onPressed: () {
                                        Navigator.pop(context);
                                      },
                                      child: const Text('Cancel'),
                                    ),
                                  ],
                                ),
                                const SizedBox(
                                  height: 10,
                                ),
                                TextField(
                                  controller: controller,
                                  scribbleEnabled: true,
                                  maxLines: 1000,
                                  minLines: 15,
                                  decoration: InputDecoration(
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
          Padding(
            padding:
                const EdgeInsets.only(bottom: 10, top: 10, right: 2, left: 2),
            child: Container(
              decoration: BoxDecoration(
                color: const Color.fromARGB(64, 162, 162, 162),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: QuillEditor.basic(
                  controller: _controller,
                  readOnly: false,
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8),
            child: Column(
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: const Color.fromARGB(82, 120, 120, 120),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: listOfContent,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}