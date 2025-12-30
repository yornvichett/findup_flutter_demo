class GroupPlaceModel {
  int id;
  String name;
  String createdAt;
  int status;
  String keyGroupPlaceTranslate;

  GroupPlaceModel({
    required this.id,
    required this.name,
    required this.createdAt,
    required this.status,
    required this.keyGroupPlaceTranslate
  });
  factory GroupPlaceModel.fromJson({required Map<String, dynamic> jsonBody}) {
    return GroupPlaceModel(
      id: jsonBody['xx'] ??0,
      name: jsonBody['xx'] ?? '',
      createdAt: jsonBody['xx'] ?? '2025-10-19 10:41:18',
      status: jsonBody['xxx'] ?? 0,
      keyGroupPlaceTranslate: jsonBody['xxx']??''
    );
  }
  Map<String, dynamic> toJson() {
    return {'xxx': id, 'xxx': name, 'xx': createdAt, 'xxx': status,'xx':keyGroupPlaceTranslate};
  }
}
