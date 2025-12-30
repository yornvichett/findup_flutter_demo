import 'dart:convert';
import 'dart:io';

import 'package:findup_mvvm/Core/constants/app_color.dart';
import 'package:findup_mvvm/Core/navigation/navigation.dart';
import 'package:findup_mvvm/Core/services/helper.dart';
import 'package:findup_mvvm/Core/services/local_storage.dart';
import 'package:findup_mvvm/Core/services/notification_service.dart';
import 'package:findup_mvvm/Core/services/telegram_bot.dart';
import 'package:findup_mvvm/Core/services/translate.dart';
import 'package:findup_mvvm/Core/utils/dialog_pop_up_elements.dart';
import 'package:findup_mvvm/Core/utils/location_picker_sheet_element%20copy.dart';
import 'package:findup_mvvm/Core/utils/sale_type_toogle_element.dart';
import 'package:findup_mvvm/Core/utils/sub_category_picker_sheet_element.dart';
import 'package:findup_mvvm/Data/models/group_category_model.dart';
import 'package:findup_mvvm/Data/models/group_place_model.dart';
import 'package:findup_mvvm/Data/models/sub_category_model.dart';
import 'package:findup_mvvm/Data/models/sub_place_model.dart';
import 'package:findup_mvvm/Data/view_models/product_model_view_model.dart';
import 'package:findup_mvvm/Data/view_models/sub_category_view_modle.dart';
import 'package:findup_mvvm/Data/view_models/sub_place_view_model.dart';
import 'package:findup_mvvm/Data/view_models/user_view_model.dart';
import 'package:findup_mvvm/Pages/home_page.dart';
import 'package:findup_mvvm/Pages/Screen/dialog_map_selecte_location_screen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

class AddProductPage extends StatefulWidget {
  final GroupPlaceModel groupPlaceModel;
  final GroupCategoryModel groupCategoryModel;

  // final SubCategoryModel subCategoryModel;


  const AddProductPage({
    super.key,
    required this.groupCategoryModel,
    // required this.subCategoryModel,
    required this.groupPlaceModel,
  
  });

  @override
  State<AddProductPage> createState() => _AddProductPageState();
}

class _AddProductPageState extends State<AddProductPage> {
  final _formKey = GlobalKey<FormState>();
  ValueNotifier<List<File>> selectedImages = ValueNotifier([]);
  final picker = ImagePicker();
  TelegramBot telegramBot = TelegramBot();
  NotificationService notificationService = NotificationService();

  // Controllers
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _subTitleController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _sizeController = TextEditingController();
  final TextEditingController _bedroomController = TextEditingController();
  final TextEditingController _bathroomController = TextEditingController();
  final TextEditingController _buillingPerioudController =
      TextEditingController(text: 'month');
  String selectedPeriod = 'month';
  List<String> billingPeriods = ['month', 'year', 'week', 'Custom'];
  ValueNotifier<String> saleType=ValueNotifier("Rent") ;
  Helper helper = Helper();

  String? customValue;
  final TextEditingController customController = TextEditingController(
    text: '',
  );

  String? selectedSubPlace;
  String? selectedSubCategory;
  int selectedSubPlaceId = 0;
  int selectSubCategoryID = 0;
  String fullAddress = "";
  bool _isSubmitting = false; // 👈 add this
  double lat = 0.00;
  double lon = 0.00;

