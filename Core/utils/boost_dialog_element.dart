import 'dart:ui';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:dio/dio.dart';
import 'package:findup_mvvm/Core/services/helper.dart';
import 'package:findup_mvvm/Data/view_models/app_config_view_model.dart';
import 'package:flutter/material.dart';
import 'package:gallery_saver_plus/gallery_saver.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:findup_mvvm/Core/services/translate.dart';
import 'package:provider/provider.dart';

class BoostDialogElement extends StatefulWidget {
  final Function(Map<String, dynamic> jsonCallBack) onCallBackAction;
  BoostDialogElement({super.key, required this.onCallBackAction});

  @override
  State<BoostDialogElement> createState() => _BoostDialogElementState();
}

class _BoostDialogElementState extends State<BoostDialogElement> {
  int selectedDay = 1;

  final Map<int, double> prices = {
    1: 0.50,
    2: 1.00,
    3: 1.50,
    4: 2.00,
    5: 2.50,
    6: 3.00,
    7: 3.50,
  };

  Helper helper = Helper();

  String imageUrl =
      "";

  // ---------------------------------------------------------------------------
  // SAVE IMAGE USING GALLERY_SAVER_PLUS (correct for version 3.2.9)
  // ---------------------------------------------------------------------------
  Future<void> saveImageFromUrl(String url) async {
    var status = await Permission.storage.request();
    if (!status.isGranted) {
      helper.showSnackBar(
        context: context,
        title: Translator.translate("permission_denied"),
      );
      return;
    }

    try {
      // Download image
      var response = await Dio().get(
        url,
        options: Options(responseType: ResponseType.bytes),
      );

      // Create temp file
      final dir = await getTemporaryDirectory();
      final filePath =
          "${dir.path}/qr_${DateTime.now().millisecondsSinceEpoch}.png";

      File file = File(filePath);
      await file.writeAsBytes(response.data);

      // Save to gallery (correct for this plugin version)
      await GallerySaver.saveImage(filePath);

      helper.showSnackBar(
        context: context,
        title: Translator.translate("save_image_success"),
      );
    } catch (e) {

    }
  }

  void _checkout() {
    widget.onCallBackAction({
      "days": selectedDay,
      "price": prices[selectedDay]!,
    });
  }

  @override
  Widget build(BuildContext context) {
    AppConfigViewModel appConfigViewModel=Provider.of<AppConfigViewModel>(context,listen: false);
    imageUrl='${appConfigViewModel.listAppConfigModel.first.baseAPIUrl}/storage/upload/images/qr/aba_qr.png';
    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 24),
      backgroundColor: Colors.transparent,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(22),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF1E1E2C), Color(0xFF2A2A3D)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(22),
              border: Border.all(color: Colors.amber.shade800),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.4),
                  blurRadius: 25,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            padding: const EdgeInsets.all(22),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.bolt_rounded,
                        color: Colors.amber.shade800, size: 28),
                    const SizedBox(width: 8),
                    Text(
                      Translator.translate('boost_your_post'),
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                // QR BOX
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.white.withOpacity(0.15)),
                  ),
                  child: Column(
                    children: [
                      CachedNetworkImage(
                        imageUrl: imageUrl,
                        width: 180,
                        height: 180,
                        fit: BoxFit.cover,
                        placeholder: (c, url) => Container(
                          width: 180,
                          height: 180,
                          child: const Center(
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                        ),
                        errorWidget: (c, url, err) => const Icon(
                          Icons.broken_image,
                          color: Colors.grey,
                        ),
                      ),
                      const SizedBox(height: 8),

                      const Text(
                        "YORN VICHET",
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                      ),

                      const SizedBox(height: 12),

                      ElevatedButton.icon(
                        onPressed: () async {
                          await saveImageFromUrl(imageUrl);
                        },
                        icon: const Icon(Icons.download, color: Colors.black),
                        label: Text(
                          Translator.translate("save"),
                          style: const TextStyle(color: Colors.black),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.amber.shade800,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    Translator.translate("boost_plan"),
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                    ),
                  ),
                ),

                const SizedBox(height: 10),

                Wrap(
                  spacing: 10,
                  children: List.generate(7, (index) {
                    final day = index + 1;
                    return ChoiceChip(
                      selected: selectedDay == day,
                      label: Text("$day Day${day > 1 ? "s" : ""}"),
                      labelStyle: const TextStyle(color: Colors.black),
                      selectedColor: Colors.amber.shade800,
                      backgroundColor: const Color.fromARGB(186, 52, 74, 88),
                      onSelected: (_) => setState(() => selectedDay = day),
                    );
                  }),
                ),

                const SizedBox(height: 20),

                Text(
                  "${Translator.translate("price")}: \$${prices[selectedDay]!.toStringAsFixed(2)}",
                  style: TextStyle(
                    color: Colors.amber.shade800,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 25),

                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
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
                    ElevatedButton(
                      onPressed: _checkout,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.amber.shade800,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 24, vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: const Text(
                        "Checkout",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
