class RefreshVersionModel {
  int id;
  int homeRefreshVersion;
  int groupCategoryRefreshVersion;
  int subCategoryRefreshVersion;
  int groupPlaceRefreshVersion;

  RefreshVersionModel({
    required this.id,
    required this.homeRefreshVersion,
    required this.groupCategoryRefreshVersion,
    required this.subCategoryRefreshVersion,
    required this.groupPlaceRefreshVersion,
    
  });

  factory RefreshVersionModel.fromJson({
    required Map<String, dynamic> jsonBody,
  }) {
    return RefreshVersionModel(
      id: jsonBody['x'],
      homeRefreshVersion: jsonBody['x'],
      groupCategoryRefreshVersion: jsonBody['x'],
      subCategoryRefreshVersion: jsonBody['x'],
      groupPlaceRefreshVersion: jsonBody['x'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'x': id,
      'x': homeRefreshVersion,
      'x': groupCategoryRefreshVersion,
      'x':subCategoryRefreshVersion,
      'x': groupCategoryRefreshVersion,
    };
  }
}
