import 'package:flutter/foundation.dart';

class GroupCategoryModel {
  int id;
  String name;
  int isRealestate;
  int status;
  int isSelected;
  String keyTranslate;
  String role;

  GroupCategoryModel({
    required this.id,
    required this.name,
    required this.isRealestate,
    required this.status,
    required this.isSelected,
    required this.keyTranslate,
    required this.role
  });

  factory GroupCategoryModel.fromJson({required Map<String, dynamic> jsonBody}) {
    return GroupCategoryModel(
      id: jsonBody['x'] ?? 0,
      name: jsonBody['xxx'] ??'',
      isRealestate: jsonBody['xx']??0,
      status: jsonBody['xxx'] ?? 0,
      isSelected: jsonBody['xxxx'] ?? 0,
      keyTranslate: jsonBody['xxx']??'',
      role: jsonBody['xx']??'xx'
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'xxxx': id,
      'x': name,
      'xx': isRealestate,
      'xx': status,
      'xxxx':isSelected,
      'xx':keyTranslate,
      'xx':role
 
    };
  }
}
