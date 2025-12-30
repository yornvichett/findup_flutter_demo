import 'dart:convert';
import 'dart:io';

import 'package:findup_mvvm/Core/constants/app_color.dart';
import 'package:findup_mvvm/Core/navigation/navigation.dart';
import 'package:findup_mvvm/Core/services/editable_image.dart';
import 'package:findup_mvvm/Core/services/helper.dart';
import 'package:findup_mvvm/Core/services/local_storage.dart';
import 'package:findup_mvvm/Core/services/notification_service.dart';
import 'package:findup_mvvm/Core/services/telegram_bot.dart';
import 'package:findup_mvvm/Core/services/translate.dart';
import 'package:findup_mvvm/Core/utils/dialog_pop_up_elements.dart';
import 'package:findup_mvvm/Core/utils/sub_category_picker_sheet_element.dart';
import 'package:findup_mvvm/Core/utils/Loading/simmer_row_image_element.dart';
import 'package:findup_mvvm/Data/models/group_category_model.dart';
import 'package:findup_mvvm/Data/models/group_place_model.dart';
import 'package:findup_mvvm/Data/models/product_model.dart';
import 'package:findup_mvvm/Data/models/sub_category_model.dart';
import 'package:findup_mvvm/Data/models/sub_place_model.dart';
import 'package:findup_mvvm/Data/view_models/product_model_view_model.dart';
import 'package:findup_mvvm/Data/view_models/sub_place_view_model.dart';
import 'package:findup_mvvm/Data/view_models/user_view_model.dart';
import 'package:findup_mvvm/Pages/Screen/dialog_map_selecte_location_screen.dart';
import 'package:findup_mvvm/Pages/_Profile/profile_page.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

class EditPage extends StatefulWidget {
  UserViewModel userViewModel;
  ProductModel productDefaultParam;
  EditPage({
    super.key,
    required this.productDefaultParam,
    required this.userViewModel,
  });

  @override
  State<EditPage> createState() => _EditPageState();
}

class _EditPageState extends State<EditPage> {
  final _formKey = GlobalKey<FormState>();
  final picker = ImagePicker();
  bool isFirsLoad = true;
   String roleAssets ="";

  // Controllers
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _subTitleController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _sizeController = TextEditingController();
  final TextEditingController _bedroomController = TextEditingController();
  final TextEditingController _bathroomController = TextEditingController();
  final TextEditingController _buillingPerioudController =
      TextEditingController(text: 'month');
  List<String> defaultImage = [];
  Helper helper = Helper();
  ValueNotifier<List<File>> selectedImages = ValueNotifier([]);
  List<String> billingPeriods = ['month', 'year', 'week', 'Custom'];
  TelegramBot telegramBot = TelegramBot();
  NotificationService notificationService = NotificationService();
  double lat = 0.00;
  double lon = 0.00;
   String fullAddress="";

  bool _isSubmitting = false; // 👈 add this

  Future<void> _loadImages() async {
    final urls = helper.productModelSplitImage(
      product: widget.productDefaultParam,
      path: 'property',
      context: context,
    );

    // Convert network images to File asynchronously
    selectedImages.value = await helper.convertNetworkImagesToFiles(urls);
    selectedImages.notifyListeners();
  }

  Future<void> _pickImages() async {
    isFirsLoad = false;
    final pickedFiles = await picker.pickMultiImage(
      imageQuality: 50,
      maxWidth: 800,
      maxHeight: 800,
    );

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

  void _clearForm() {
    // setState(() {
    //   _titleController.clear();
    //   _subTitleController.clear();
    //   _priceController.clear();
    //   _sizeController.clear();
    //   _bedroomController.clear();
    //   _bathroomController.clear();
    //   lat=0;
    //   lon=0;
    //   selectedImages.value.clear();
  
    
    // });

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => DialogPopUpElements(
        icon: Icons.av_timer,
        message:
            '${Translator.translate('your_post_has_been_submitted')}.\n ${Translator.translate('it_is_waiting_for_approval_before_it_becomes_visible_to_others')}.',
        onProcess: () async {},
      ),
    );
    Future.delayed(const Duration(seconds: 5));
    Navigator.pop(context);
   // Navigation.goReplacePage(context: context, page: ProfilePage());
  }

