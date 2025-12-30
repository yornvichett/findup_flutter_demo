import 'package:findup_mvvm/Core/constants/app_color.dart';
import 'package:findup_mvvm/Core/constants/text_helper.dart';
import 'package:findup_mvvm/Core/services/helper.dart';
import 'package:findup_mvvm/Core/services/local_storage.dart';
import 'package:findup_mvvm/Core/services/notification_service.dart';
import 'package:findup_mvvm/Core/services/telegram_bot.dart';
import 'package:findup_mvvm/Core/services/translate.dart';
import 'package:findup_mvvm/Core/utils/Loading/your_boost_shimmer.dart';
import 'package:findup_mvvm/Core/utils/boost_card_item_elements.dart';
import 'package:findup_mvvm/Core/utils/pop_up_boost_payment_item_history.dart';
import 'package:findup_mvvm/Data/models/user_model.dart';
import 'package:findup_mvvm/Data/view_models/product_model_view_model.dart';
import 'package:findup_mvvm/Data/view_models/user_view_model.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class YourBoostPage extends StatefulWidget {
  UserViewModel userViewModel;
  YourBoostPage({super.key, required this.userViewModel});

  @override
  State<YourBoostPage> createState() => _YourBoostPageState();
}

class _YourBoostPageState extends State<YourBoostPage> {
  final TextHelper textHelper = TextHelper();
  Helper helper = Helper();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (LocalStorage.userModel != null) {
        context.read<ProductModelViewModel>().getAllBoostPending(
          userID: LocalStorage.userModel!.id,
        );
      } else {
        // productModelViewModel.listUserGetAllBoostPending = [];
      }
    });
  }

  NotificationService notificationService = NotificationService();
  TelegramBot telegramBot = TelegramBot();

  Future<void> pushDataAlertToAdmin({required int productID}) async {
    try {
      telegramBot.sendMessageToTelegram(
        '''📱✅USER VERIFY PAYMENT (${helper.getFormattedDateTime()})
                          User Info : ${widget.userViewModel.userModel!.name} (${widget.userViewModel.userModel!.id})
                          Product ID: ${productID}
                          =========================
                          Status    : Verify Payment''',
      );
      await notificationService.sentNotification(
        fcmToken: widget.userViewModel.userAdmin!.fcmToken,
        title: "Check Out",
        body: "User payment",
      );
      Navigator.pop(context);
    } catch (e) {

    }
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    ProductModelViewModel productModelViewModel =
        Provider.of<ProductModelViewModel>(context);
    return Scaffold(
      backgroundColor: const Color(0xFFF4F5F7),

      appBar: AppBar(
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
        backgroundColor: AppColor.appBarColor,
        title: Text(
          Translator.translate('your_boost'),
          style: textHelper.textAppBarStyle(),
        ),
      ),

      body: Column(
        children: [
          /// TOP SUMMARY CARD
          Padding(
            padding: const EdgeInsets.all(14),
            child: Container(
              width: size.width,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFFFF7A00), Color(0xFFFFB800)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(22),
                boxShadow: [
                  BoxShadow(
                    color: Colors.orange.withOpacity(0.3),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  /// ICON
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.25),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Icon(
                      Icons.campaign,
                      color: Colors.white,
                      size: 32,
                    ),
                  ),

                  const SizedBox(width: 16),

                  /// TEXT
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Request Advertisement",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "Boost your property for more visibility",
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.9),
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          /// BOOST LIST
          productModelViewModel.isLoading
              ? SizedBox()
              : Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.only(bottom: 20),
                    itemCount:
                        productModelViewModel.listUserGetAllBoostPending.length,
                    itemBuilder: (context, index) {
                      return BoostCardItemElements(
                        onViewPayment: (product) {
                          String iamgeUrl = helper.getSingleImage(
                            imgName: product.boostImageVerify,
                            path: 'boostVerify',
                            context: context
                          );

                          showDialog(
                            context: context,
                            builder: (context) => PopUpBoostPaymentItemHistory(
                              imageUrl: iamgeUrl,
                              boostDay: product.boostPendingDay,
                              total: product.boostPendingTotal,

                              //totalPoint: totalPoint,
                            ),
                          );
                        },
                        onVerifyPayment: (productID) {
                          helper.showVerifyPaymentSheet(
                            context,
                            onConfirmVerify:
                                ({required message, required pathImage}) async {
                                  bool isUploaded = await productModelViewModel
                                      .uploadBoostPayment(
                                        productID: productID,
                                        message: message,
                                        imagePah: pathImage,
                                        userID: LocalStorage.userModel!.id,
                                        userName: LocalStorage.userModel!.name,
                                      );

                                  if (isUploaded) {
                        

                                    // Notify admin
                                    pushDataAlertToAdmin(productID: productID);

                                    // Show success screen
                                    helper.showSuccessScreen(
                                      context: context,
                                      title: 'verify_completed',
                                      subTitle: 'we_need_verify_your_payment',
                                    );
                                  }
                                },
                          );
                        },

                        removeCallBack: (productId) async {
                          await productModelViewModel.removeBoostPending(
                            productID: productId,
                            userID: LocalStorage.userModel!.id,
                          );
                        },
                        productModel: productModelViewModel
                            .listUserGetAllBoostPending[index],
                      );
                    },
                  ),
                ),
        ],
      ),
    );
  }
}
