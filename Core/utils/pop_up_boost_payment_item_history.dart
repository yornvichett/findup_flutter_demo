import 'dart:ui';
import 'dart:io';
import 'dart:typed_data';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:dio/dio.dart';
import 'package:findup_mvvm/Core/services/helper.dart';
import 'package:flutter/material.dart';
import 'package:gallery_saver_plus/gallery_saver.dart';        // ✔ CORRECT IMPORT
import 'package:flutter/services.dart';
import 'package:findup_mvvm/Core/services/translate.dart';
import 'package:permission_handler/permission_handler.dart';

class PopUpBoostPaymentItemHistory extends StatefulWidget {
  String imageUrl;
  int boostDay;
  double total;

  PopUpBoostPaymentItemHistory({
    super.key,
    required this.imageUrl,
    required this.boostDay,
    required this.total,
  });

  @override
  State<PopUpBoostPaymentItemHistory> createState() =>
      _PopUpBoostPaymentItemHistoryState();
}

class _PopUpBoostPaymentItemHistoryState
    extends State<PopUpBoostPaymentItemHistory> {
  int selectedDay = 1;
  Helper helper = Helper();

  final Map<int, double> prices = {
    1: 0.50,
    2: 1.00,
    3: 1.50,
    4: 2.00,
    5: 2.50,
    6: 3.00,
    7: 3.50,
  };

  ValueNotifier<int> totalBoostDay = ValueNotifier(0);

  // ---------------------------------------------------------------------------
  // ✔ FIXED SAVE IMAGE USING gallery_saver_plus
  // ---------------------------------------------------------------------------
  Future<void> saveImageFromUrl(String imageUrl) async {
    var status = await Permission.storage.request();
    if (!status.isGranted) {
      helper.showSnackBar(
        context: context,
        title: Translator.translate("permission_denied"),
      );
      return;
    }

    try {
      // Download image as bytes
      var response = await Dio().get(
        imageUrl,
        options: Options(responseType: ResponseType.bytes),
      );

      Uint8List imageBytes = Uint8List.fromList(response.data);

      // Create temp file
      final tempDir = Directory.systemTemp;
      final filePath =
          "${tempDir.path}/download_${DateTime.now().millisecondsSinceEpoch}.png";

      File file = File(filePath);
      await file.writeAsBytes(imageBytes);

      // Save to gallery using GallerySaver (correct class)
      await GallerySaver.saveImage(filePath);

      helper.showSnackBar(
        context: context,
        title: Translator.translate("save_image_success"),
      );
    } catch (e) {
    }
  }

  @override
  void initState() {
    totalBoostDay = ValueNotifier(widget.boostDay);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
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
                      Translator.translate('your_upload'),
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
                        imageUrl: widget.imageUrl,
                        width: 180,
                        height: 180,
                        fit: BoxFit.cover,
                        placeholder: (context, url) => Container(
                          width: 180,
                          height: 180,
                          color: Colors.grey.shade300,
                          child: const Center(
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                        ),
                        errorWidget: (context, url, error) => Container(
                          width: 180,
                          height: 180,
                          color: Colors.grey.shade300,
                          child: const Icon(Icons.broken_image),
                        ),
                      ),

                      const SizedBox(height: 12),

                      ElevatedButton.icon(
                        onPressed: () async {
                          await saveImageFromUrl(widget.imageUrl);
                        },
                        icon: const Icon(Icons.download, color: Colors.black),
                        label: Text(
                          Translator.translate('save'),
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
                    "${Translator.translate('boost_plan')}:",
                    style: const TextStyle(color: Colors.white70, fontSize: 14),
                  ),
                ),

                const SizedBox(height: 10),

                ValueListenableBuilder(
                  valueListenable: totalBoostDay,
                  builder: (context, value, child) {
                    return Wrap(
                      spacing: 10,
                      children: List.generate(7, (index) {
                        return ChoiceChip(
                          selected: (index + 1) == totalBoostDay.value,
                          label: Text(
                            "${index + 1} ${Translator.translate('day${index + 1 > 1 ? 's' : ''}')} ",
                          ),
                          labelStyle:
                              const TextStyle(color: Colors.black),
                          selectedColor: Colors.amber.shade800,
                          backgroundColor:
                              const Color.fromARGB(186, 52, 74, 88),
                          onSelected: (_) {},
                        );
                      }),
                    );
                  },
                ),

                const SizedBox(height: 20),

                Text(
                  "${Translator.translate('price')}: \$${widget.total.toStringAsFixed(2)}",
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
                    ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.amber.shade800,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 24, vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: Text(
                        Translator.translate('back'),
                        style: const TextStyle(
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
