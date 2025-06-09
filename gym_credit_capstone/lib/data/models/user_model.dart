class UserModel {
  final String? email;
  final String nickName;
  final String phoneNumber;
  final List<String> favorite;
  final DateTime birthDate;
  final String address;
  final bool agreeToTerms;
  final bool agreeToPrivacy;
  final bool agreeToPayment;

  // 필요한 다른 사용자 정보 추가
  UserModel({
    this.email,
    required this.nickName,
    required this.phoneNumber,
    required this.favorite,
    required this.birthDate,
    required this.address,
    required this.agreeToTerms,
    required this.agreeToPrivacy,
    required this.agreeToPayment,
  });

  factory UserModel.fromFirestore(Map<String, dynamic> data) {
    return UserModel(
      email: data['email'],
      nickName: data['nickname'],
      phoneNumber: data['phonenum'],
      favorite: data['favorite'],
      birthDate: data['birthDate'].toDate(),
      address: data['address'],
      agreeToTerms: data['agreeToTerms'],
      agreeToPrivacy: data['agreeToPrivacy'],
      agreeToPayment: data['agreeToPayment'],
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'nickname': nickName,
      'phonenum': phoneNumber,
      'favorite': favorite,
      'birthDate': birthDate,
      'address': address,
      'agreeToTerms': agreeToTerms,
      'agreeToPrivacy': agreeToPrivacy,
      'agreeToPayment': agreeToPayment,
    };
  }

}