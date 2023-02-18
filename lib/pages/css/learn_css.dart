import 'package:flutter/material.dart';
import 'package:tpiprogrammingclub/widget/stram_builder.dart';

class CSS extends StatefulWidget {
  const CSS({super.key});

  @override
  State<CSS> createState() => _CSSState();
}

class _CSSState extends State<CSS> {
  @override
  Widget build(BuildContext context) {
    return const MyStramBuilder(language: "css");
  }
}
