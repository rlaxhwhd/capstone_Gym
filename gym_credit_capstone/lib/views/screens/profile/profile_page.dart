import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../view_models/profile_view_model.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({Key? key}) : super(key: key);

  void _showLogoutDialog(BuildContext context, ProfileViewModel viewModel) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("로그아웃"),
        content: const Text("정말 로그아웃 하시겠습니까?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("취소"),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await viewModel.logout(context);
            },
            child: const Text("확인"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<ProfileViewModel>(
      create: (_) => ProfileViewModel()..fetchUserData(),
      child: Consumer<ProfileViewModel>(
        builder: (context, viewModel, child) {
          final nickname = viewModel.user?.nickname ?? '';
          final email = viewModel.user?.email ?? '';
          return Scaffold(
            body: SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '내 정보',
                      style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 24),
                    _buildItem('닉네임', onTap: () => Navigator.pushNamed(context, '/changeNickname')),
                    _buildItem('이름', value: nickname, showArrow: false),
                    _buildItem(
                      '이메일',
                      value: email,
                      onTap: () => Navigator.pushNamed(context, '/changeEmail'),
                      textColor: Colors.grey,
                    ),
                    _buildItem('비밀번호 변경', onTap: () {}),
                    _buildItem('휴대폰 번호 변경', onTap: () {}),
                    _buildItem('이용 내역', onTap: () {}),
                    _buildItem('이용약관 및 정책', onTap: () {}),
                    _buildItem(
                      '버전 정보',
                      value: viewModel.appVersion,
                      showArrow: false,
                      textColor: Colors.grey,
                    ),
                    const SizedBox(height: 32),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        TextButton(
                          onPressed: () => _showLogoutDialog(context, viewModel),
                          child: const Text('로그아웃', style: TextStyle(fontSize: 16)),
                        ),
                        const Text('|', style: TextStyle(fontSize: 16)),
                        TextButton(
                          onPressed: () => viewModel.goToDeleteAccount(context),
                          child: const Text('회원탈퇴', style: TextStyle(fontSize: 16)),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildItem(
      String title, {
        String? value,
        VoidCallback? onTap,
        bool showArrow = true,
        Color textColor = Colors.black,
      }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 18),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            Row(
              children: [
                if (value != null) Text(value, style: TextStyle(fontSize: 15, color: textColor)),
                if (showArrow && onTap != null) const Icon(Icons.chevron_right, color: Colors.grey),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
