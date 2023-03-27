import "package:cloud_firestore/cloud_firestore.dart";
import "package:flutter/material.dart";
import "package:fluttertoast/fluttertoast.dart";

final deleteController = TextEditingController();
final key = GlobalKey<FormState>();

class DeletePost extends StatelessWidget {
  const DeletePost({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
            onPressed: () async {
              if (key.currentState!.validate()) {
                Fluttertoast.showToast(
                  msg: "searching..",
                  toastLength: Toast.LENGTH_LONG,
                  gravity: ToastGravity.BOTTOM,
                  backgroundColor: Colors.grey[700],
                  textColor: Colors.white,
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
                  FirebaseFirestore.instance.collection(path).doc(sId).delete();
                  final searchOption = await FirebaseFirestore.instance
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
                      .set({"des": des, "id": idList, "title": title});
                  Fluttertoast.showToast(
                    msg: "Delete Successfull",
                    toastLength: Toast.LENGTH_LONG,
                    gravity: ToastGravity.BOTTOM,
                    backgroundColor: Colors.grey[700],
                    textColor: Colors.white,
                  );
                  // ignore: use_build_context_synchronously
                  Navigator.pop(context);
                } else {
                  Fluttertoast.showToast(
                    msg: "No mached found",
                    toastLength: Toast.LENGTH_LONG,
                    gravity: ToastGravity.BOTTOM,
                    backgroundColor: Colors.grey[700],
                    textColor: Colors.white,
                  );
                }
              }
            },
            child: const Text("Delete"),
          ),
          const Text(
            "Warning : Once you delete, It never can be recovered.",
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.red,
            ),
          ),
        ],
      ),
    );
  }
}
