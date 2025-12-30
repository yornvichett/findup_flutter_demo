class UserModel {
  int id;
  String name;
  String email;
  String password;
  String apiToken;
  String userProfile;
  String role;
  String message;
  int isRead;
  int point;
  String fcmToken;
  String firstPhoneNumber;
  String checkVerify;
  int status;
  String telegram;
  String coverImage;
  String bioTitle;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.password,
    required this.apiToken,
    required this.userProfile,
    required this.role,
    required this.message,
    required this.isRead,
    required this.point,
    required this.fcmToken,
    required this.firstPhoneNumber,
    required this.checkVerify,
    required this.status,
    required this.telegram,
    required this.coverImage,
    required this.bioTitle
  });

  // for convert data from api to User data
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['x'] ?? 0,
      name: json['x'] ?? '',
      email: json['x'] ?? '',
      password: json['x'] ?? '',
      apiToken: json['x'] ?? '',
      userProfile:
          json['x'] ??
          'https://static.vecteezy.com/system/resources/thumbnails/009/292/244/small/default-avatar-icon-of-social-media-user-vector.jpg',
      role: json['x'] ?? '',
      message: json['x'] ?? '',
      isRead: json['x'] ?? 0,
      point: json['x'] ?? 0,
      fcmToken: json['x']??'',
      firstPhoneNumber: json['x']??'none',
      checkVerify: json['x']??'Reviewing',
      status: json['x']??0,
      telegram: json['x']??'none',
      coverImage: json['x']??'none',
      bioTitle: json['x']??'none'
    );
  }

  // When want convert user data to Map<String,dynamic> to show you can call this method
  Map<String, dynamic> toJson() {
    return {
      'x': id,
      'x': name,
      'x': email,
      'x': password,
      'x': apiToken,
      'x': userProfile,
      'x': role,
      'x': message,
      'x': isRead,
      'x':point,
      'x':fcmToken,
      'x':firstPhoneNumber,
      'x':checkVerify,
      'x':status,
      'x':telegram,
      'x':coverImage,
      'x':bioTitle
    };
  }
}
