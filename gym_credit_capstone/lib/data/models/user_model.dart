class UserModel {
  final String email;
  final String nickname;
  final String phoneNum;

  UserModel({
    required this.email,
    required this.nickname,
    required this.phoneNum,
  });

  factory UserModel.fromFirestore(Map<String, dynamic> data) {
    return UserModel(
      email: data['email'] ?? '',
      nickname: data['nickname'] ?? '닉네임 없음',
      phoneNum: data['phonenum'] ?? '전화번호 없음',
    );
  }

}