  void _editSubmit({
    required ProductModelViewModel productModelViewModel,
  }) async {
    if (_formKey.currentState!.validate()) {
      if(fullAddress.isEmpty){
        helper.showSnackBar(context: context, title: "Please selected location");
        return;
      }
      final Map<String, dynamic> jsonBody = {
        'user_id': LocalStorage.userModel?.id,
        'user_name': LocalStorage.userModel?.name,
        'product_id': widget.productDefaultParam.id,
        'title': _titleController.text.trim(),
        'sub_title': _subTitleController.text.trim(),
        'base_price': double.parse(_priceController.text.trim()),
        'billing_period':
            widget.productDefaultParam.saleType.toLowerCase() == 'rent'
            ? '/${_buillingPerioudController.text.trim()}'
            : '',
        'size': _sizeController.text.trim(),
        'bed_count': int.parse(_bedroomController.text.trim()),
        'bath_count': int.parse(_bathroomController.text.trim()),
        'location_detail': fullAddress,
      };
   
      FocusScope.of(context).unfocus();
      setState(() => _isSubmitting = true); // ⛔ disable all UI
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

      // You can upload even if no new files (since old ones exist)
      final success = await productModelViewModel.editProduct(
        jsonBody: jsonBody,
        userID: LocalStorage.userModel!.id,
        images: selectedImages.value,
        oldFileName: widget.productDefaultParam.imageList,
        context: context,
      );

      if (mounted) setState(() => _isSubmitting = false);

      if (success) {
        helper.showSuccessScreen(
          context: context,
          title: Translator.translate('edit_success'),
        );

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

  @override
  void initState() {
    super.initState();
     _loadImages();
    roleAssets = widget.productDefaultParam.groupCategoryRole;
    lat=widget.productDefaultParam.lat;
    lon=widget.productDefaultParam.lon;
    fullAddress=widget.productDefaultParam.fullAddress;
    _titleController.text = widget.productDefaultParam.title;
    _subTitleController.text = widget.productDefaultParam.subTitle;
    _priceController.text = widget.productDefaultParam.basePrice.toString();
    _sizeController.text = widget.productDefaultParam.size;
    _bedroomController.text = widget.productDefaultParam.bedCount.toString();
    _bathroomController.text = widget.productDefaultParam.bathCount.toString();
    _buillingPerioudController.text = widget.productDefaultParam.billingPeriod
        .toString()
        .replaceFirst('/', '');
    if (!billingPeriods.contains(_buillingPerioudController.text)) {
      billingPeriods.add(_buillingPerioudController.text);
    }
    defaultImage = helper.productModelSplitImage(
      product: widget.productDefaultParam,
      path: 'property',
      context: context,
    );
   
  }

  @override
  Widget build(BuildContext context) {
    
    ProductModelViewModel productModelViewModel =
        Provider.of<ProductModelViewModel>(context);
    Size size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text(
          Translator.translate('edit'),
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
                        "${Translator.translate('basic_info')} (${Translator.translate(widget.productDefaultParam.saleType.toLowerCase())})",
                      ),
                      helper.buildTextArea(
                        Translator.translate('description'),
                        _subTitleController,
                        maxLines: 3,
                      ),

                      const SizedBox(height: 10),
                      _sectionTitle(Translator.translate('detail')),
                      widget.productDefaultParam.saleType.toLowerCase() ==
                              'rent'
                          ? _buildPriceWithBillingPeriod(
                              _priceController,
                              selectedPeriod: _buillingPerioudController.text,
                            )
                          : _buildTextField(
                              "${Translator.translate('total_price')} (\$)",
                              _priceController,
                              keyboardType: TextInputType.numberWithOptions(),
                            ),
                      _buildTextField(
                        Translator.translate('size'),
                        _sizeController,
                      ),
                      roleAssets == 'land'
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
                                "${Translator.translate('images')} (${selectedImages.value.length}/10)",
                              ),
                              GestureDetector(
                                onTap: _pickImages,
                                child:
                                    selectedImages.value.isEmpty && isFirsLoad
                                    ? SimmerRowImageElement(size: size)
                                    : selectedImages.value.isEmpty
                                    ? SizedBox()
                                    : SizedBox(
                                        height: 150,
                                        child: ListView.separated(
                                          scrollDirection: Axis.horizontal,
                                          itemCount:
                                              selectedImages.value.isEmpty
                                              ? 0
                                              : selectedImages.value.length,
                                          separatorBuilder: (_, __) =>
                                              const SizedBox(width: 8),
                                          itemBuilder: (context, i) {
                                            final img = selectedImages.value[i];
                                            return Stack(
                                              children: [
                                                ClipRRect(
                                                  borderRadius:
                                                      BorderRadius.circular(12),
                                                  child: Image.file(
                                                    img,
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
                                                      isFirsLoad = false;
                                                      selectedImages.value
                                                          .removeAt(
                                                            i,
                                                          ); // delete image
                                                      selectedImages
                                                          .notifyListeners();
                                                    },
                                                    child: Container(
                                                      decoration:
                                                          const BoxDecoration(
                                                            color:
                                                                Colors.black54,
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
                                            );
                                          },
                                        ),
                                      ),
                              ),
                            ],
                          );
                        },
                      ),

                      const SizedBox(height: 30),
                      ElevatedButton(
                        onPressed: isFirsLoad == false
                            ? () {}
                            : () {
                                _editSubmit(
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
                              ? '${Translator.translate('uploading')}...'
                              : Translator.translate('edit_property'),
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

  Widget _buildPriceWithBillingPeriod(
    TextEditingController priceController, {
    String selectedPeriod = 'month',
  }) {
    String? customValue;

    return StatefulBuilder(
      builder: (context, setState) {
        Future<void> _showCustomInputDialog() async {
          final TextEditingController customController = TextEditingController(
            text: customValue ?? '',
          );
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
                                : Translator.translate(period),
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
