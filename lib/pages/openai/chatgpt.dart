import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:openai_client/openai_client.dart';
// ignore: implementation_imports
import 'package:openai_client/src/model/openai_chat/chat_message.dart';
import 'package:tpiprogrammingclub/pages/home/home_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ChatGPT extends StatefulWidget {
  const ChatGPT({super.key});

  @override
  State<ChatGPT> createState() => _ChatGPTState();
}

bool buttonclickable = true;

class _ChatGPTState extends State<ChatGPT> {
  final textcontroller = TextEditingController();

  Widget normalWidgetMaker(String text) {
    return SelectableText(
      text,
      textAlign: TextAlign.start,
      style: const TextStyle(
        fontSize: 16,
      ),
    );
  }

  Widget programWidgetMaker(String program) {
    return Padding(
      padding: const EdgeInsets.all(3),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
          color: Colors.black,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    SizedBox(
                      width: 10,
                    ),
                    CircleAvatar(
                      radius: 4,
                      backgroundColor: Colors.red,
                    ),
                    SizedBox(
                      width: 5,
                    ),
                    CircleAvatar(
                      radius: 4,
                      backgroundColor: Colors.yellow,
                    ),
                    SizedBox(
                      width: 5,
                    ),
                    CircleAvatar(
                      radius: 4,
                      backgroundColor: Colors.green,
                    )
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.only(right: 7),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      shape: elevatedStyle,
                      backgroundColor: Colors.blueGrey,
                    ),
                    onPressed: () {
                      Clipboard.setData(
                        ClipboardData(
                          text: program,
                        ),
                      );
                      Fluttertoast.showToast(
                        msg: "Copied Successfull!",
                        toastLength: Toast.LENGTH_LONG,
                        gravity: ToastGravity.BOTTOM,
                        backgroundColor: Colors.grey[700],
                        textColor: Colors.white,
                      );
                    },
                    child: Row(
                      children: const [
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
              physics: const BouncingScrollPhysics(),
              scrollDirection: Axis.horizontal,
              child: Padding(
                padding: const EdgeInsets.all(5),
                child: SelectableText(
                  program,
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
    );
  }

  Widget replyMaker(String msg) {
    if (msg.contains("```")) {
      List<Widget> allMsg = [];
      while (msg.contains("```")) {
        int index = msg.indexOf("```");
        String normalMsg = msg.substring(0, index);
        allMsg.add(normalWidgetMaker(normalMsg));
        msg = msg.substring(index + 3, msg.length);
        int newindex = msg.indexOf("```");
        if (index != -1) {
          String program = msg.substring(0, newindex);
          allMsg.add(programWidgetMaker(program));
          msg = msg.substring(newindex + 3, msg.length);
        }

        break;
      }
      if (msg.isNotEmpty) {
        allMsg.add(normalWidgetMaker(msg));
      }
      return Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: allMsg,
      );
    } else {}
    return SelectableText(
      msg,
      textAlign: TextAlign.start,
      style: const TextStyle(
        fontSize: 16,
      ),
    );
  }

  void getAnsChatGPT() async {
    setState(() {
      buttonclickable = false;
    });
    final ref = FirebaseFirestore.instance.collection("chatGPT").doc(chatID!);
    final docmsg = await ref.get();
    List allMsg = docmsg['msg'];
    allMsg.add({"msg": textcontroller.text, "who": "user"});
    await ref.update({"msg": allMsg});

    const conf = OpenAIConfiguration(
      apiKey: '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',
      organizationId: 'org-xweIePRGTPuKL9aNRzE6MfqQ', // Optional
    );

    final client = OpenAIClient(configuration: conf);

    try {
      final chat = await client.chat.create(
        model: 'gpt-3.5-turbo',
        messages: [
          ChatMessage(
            role: 'user',
            content: textcontroller.text,
          )
        ],
      ).data;

      Map<String, dynamic> mapData = chat.toMap();
      List choices = mapData["choices"];
      Map<String, dynamic> firstMessage = choices[0];
      String msg = "${firstMessage["message"]["content"]}";

      allMsg.add({"msg": msg, "who": "bot"});
      await ref.update({"msg": allMsg});

      setState(() {
        buttonclickable = true;
        textcontroller.clear();
      });
    } catch (e) {
      Fluttertoast.showToast(
        msg: "Something went wrong",
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.grey[700],
        textColor: Colors.white,
      );
      setState(() {
        buttonclickable = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chat GPT'),
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder(
              stream: FirebaseFirestore.instance
                  .collection("chatGPT")
                  .doc(chatID!)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (!snapshot.hasData) {
                  return const Center(child: Text("No data"));
                }

                final jsonChat = snapshot.data!.data();
                if (jsonChat == null) {
                  return const Center(
                    child: Text("Something went wrong"),
                  );
                }
                List listOfMessage = jsonChat['msg'];
                listOfMessage = listOfMessage.reversed.toList();

                return ListView.builder(
                  physics: const BouncingScrollPhysics(),
                  itemCount: listOfMessage.length,
                  reverse: true,
                  itemBuilder: (context, index) {
                    String who = listOfMessage[index]["who"];
                    String msg = listOfMessage[index]["msg"];
                    if (who == "bot") {
                      return Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(3),
                            child: Container(
                              width: MediaQuery.of(context).size.width * 0.90,
                              decoration: const BoxDecoration(
                                borderRadius: BorderRadius.only(
                                  topLeft: Radius.circular(20),
                                  topRight: Radius.circular(20),
                                  bottomRight: Radius.circular(20),
                                ),
                                color: Colors.black26,
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(6),
                                child: replyMaker(msg),
                              ),
                            ),
                          ),
                          SizedBox(
                            width: MediaQuery.of(context).size.width * 0.07,
                          )
                        ],
                      );
                    } else {
                      return Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          SizedBox(
                            width: MediaQuery.of(context).size.width * 0.07,
                          ),
                          Padding(
                            padding: const EdgeInsets.all(3),
                            child: Container(
                              width: MediaQuery.of(context).size.width * 0.90,
                              decoration: const BoxDecoration(
                                borderRadius: BorderRadius.only(
                                  topLeft: Radius.circular(20),
                                  topRight: Radius.circular(20),
                                  bottomLeft: Radius.circular(20),
                                ),
                                color: Colors.greenAccent,
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(6),
                                child: SelectableText(
                                  msg,
                                  textAlign: TextAlign.end,
                                  style: const TextStyle(
                                      fontSize: 16, color: Colors.black),
                                ),
                              ),
                            ),
                          ),
                        ],
                      );
                    }
                  },
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 5),
            child: Container(
              decoration: const BoxDecoration(
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(15),
                  topRight: Radius.circular(15),
                ),
                color: Colors.black26,
              ),
              child: Padding(
                padding: const EdgeInsets.all(5),
                child: Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: textcontroller,
                        autocorrect: true,
                        minLines: 1,
                        maxLines: 1000,
                        decoration: InputDecoration(
                          hintText: "Type here...",
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                        ),
                      ),
                    ),
                    buttonclickable
                        ? IconButton(
                            onPressed: () {
                              if (textcontroller.text.trim().isNotEmpty) {
                                getAnsChatGPT();
                              }
                            },
                            icon: const Icon(Icons.send),
                          )
                        : const Padding(
                            padding: EdgeInsets.all(3),
                            child: CircularProgressIndicator(),
                          ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
