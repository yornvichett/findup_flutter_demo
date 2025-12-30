import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:findup_mvvm/Core/constants/app_color.dart';
import 'package:findup_mvvm/Core/constants/text_helper.dart';
import 'package:findup_mvvm/Core/services/helper.dart';
import 'package:findup_mvvm/Core/services/local_storage.dart';
import 'package:findup_mvvm/Core/services/translate.dart';
import 'package:findup_mvvm/Core/utils/cache_profile_image.dart';
import 'package:findup_mvvm/Core/utils/edit_cover_profile_dialog_element.dart';
import 'package:findup_mvvm/Core/utils/edit_profile_dialog_element.dart';
import 'package:findup_mvvm/Data/view_models/user_view_model.dart';
import 'package:flutter/material.dart';

class EditProfilePage extends StatefulWidget {
  final UserViewModel userViewModel;

  const EditProfilePage({super.key, required this.userViewModel});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  TextHelper textHelper = TextHelper();
  Helper helper = Helper();
  ValueNotifier<bool> isBioUpdating = ValueNotifier(false);

  late TextEditingController nameCtrl;
  late TextEditingController phoneCtrl;
  late TextEditingController telegramCtrl;
  late TextEditingController bioController;

  String selectProfilePath = '';
  String selectCoverPath = '';

  @override
  void initState() {
    super.initState();
    final user = widget.userViewModel.userModel!;
    nameCtrl = TextEditingController(text: user.name);
    phoneCtrl = TextEditingController(text: user.firstPhoneNumber);
    telegramCtrl = TextEditingController(text: user.telegram);
    bioController = TextEditingController(text: user.bioTitle);
  }

  @override
  void dispose() {
    nameCtrl.dispose();
    phoneCtrl.dispose();
    telegramCtrl.dispose();
    bioController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SingleChildScrollView(
          child: Column(
            children: [
              // ================= COVER + HEADER =================
              Stack(
                children: [
                  // COVER IMAGE
                  selectCoverPath.isEmpty
                      ? CachedNetworkImage(
                          width: size.width,
                          height: 250,
                          fit: BoxFit.cover,
                          imageUrl: widget.userViewModel.userModel!.coverImage,
                          placeholder: (_, __) => const SizedBox(
                            height: 250,
                            child: Center(child: CircularProgressIndicator()),
                          ),
                          errorWidget: (_, __, ___) => Container(
                            height: 250,
                            color: Colors.grey.shade200,
                            child: const Icon(Icons.image),
                          ),
                        )
                      : Container(
                          height: 250,
                          decoration: BoxDecoration(
                            image: DecorationImage(
                              image: FileImage(File(selectCoverPath)),
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),

                  // DARK OVERLAY
                  Container(height: 250, color: Colors.black26),

                  // 🔹 HEADER BUTTONS (FIXED)
                  Positioned(
                    top: 0,
                    left: 0,
                    right: 0,
                    child: SafeArea(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            circualrIcon(
                              onTab: () => Navigator.pop(context),
                              icon: Icons.arrow_back_ios_new_outlined,
                            ),
                            GestureDetector(
                              onTap: () {
                                showDialog(
                                  context: context,
                                  builder: (_) => EditCoverProfileDialogElement(
                                    onConfirm: (imagePath) async {
                                      final ok = await widget.userViewModel
                                          .uploadCoverProfile(
                                            imagePath: imagePath,
                                            username:
                                                LocalStorage.userModel!.name,
                                            userID: LocalStorage.userModel!.id,
                                          );
                                      if (ok) {
                                        setState(() {
                                          selectCoverPath = imagePath;
                                        });
                                      }
                                    },
                                  ),
                                );
                              },
                              child: Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: Colors.black.withOpacity(0.55),
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                child: const Icon(
                                  Icons.camera_alt_outlined,
                                  color: Colors.white,
                                  size: 20,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  // 🔹 AVATAR
                  Positioned(
                    bottom: 10,
                    left: 16,
                    child: Stack(
                      children: [
                        CircleAvatar(
                          radius: 52,
                          backgroundColor: Colors.white,
                          child: selectProfilePath.isEmpty
                              ? CacheProfileImage(
                                  userProfileImage: widget
                                      .userViewModel
                                      .userModel!
                                      .userProfile,
                                  radius: 48,
                                )
                              : CircleAvatar(
                                  radius: 48,
                                  backgroundImage: FileImage(
                                    File(selectProfilePath),
                                  ),
                                ),
                        ),
                        Positioned(
                          bottom: 2,
                          right: 2,
                          child: GestureDetector(
                            onTap: () {
                              showDialog(
                                context: context,
                                builder: (_) => EditProfileDialogElement(
                                  onConfirm: (imagePath) async {
                                    final ok = await widget.userViewModel
                                        .uploadImageProfile(
                                          imagePath: imagePath,
                                          username:
                                              LocalStorage.userModel!.name,
                                          userID: LocalStorage.userModel!.id,
                                        );
                                    if (ok) {
                                      setState(() {
                                        selectProfilePath = imagePath;
                                      });
                                    }
                                  },
                                ),
                              );
                            },
                            child: Container(
                              width: 34,
                              height: 34,
                              decoration: BoxDecoration(
                                color: AppColor.appBarColor,
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: Colors.white,
                                  width: 2,
                                ),
                              ),
                              child: const Icon(
                                Icons.camera_alt,
                                size: 18,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // ================= BIO =================
              Padding(
                padding: const EdgeInsets.all(12),
                child: Stack(
                  children: [
                    TextFormField(
                      controller: bioController,
                      keyboardType: TextInputType.multiline,
                      maxLines: 4,

                      decoration: InputDecoration(
                        enabledBorder:OutlineInputBorder(
                          borderSide: BorderSide(color: const Color.fromARGB(105, 158, 158, 158)),
                        ),
                        disabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: const Color.fromARGB(105, 158, 158, 158)),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.blueAccent),
                        ),
                        labelText: Translator.translate('your_bio'),
                        labelStyle: TextStyle(
                          color: const Color.fromARGB(94, 0, 0, 0),
                        ),
                        filled: true,
                        fillColor: Colors.white,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 14,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(2),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: 10,
                      right: 10,
                      child: GestureDetector(
                        onTap: () async {
                          isBioUpdating.value = true;
                          await widget.userViewModel
                              .updateBioUser(
                                userID: widget.userViewModel.userModel!.id,
                                userBio: bioController.text.trim(),
                              )
                              .whenComplete(() {
                                isBioUpdating.value = false;
                              });
                        },
                        child: ValueListenableBuilder(
                          valueListenable: isBioUpdating,
                          builder: (context, value, child) {
                            return Container(
                              width: 80,
                              height: 30,
                              decoration: BoxDecoration(
                                color: Colors.blueAccent,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Center(
                                child: isBioUpdating.value
                                    ? SizedBox(
                                        width: 16,
                                        height: 16,
                                        child: Center(
                                          child: CircularProgressIndicator(color: Colors.white,strokeWidth: 1,),
                                        ),
                                      )
                                    : Icon(
                                        Icons.check,
                                        color: Colors.white,
                                        size: 16,
                                      ),
                              ),
                            );
                          }
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget circualrIcon({required Function() onTab, required IconData icon}) {
    return GestureDetector(
      onTap: onTab,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: const Color.fromARGB(184, 255, 255, 255),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Icon(icon, size: 18),
      ),
    );
  }
}
