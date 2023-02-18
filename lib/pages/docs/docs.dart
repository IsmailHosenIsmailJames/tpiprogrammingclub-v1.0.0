import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../widget/stram_builder.dart';

class Docs extends StatefulWidget {
  const Docs({super.key});

  @override
  State<Docs> createState() => _DocsState();
}

class _DocsState extends State<Docs> {
  @override
  Widget build(BuildContext context) {
    return const MyStramBuilder(
      language: "doc",
    );
  }
}
