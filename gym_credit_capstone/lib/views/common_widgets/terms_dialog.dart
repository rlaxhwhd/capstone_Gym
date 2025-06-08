import 'package:flutter/material.dart';
import 'package:gym_credit_capstone/view_models/terms_dialog_view_model.dart';
import 'package:gym_credit_capstone/views/common_widgets/primary_button.dart';
import 'package:provider/provider.dart';

class TermsDialog extends StatelessWidget {
  final String dialogTitle;
  final VoidCallback? onAgree;

  static const TextStyle labelTextStyle = TextStyle(
      fontWeight: FontWeight.bold, fontSize: 17, fontFamily: "NanumSquare"
  );
  static const TextStyle valueTextStyle = TextStyle(
      fontWeight: FontWeight.w500, fontSize: 17, fontFamily: "NanumSquare"
  );

  const TermsDialog({
    Key? key,
    required this.dialogTitle,
    this.onAgree,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {

    return ChangeNotifierProvider(
      create: (_) => TermsDialogViewModel()..loadTerms(dialogTitle),
      child: Dialog(
        backgroundColor: Colors.white,
        insetPadding: EdgeInsets.zero,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: SizedBox(
          width: MediaQuery.of(context).size.width * 0.9,
          height: MediaQuery.of(context).size.height * 0.9,
          child: Consumer<TermsDialogViewModel>(
            builder: (context, vm, _) {
              return Column(

                children: [
                  // 헤더
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Flexible(
                          child: Text(
                            vm.termTitle ?? dialogTitle,
                            style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'NanumSquare',
                            ),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ],
                    ),
                  ),

                  // 본문
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: _buildContent(vm),
                    ),
                  ),

                  if (onAgree != null)
                  // 동의 버튼
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: PrimaryButton(
                      text: '동의',
                      onPressed:
                          (vm.isLoading || vm.errorMessage != null)
                              ? null
                              : () {
                                onAgree!();
                                Navigator.pop(context);
                              },
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildContent(TermsDialogViewModel vm) {
    if (vm.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (vm.errorMessage != null) {
      return Center(child: Text('오류: ${vm.errorMessage!}'));
    }

    if (vm.sections == null || vm.sections!.isEmpty) {
      return const Center(child: Text('약관 정보가 없습니다.'));
    }

    return ListView(
      padding: const EdgeInsets.symmetric(vertical: 16),
      children: [
        ...vm.sections!.map(
          (section) => Padding(
            padding: const EdgeInsets.only(bottom: 24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  section.title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                ...section.content.map(
                  (text) => Padding(
                    padding: const EdgeInsets.only(bottom: 6),
                    child: Text(
                      '• $text',
                      style: const TextStyle(fontSize: 15, height: 1.5),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        const Divider(),
        const SizedBox(height: 16),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween, // 변경
              children: [Text('약관 시행일 : ', style: labelTextStyle), Text(vm.effectiveDate ?? '', style: valueTextStyle,)],
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween, // 변경
              children: [Text('서비스 제공자 : ', style: labelTextStyle), Text(vm.company ?? '', style: valueTextStyle)],
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween, // 변경
              children: [Text('제공 서비스 : ', style: labelTextStyle), Text(vm.service ?? '', style: valueTextStyle)],
            ),
          ],
        )
      ],
    );
  }
}
