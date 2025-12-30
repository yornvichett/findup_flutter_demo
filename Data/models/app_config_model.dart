class AppConfigModel {
  String baseAPIUrl;
  String baseImageURL;
  int upadateStatus;
  int initSelectedGroupCategoryID;

  AppConfigModel({
    required this.baseAPIUrl,
    required this.baseImageURL,
    required this.upadateStatus,
    required this.initSelectedGroupCategoryID
  });

  factory AppConfigModel.fromJson({required Map<String, dynamic> jsonBody}) {
    return AppConfigModel(
      baseAPIUrl: jsonBody['xx'] ?? '',
      baseImageURL: jsonBody['xxx'] ?? '',
      upadateStatus: jsonBody['xxxx'] ?? 0,
      initSelectedGroupCategoryID:jsonBody['xxxx']??0
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'xxx': baseAPIUrl,
      'xxxx': baseImageURL,
      'xx': upadateStatus,
      'xxxxx':initSelectedGroupCategoryID
    };
  }
}
