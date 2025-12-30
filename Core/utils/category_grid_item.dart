import 'package:findup_mvvm/Core/services/translate.dart';
import 'package:findup_mvvm/Core/utils/profile_icon_element.dart';
import 'package:findup_mvvm/Data/models/sub_category_model.dart';
import 'package:findup_mvvm/Data/view_models/sub_category_view_modle.dart';
import 'package:flutter/material.dart';

class CategoryGridItem extends StatelessWidget {
  final int itemPerRow;
  final int itemsPerPage;
  final Function(SubCategoryModel valCallBack)? calBack;
  final List<SubCategoryModel> subCategoryList;

  const CategoryGridItem({
    super.key,
    this.itemPerRow = 5,
    this.itemsPerPage = 12,
    this.calBack,
    required this.subCategoryList,
  });

  @override
  Widget build(BuildContext context) {
    // 🔹 Split the list into pages of 12 items
    final List<List<SubCategoryModel>> pages = [];
    for (int i = 0; i < subCategoryList.length; i += itemsPerPage) {
      pages.add(
        subCategoryList.sublist(
          i,
          (i + itemsPerPage > subCategoryList.length)
              ? subCategoryList.length
              : i + itemsPerPage,
        ),
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final totalSpacing = (itemPerRow - 1) * 8;
        final itemWidth = (constraints.maxWidth - totalSpacing) / itemPerRow;

        return SizedBox(
          height: _calculateGridHeight(itemWidth, itemsPerPage, itemPerRow),
          // ✅ PageView for horizontal sliding between pages
          child: PageView.builder(
            itemCount: pages.length,
            scrollDirection: Axis.horizontal,
            itemBuilder: (context, pageIndex) {
              final currentPage = pages[pageIndex];

              return GestureDetector(
                child: Wrap(
                  spacing: 8,
                  runSpacing: 13,
                  children: currentPage.map((item) {
                    return GestureDetector(
                      onTap: () {
                        calBack!(item);
                      },
                      child: Container(
                        width: itemWidth,

                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            ProfileIconElement(
                              imageUrl: item.imageUrl,
                              isAssets: false,
                              borderColor: Color(0xff344a58),
                              borderWidth: 4,
                              size: 50,
                            ),
                            const SizedBox(height: 6),
                            Text(
                              Translator.translate(item.keyTranslate),
                          
                              textAlign: TextAlign.center,
                              style: const TextStyle(fontSize: 14),
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ),
              );
            },
          ),
        );
      },
    );
  }

  /// Dynamically calculate grid height based on number of rows
  double _calculateGridHeight(
    double itemWidth,
    int itemsPerPage,
    int itemPerRow,
  ) {
    final rows = (itemsPerPage / itemPerRow).ceil();
    // Approximate height: image (60) + text (20) + spacing
    final double itemHeight =
        60 + 4 + 10 + 20 + double.parse(itemPerRow.toString());
    return rows * itemHeight;
  }
}
