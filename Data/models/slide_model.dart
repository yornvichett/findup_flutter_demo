

class SlideModel {
  int id;
  String title;
  String subTitle;
  String imageUrl;
  String createdAt;

  SlideModel({
    required this.id,
    required this.title,
    required this.subTitle,
    required this.imageUrl,
    required this.createdAt,
  });

  factory SlideModel.fromJson({required Map<String, dynamic> jsonBody}) {
    return SlideModel(
      id: jsonBody['x'],
      title: jsonBody['x'],
      subTitle: jsonBody['x'],
      imageUrl: jsonBody['x'],
      createdAt: jsonBody['x'],
    );
  }
  Map<String, dynamic> toJson() {
    return {
      'x': id,
      'x': subTitle,
      'x': subTitle,
      'x': imageUrl,
      'x': createdAt,
    };
  }
}
