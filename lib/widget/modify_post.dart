import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart' hide Text;
import 'package:fluttertoast/fluttertoast.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

import '../pages/home/home_page.dart';

class ModifyPost extends StatefulWidget {
  final String path;
  final String id;
  const ModifyPost({super.key, required this.path, required this.id});

  @override
  State<ModifyPost> createState() => _ModifyPostState();
}

QuillController quillController = QuillController.basic();

class _ModifyPostState extends State<ModifyPost> {
  bool loading = true;
  bool oneTimeCall = true;
  bool showEditor = false;

  int indexForEditing = 0;
  List jsonDataList = [];

  Widget editingWidget = const Center();
  final txtController = TextEditingController();
  void publish() async {
    apply();
    final docRef =
        FirebaseFirestore.instance.collection(widget.path).doc(widget.id);
    final json = {
      "count": {"doc": "doc", "type": "type"},
    };
    for (var i = 0; i < jsonDataList.length; i++) {
      json.addAll({
        "$i": {
          "doc": "${(jsonDataList[i])["doc"]}",
          "type": "${(jsonDataList[i])["type"]}"
        }
      });
    }

    final mainDoc = await docRef.get();
    final doc = jsonDecode(mainDoc['doc']);
    final info = doc['info'];

    final modifiedinfo = {
      "len": "${jsonDataList.length + 1}",
      "title": "${info['title']}",
      "des": "${info['des']}",
      "name": "${info['name']}",
      "profile": "${info['profile']}",
      "email": "${info['email']}",
    };
    json.addAll({"info": modifiedinfo});
    String jsonAsString = jsonEncode(json);

    await docRef.update({"doc": jsonAsString});

    // ignore: use_build_context_synchronously
    Navigator.pop(context);
    Fluttertoast.showToast(
      msg: "Modified Successfully",
      toastLength: Toast.LENGTH_LONG,
      gravity: ToastGravity.BOTTOM,
      backgroundColor: Colors.grey[700],
      textColor: Colors.white,
      timeInSecForIosWeb: 3,
    );
  }

  void add() {
    QuillController tem = QuillController.basic();
    String txt = jsonEncode(tem.document.toDelta().toJson());
    if (jsonDataList.isEmpty) {
      jsonDataList.insert(0, {"doc": txt, "type": "quill"});
      editingWidgetMaker(0);
    } else {
      jsonDataList.insert(indexForEditing + 1, {"doc": txt, "type": "quill"});
      editingWidgetMaker(indexForEditing + 1);
    }
  }

  void apply() {
    if (jsonDataList.isEmpty) {
      Fluttertoast.showToast(
        msg: "The Post is Empty.",
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.grey[700],
        textColor: Colors.white,
        timeInSecForIosWeb: 3,
      );
    } else {
      final doc = jsonDataList[indexForEditing];
      String type = doc!['type']!;
      if (type == "quill") {
        String doc = jsonEncode(quillController.document.toDelta().toJson());
        jsonDataList[indexForEditing] = {"doc": doc, "type": "quill"};
      } else if (type == "code") {
        jsonDataList[indexForEditing] = {
          "doc": txtController.text,
          "type": "code"
        };
      }
    }
  }

  void delete() {
    if (jsonDataList.length > 1) {
      if (indexForEditing != 0) {
        jsonDataList.removeAt(indexForEditing);
        setState(() {
          indexForEditing--;
        });
        editingWidgetMaker(indexForEditing);
      } else {
        jsonDataList.removeAt(indexForEditing);
        editingWidgetMaker(indexForEditing);
      }
    } else {
      jsonDataList = [];
      indexForEditing = 0;
      setState(() {
        editingWidget = const Center(
          child: Text('Empty'),
        );
      });
    }
  }

  void next() {
    apply();
    if (indexForEditing < jsonDataList.length - 1) {
      setState(() {
        indexForEditing++;
      });
      editingWidgetMaker(indexForEditing);
    }
  }

  void previous() {
    apply();

    if (indexForEditing > 0) {
      setState(() {
        indexForEditing--;
      });
      editingWidgetMaker(indexForEditing);
    }
  }

