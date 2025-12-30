class SubCategoryModel {
  int id;
  String name;
  int isRealestate;
  int groupCategoryId;
  String createdAt;
  String imageUrl;
  int status;
  bool is_selected;
  String keyTranslate;
  String role;


  SubCategoryModel({
    required this.id,
    required this.name,
    required this.isRealestate,
    required this.groupCategoryId,
    required this.createdAt,
    required this.imageUrl,
    required this.status,
    required this.keyTranslate,
    required this.is_selected,
    required this.role

  });

  factory SubCategoryModel.fromJson({required Map<String, dynamic> jsonBody}) {
    return SubCategoryModel(
      id: jsonBody['x'] ?? 0,
      name: jsonBody['x'],
      isRealestate: jsonBody['x'] ?? 0,
      groupCategoryId: jsonBody['x'] ?? 0,
      createdAt: jsonBody['x'] ??'2025-10-19 10:41:18',
      imageUrl: jsonBody['x']??'https://static.thenounproject.com/png/default-image-icon-4595376-512.png',
      status: jsonBody['x'] ?? 0,
      keyTranslate: jsonBody['x']??'',
      is_selected: false,
      role: jsonBody['x']??'space'

    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'is_realestate': isRealestate,
      'group_category_id': groupCategoryId,
      'created_at': createdAt,
      'image_url': imageUrl,
      'status': status,
      'key_translate':keyTranslate,
      'is_selected':is_selected,
      'role':role

    };
  }
}