  Future<void> _pickImages() async {
    final pickedFiles = await picker.pickMultiImage(
      imageQuality: 50,
      maxWidth: 800,
      maxHeight: 800,
    );
    if (pickedFiles != null) {
      if (!((selectedImages.value.length + pickedFiles.length) > 10)) {
        selectedImages.value.addAll(pickedFiles.map((e) => File(e.path)));
        selectedImages.notifyListeners();
      } else {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (_) => DialogPopUpElements(
            icon: Icons.warning,
            iconColor: Colors.yellow.shade600,
            message: Translator.translate('multhi_image'),
            onProcess: () async {
              await Future.delayed(const Duration(seconds: 3));
            },
          ),
        );
      }
    }
  }

  void _clearForm() {
    setState(() {
      _titleController.clear();
      _subTitleController.clear();
      _priceController.clear();
      _sizeController.clear();
      _bedroomController.clear();
      _bathroomController.clear();
      selectedSubPlace = null;
      selectedSubPlaceId = 0;
      selectedPeriod = "month";
      fullAddress = '';
      lat = 0.00;
      lon = 0.00;
      selectedImages.value.clear();
    });

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => DialogPopUpElements(
        icon: Icons.check_circle_outline_outlined,
        message: '${Translator.translate('your_post_has_been_submitted')}.\n',
        onProcess: () async {
          await Future.delayed(const Duration(seconds: 5));
        },
      ),
    );
  }

  Future<void> pushDataAlertToAdmin() async {
    try {
      telegramBot.sendMessageToTelegram(
        '''🧑‍💻📤USER POST PRODUCT (${helper.getFormattedDateTime()})
                          User Info : ${LocalStorage.userModel!.name} (${LocalStorage.userModel!.id})
                   
                          =========================
                          Status    : Product Edit''',
      );
    } catch (e) {}
  }

  void _submitForm({
    required ProductModelViewModel productModelViewModel,
  }) async {
    if (_formKey.currentState!.validate()) {
      if (fullAddress == '') {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(Translator.translate('please_select_location')),
          ),
        );
        return;
      }
      if (selectedSubCategory == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(Translator.translate('please_select_sub_category')),
          ),
        );
        return;
      }

      FocusScope.of(context).unfocus();
      setState(() => _isSubmitting = true); // ⛔ disable all UI

      Map<String, dynamic> jsonBody = {
        'user_id': LocalStorage.userModel?.id,
        'user_name': LocalStorage.userModel?.name,
        'group_category_id': widget.groupCategoryModel.id,
        'sub_category_id': selectSubCategoryID,
        'group_place_id': widget.groupPlaceModel.id,
        'sub_place_id': 0,
        'title': selectedSubCategory,
        'sub_title': _subTitleController.text.trim(),
        'location_detail': fullAddress,
        'sale_type': saleType.value,
        'base_price': double.parse(_priceController.text.trim()),
        'billing_period': saleType.value.toLowerCase() == 'rent'
            ? '/$selectedPeriod'
            : '',
        'bed_count': widget.groupCategoryModel.role == 'land'
            ? 0
            : int.parse(_bedroomController.text.trim()),
        'bath_count': widget.groupCategoryModel.role == 'land'
            ? 0
            : int.parse(_bathroomController.text.trim()),
        'size': _sizeController.text.trim(),
        'lat': lat,
        'lon': lon,
      };

      if (selectedImages.value.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              Translator.translate('please_select_at_least_one_image'),
            ),
          ),
        );
        setState(() => _isSubmitting = false);
        return;
      }

      final success = await productModelViewModel.postProduct(
        jsonBody: jsonBody,
        images: selectedImages.value,
        userID: LocalStorage.userModel!.id,
        context: context,
      );

      if (mounted) setState(() => _isSubmitting = false); // ✅ re-enable UI

      if (success) {
        pushDataAlertToAdmin();

        _clearForm();
      } else {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (_) => DialogPopUpElements(
            icon: Icons.error,
            iconColor: Colors.red,
            message: Translator.translate('failed_upload'),
            onProcess: () async {
              await Future.delayed(const Duration(seconds: 3));
            },
          ),
        );
      }
    }
  }

  void _openSubCategoryPicker({
    required SubCategoryViewModle subCategoryViewModel,
  }) async {
    final result = await showModalBottomSheet<SubCategoryModel>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => SubCategoryPickerSheetElement(
        listSubCategory: subCategoryViewModel.listFilterSubCategory,
        currentId: selectSubCategoryID,
      ),
    );

    if (result != null && mounted) {
      setState(() {
        selectedSubCategory = result.name;
        selectSubCategoryID = result.id;
      });
    }
  }

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      Provider.of<SubPlaceViewModel>(
        context,
        listen: false,
      ).getSubPlace(groupPlaceID: widget.groupPlaceModel.id);
      Provider.of<SubCategoryViewModle>(
        context,
        listen: false,
      ).getFilterSubcategory(groupCategoryID: widget.groupCategoryModel.id);
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    SubPlaceViewModel subPlaceViewModel = Provider.of<SubPlaceViewModel>(
      context,
    );
    SubCategoryViewModle subCategoryViewModle =
        Provider.of<SubCategoryViewModle>(context);
    ProductModelViewModel productModelViewModel =
        Provider.of<ProductModelViewModel>(context);

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text(
          '${Translator.translate(widget.groupCategoryModel.keyTranslate)} ${Translator.translate(widget.groupPlaceModel.keyGroupPlaceTranslate)}',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
            color: AppColor.textAppBarColor,
            fontSize: 20,
          ),
        ),
        centerTitle: true,
        backgroundColor: AppColor.appBarColor,
      ),

      body: GestureDetector(
        onTap: () {
          FocusScope.of(context).unfocus();
        },
        child: Stack(
          children: [
            AbsorbPointer(
              absorbing: _isSubmitting, // 👈 disables all user actions
              child: Form(
                key: _formKey,
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _sectionTitle(
                        "${Translator.translate('basic_info')} (${Translator.translate(widget.groupCategoryModel.keyTranslate)})",
                      ),
                      helper.buildTextArea(
                        Translator.translate('description'),
                        _subTitleController,
                        maxLines: 3,
                      ),
                      const SizedBox(height: 10),
                      _sectionTitle(
                        Translator.translate(
                          widget.groupCategoryModel.keyTranslate,
                        ),
                      ),
                      // Sub Category
                      GestureDetector(
                        onTap: () => _openSubCategoryPicker(
                          subCategoryViewModel: subCategoryViewModle,
                        ),
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 18,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(14),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.05),
                                blurRadius: 8,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                selectedSubCategory ??
                                    "${Translator.translate('choose_sub_category')}...",
                                style: TextStyle(
                                  color: selectedSubCategory == null
                                      ? Colors.grey
                                      : Colors.black87,
                                  fontSize: 16,
                                ),
                              ),
                              const Icon(
                                Icons.keyboard_arrow_down_rounded,
                                color: Colors.grey,
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      SaleTypeToogleElement(
                        onTab: (json) {
                          saleType.value=json['title'];
                        },
                      ),

                      const SizedBox(height: 10),
                      _sectionTitle(Translator.translate('detail')),
                      ValueListenableBuilder(
                        valueListenable: saleType,
                        builder: (context, value, child) {
                          return saleType.value.toLowerCase() == 'rent'
                              ? _buildPriceWithBillingPeriod(_priceController)
                              : _buildTextField(
                                  "${Translator.translate('total_price')} (\$)",
                                  _priceController,
                                  keyboardType: TextInputType.numberWithOptions(),
                                );
                        }
                      ),
                      _buildTextField(
                        Translator.translate(Translator.translate('size')),
                        _sizeController,
                      ),
                      widget.groupCategoryModel.role == 'land'
                          ? SizedBox()
                          : Row(
                              children: [
                                Expanded(
                                  child: _buildTextField(
                                    Translator.translate('bedrooms'),
                                    _bedroomController,
                                    keyboardType: TextInputType.number,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: _buildTextField(
                                    Translator.translate('bathrooms'),
                                    _bathroomController,
                                    keyboardType: TextInputType.number,
                                  ),
                                ),
                              ],
                            ),
                      const SizedBox(height: 20),
                      ValueListenableBuilder(
                        valueListenable: selectedImages,
                        builder: (context, value, child) {
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _sectionTitle(
                                "${Translator.translate('images')}(${selectedImages.value.length}/10)",
                              ),
                              GestureDetector(
                                onTap: _pickImages,
                                child: Container(
                                  width: double.infinity,
                                  height: 150,
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(
                                      color: Colors.grey.shade300,
                                    ),
                                  ),
                                  child: selectedImages.value.isEmpty
                                      ? Center(
                                          child: Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              Icon(
                                                Icons.camera_alt_outlined,
                                                size: 36,
                                                color: Colors.grey,
                                              ),
                                              SizedBox(height: 8),
                                              Text(
                                                Translator.translate(
                                                  'tab_to_upload_images',
                                                ),
                                                style: TextStyle(
                                                  color: Colors.grey,
                                                ),
                                              ),
                                            ],
                                          ),
                                        )
                                      : ListView.separated(
                                          scrollDirection: Axis.horizontal,
                                          padding: const EdgeInsets.all(8),
                                          itemBuilder: (context, i) => Stack(
                                            children: [
                                              ClipRRect(
                                                borderRadius:
                                                    BorderRadius.circular(12),
                                                child: Image.file(
                                                  selectedImages.value[i],
                                                  width: 120,
                                                  height: 120,
                                                  fit: BoxFit.cover,
                                                ),
                                              ),
                                              Positioned(
                                                top: 4,
                                                right: 4,
                                                child: GestureDetector(
                                                  onTap: () {
                                                    selectedImages.value
                                                        .removeAt(i);
                                                    selectedImages
                                                        .notifyListeners();
                                                  },
                                                  child: Container(
                                                    decoration:
                                                        const BoxDecoration(
                                                          color: Colors.black54,
                                                          shape:
                                                              BoxShape.circle,
                                                        ),
                                                    child: const Icon(
                                                      Icons.close,
                                                      size: 20,
                                                      color: Colors.white,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                          separatorBuilder: (_, __) =>
                                              const SizedBox(width: 8),
                                          itemCount:
                                              selectedImages.value.length,
                                        ),
                                ),
                              ),
                            ],
                          );
                        },
                      ),

                      const SizedBox(height: 30),
                      ElevatedButton(
                        onPressed: () {
                          _submitForm(
                            productModelViewModel: productModelViewModel,
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColor.appBarColor,
                          minimumSize: const Size(double.infinity, 56),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: Text(
                          productModelViewModel.isLoading
                              ? '${Translator.translate('uploading')}...' //xxx
                              : Translator.translate('publish_property'),
                          style: GoogleFonts.poppins(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // 🌀 Overlay loading animation
            if (_isSubmitting)
              Container(
                color: Colors.black.withOpacity(0.4),
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CircularProgressIndicator(color: Colors.green),
                      SizedBox(height: 12),
                      Text(
                        "${Translator.translate('uploading_property')}...",
                        style: TextStyle(color: Colors.white, fontSize: 16),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
      floatingActionButton: GestureDetector(
        onTap: () {
          showGeneralDialog(
            context: context,
            barrierDismissible: true,
            barrierLabel: "Map Dialog",
            barrierColor: Colors.black54, // background dim
            transitionDuration: const Duration(milliseconds: 500),
            pageBuilder: (context, animation, secondaryAnimation) {
              return Center(
                child: Material(
                  color: Colors.transparent,
                  child: DialogMapSelecteLocationScreen(
                    defaultLat: lat,
                    defaultLon: lon,
                    selectedCalBack: (mapSelectedLatLong) {
                      lat = double.parse(mapSelectedLatLong['lat'].toString());
                      lon = double.parse(mapSelectedLatLong['lon'].toString());
                      if (lat == 0 && lon == 0) {
                        fullAddress = "";
                      } else {
                        fullAddress = mapSelectedLatLong['full_address']
                            .toString();
                      }
                    },
                  ),
                ),
              );
            },
            transitionBuilder: (context, animation, secondaryAnimation, child) {
              final curvedValue =
                  Curves.easeInOut.transform(animation.value) - 1.0;
              return Transform.translate(
                offset: Offset(0.0, curvedValue * -50), // slide from bottom
                child: Opacity(opacity: animation.value, child: child),
              );
            },
          );
        },
        child: Image.asset('assets/icons/remark_icon.png', width: 70),
      ),
    );
  }

  Widget _sectionTitle(String text) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 8),
    child: Text(
      text,
      style: GoogleFonts.poppins(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: Colors.black87,
      ),
    ),
  );

  Widget _buildPriceWithBillingPeriod(TextEditingController priceController) {
    return StatefulBuilder(
      builder: (context, setState) {
        Future<void> _showCustomInputDialog() async {
          customController.text = customValue ?? '';
          await showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            backgroundColor: Colors.transparent,
            builder: (context) {
              return Padding(
                padding: EdgeInsets.only(
                  bottom: MediaQuery.of(context).viewInsets.bottom,
                  left: 16,
                  right: 16,
                ),
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 10,
                        offset: const Offset(0, -2),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                        child: Container(
                          width: 40,
                          height: 4,
                          decoration: BoxDecoration(
                            color: Colors.grey.shade300,
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        Translator.translate('enter_custome_billing_period'),
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: customController,
                        autofocus: true,
                        decoration: InputDecoration(
                          hintText: Translator.translate('period'),
                          filled: true,
                          fillColor: Colors.grey.shade100,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide: BorderSide.none,
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 14,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () => Navigator.pop(context),
                              style: OutlinedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 14,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                              ),
                              child: Text(Translator.translate('cancel')),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () {
                                final entered = customController.text.trim();
                                if (entered.isNotEmpty) {
                                  setState(() {
                                    customValue = entered;
                                    _buillingPerioudController.text =
                                        customValue!.trim();
                                    if (!billingPeriods.contains(entered)) {
                                      billingPeriods.insert(
                                        billingPeriods.length - 1,
                                        entered,
                                      );
                                    }
                                    selectedPeriod = entered;
                                  });
                                  Navigator.pop(context);
                                }
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blueAccent,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 14,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                              ),
                              child: Text(
                                Translator.translate('save'),
                                style: TextStyle(color: Colors.white),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        }

        return Row(
          children: [
            Expanded(
              flex: 2,
              child: _buildTextField(
                "${Translator.translate('total_price')} (\$)",
                priceController,
                keyboardType: TextInputType.number,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              flex: 1,
              child: Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Container(
                  height: 50,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: Colors.grey.shade300),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.shade200,
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: selectedPeriod,
                      isExpanded: true,
                      icon: const Icon(Icons.keyboard_arrow_down_rounded),
                      style: const TextStyle(fontSize: 15),
                      dropdownColor: Colors.white,
                      onChanged: (newValue) async {
                        if (newValue == 'Custom') {
                          await _showCustomInputDialog();
                        } else {
                          setState(() {
                            selectedPeriod = newValue!;
                            _buillingPerioudController.text = selectedPeriod
                                .trim();
                          });
                        }
                      },
                      items: billingPeriods.map((period) {
                        return DropdownMenuItem<String>(
                          value: period,
                          child: Text(
                            period == 'Custom'
                                ? '${Translator.translate('custom')}...'
                                : Translator.translate(period.toLowerCase()),
                            style: const TextStyle(
                              fontWeight: FontWeight.w500,
                              color: Colors.black,
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildTextField(
    String label,

    TextEditingController controller, {

    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        maxLines: maxLines,

        validator: (value) => value == null || value.isEmpty
            ? '${Translator.translate('please_enter')} $label'
            : null,
        decoration: InputDecoration(
          labelText: label,
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 14,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }
}
