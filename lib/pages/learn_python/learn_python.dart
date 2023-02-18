import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../widget/stram_builder.dart';

class Python extends StatefulWidget {
  const Python({super.key});

  @override
  State<Python> createState() => _PythonState();
}

class _PythonState extends State<Python> {
  @override
  Widget build(BuildContext context) {
    return const MyStramBuilder(
      language: "python",
    );
  }
}