  void editingWidgetMaker(int indexForEditing) {
    final doc = jsonDataList[indexForEditing];
    String type = doc!['type']!;
    if (type == "quill") {
      setState(() {
        showEditor = true;
        quillController = QuillController(
          document: Document.fromJson(
            jsonDecode(doc['doc']!),
          ),
          selection: const TextSelection.collapsed(offset: 0),
        );
        editingWidget =
            QuillEditor.basic(controller: quillController, readOnly: false);
      });
    } else if (type == "image") {
      Widget myWidget = GestureDetector(
        onTap: () async {
          if (!await launchUrl(
            Uri.parse(
              doc['doc']!,
            ),
          )) {
            throw Exception(
              'Could not launch',
            );
          }
        },
        child: SizedBox(
          height: MediaQuery.of(context).size.width * 0.60,
          width: MediaQuery.of(context).size.width,
          child: CachedNetworkImage(
            imageUrl: doc['doc']!,
            progressIndicatorBuilder: (context, url, downloadProgress) =>
                Center(
              child: Center(
                child:
                    CircularProgressIndicator(value: downloadProgress.progress),
              ),
            ),
            errorWidget: (context, url, error) => OutlinedButton(
              onPressed: () async {
                if (!await launchUrl(
                  Uri.parse(
                    doc['doc']!,
                  ),
                )) {
                  throw Exception(
                    'Could not launch ${doc['doc']}',
                  );
                }
              },
              child: const Text(
                'For Image Click Here',
                style: TextStyle(
                  color: Colors.blue,
                  fontSize: 22,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ),
      );
      setState(() {
        showEditor = false;
        editingWidget = myWidget;
      });
    } else if (type == 'code') {
      txtController.text = doc['doc']!;
      setState(() {
        showEditor = false;
        editingWidget = TextFormField(
          controller: txtController,
          autocorrect: false,
          minLines: 10,
          maxLines: 1000,
          autofocus: true,
          decoration: InputDecoration(
            hintText: "Type your Code",
            labelText: "Code",
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15),
            ),
          ),
        );
      });
    }
  }

  void getData() async {
    setState(() {
      jsonDataList = [];
      indexForEditing = 0;
      oneTimeCall = false;
    });
    final docRef =
        FirebaseFirestore.instance.collection(widget.path).doc(widget.id);
    final doc = await docRef.get();
    final editableJson = jsonDecode(doc['doc']);
    int len = int.parse((editableJson['info'])['len']);
    for (var i = 0; i < len - 1; i++) {
      jsonDataList.add(editableJson['$i']);
    }

    editingWidgetMaker(0);
  }

  @override
  Widget build(BuildContext context) {
    if (oneTimeCall) getData();
    return Scaffold(
      drawer: const MyDrawer(),
      appBar: AppBar(
        title: const Text('Modify Post'),
      ),
      body: ListView(
        physics: const BouncingScrollPhysics(),
        reverse: true,
        children: [
          QuillToolbar.basic(
            controller: quillController,
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

                      String uploadePath =
                          "${widget.path}/${Random().nextDouble()}.$extension";
                      final ref =
                          FirebaseStorage.instance.ref().child(uploadePath);
                      UploadTask uploadTask;
                      uploadTask = ref.putFile(imageFile);
                      final snapshot = await uploadTask.whenComplete(() {});
                      String url = await snapshot.ref.getDownloadURL();
                      setState(() {
                        jsonDataList.insert(indexForEditing + 1,
                            {"doc": url, "type": "image", "loc": "fire"});
                        editingWidgetMaker(indexForEditing + 1);
                      });
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

                      String uploadePath =
                          "${widget.path}/${Random().nextDouble()}.$extension";
                      final ref =
                          FirebaseStorage.instance.ref().child(uploadePath);
                      UploadTask uploadTask;
                      final metadata =
                          SettableMetadata(contentType: 'image/jpeg');
                      uploadTask = ref.putData(selectedImage!, metadata);
                      final snapshot = await uploadTask.whenComplete(() {});
                      String url = await snapshot.ref.getDownloadURL();
                      setState(() {
                        jsonDataList.insert(indexForEditing + 1,
                            {"doc": url, "type": "image", "loc": "fire"});
                        editingWidgetMaker(indexForEditing + 1);
                      });
                    }
                  }
                },
              ),
              QuillCustomButton(
                icon: FontAwesomeIcons.link,
                onTap: () {
                  final temController = TextEditingController();
                  showCupertinoModalPopup(
                    context: context,
                    builder: (context) => Scaffold(
                      appBar: AppBar(
                        title: const Text('Link Image'),
                      ),
                      body: Column(
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
                                    jsonDataList.insert(indexForEditing + 1, {
                                      "doc": temController.text.trim(),
                                      "type": "image",
                                      "loc": "url"
                                    });
                                    editingWidgetMaker(indexForEditing + 1);
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
                    builder: (context) => Scaffold(
                      appBar: AppBar(
                        title: const Text('Code'),
                      ),
                      body: Padding(
                        padding: const EdgeInsets.all(5),
                        child: ListView(
                          reverse: true,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                ElevatedButton(
                                  onPressed: () {
                                    String code = controller.text;
                                    setState(() {
                                      jsonDataList.insert(indexForEditing + 1, {
                                        "doc": code,
                                        "type": "code",
                                      });
                                      editingWidgetMaker(indexForEditing + 1);
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
                              autocorrect: false,
                              autofocus: true,
                              maxLines: 1000,
                              minLines: 7,
                              decoration: InputDecoration(
                                labelText: "Code",
                                hintText: "Type or Paste your code",
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              IconButton(
                onPressed: () {
                  previous();
                },
                icon: const Icon(
                  Icons.arrow_back_ios_new_outlined,
                  size: 20,
                ),
              ),
              IconButton(
                onPressed: () {
                  delete();
                },
                icon: const Icon(
                  Icons.delete_forever_rounded,
                  size: 20,
                ),
              ),
              IconButton(
                onPressed: () {
                  getData();
                },
                icon: const Icon(
                  Icons.restore,
                  size: 20,
                ),
              ),
              IconButton(
                onPressed: () {
                  add();
                },
                icon: const Icon(
                  Icons.add_box,
                  size: 20,
                ),
              ),
              IconButton(
                onPressed: () {
                  publish();
                },
                icon: const Icon(
                  Icons.publish,
                  size: 20,
                ),
              ),
              IconButton(
                onPressed: () {
                  next();
                },
                icon: const Icon(
                  Icons.arrow_forward_ios_outlined,
                  size: 20,
                ),
              ),
            ],
          ),
          Container(
            decoration: BoxDecoration(
              color: const Color.fromARGB(64, 162, 162, 162),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Padding(
              padding: const EdgeInsets.all(5),
              child: editingWidget,
            ),
          ),
        ],
      ),
    );
  }
}
