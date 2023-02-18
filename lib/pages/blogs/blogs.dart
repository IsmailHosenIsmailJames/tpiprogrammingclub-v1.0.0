import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../widget/stram_builder.dart';

class Blogs extends StatefulWidget {
  const Blogs({super.key});

  @override
  State<Blogs> createState() => _BlogsState();
}

class _BlogsState extends State<Blogs> {
  @override
  Widget build(BuildContext context) {
    return const MyStramBuilder(
      language: "blog",
    );
  }
}
