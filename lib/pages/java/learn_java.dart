import 'package:flutter/material.dart';
import 'package:tpiprogrammingclub/widget/stram_builder.dart';

class Java extends StatefulWidget {
  const Java({super.key});

  @override
  State<Java> createState() => _JavaState();
}

class _JavaState extends State<Java> {
  @override
  Widget build(BuildContext context) {
    return const MyStramBuilder(language: "java");
  }
}
