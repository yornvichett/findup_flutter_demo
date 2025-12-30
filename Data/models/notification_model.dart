class NotificationModel {
  String fcmToken;
  String title;
  String message;

  NotificationModel({
    required this.fcmToken,
    required this.title,
    required this.message,
  });

  factory NotificationModel.fromJson({required Map<String, dynamic> json}) {
    return NotificationModel(
      fcmToken: json['xxx'],
      title: json['xxx'],
      message: json['xxx'],
    );
  }

  Map<String,dynamic> toJson(){
    return {
      'xxx':fcmToken,
      'xxx':title,
      'xxx':message
    };
  }
}
