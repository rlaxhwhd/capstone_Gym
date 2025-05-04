import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../view_models/profile_view_model.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ProfileViewModel(),
      child: const _ProfilePageBody(),
    );
  }
}

class _ProfilePageBody extends StatelessWidget {
  const _ProfilePageBody({super.key});

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<ProfileViewModel>();
    final Color primaryColor = const Color(0xFF69B6F9);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          '마이페이지',
          style: TextStyle(color: Colors.black),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: primaryColor),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: viewModel.isLoading
          ? const Center(child: CircularProgressIndicator())
          : viewModel.userModel == null
          ? const Center(child: Text('유저 정보를 불러올 수 없습니다.'))
          : _buildProfileContent(viewModel, primaryColor),
    );
  }

  Widget _buildProfileContent(ProfileViewModel viewModel, Color primaryColor) {
    final user = viewModel.userModel!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 20),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              CircleAvatar(
                radius: 35,
                backgroundColor: primaryColor.withOpacity(0.2),
                child: Icon(Icons.person, size: 40, color: primaryColor),
              ),
              const SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    user.nickname,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    user.phoneNum,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        const Divider(thickness: 1),
        _buildMenuItem(Icons.person, '나의 정보', () {}),
        _buildMenuItem(Icons.history, '이용내역', () {}),
        _buildMenuItem(Icons.credit_card, '결제수단', () {}),
        _buildMenuItem(Icons.settings, '설정', () {}),
        const Divider(thickness: 1),
      ],
    );
  }

  Widget _buildMenuItem(IconData icon, String title, VoidCallback onTap) {
    final Color primaryColor = const Color(0xFF69B6F9);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: ListTile(
        leading: Icon(icon, color: Colors.black),
        title: Text(
          title,
          style: const TextStyle(fontSize: 16, color: Colors.black),
        ),
        trailing: Icon(Icons.arrow_forward_ios, size: 16, color: primaryColor),
        onTap: onTap,
      ),
    );
  }
}
