import 'package:findup_mvvm/Core/constants/app_color.dart';
import 'package:findup_mvvm/Core/constants/text_helper.dart';
import 'package:findup_mvvm/Core/navigation/navigation.dart';
import 'package:findup_mvvm/Core/services/helper.dart';
import 'package:findup_mvvm/Core/services/local_storage.dart';
import 'package:findup_mvvm/Core/services/translate.dart';
import 'package:findup_mvvm/Data/models/group_place_model.dart';
import 'package:findup_mvvm/Data/models/sub_category_model.dart';
import 'package:findup_mvvm/Data/view/product_model_view.dart';
import 'package:findup_mvvm/Data/view_models/group_place_view_model.dart';
import 'package:findup_mvvm/Data/view_models/product_model_view_model.dart';
import 'package:findup_mvvm/Data/view_models/sub_category_view_modle.dart';
import 'package:findup_mvvm/Pages/FIlter/filter_result_page.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class FilterPage extends StatefulWidget {
  const FilterPage({super.key});

  @override
  State<FilterPage> createState() => _FilterPageState();
}

class _FilterPageState extends State<FilterPage> {
  String? selectedCategory;
  String? selectedLocation;

  final TextEditingController minPriceController = TextEditingController();
  final TextEditingController maxPriceController = TextEditingController();
  Helper helper=Helper();

  // int subCategoryID = 0;
  // int groupPlaceID = 0;

  TextHelper textHelper = TextHelper();
  GroupPlaceModel? groupPlaceModel;
  SubCategoryModel? subCategoryModel;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      context.read<GroupPlaceViewModel>().getGroupPlace();
      context.read<SubCategoryViewModle>().getAllSubcategory();
    });
  }

  @override
  Widget build(BuildContext context) {
    final groupPlaceViewModel = context.watch<GroupPlaceViewModel>();
    final subCategoryViewModle = context.watch<SubCategoryViewModle>();

    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        backgroundColor: AppColor.backgroundColor,
        appBar: AppBar(
          centerTitle: false,
          backgroundColor: AppColor.appBarColor,
          iconTheme: const IconThemeData(color: Colors.white),
          title: Text(Translator.translate('filter'), style: textHelper.textAppBarStyle()),
          elevation: 0,
          actions: [
            TextButton(
              onPressed: () {
                setState(() {
                  selectedCategory = null;
                  selectedLocation = null;
                  subCategoryModel = null;
                  groupPlaceModel = null;
                  minPriceController.clear();
                  maxPriceController.clear();
                });
              },
              child:  Text(Translator.translate('reset'), style: TextStyle(color: Colors.white)),
            ),
          ],
        ),

        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ===================== CATEGORY =====================
              Text(
                Translator.translate('category'),
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),

              if (subCategoryViewModle.listAllSubCategory.isEmpty)
                const Center(child: CircularProgressIndicator())
              else
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: subCategoryViewModle.listAllSubCategory.map((cat) {
                    final isSelected = selectedCategory == cat.name;
                    return GestureDetector(
                      onTap: () {
                        subCategoryModel=cat;
                    
                        setState(() => selectedCategory = cat.name);
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? Colors.blue.shade600
                              : Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              spreadRadius: 1,
                              blurRadius: 5,
                            ),
                          ],
                        ),
                        child: Text(
                          Translator.translate(cat.keyTranslate),
                          style: TextStyle(
                            color: isSelected ? Colors.white : Colors.black87,
                            fontWeight: isSelected
                                ? FontWeight.bold
                                : FontWeight.normal,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),

              const SizedBox(height: 30),

              // ===================== LOCATION =====================
              Text(
                Translator.translate('location'),
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),

              Container(
                padding: const EdgeInsets.symmetric(horizontal: 15),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 5,
                      spreadRadius: 1,
                    ),
                  ],
                ),
                child: DropdownButtonFormField<String>(
                  value: selectedLocation,
                  dropdownColor: Colors.white,
                  decoration: const InputDecoration(border: InputBorder.none),
                  hint:  Text(Translator.translate('choose_location')),
                  items: groupPlaceViewModel.gropuPlaceModel.map((e) {
                    return DropdownMenuItem(value: e.name, child: Text(Translator.translate(e.keyGroupPlaceTranslate),style: TextStyle(color: Colors.black),));
                  }).toList(),
                  onChanged: (value) {
                    for (var item in groupPlaceViewModel.gropuPlaceModel) {
                      if (item.name == value) {
                        groupPlaceModel=item;
                        // groupPlaceID = item.id;

                        break;
                      }
                    }
                    setState(() => selectedLocation = value);
                  },
                ),
              ),

              const SizedBox(height: 30),

              // ===================== PRICE RANGE =====================
              Text(
                '${Translator.translate('price_range')}(\$)',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),

              Row(
                children: [
                  // MIN PRICE
                  Expanded(
                    child: _buildInputBox(
                      controller: minPriceController,
                      hint: Translator.translate('min'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  // MAX PRICE
                  Expanded(
                    child: _buildInputBox(
                      controller: maxPriceController,
                      hint: Translator.translate('max'),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 100),
            ],
          ),
        ),

        // ================= APPLY BUTTON =================
        bottomNavigationBar: Container(
          padding: const EdgeInsets.all(16),
          color: Colors.white,
          child: SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                backgroundColor: Colors.blue.shade700,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              onPressed: () async {
                if (selectedCategory == null ||
                    selectedLocation == null ||
                    minPriceController.text.isEmpty ||
                    maxPriceController.text.isEmpty) {
                  helper.showSnackBar(context: context, title: Translator.translate('please_complete_filter_input'));
                  return;
                }
                double minPrice = double.parse(minPriceController.text.trim());
                double maxPrice = double.parse(maxPriceController.text.trim());
                await context
                    .read<ProductModelViewModel>()
                    .filterProductByRangePrice(
                      subCategoryID: subCategoryModel!.id,
                      groupPlaceID: groupPlaceModel!.id,
                      userId: LocalStorage.userModel == null
                          ? 0
                          : LocalStorage.userModel!.id,
                      minPrice: minPrice,
                      maxPrice: maxPrice,
                    );
                Navigation.goPage(context: context, page: FilterResultPage(subCategoryModel: subCategoryModel!, groupPlaceModel: groupPlaceModel!, maxPrice: maxPrice, minPrice: minPrice,));
                
              },
              child:  Text(
                Translator.translate('apply_filter'),
                style: TextStyle(fontSize: 17, color: Colors.white),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Modern Input Box
  Widget _buildInputBox({
    required TextEditingController controller,
    required String hint,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 5,
            spreadRadius: 1,
          ),
        ],
      ),
      child: TextField(
        controller: controller,
        keyboardType: TextInputType.number,
        decoration: InputDecoration(border: InputBorder.none, hintText: hint),
      ),
    );
  }
}
