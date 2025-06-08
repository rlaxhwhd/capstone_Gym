import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:gym_credit_capstone/view_models/sign_up_view_model.dart';
import 'package:gym_credit_capstone/style/custom_colors.dart';
import 'dart:math';

class FinalResultStep extends StatefulWidget {
  final SignUpViewModel viewModel;

  const FinalResultStep({required this.viewModel, super.key});

  @override
  State<FinalResultStep> createState() => _FinalResultState();
}

class _FinalResultState extends State<FinalResultStep>
    with SingleTickerProviderStateMixin {
  //bool _isRegistered = widget.viewModel.isRegistered;
  late AnimationController _controller;
  Animation<double>? _flipAnimation; // null 허용으로 변경

  @override
  void initState() {
    super.initState();

    // 애니메이션 세팅
    _controller = AnimationController(
      duration: const Duration(milliseconds: 700),
      vsync: this,
    );
    _flipAnimation = Tween<double>(
      begin: 0.0,
      end: 2 * pi,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

    // 페이지가 먼저 렌더링된 뒤에 ViewModel.verify() 호출
    WidgetsBinding.instance.addPostFrameCallback((_) async{
      _controller.forward();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          children: [
            const SizedBox(height: 100),
            if (_flipAnimation != null)
              AnimatedBuilder(
                animation: _flipAnimation!,
                builder: (context, child) {
                  return Transform(
                    transform: Matrix4.identity()
                      ..setEntry(3, 2, 0.001)
                      ..rotateY(_flipAnimation!.value),
                    alignment: Alignment.center,
                    child: child,
                  );
                },
                child: SvgPicture.asset(
                  'assets/images/verified.svg',
                  colorFilter: ColorFilter.mode(
                    widget.viewModel.isRegistered
                        ? CustomColors.primaryColor
                        : Colors.grey,
                    BlendMode.srcIn,
                  ),
                  fit: BoxFit.contain,
                  width: 200,
                ),
              ),
            const SizedBox(height: 30),
            Text(
              widget.viewModel.isRegistered ? '회원가입 완료' : '회원가입 실패',
              style: TextStyle(
                fontSize: 30,
                fontFamily: 'NanumSquare',
                fontWeight: FontWeight.w600,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              widget.viewModel.isRegistered
                  ? '환영합니다!\n이제 서비스를 이용하실 수 있습니다.'
                  : '이전 화면에서 다시 가입을 해주세요.',
              style: TextStyle(
                fontSize: 16,
                fontFamily: 'NanumSquare',
                fontWeight: FontWeight.w500,
                color: Colors.black,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
