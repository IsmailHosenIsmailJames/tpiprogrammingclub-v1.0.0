// // ignore_for_file: use_build_context_synchronously

// import 'dart:convert';

// import 'package:cached_network_image/cached_network_image.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:flutter_quill/flutter_quill.dart' hide Text;
// import 'package:fluttertoast/fluttertoast.dart';
// import 'package:url_launcher/url_launcher.dart';

// import '../authentication/login.dart';
// import '../pages/home/home_page.dart';
// import '../pages/profile/profile.dart';
// import 'comment.dart';
// import 'modify_post.dart';

// List supportedLanguage = [
//   "python",
//   "java",
//   "c",
//   "c++",
//   "c#",
//   "javascript",
//   "dart",
//   "html",
//   "css",
//   "flutter",
//   "windows",
//   "linux",
//   "docs",
// ];

// class MyStramBuilder extends StatefulWidget {
//   final String path;

//   const MyStramBuilder({super.key, required this.path});

//   @override
//   State<MyStramBuilder> createState() => _MyStramBuilderState();
// }

// bool callOneTimeStream = true;
// bool canGotDataStream = true;

// class _MyStramBuilderState extends State<MyStramBuilder> {
//   Widget allTutorial = const CircularProgressIndicator();
//   List<Widget> smallTutorialList = [];
//   List<Widget> fullTutorialList = [];

//   Widget documentView = const Center(child: CircularProgressIndicator());
//   int flexNumber = 1;
//   Icon iconButton = const Icon(
//     Icons.arrow_forward_ios,
//     size: 12,
//   );

//   void getListOfTutorial() async {
//     List paths = widget.path.split("/");
//     if (!supportedLanguage.contains(paths[1])) {
//       setState(() {
//         documentView = const Center(child: Text("No Data Found"));
//         allTutorial = const Text("No Data Found");
//         smallTutorialList = [];
//         fullTutorialList = [];
//         canGotDataStream = false;
//       });
//       return;
//     }
//     setState(() {
//       documentView = const Center(child: CircularProgressIndicator());
//       allTutorial = const CircularProgressIndicator();
//       smallTutorialList = [];
//       fullTutorialList = [];
//       canGotDataStream = false;
//     });
//     print("Ismail");
//     final documentRef = FirebaseFirestore.instance
//         .collection("search")
//         .doc(widget.path.split("/")[1]);
//     final document = await documentRef.get();
//     List id = document["id"];
//     List title = document["title"];
//     if (paths.length == 3) {
//       try {
//         print("dskhvfdhjgvshjgcjshcjsh");
//         double doubleValueOfId = double.parse(paths[2]) * 10000000000;
//         String sId = "$doubleValueOfId";
//         int lenth = sId.length;
//         int needToFill = 20 - lenth;
//         String fillString = "0" * needToFill;
//         sId = fillString + sId;
//         print(sId);
//         getFile(sId);
//       } catch (e) {
//         setState(() {
//           documentView = documentView =
//               const Center(child: Text("Cheak your ID. ID is not found"));
//         });
//       }
//     } else {
//       if (callOneTimeStream) getFile(id[0]);
//     }
//     for (int i = 0; i < id.length; i++) {
//       double doubleId = int.parse(id[i]) / 10000000000;
//       smallTutorialList.add(
//         Padding(
//           padding: const EdgeInsets.only(top: 2, bottom: 2),
//           child: TextButton(
//             onPressed: () {
//               setState(() {
//                 documentView = const Center(child: CircularProgressIndicator());
//               });
//               getFile(id[i]);
//             },
//             child: Text(
//               "${doubleId.toInt()}",
//               style: const TextStyle(
//                 fontSize: 16,
//                 fontWeight: FontWeight.bold,
//               ),
//             ),
//           ),
//         ),
//       );
//       fullTutorialList.add(
//         Padding(
//             padding: const EdgeInsets.only(top: 2, bottom: 2),
//             child: TextButton(
//               onPressed: () {
//                 setState(() {
//                   documentView =
//                       const Center(child: CircularProgressIndicator());
//                 });
//                 getFile(id[i]);
//               },
//               child: SingleChildScrollView(
//                 scrollDirection: Axis.horizontal,
//                 child: Row(
//                   mainAxisAlignment: MainAxisAlignment.start,
//                   crossAxisAlignment: CrossAxisAlignment.center,
//                   children: [
//                     Text(
//                       "${doubleId.toInt()}: ",
//                       style: const TextStyle(
//                         fontSize: 16,
//                         fontWeight: FontWeight.bold,
//                       ),
//                     ),
//                     Text(
//                       "${title[i]}",
//                     ),
//                   ],
//                 ),
//               ),
//             )),
//       );
//     }
//     setState(() {
//       allTutorial = Expanded(
//         child: ListView(
//           children: smallTutorialList,
//         ),
//       );
//     });
//   }

