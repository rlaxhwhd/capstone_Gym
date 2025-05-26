import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../view_models/phone_change_view_model.dart';
import '../../common_widgets/custom_back_button.dart';
import '../../../utils/phone_number_formatter.dart';

class PhoneChangeScreen extends StatefulWidget {
  const PhoneChangeScreen({super.key});

  @override
  State<PhoneChangeScreen> createState() => _PhoneChangeScreenState();
}

class _PhoneChangeScreenState extends State<PhoneChangeScreen> {
  late FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode();
    _focusNode.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => PhoneChangeViewModel(),
      child: Consumer<PhoneChangeViewModel>(
        builder: (context, viewModel, _) {
          return Scaffold(
            backgroundColor: Colors.white,
            body: SafeArea(
              child: Column(
                children: [
                  const Padding(
                    padding: EdgeInsets.fromLTRB(20, 20, 0, 30),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: CustomBackButton(),
                    ),
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        '휴대폰 번호 변경',
                        style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                  const Padding(
                    padding: EdgeInsets.fromLTRB(18, 12, 20, 24),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        '새로운 휴대폰 번호를 입력해주세요.',
                        style: TextStyle(fontSize: 14, color: Colors.black87),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32),
                    child: TextField(
                      controller: viewModel.phoneController,
                      focusNode: _focusNode,
                      keyboardType: TextInputType.phone,
                      onChanged: viewModel.onPhoneChanged,
                      inputFormatters: [PhoneNumberFormatter()], // ✅ 포맷터 적용
                      style: const TextStyle(fontSize: 16),
                      decoration: const InputDecoration(
                        hintText: '010-1234-5678',
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                  Divider(
                    height: 1,
                    thickness: 1,
                    indent: 32,
                    endIndent: 32,
                    color: _focusNode.hasFocus
                        ? Colors.black
                        : const Color(0xFFDDDDDD),
                  ),
                  if (viewModel.isInvalidFormat)
                    const Padding(
                      padding: EdgeInsets.only(top: 12, left: 32),
                      child: Row(
                        children: [
                          Icon(Icons.error, color: Colors.red, size: 18),
                          SizedBox(width: 6),
                          Text(
                            '올바른 전화번호 형식이 아닙니다.',
                            style: TextStyle(color: Colors.red, fontSize: 13),
                          ),
                        ],
                      ),
                    ),
                  const Spacer(),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                    child: SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        onPressed: viewModel.isValid
                            ? () => viewModel.submitPhone(context)
                            : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: viewModel.isValid
                              ? const Color(0xFF81C6FF)
                              : const Color(0xFFF3F2F5),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                          elevation: 0,
                        ),
                        child: viewModel.isLoading
                            ? const CircularProgressIndicator(color: Colors.white)
                            : Text(
                          '변경하기',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: viewModel.isValid ? Colors.white : Colors.grey,
                          ),
                        ),
                      ),
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
}
