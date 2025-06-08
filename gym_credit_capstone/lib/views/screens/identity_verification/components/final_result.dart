import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:gym_credit_capstone/view_models/identity_verification_view_model.dart';
import 'package:gym_credit_capstone/style/custom_colors.dart';
import 'dart:math';

class FinalResult extends StatefulWidget {
  final IdentityVerificationViewModel viewModel;

  const FinalResult({required this.viewModel, super.key});

  @override
  State<FinalResult> createState() => _FinalResultState();
}

class _FinalResultState extends State<FinalResult>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  Animation<double>? _flipAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: const Duration(milliseconds: 700),
      vsync: this,
    );
    _flipAnimation = Tween<double>(
      begin: 0.0,
      end: 2 * pi,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _controller.forward();
    });
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
                    widget.viewModel.isVerified
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
              widget.viewModel.isVerified ? '인증완료' : '인증실패',
              style: TextStyle(
                fontSize: 30,
                fontFamily: 'NanumSquare',
                fontWeight: FontWeight.w600,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              widget.viewModel.isVerified
                  ? '이제 회원가입 폼에서 회원가입을 해주세요.'
                  : '이전 화면에서 다시 인증을 해주세요.',
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
