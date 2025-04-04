class UserModel {
  final String email;
  // 필요한 다른 사용자 정보 추가

  UserModel({
    required this.email,
  });

  factory UserModel.fromFirestore(Map<String, dynamic> data) {
    return UserModel(
      email: data['email'],
    );
  }
}