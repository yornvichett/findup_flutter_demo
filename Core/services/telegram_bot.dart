import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';

class TelegramBot {
  String baseToken = "8228220652:AAF2t-doz5xVGU2A7LW293M_Avn0Rqzk3uE";
  String chatID = "5402453268";
  // String botSentURL=" https://api.telegram.org/bot$baseToken/sendMessage?chat_id=$chatID&text='Hello world'";

  Future<void> contactViaTelegram({required String telegramUrl}) async {
    final Uri url = Uri.parse(telegramUrl);

    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } else {
      debugPrint("Cannot open Telegram");
    }
  }

  Future<void> sendMessageToTelegram(String message) async {
    final String url = 'https://api.telegram.org/bot$baseToken/sendMessage';

    final response = await http.post(
      Uri.parse(url),
      body: {'chat_id': chatID, 'text': message},
    );
  }

  void loginWithTelegram() async {
    final botUsername = "findup_post_bot"; // example: MyFindUPBot
    final url = "https://t.me/$botUsername?start=login";

    await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
  }
}
