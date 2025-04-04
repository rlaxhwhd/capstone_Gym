import 'package:flutter/material.dart';

class MeetupPage extends StatelessWidget {
  const MeetupPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('모임')),
      body: const Center(child: Text('모임 화면')),
    );
  }
}
