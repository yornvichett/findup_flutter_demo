import 'package:cached_network_image/cached_network_image.dart';
import 'package:findup_mvvm/Core/constants/app_color.dart';
import 'package:findup_mvvm/Core/services/translate.dart';
import 'package:findup_mvvm/Data/models/group_category_model.dart';
import 'package:findup_mvvm/Data/models/sub_category_model.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class SubCategoryHorizonScroll extends StatelessWidget {
  final List<SubCategoryModel> listSUbCategory;
  final Function(SubCategoryModel item) onTab;

  ValueNotifier<bool> refresh = ValueNotifier(false);

  SubCategoryHorizonScroll({
    super.key,
    required this.listSUbCategory,
    required this.onTab,
  });

  @override
  Widget build(BuildContext context) {
    Size size=MediaQuery.of(context).size;
    // set firse select
    //listSUbCategory.first.is_selected=true;
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: ValueListenableBuilder(
        valueListenable: refresh,
        builder: (context, value, child) {
          
          return Container(
            width: size.width,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              
              children: listSUbCategory
                  .map(
                    (subCatItem) => Padding(
                      padding: const EdgeInsets.only(right: 10),
                      child: GestureDetector(
                        onTap: () {
                          onTab(subCatItem);
                          refresh.value = !refresh.value;
                        },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 400),
                          curve: Curves.easeInOut,
                          decoration: BoxDecoration(
                            color: subCatItem.is_selected
                                ? Color(0xff344a58)
                                : AppColor.categoryBackgroundColor,
                            borderRadius: BorderRadius.circular(40),
                            border: Border.all(
                              width: 2,
                              color: subCatItem.is_selected
                                  ? Colors.blue
                                  : Colors.transparent,
                            ),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.only(
                              left: 10,
                              right: 10,
                              top: 3,
                              bottom: 3
                            ),
                            child: Row(
                              children: [
                                SizedBox(
                                  width: 40,
                                  height: 40,
                                  child: CachedNetworkImage(
                                    color: subCatItem.is_selected?Colors.white:Colors.blue,
                                    imageUrl: subCatItem.imageUrl,
                                    fit: BoxFit.cover,
                                    placeholder: (context, url) =>
                                        Container(color: Colors.grey[300]),
                                    errorWidget: (context, url, error) =>
                                        Icon(Icons.error),
                                  ),
                                ),
                                SizedBox(width: 5),
                                Text(
                                  Translator.translate(subCatItem.keyTranslate),
                                  style: GoogleFonts.poppins(
                                    color: subCatItem.is_selected
                                        ? Colors.white
                                        : AppColor.textCategoryColor,
                                  ),
                                ),
                                SizedBox(width: 10),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  )
                  .toList(),
            ),
          );
        },
      ),
    );
  }
}