//   void getFile(String id) async {
//     setState(() {
//       callOneTimeStream = false;
//     });
//     final documentRef =
//         FirebaseFirestore.instance.collection(widget.path).doc(id);
//     final document = await documentRef.get();
//     if (document.exists) {
//       final allDoc = jsonDecode(document['doc']);
//       List like = document['like'];
//       final user = FirebaseAuth.instance.currentUser;
//       List comment = document['comment'];
//       final info = allDoc['info'];
//       String title = info['title'];
//       String shortDes = info['des'];
//       int len = int.parse(info['len']);
//       String email = info['email'];
//       String profilePhoto = info['profile'];
//       String name = info['name'];

//       List<Widget> listOfContent = [];
//       for (var i = 0; i < len - 1; i++) {
//         final singleDoc = allDoc['$i'];
//         String type = singleDoc['type'];

//         if (type == "quill") {
//           QuillController singleContentWidget = QuillController(
//             document: Document.fromJson(
//               jsonDecode(singleDoc['doc']),
//             ),
//             selection: const TextSelection.collapsed(offset: 0),
//           );
//           Widget myWiget = QuillEditor.basic(
//             controller: singleContentWidget,
//             readOnly: true,
//           );
//           listOfContent.add(myWiget);
//         }
//         if (type == "image") {
//           listOfContent.add(
//             Padding(
//               padding: const EdgeInsets.only(top: 10, bottom: 10),
//               child: GestureDetector(
//                 onTap: () async {
//                   if (!await launchUrl(
//                     Uri.parse(
//                       singleDoc['doc'],
//                     ),
//                   )) {
//                     throw Exception(
//                       'Could not launch ${singleDoc['doc']}',
//                     );
//                   }
//                 },
//                 child: SizedBox(
//                   height: MediaQuery.of(context).size.width * 0.60,
//                   width: MediaQuery.of(context).size.width,
//                   child: CachedNetworkImage(
//                     imageUrl: singleDoc['doc'],
//                     progressIndicatorBuilder:
//                         (context, url, downloadProgress) => Center(
//                       child: Center(
//                         child: CircularProgressIndicator(
//                             value: downloadProgress.progress),
//                       ),
//                     ),
//                     errorWidget: (context, url, error) => OutlinedButton(
//                       onPressed: () async {
//                         if (!await launchUrl(
//                           Uri.parse(
//                             singleDoc['doc'],
//                           ),
//                         )) {
//                           throw Exception(
//                             'Could not launch ${singleDoc['doc']}',
//                           );
//                         }
//                       },
//                       child: const Text(
//                         'For Image Click Here',
//                         style: TextStyle(
//                           color: Colors.blue,
//                           fontSize: 22,
//                         ),
//                         textAlign: TextAlign.center,
//                       ),
//                     ),
//                   ),
//                 ),
//               ),
//             ),
//           );
//         }
//         if (type == 'code') {
//           listOfContent.add(
//             Padding(
//               padding: const EdgeInsets.all(3),
//               child: Container(
//                 decoration: BoxDecoration(
//                   borderRadius: BorderRadius.circular(15),
//                   color: Colors.black,
//                 ),
//                 child: Column(
//                   mainAxisAlignment: MainAxisAlignment.start,
//                   children: [
//                     Row(
//                       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                       children: [
//                         const Row(
//                           mainAxisAlignment: MainAxisAlignment.center,
//                           children: [
//                             SizedBox(
//                               width: 10,
//                             ),
//                             CircleAvatar(
//                               radius: 4,
//                               backgroundColor: Colors.red,
//                             ),
//                             SizedBox(
//                               width: 5,
//                             ),
//                             CircleAvatar(
//                               radius: 4,
//                               backgroundColor: Colors.yellow,
//                             ),
//                             SizedBox(
//                               width: 5,
//                             ),
//                             CircleAvatar(
//                               radius: 4,
//                               backgroundColor: Colors.green,
//                             )
//                           ],
//                         ),
//                         Row(
//                           children: [
//                             Padding(
//                               padding: const EdgeInsets.only(right: 7),
//                               child: ElevatedButton(
//                                 style: ElevatedButton.styleFrom(
//                                   shape: elevatedStyle,
//                                   backgroundColor: Colors.blueGrey,
//                                 ),
//                                 onPressed: () {
//                                   Clipboard.setData(
//                                     ClipboardData(
//                                       text: singleDoc['doc'],
//                                     ),
//                                   );
//                                   Fluttertoast.showToast(
//                                     msg: "Copied Successfull!",
//                                     toastLength: Toast.LENGTH_LONG,
//                                     gravity: ToastGravity.BOTTOM,
//                                     backgroundColor: Colors.grey[700],
//                                     textColor: Colors.white,
//                                   );
//                                 },
//                                 child: const Row(
//                                   children: [
//                                     Text('Copy'),
//                                     Icon(Icons.copy),
//                                   ],
//                                 ),
//                               ),
//                             ),
//                             Padding(
//                               padding: const EdgeInsets.only(right: 7),
//                               child: ElevatedButton(
//                                 style: ElevatedButton.styleFrom(
//                                   shape: elevatedStyle,
//                                   backgroundColor: Colors.blueGrey,
//                                 ),
//                                 onPressed: () async {
//                                   Clipboard.setData(
//                                     ClipboardData(text: singleDoc['doc']),
//                                   );
//                                   Fluttertoast.showToast(
//                                     msg: "Copied Successfull!",
//                                     toastLength: Toast.LENGTH_LONG,
//                                     gravity: ToastGravity.BOTTOM,
//                                     backgroundColor: Colors.grey[700],
//                                     textColor: Colors.white,
//                                   );

