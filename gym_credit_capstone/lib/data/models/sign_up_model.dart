import 'package:gym_credit_capstone/data/models/user_model.dart';

class SignUpModel {
  String nickName;
  String phoneNumber;
  String favorite;            // 쉼표로 구분된 String
  String birthDate;           // 'yyyy-MM-dd' 형식
  String address;
  bool agreeToTerms;
  bool agreeToPrivacy;
  bool agreeToPayment;
  dynamic idCardImage;

  SignUpModel({
    this.nickName = '',
    this.phoneNumber = '',
    this.favorite = '',
    this.birthDate = '',
    this.address = '',
    this.agreeToTerms = false,
    this.agreeToPrivacy = false,
    this.agreeToPayment = false,
  });

  /// SignUpModel → UserModel 변환
  UserModel toUserModel() {
    return UserModel(
      nickName: nickName,
      phoneNumber: phoneNumber,
      favorite: favorite.isEmpty
          ? []
          : favorite.split(',').map((e) => e.trim()).toList(), // 문자열 → List<String>
      birthDate: DateTime.parse(birthDate),
      address: address,
      agreeToTerms: agreeToTerms,
      agreeToPrivacy: agreeToPrivacy,
      agreeToPayment: agreeToPayment,
    );
  }
}
