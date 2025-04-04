import 'package:flutter/material.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('프로필 화면'),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // DeleteAccountScreen으로 이동
                Navigator.pushNamed(context, '/deleteAccount');
              },
              child: const Text('계정 탈퇴'),
            ),
          ],
        ),
      ),
    );
  }
}