//                                   if (widget.path == "python") {
//                                     if (!await launchUrl(
//                                       Uri.parse(
//                                         'https://replit.com/languages/python3',
//                                       ),
//                                     )) {
//                                       Fluttertoast.showToast(
//                                         msg: "Couldn't launch url!",
//                                         toastLength: Toast.LENGTH_LONG,
//                                         gravity: ToastGravity.BOTTOM,
//                                         backgroundColor: Colors.grey[700],
//                                         textColor: Colors.white,
//                                       );
//                                     }
//                                   } else if (widget.path == "java") {
//                                     if (!await launchUrl(
//                                       Uri.parse(
//                                         'https://replit.com/languages/java10',
//                                       ),
//                                     )) {
//                                       Fluttertoast.showToast(
//                                         msg: "Couldn't launch url!",
//                                         toastLength: Toast.LENGTH_LONG,
//                                         gravity: ToastGravity.BOTTOM,
//                                         backgroundColor: Colors.grey[700],
//                                         textColor: Colors.white,
//                                       );
//                                     }
//                                   } else if (widget.path == 'javascript') {
//                                     if (!await launchUrl(
//                                       Uri.parse(
//                                         'https://replit.com/languages/nodejs',
//                                       ),
//                                     )) {
//                                       Fluttertoast.showToast(
//                                         msg: "Couldn't launch url!",
//                                         toastLength: Toast.LENGTH_LONG,
//                                         gravity: ToastGravity.BOTTOM,
//                                         backgroundColor: Colors.grey[700],
//                                         textColor: Colors.white,
//                                       );
//                                     }
//                                   } else if (widget.path == 'c++') {
//                                     if (!await launchUrl(
//                                       Uri.parse(
//                                         'https://replit.com/languages/cpp',
//                                       ),
//                                     )) {
//                                       Fluttertoast.showToast(
//                                         msg: "Couldn't launch url!",
//                                         toastLength: Toast.LENGTH_LONG,
//                                         gravity: ToastGravity.BOTTOM,
//                                         backgroundColor: Colors.grey[700],
//                                         textColor: Colors.white,
//                                       );
//                                     }
//                                   } else if (widget.path == 'c#') {
//                                     if (!await launchUrl(
//                                       Uri.parse(
//                                         'https://replit.com/languages/csharp',
//                                       ),
//                                     )) {
//                                       Fluttertoast.showToast(
//                                         msg: "Couldn't launch url!",
//                                         toastLength: Toast.LENGTH_LONG,
//                                         gravity: ToastGravity.BOTTOM,
//                                         backgroundColor: Colors.grey[700],
//                                         textColor: Colors.white,
//                                       );
//                                     }
//                                   } else if (widget.path == 'c') {
//                                     if (!await launchUrl(
//                                       Uri.parse(
//                                         'https://replit.com/languages/c',
//                                       ),
//                                     )) {
//                                       Fluttertoast.showToast(
//                                         msg: "Couldn't launch url!",
//                                         toastLength: Toast.LENGTH_LONG,
//                                         gravity: ToastGravity.BOTTOM,
//                                         backgroundColor: Colors.grey[700],
//                                         textColor: Colors.white,
//                                       );
//                                     }
//                                   } else if (widget.path == 'dart') {
//                                     if (!await launchUrl(
//                                       Uri.parse(
//                                         'https://dartpad.dev/?',
//                                       ),
//                                     )) {
//                                       Fluttertoast.showToast(
//                                         msg: "Couldn't launch url!",
//                                         toastLength: Toast.LENGTH_LONG,
//                                         gravity: ToastGravity.BOTTOM,
//                                         backgroundColor: Colors.grey[700],
//                                         textColor: Colors.white,
//                                       );
//                                     }
//                                   } else if (widget.path == 'html' ||
//                                       widget.path == 'css') {
//                                     if (!await launchUrl(
//                                       Uri.parse(
//                                         'https://www.programiz.com/html/online-compiler/',
//                                       ),
//                                     )) {
//                                       Fluttertoast.showToast(
//                                         msg: "Couldn't launch url!",
//                                         toastLength: Toast.LENGTH_LONG,
//                                         gravity: ToastGravity.BOTTOM,
//                                         backgroundColor: Colors.grey[700],
//                                         textColor: Colors.white,
//                                       );
//                                     }
//                                   } else {
//                                     Fluttertoast.showToast(
//                                       msg: "We still working on it!",
//                                       toastLength: Toast.LENGTH_LONG,
//                                       gravity: ToastGravity.BOTTOM,
//                                       backgroundColor: Colors.grey[700],
//                                       textColor: Colors.white,
//                                     );
//                                   }
//                                 },
//                                 child: const Icon(Icons.play_arrow),
//                               ),
//                             ),
//                           ],
//                         )
//                       ],
//                     ),
//                     const SizedBox(
//                       height: 2,
//                     ),
//                     SingleChildScrollView(
//                       physics: const BouncingScrollPhysics(),
//                       scrollDirection: Axis.horizontal,
//                       child: Padding(
//                         padding: const EdgeInsets.all(5),
//                         child: SelectableText(
//                           singleDoc['doc'],
//                           textAlign: TextAlign.start,
//                           style: const TextStyle(
//                             fontFamily: 'monospace',
//                             fontSize: 16.0,
//                             color: Colors.white,
//                           ),
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//           );
//         }
//       }
//       Widget profile = Padding(
//         padding: const EdgeInsets.only(top: 8, bottom: 8),
//         child: Column(
//           children: [
//             GestureDetector(
//               onTap: () => Navigator.push(
//                   context,
//                   MaterialPageRoute(
//                     builder: (context) => Profile(email: email),
//                   )),
//               child: Container(
//                 decoration: BoxDecoration(
//                   borderRadius: BorderRadius.circular(100),
//                   color: const Color.fromARGB(84, 153, 153, 153),
//                 ),
//                 height: 50,
//                 width: double.infinity,
//                 child: Row(
//                   mainAxisAlignment: MainAxisAlignment.start,
//                   crossAxisAlignment: CrossAxisAlignment.center,
//                   children: [
//                     ClipRRect(
//                       borderRadius: BorderRadius.circular(100),
//                       child: SizedBox(
//                         height: 50,
//                         width: 50,
//                         child: CachedNetworkImage(
//                           imageUrl: profilePhoto,
//                           fit: BoxFit.cover,
//                           progressIndicatorBuilder:
//                               (context, url, downloadProgress) => Center(
//                             child: Center(
//                               child: CircularProgressIndicator(
//                                   value: downloadProgress.progress),
//                             ),
//                           ),
//                           errorWidget: (context, url, error) =>
//                               const Icon(Icons.image_outlined),
//                         ),
//                       ),
//                     ),
//                     const SizedBox(
//                       width: 20,
//                     ),
//                     Column(
//                       mainAxisAlignment: MainAxisAlignment.center,
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         SelectableText(
//                           name,
//                           style: const TextStyle(fontSize: 20),
//                         ),
//                         SelectableText(email),
//                       ],
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//             const SizedBox(
//               height: 5,
//             ),
//             Container(
//               width: MediaQuery.of(context).size.width * 98,
//               decoration: BoxDecoration(
//                 borderRadius: BorderRadius.circular(20),
//                 color: const Color.fromARGB(81, 168, 168, 168),
//               ),
//               child: Padding(
//                 padding: const EdgeInsets.all(10),
//                 child: Column(
//                   mainAxisAlignment: MainAxisAlignment.start,
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     SelectableText(
//                       "Rank : ${double.parse(document.id) ~/ 10000000000}",
//                       style: const TextStyle(
//                           fontSize: 16, fontWeight: FontWeight.bold),
//                     ),
//                     const SizedBox(
//                       height: 5,
//                     ),
//                     SingleChildScrollView(
//                       scrollDirection: Axis.horizontal,
//                       child: Row(
//                         mainAxisAlignment: MainAxisAlignment.start,
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           const SelectableText(
//                             "Title : ",
//                             style: TextStyle(
//                                 fontSize: 16, fontWeight: FontWeight.bold),
//                           ),
//                           SizedBox(
//                             width: MediaQuery.of(context).size.width - 70,
//                             child: SelectableText(title),
//                           ),
//                         ],
//                       ),
//                     ),
//                     const SizedBox(
//                       height: 5,
//                     ),
//                     SingleChildScrollView(
//                       scrollDirection: Axis.horizontal,
//                       child: Row(
//                         mainAxisAlignment: MainAxisAlignment.start,
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           const SelectableText(
//                             "Description : ",
//                             style: TextStyle(
//                                 fontSize: 16, fontWeight: FontWeight.bold),
//                           ),
//                           SizedBox(
//                             width: MediaQuery.of(context).size.width - 120,
//                             child: SelectableText(shortDes),
//                           ),
//                         ],
//                       ),
//                     )
//                   ],
//                 ),
//               ),
//             ),
//             const SizedBox(
//               height: 10,
//             ),
//             Padding(
//               padding: const EdgeInsets.all(1.5),
//               child: Container(
//                 decoration: BoxDecoration(
//                   color: const Color.fromARGB(82, 150, 150, 150),
//                   borderRadius: BorderRadius.circular(20),
//                 ),
//                 child: Padding(
//                   padding: const EdgeInsets.only(
//                       bottom: 10, top: 10, left: 1, right: 1),
//                   child: Column(
//                     mainAxisAlignment: MainAxisAlignment.start,
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: listOfContent,
//                   ),
//                 ),
//               ),
//             ),
//             const SizedBox(
//               height: 15,
//             ),
//             Row(
//               mainAxisAlignment: MainAxisAlignment.spaceAround,
//               crossAxisAlignment: CrossAxisAlignment.center,
//               children: [
//                 Row(
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   crossAxisAlignment: CrossAxisAlignment.center,
//                   children: [
//                     IconButton(
//                       onPressed: () async {
//                         final user = FirebaseAuth.instance.currentUser;

//                         if (user != null) {
//                           final temDocRef = FirebaseFirestore.instance
//                               .collection(widget.path)
//                               .doc(document.id);
//                           final temUserRef = FirebaseFirestore.instance
//                               .collection('user')
//                               .doc(email);

//                           final likkeNumberFile = await temUserRef.get();
//                           int likeNumber = likkeNumberFile['like'];

//                           if (like.contains(user.email)) {
//                             likeNumber--;
//                             await temUserRef.update({"like": likeNumber});
//                             like.remove(user.email);
//                           } else {
//                             likeNumber++;
//                             await temUserRef.update({"like": likeNumber});
//                             like.add(user.email);
//                           }

//                           temDocRef.update({"like": like});
//                           getFile(id);
//                         } else {
//                           await Navigator.push(
//                             context,
//                             MaterialPageRoute(
//                               builder: (context) => const Login(),
//                             ),
//                           );
//                           getFile(id);
//                         }
//                       },
//                       icon: Icon(
//                         Icons.thumb_up_alt,
//                         size: 24,
//                         color: (user != null && like.contains(user.email))
//                             ? Colors.blue
//                             : Colors.black,
//                       ),
//                     ),
//                     const SizedBox(
//                       width: 10,
//                     ),
//                     SelectableText("${like.length}"),
//                     const SizedBox(
//                       width: 40,
//                     ),
//                     IconButton(
//                       onPressed: () {
//                         final user = FirebaseAuth.instance.currentUser;
//                         if (user != null) {
//                           Navigator.push(
//                             context,
//                             MaterialPageRoute(
//                               builder: (context) => AllComment(
//                                 comment: comment,
//                                 id: document.id,
//                                 path: widget.path,
//                               ),
//                             ),
//                           );
//                         } else {
//                           Navigator.push(
//                             context,
//                             MaterialPageRoute(
//                               builder: (context) => const Login(),
//                             ),
//                           );
//                         }
//                       },
//                       icon: const Icon(Icons.comment),
//                     ),
//                     const SizedBox(
//                       width: 10,
//                     ),
//                     Text(
//                       "${comment.length}",
//                     ),
//                   ],
//                 ),
//                 Row(
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   crossAxisAlignment: CrossAxisAlignment.center,
//                   children: [
//                     ElevatedButton(
//                       onPressed: () async {
//                         final user = FirebaseAuth.instance.currentUser;
//                         if (user != null) {
//                           String useremail = user.email!;
//                           if (useremail == email) {
//                             Navigator.push(
//                               context,
//                               MaterialPageRoute(
//                                 builder: (context) =>
//                                     ModifyPost(path: widget.path, id: id),
//                               ),
//                             );
//                           } else {
//                             final adminRef = await FirebaseFirestore.instance
//                                 .collection('admin')
//                                 .doc('admin')
//                                 .get();
//                             List adminList = adminRef['admin'];
//                             if (adminList.contains(useremail)) {
//                               Navigator.push(
//                                 context,
//                                 MaterialPageRoute(
//                                   builder: (context) =>
//                                       ModifyPost(path: widget.path, id: id),
//                                 ),
//                               );
//                             } else {
//                               showModalBottomSheet(
//                                 context: context,
//                                 builder: (context) => const Center(
//                                   child: Text(
//                                     'You are not an Admin\nYou are not the owner/creator of this post.',
//                                     textAlign: TextAlign.center,
//                                   ),
//                                 ),
//                               );
//                             }
//                           }
//                         } else {
//                           Navigator.push(
//                             context,
//                             MaterialPageRoute(
//                               builder: (context) => const Login(),
//                             ),
//                           );
//                         }
//                       },
//                       child: const Text('Modify'),
//                     ),
//                     const SizedBox(
//                       width: 15,
//                     ),
//                   ],
//                 ),
//               ],
//             ),
//           ],
//         ),
//       );
//       setState(() {
//         documentView = profile;
//       });
//     } else {
//       setState(() {
//         documentView = const Center(
//           child: Text('No data'),
//         );
//       });
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     print([StramBuilderArgumentPass.language, StramBuilderArgumentPass.docId]);
//     if (canGotDataStream == true) getListOfTutorial();

//     return Scaffold(
//       body: Row(
//         mainAxisAlignment: MainAxisAlignment.start,
//         crossAxisAlignment: CrossAxisAlignment.center,
//         children: [
//           Expanded(
//             flex: flexNumber,
//             child: Container(
//               decoration: BoxDecoration(
//                 color: const Color.fromARGB(88, 168, 168, 168),
//                 borderRadius: BorderRadius.circular(15),
//               ),
//               child: Column(
//                 children: [
//                   const SizedBox(
//                     height: 10,
//                   ),
//                   SizedBox(
//                     height: 30,
//                     width: 30,
//                     child: FloatingActionButton(
//                       onPressed: () {
//                         if (flexNumber == 1) {
//                           setState(() {
//                             flexNumber = 4;
//                             iconButton = const Icon(
//                               Icons.arrow_back_ios,
//                               size: 12,
//                             );
//                             allTutorial = Expanded(
//                               child: ListView(
//                                 children: fullTutorialList,
//                               ),
//                             );
//                           });
//                         } else {
//                           setState(() {
//                             flexNumber = 1;
//                             iconButton = const Icon(
//                               Icons.arrow_forward_ios,
//                               size: 12,
//                             );
//                             allTutorial = Expanded(
//                               child: ListView(
//                                 children: smallTutorialList,
//                               ),
//                             );
//                           });
//                         }
//                       },
//                       child: iconButton,
//                     ),
//                   ),
//                   const SizedBox(
//                     height: 10,
//                   ),
//                   allTutorial
//                 ],
//               ),
//             ),
//           ),
//           Expanded(
//             flex: 10,
//             child: SingleChildScrollView(
//               child: documentView,
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

// class StramBuilderArgumentPass {
//   static String language = "Python";
//   static String docId = "0";
// }
