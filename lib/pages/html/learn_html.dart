import 'package:flutter/material.dart';
import 'package:tpiprogrammingclub/widget/stram_builder.dart';

class HTML extends StatefulWidget {
  const HTML({super.key});

  @override
  State<HTML> createState() => _HTMLState();
}

class _HTMLState extends State<HTML> {
  @override
  Widget build(BuildContext context) {
    return const MyStramBuilder(language: "html");
  }
}
