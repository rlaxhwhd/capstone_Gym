import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../view_models/nickname_change_view_model.dart';
import '../../common_widgets/custom_back_button.dart';

class NicknameChangeScreen extends StatefulWidget {
  const NicknameChangeScreen({super.key});

  @override
  State<NicknameChangeScreen> createState() => _NicknameChangeScreenState();
}

class _NicknameChangeScreenState extends State<NicknameChangeScreen> {
  late FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode();
    _focusNode.addListener(() {
      setState(() {}); // 포커스 상태가 바뀔 때 UI 갱신
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
      create: (_) => NicknameChangeViewModel(),
      child: Consumer<NicknameChangeViewModel>(
        builder: (context, viewModel, _) {
          return Scaffold(
            backgroundColor: Colors.white,
            body: SafeArea(
              child: Column(
                children: [
                  const Padding(
                    padding: EdgeInsets.fromLTRB(18, 20, 0, 30),
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
                        '닉네임 변경',
                        style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                  const Padding(
                    padding: EdgeInsets.fromLTRB(20, 12, 20, 24),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        '새로운 닉네임을 입력해주세요.',
                        style: TextStyle(fontSize: 14, color: Colors.black87),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32),
                    child: TextField(
                      controller: viewModel.nicknameController,
                      focusNode: _focusNode,
                      onChanged: viewModel.onNicknameChanged,
                      style: const TextStyle(fontSize: 16),
                      decoration: const InputDecoration(
                        hintText: '',
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
                  if (viewModel.isDuplicate)
                    const Padding(
                      padding: EdgeInsets.only(top: 12, left: 32),
                      child: Row(
                        children: [
                          Icon(Icons.error, color: Colors.red, size: 18),
                          SizedBox(width: 6),
                          Text(
                            '존재하는 이름입니다.',
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
                            ? () => viewModel.submitNickname(context)
                            : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: viewModel.isValid
                              ? const Color(0xFF81C6FF)
                              : const Color(0xFF81C6FF),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                          elevation: 0,
                        ),
                        child: viewModel.isLoading
                            ? const CircularProgressIndicator(
                          color: Colors.white,
                        )
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
