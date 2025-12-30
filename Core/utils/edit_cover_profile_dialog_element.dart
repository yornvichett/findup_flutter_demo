import 'dart:ui';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:findup_mvvm/Core/services/translate.dart';

class EditCoverProfileDialogElement extends StatefulWidget {
  final Function(String imagePath) onConfirm;

  const EditCoverProfileDialogElement({
    super.key,
    required this.onConfirm,
  });

  @override
  State<EditCoverProfileDialogElement> createState() =>
      _EditCoverProfileDialogElementState();
}

class _EditCoverProfileDialogElementState
    extends State<EditCoverProfileDialogElement> {
  String? selectedImagePath;

  Future<void> _pickImage(ImageSource source) async {
    final picker = ImagePicker();
    final XFile? image = await picker.pickImage(
      source: source,
      imageQuality: 80,
    );

    if (image != null) {
      setState(() => selectedImagePath = image.path);
    }
  }

  @override
  Widget build(BuildContext context) {
    Size size=MediaQuery.of(context).size;
    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 28),
      backgroundColor: Colors.transparent,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(22),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF1E1E2C), Color(0xFF2A2A3D)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(22),
              border: Border.all(color: Colors.amber, width: 1.2),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.45),
                  blurRadius: 30,
                  offset: Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Title
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.person_pin_circle_rounded,
                        color: Colors.amber.shade700, size: 30),
                    const SizedBox(width: 8),
                    Text(
                      Translator.translate("upload_cover"),
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    )
                  ],
                ),

                const SizedBox(height: 20),

                // IMAGE PREVIEW
                selectedImagePath != null? Container(
                  width: size.width,
                  height: 100,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: Colors.white.withOpacity(0.08),
                    image: DecorationImage(image: FileImage(File(selectedImagePath!)),fit: BoxFit.cover)
                  ),
                ):Container(
                  width: size.width,
                  height: 100,
                  
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: selectedImagePath == null
                      ? Icon(Icons.image,
                          size: 25, color: Colors.white.withOpacity(0.30))
                      : null,
                ),
               
                // CircleAvatar(
                //   radius: 10,
                //   backgroundColor: Colors.white.withOpacity(0.08),
                //   backgroundImage: selectedImagePath != null
                //       ? FileImage(File(selectedImagePath!))
                //       : null,
                //   child: selectedImagePath == null
                //       ? Icon(Icons.person,
                //           size: 65, color: Colors.white.withOpacity(0.30))
                //       : null,
                // ),

                const SizedBox(height: 25),

                // PICK OPTIONS
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Camera
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () => _pickImage(ImageSource.camera),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.amber.shade700,
                          padding: const EdgeInsets.symmetric(vertical: 13),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.photo_camera, color: Colors.black87),
                            SizedBox(width: 6),
                            Text(Translator.translate('camera'),
                                style: TextStyle(color: Colors.black87)),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(width: 12),

                    // Gallery
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () => _pickImage(ImageSource.gallery),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white.withOpacity(0.10),
                          padding: const EdgeInsets.symmetric(vertical: 13),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          side: BorderSide(
                            color: Colors.white.withOpacity(0.25),
                          ),
                        ),
                        child:  Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.photo_library, color: Colors.white70),
                            SizedBox(width: 6),
                            Text(Translator.translate('gallery'),
                                style: TextStyle(color: Colors.white70)),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                // CONFIRM + CANCEL BUTTONS
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    // Cancel
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text(
                        Translator.translate("cancel"),
                        style: const TextStyle(
                          color: Colors.white54,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),

                    const SizedBox(width: 12),

                    // Confirm
                    ElevatedButton(
                      onPressed: selectedImagePath == null
                          ? null
                          : () {
                              widget.onConfirm(selectedImagePath!);
                              Navigator.pop(context);
                            },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.amber.shade700,
                        disabledBackgroundColor: Colors.grey.shade700,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 26, vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child:  Text(
                        Translator.translate('confirm'),
                        style: TextStyle(
                          color: Colors.black87,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
