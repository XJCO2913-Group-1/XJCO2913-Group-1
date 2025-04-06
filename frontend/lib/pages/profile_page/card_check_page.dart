import 'package:easy_scooter/components/page_title.dart';
import 'package:flutter/material.dart';

class CardCheckPage extends StatefulWidget {
  const CardCheckPage({Key? key}) : super(key: key);
  @override
  State<CardCheckPage> createState() => _CardCheckPageState();
}

class _CardCheckPageState extends State<CardCheckPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const PageTitle(title: "Card Check")),
    );
  }
}
