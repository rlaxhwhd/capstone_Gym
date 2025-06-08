import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../view_models/profile_view_model.dart';
import '../../../routes.dart';
import 'package:gym_credit_capstone/views/common_widgets/terms_dialog.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({Key? key}) : super(key: key);

  void _showLogoutDialog(BuildContext context, ProfileViewModel viewModel) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 32),
                child: Text(
                  '로그아웃 하시겠습니까?',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
              SizedBox(
                height: 50,
                child: Row(
                  children: [
                    Expanded(
                      child: InkWell(
                        borderRadius: const BorderRadius.only(
                          bottomLeft: Radius.circular(16),
                        ),
                        onTap: () => Navigator.of(context).pop(),
                        child: const Center(
                          child: Text(
                            '취소',
                            style: TextStyle(fontSize: 16, color: Colors.grey),
                          ),
                        ),
                      ),
                    ),
                    Container(width: 1, color: Colors.black12),
                    Expanded(
                      child: InkWell(
                        borderRadius: const BorderRadius.only(
                          bottomRight: Radius.circular(16),
                        ),
                        onTap: () async {
                          Navigator.of(context).pop();
                          await viewModel.logout(context);
                        },
                        child: const Center(
                          child: Text(
                            '확인',
                            style: TextStyle(
                              fontSize: 16,
                              color: Color(0xFF007AFF),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showEmailChangedToast(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.grey.withOpacity(0.6),
      builder: (context) {
        Future.delayed(const Duration(seconds: 2), () {
          Navigator.of(context).pop();
        });

        return Center(
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
            decoration: BoxDecoration(
              color: const Color(0xFF2B2B2B),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Text(
              '이메일이 변경되었습니다.',
              style: TextStyle(color: Colors.white, fontSize: 14),
            ),
          ),
        );
      },
    );
  }

  void _showPasswordChangedToast(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.grey.withOpacity(0.6),
      builder: (context) {
        Future.delayed(const Duration(seconds: 2), () {
          Navigator.of(context).pop();
        });

        return Center(
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
            decoration: BoxDecoration(
              color: const Color(0xFF2B2B2B),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Text(
              '비밀번호가 변경되었습니다.',
              style: TextStyle(color: Colors.white, fontSize: 14),
            ),
          ),
        );
      },
    );
  }

  void _showAgreementDialog(
      BuildContext context,
      String title,
      ) {
    showDialog(
      context: context,
      builder:
          (_) => TermsDialog(
        dialogTitle: title // 동의 처리 함수 전달
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<ProfileViewModel>(
      create: (_) => ProfileViewModel()..fetchUserData(),
      child: Consumer<ProfileViewModel>(
        builder: (context, viewModel, child) {
          final nickname = viewModel.user?.nickName ?? '';
          final email = viewModel.user?.email ?? '';
          return Scaffold(
            backgroundColor: Colors.white,
            body: SafeArea(
              child: Column(
                children: [
                  const SizedBox(height: 44),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 24),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        '내 정보',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  _buildItem(
                    '닉네임',
                    value: nickname,
                    onTap: () async {
                      final shouldRefresh =
                      await Navigator.pushNamed(context, '/change_nickname');
                      if (shouldRefresh == true) {
                        viewModel.fetchUserData();
                      }
                    },
                  ),
                  _buildItem(
                    '이름',
                    value: nickname,
                    showArrow: false,
                  ),
                  _buildItem(
                    '비밀번호 변경',
                    onTap: () async {
                      final shouldRefresh =
                      await Navigator.pushNamed(context, AppRoutes.changePassword);
                      if (shouldRefresh == true) {
                        _showPasswordChangedToast(context);
                      }
                    },
                  ),
                  _buildItem(
                    '휴대폰 번호 변경',
                    onTap: () async {
                      final shouldRefresh =
                      await Navigator.pushNamed(context, AppRoutes.changePhone);
                      if (shouldRefresh == true) {
                        viewModel.fetchUserData();
                      }
                    },
                  ),
                  _buildItem('이용 내역', onTap: () {
                    Navigator.pushNamed(context, AppRoutes.usageHistory);
                  }),
                  _buildItem('이용약관 및 정책', onTap: () {
                    _showAgreementDialog(context, '서비스 이용 약관 동의');
                  }),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 18),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          '버전 정보',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        Text(
                          viewModel.appVersion,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF999999),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 30),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        TextButton(
                          onPressed: () => _showLogoutDialog(context, viewModel),
                          child: const Text(
                            '로그아웃',
                            style: TextStyle(fontSize: 16, color: Colors.grey),
                          ),
                        ),
                        const Text(' | ', style: TextStyle(color: Colors.grey)),
                        TextButton(
                          onPressed: () => viewModel.goToDeleteAccount(context),
                          child: const Text(
                            '회원탈퇴',
                            style: TextStyle(fontSize: 16, color: Colors.grey),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
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
    final isNameItem = title == '이름';

    return InkWell(
      onTap: isNameItem ? null : onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 18),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Row(
              children: [
                if (value != null)
                  Padding(
                    padding: const EdgeInsets.only(right: 4),
                    child: Text(
                      value,
                      style: TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                  ),
                if (!isNameItem && showArrow)
                  const Icon(Icons.chevron_right, color: Colors.grey),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
