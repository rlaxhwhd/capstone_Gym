import 'package:flutter/material.dart';

class QrcodePage extends StatelessWidget {
  const QrcodePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('QR Code')),
      body: const Center(child: Text('QR 코드 화면')),
    );
  }
}
