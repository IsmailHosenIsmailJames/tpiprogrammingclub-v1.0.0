import "package:cloud_firestore/cloud_firestore.dart";
import "package:flutter/material.dart";
import "package:fluttertoast/fluttertoast.dart";
import "package:tpiprogrammingclub/pages/home/home_page.dart";

final deleteController = TextEditingController();
final key = GlobalKey<FormState>();

class DeletePost extends StatelessWidget {
  const DeletePost({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const MyDrawer(),
      appBar: AppBar(
        title: const Text("Delete a Post"),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Form(
            key: key,
            child: TextFormField(
              controller: deleteController,
              autocorrect: false,
              validator: (value) {
                if (value!.isNotEmpty && value.contains('/')) {
                  return null;
                } else {
                  return "This is not correct.";
                }
              },
              decoration: InputDecoration(
                hintText: "Enter address as path/id(e.g. python/5)",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
              ),
            ),
          ),
          const SizedBox(
            height: 15,
          ),
          ElevatedButton(
            onPressed: () {
              showModalBottomSheet(
                context: context,
                builder: (context) => Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const Text("Are you sure ?"),
                      const SizedBox(
                        height: 20,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          ElevatedButton(
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            child: const Text("Cancel"),
                          ),
                          const SizedBox(
                            width: 20,
                          ),
                          ElevatedButton(
                            onPressed: () async {
                              if (key.currentState!.validate()) {
                                Fluttertoast.showToast(
                                  msg: "searching..",
                                  toastLength: Toast.LENGTH_LONG,
                                  gravity: ToastGravity.BOTTOM,
                                  backgroundColor: Colors.grey[700],
                                  textColor: Colors.white,
                                  timeInSecForIosWeb: 3,
                                );
                                List address = deleteController.text.split("/");
                                String path = address[0];
                                double doubleId = double.parse(address[1]);
                                int id = (doubleId * 10000000000).toInt();
                                String sId = "$id";
                                int lenth = sId.length;
                                int needToFill = 20 - lenth;
                                String fillString = "0" * needToFill;
                                sId = fillString + sId;
                                final result = await FirebaseFirestore.instance
                                    .collection(path)
                                    .doc(sId)
                                    .get();

                                if (result.exists) {
                                  DateTime now = DateTime.now();
                                  int randomNumber =
                                      now.year * 365 * 24 * 60 * 60 +
                                          now.month * 30 * 24 * 60 * 60 +
                                          now.day * 24 * 60 * 60 +
                                          now.hour * 60 * 60 +
                                          now.minute * 60 +
                                          now.second;
                                  FirebaseFirestore.instance
                                      .collection('achieve')
                                      .doc("$randomNumber")
                                      .set({
                                    "comment": result['comment'],
                                    "doc": result['doc'],
                                    "like": result['like'],
                                    "language": path,
                                    "id": sId,
                                  });
                                  FirebaseFirestore.instance
                                      .collection(path)
                                      .doc(sId)
                                      .delete();
                                  final searchOption = await FirebaseFirestore
                                      .instance
                                      .collection("search")
                                      .doc(path)
                                      .get();
                                  List des = searchOption['des'];
                                  List idList = searchOption['id'];
                                  List title = searchOption['title'];
                                  int index = idList.indexOf(id);
                                  if (index != -1) {
                                    des.removeAt(index);
                                    idList.removeAt(index);
                                    title.removeAt(index);
                                  }
                                  await FirebaseFirestore.instance
                                      .collection("search")
                                      .doc(path)
                                      .set({
                                    "des": des,
                                    "id": idList,
                                    "title": title
                                  });
                                  Fluttertoast.showToast(
                                    msg: "Delete Successfull",
                                    toastLength: Toast.LENGTH_LONG,
                                    gravity: ToastGravity.BOTTOM,
                                    backgroundColor: Colors.grey[700],
                                    textColor: Colors.white,
                                    timeInSecForIosWeb: 3,
                                  );
                                  // ignore: use_build_context_synchronously
                                  Navigator.pop(context);
                                  // ignore: use_build_context_synchronously
                                  Navigator.canPop(context);
                                  // ignore: use_build_context_synchronously
                                  Navigator.canPop(context);
                                } else {
                                  Fluttertoast.showToast(
                                    msg: "No mached found",
                                    toastLength: Toast.LENGTH_LONG,
                                    gravity: ToastGravity.BOTTOM,
                                    backgroundColor: Colors.grey[700],
                                    textColor: Colors.white,
                                    timeInSecForIosWeb: 3,
                                  );
                                  // ignore: use_build_context_synchronously
                                  Navigator.pop(context);
                                }
                              }
                            },
                            child: const Text('Delete'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
            child: const Text("Delete"),
          ),
        ],
      ),
    );
  }
}
