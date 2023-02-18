import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../widget/stram_builder.dart';

class CSharp extends StatefulWidget {
  const CSharp({super.key});

  @override
  State<CSharp> createState() => _CSharpState();
}

class _CSharpState extends State<CSharp> {
  @override
  Widget build(BuildContext context) {
    return const MyStramBuilder(
      language: "c#",
    );
  }
}
