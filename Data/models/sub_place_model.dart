class SubPlaceModel {
  int id;
  String name;
  int groupPlaceID;
  String createdAt;
  int status;
  int isSelected;

  SubPlaceModel({
    required this.id,
    required this.name,
    required this.groupPlaceID,
    required this.createdAt,
    required this.status,
    required this.isSelected
  });

  factory SubPlaceModel.fromJson({required Map<String, dynamic> jsonBody}) {
    return SubPlaceModel(
      id: jsonBody['x'] ??0,
      name: jsonBody['x'] ??'',
      groupPlaceID: jsonBody['x']??0,
      createdAt: jsonBody['x']??'2025-10-19 10:41:18',
      status: jsonBody['x'] ??0,
      isSelected: jsonBody['x']??0,
    );
  }
  Map<String, dynamic> toJson() {
    return {
      'x': id,
      'x': name,
      'x': groupPlaceID,
      'x': createdAt,
      'x': status,
      'x':isSelected
    };
  }
}
