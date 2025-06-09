// lib/views/screens/login/components/UserInfoStep.dart
import 'package:flutter/material.dart';
import 'package:gym_credit_capstone/view_models/sign_up_view_model.dart';
import 'package:gym_credit_capstone/style/custom_colors.dart';
import 'package:gym_credit_capstone/views/common_widgets/CustomInputLine.dart';
import 'package:gym_credit_capstone/views/common_widgets/input_section.dart';
import 'package:gym_credit_capstone/views/common_widgets/searchPostcodePage.dart';
import 'package:gym_credit_capstone/views/common_widgets/custom_wheel_date_picker_field.dart';
import 'package:provider/provider.dart';

class UserInfoStep extends StatefulWidget {
  final SignUpViewModel viewModel;
  static double spaceBetween = 33;

  const UserInfoStep({required this.viewModel, super.key});

  @override
  State<UserInfoStep> createState() => _UserInfoStepState();
}

class _UserInfoStepState extends State<UserInfoStep> {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(28, 10, 28, 0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '개인 정보 입력',
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.w900,
                    fontFamily: 'NanumSquare',
                    color: Colors.grey.shade800,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '추가 정보를 입력해 계정 생성을 완료해주세요',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    fontFamily: 'NanumSquare',
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),

            // 상단 제목
            const SizedBox(height: 20),

            Expanded(
              child: Form(
                key: widget.viewModel.formKeys[SignUpStep.signUpInfo.index],
                child: Consumer<SignUpViewModel>(
                  builder: (context, viewModel, child) {
                    return ListView(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 0,
                        vertical: 8,
                      ),
                      children: [
                        // 닉네임
                        InputSectionWidget(
                          title: '닉네임',
                          errorMessage: viewModel.userInfoFieldErrors['nickname'],
                          child: Row(
                            children: [
                              Expanded(
                                child: CustomInputLine(
                                  hintTextValue: '닉네임 입력',
                                  controller: viewModel.nicknameController,
                                  inputValue: '닉네임',
                                  suffixIcon: viewModel.isNicknameVerified
                                      ? Icon(
                                    Icons.check,
                                    color: CustomColors.primaryColor,
                                    size: 27,
                                  )
                                      : null,
                                  onChanged: (value) {
                                    viewModel.validateUserInfoFieldAndUpdate('nickname', value);
                                  },
                                ),
                              ),
                              const SizedBox(width: 12),
                              Align(
                                alignment: Alignment.bottomCenter,
                                child: TextButton(
                                  onPressed: viewModel.isCheckingNickname
                                      ? null
                                      : () async {
                                    await viewModel.checkNicknameDuplicateAndUpdate();
                                  },
                                  style: TextButton.styleFrom(
                                    backgroundColor: viewModel.isNicknameVerified
                                        ? CustomColors.primaryColor
                                        : Colors.transparent,
                                    side: BorderSide(
                                      color: viewModel.isNicknameVerified
                                          ? CustomColors.primaryColor
                                          : Colors.grey.shade400,
                                      width: 1.2,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    foregroundColor: viewModel.isNicknameVerified
                                        ? Colors.white
                                        : Colors.grey.shade600,
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 8,
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      if (viewModel.isCheckingNickname) ...[
                                        SizedBox(
                                          width: 16,
                                          height: 16,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                            valueColor: AlwaysStoppedAnimation<Color>(
                                              viewModel.isNicknameVerified
                                                  ? Colors.white
                                                  : CustomColors.primaryColor,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                      ],
                                      Text(
                                        viewModel.isCheckingNickname
                                            ? '확인 중...'
                                            : viewModel.isNicknameVerified
                                            ? '확인 완료'
                                            : '중복확인',
                                        style: TextStyle(
                                          fontFamily: 'NanumSquare',
                                          fontWeight: FontWeight.bold,
                                          fontSize: 13,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        // 주소
                        InputSectionWidget(
                          title: '주소',
                          errorMessage: viewModel.userInfoFieldErrors['streetAddress'],
                          streetAddressResult: (value) {
                            widget.viewModel.setStreetAddress(value);
                          },
                          child: Column(
                            children: [
                              // 도로명주소 필드
                              Container(
                                padding: const EdgeInsets.only(left: 8),
                                decoration: BoxDecoration(
                                  color: Colors.grey.shade50,
                                  borderRadius: BorderRadius.circular(5),
                                  border: Border.all(
                                    color: Colors.grey.shade300,
                                    width: 1,
                                  ),
                                ),
                                child: TextFormField(
                                  controller: viewModel.streetAddressController,
                                  enabled: false,
                                  style: const TextStyle(
                                    color: Colors.black87,
                                    fontFamily: 'NanumSquare',
                                    fontWeight: FontWeight.w500,
                                  ),
                                  decoration: const InputDecoration(
                                    hintText: '도로명주소',
                                    hintStyle: TextStyle(
                                      color: Colors.black54,
                                      fontFamily: 'NanumSquare',
                                      fontWeight: FontWeight.w600,
                                    ),
                                    border: InputBorder.none,
                                    contentPadding: EdgeInsets.zero,
                                  ),
                                ),
                              ),

                              const SizedBox(height: 10),

                              CustomInputLine(
                                hintTextValue: '상세주소 입력',
                                controller: viewModel.detailAddressController,
                                inputValue: '상세주소',
                                enabled: viewModel.streetAddressController.text.trim().isNotEmpty,
                                onChanged: (value) {
                                  viewModel.validateUserInfoFieldAndUpdate('detailAddress', value);
                                },
                              ),
                            ],
                          ),
                        ),

                        // 생년월일
                        InputSectionWidget(
                          title: '생년월일',
                          errorMessage: viewModel.userInfoFieldErrors['birth'],
                          child: CustomWheelDatePickerField(
                            controller: viewModel.birthController,
                            hintText: "생년월일 입력",
                            onChanged: (value) {
                              viewModel.validateUserInfoFieldAndUpdate('birth', value);
                            },
                          ),
                        ),

                        SizedBox(height: UserInfoStep.spaceBetween * 2),
                      ],
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }


}