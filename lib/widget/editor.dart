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
import 'package:flutter/services.dart';
import 'package:flutter_quill/flutter_quill.dart' hide Text;
import 'package:fluttertoast/fluttertoast.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../pages/home/home_page.dart';
import 'publish_post.dart';

class Editor extends StatefulWidget {
  final String contributionArea;
  const Editor({super.key, required this.contributionArea});

  @override
  State<Editor> createState() => _EditorState();
}

QuillController _controller = QuillController.basic();
final json = {
  "count": {"doc": "doc", "type": "type"},
};

class _EditorState extends State<Editor> {
  List<Widget> listOfContent = [];

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
      drawer: const MyDrawer(),
      appBar: AppBar(
        title: const Text('Editor'),
      ),
      body: ListView(
        physics: const BouncingScrollPhysics(),
        reverse: true,
        children: [
          QuillToolbar.basic(
            controller: _controller,
            customButtons: [
              QuillCustomButton(
                icon: Icons.image,
                onTap: () async {
                  setState(() {
                    final json = _controller.document.toDelta().toJson();
                    add(json);
                    _controller.clear();
                  });
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
                            height: MediaQuery.of(context).size.width * 0.60,
                            width: MediaQuery.of(context).size.width,
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
                  setState(() {
                    final json = _controller.document.toDelta().toJson();
                    add(json);
                    _controller.clear();
                  });
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
                                hintText: "Paste URL link of your image..",
                                labelText: "Link of image",
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
                  setState(() {
                    final json = _controller.document.toDelta().toJson();
                    add(json);
                    _controller.clear();
                  });
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
                                      listOfContent.add(Padding(
                                        padding: const EdgeInsets.all(3),
                                        child: Container(
                                          decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(15),
                                            color: Colors.black,
                                          ),
                                          child: Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.start,
                                            children: [
                                              Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: [
                                                  const Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .center,
                                                    children: [
                                                      SizedBox(
                                                        width: 10,
                                                      ),
                                                      CircleAvatar(
                                                        radius: 4,
                                                        backgroundColor:
                                                            Colors.red,
                                                      ),
                                                      SizedBox(
                                                        width: 5,
                                                      ),
                                                      CircleAvatar(
                                                        radius: 4,
                                                        backgroundColor:
                                                            Colors.yellow,
                                                      ),
                                                      SizedBox(
                                                        width: 5,
                                                      ),
                                                      CircleAvatar(
                                                        radius: 4,
                                                        backgroundColor:
                                                            Colors.green,
                                                      )
                                                    ],
                                                  ),
                                                  Padding(
                                                    padding:
                                                        const EdgeInsets.only(
                                                            right: 7),
                                                    child: ElevatedButton(
                                                      style: ElevatedButton
                                                          .styleFrom(
                                                        shape: elevatedStyle,
                                                        backgroundColor:
                                                            Colors.blueGrey,
                                                      ),
                                                      onPressed: () {
                                                        Clipboard.setData(
                                                          ClipboardData(
                                                            text: code,
                                                          ),
                                                        );
                                                        Fluttertoast.showToast(
                                                          msg:
                                                              "Copied Successfull!",
                                                          toastLength:
                                                              Toast.LENGTH_LONG,
                                                          gravity: ToastGravity
                                                              .BOTTOM,
                                                          backgroundColor:
                                                              Colors.grey[700],
                                                          textColor:
                                                              Colors.white,
                                                        );
                                                      },
                                                      child: const Row(
                                                        children: [
                                                          Text('Copy'),
                                                          Icon(Icons.copy),
                                                        ],
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              const SizedBox(
                                                height: 2,
                                              ),
                                              SingleChildScrollView(
                                                physics:
                                                    const BouncingScrollPhysics(),
                                                scrollDirection:
                                                    Axis.horizontal,
                                                child: Padding(
                                                  padding:
                                                      const EdgeInsets.all(5),
                                                  child: SelectableText(
                                                    code,
                                                    textAlign: TextAlign.start,
                                                    style: const TextStyle(
                                                      fontFamily: 'monospace',
                                                      fontSize: 16.0,
                                                      color: Colors.white,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ));
                                      json.addAll({
                                        "$count": {"doc": code, "type": "code"}
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
                              autocorrect: false,
                              autofocus: true,
                              maxLines: 1000,
                              minLines: 10,
                              decoration: InputDecoration(
                                labelText: "Code",
                                hintText: "Type or Paste here your code",
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
              QuillCustomButton(
                onTap: () {
                  setState(() {
                    final json = _controller.document.toDelta().toJson();
                    add(json);
                    _controller.clear();
                  });
                },
                icon: Icons.add_box_outlined,
              ),
              QuillCustomButton(
                onTap: () {
                  setState(() {
                    if (count > 0) {
                      listOfContent.removeLast();
                      json.remove("${count - 1}");
                      count--;
                    }
                  });
                },
                icon: Icons.undo,
              ),
              QuillCustomButton(
                onTap: () async {
                  setState(() {
                    final json = _controller.document.toDelta().toJson();
                    add(json);
                    _controller.clear();
                  });
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => PublishPost(
                        contributionArea: widget.contributionArea,
                        name: name,
                        profile: profile,
                      ),
                    ),
                  );
                },
                icon: Icons.publish,
              )
            ],
          ),
          Container(
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
