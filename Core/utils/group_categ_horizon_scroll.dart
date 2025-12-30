import 'package:findup_mvvm/Core/constants/app_color.dart';
import 'package:findup_mvvm/Core/services/translate.dart';
import 'package:findup_mvvm/Data/models/group_category_model.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class GroupCategHorizonScroll extends StatelessWidget {
  final List<GroupCategoryModel> listGroupCategory;
  final Function(GroupCategoryModel item) onTab;

  GroupCategHorizonScroll({
    super.key,
    required this.listGroupCategory,
    required this.onTab,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: listGroupCategory.map((catItem) {

          return Padding(
            padding: const EdgeInsets.only(right: 10),
            child: GestureDetector(
              onTap: () {
                onTab(catItem);
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 400),
                curve: Curves.easeInOut,
                decoration: BoxDecoration(
                  color: catItem.isSelected==1
                      ? Color(0xff344a58)
                      : AppColor.categoryBackgroundColor,
                  borderRadius: BorderRadius.circular(40),
                  border: Border.all(
                    width: 2,
                    color: catItem.isSelected==1
                        ? Colors.blue
                        : Colors.transparent,
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.only(
                    left: 20,
                    right: 20,
                    top: 12,
                    bottom: 12,
                  ),
                  child: Row(
                    children: [
                      Text(
                        Translator.translate(catItem.keyTranslate),
                        style: GoogleFonts.poppins(
                          color: catItem.isSelected==1
                              ? Colors.white
                              : AppColor.textCategoryColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
