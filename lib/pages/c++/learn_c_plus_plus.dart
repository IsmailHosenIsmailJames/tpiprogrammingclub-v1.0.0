import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../widget/stram_builder.dart';

class CPlusPlus extends StatefulWidget {
  const CPlusPlus({super.key});

  @override
  State<CPlusPlus> createState() => _CPlusPlusState();
}

class _CPlusPlusState extends State<CPlusPlus> {
  @override
  Widget build(BuildContext context) {
    return const MyStramBuilder(
      language: "c++",
    );
  }
}
