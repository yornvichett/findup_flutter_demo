import 'dart:async';
import 'package:findup_mvvm/Core/Storage/pref_storage.dart';
import 'package:findup_mvvm/Core/constants/app_color.dart';
import 'package:findup_mvvm/Core/constants/text_helper.dart';
import 'package:findup_mvvm/Core/navigation/navigation.dart';
import 'package:findup_mvvm/Core/services/translate.dart';
import 'package:findup_mvvm/Data/view_models/user_view_model.dart';
import 'package:findup_mvvm/Pages/_Auth/phone_number.dart';
import 'package:findup_mvvm/Pages/splash_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:pinput/pinput.dart';
import 'package:provider/provider.dart';

class PhoneOtpVerifyPage extends StatefulWidget {
  String fullPhoneNumber;
  String verificationId;
  PhoneOtpVerifyPage({
    super.key,
    required this.fullPhoneNumber,
    required this.verificationId,
  });

  @override
  _PhoneOtpVerifyPageState createState() => _PhoneOtpVerifyPageState();
}

class _PhoneOtpVerifyPageState extends State<PhoneOtpVerifyPage> {
  PrefStorage prefStorage = PrefStorage();
  String otpCode = "";
  int _seconds = 60;
  Timer? _timer;
   ValueNotifier<bool> isVerify = ValueNotifier(false);

  @override
  void initState() {
    super.initState();
    startTimer();
  }

  void startTimer() {
    _seconds = 60;
    _timer?.cancel();
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (_seconds > 0) {
        setState(() => _seconds--);
      } else {
        timer.cancel();
      }
    });
  }

  Future<UserCredential?> verifyOtp({
    required String verificationId,
    required String smsCode,
  }) async {
    try {
      isVerify.value=true;
      final credential = PhoneAuthProvider.credential(
        verificationId: verificationId,
        smsCode: smsCode,
      );

      final userCredential = await FirebaseAuth.instance.signInWithCredential(
        credential,
      );
  
      return userCredential;
    } on FirebaseAuthException catch (e) {

      return null;
    }
  }

  void registeruser({
    required UserViewModel userViewModel,
    required String userName,
    required String phoneNumber,
    required String password,
    required BuildContext context,
  }) async {
    String fcmTokenKey = await prefStorage.getFCMToken();
    userViewModel.userModel = await userViewModel.continueWithUserInfo(
      phoneNumber: phoneNumber,
      name: userName,
      email: 'none',
      userProfile: '',
      password: password,
      confirmPassword: password,
      fcmToken: fcmTokenKey,
      context: context,
    );
  }
  TextHelper textHelper=TextHelper();
  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final userViewModel = Provider.of<UserViewModel>(context);
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        centerTitle: true,
        iconTheme: IconThemeData(color: Colors.white),
        backgroundColor: AppColor.appBarColor,
        title: Text(Translator.translate('verify_code'),style: textHelper.textAppBarStyle(),),
        
        elevation: 0,
        foregroundColor: Colors.black,
      ),

      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 30),

            Text(
              Translator.translate('enter_verification_code'),
              style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
            ),

            SizedBox(height: 10),

            Text(
              Translator.translate('we_have_sent_a_6_digit_code_to'),
              style: TextStyle(color: Colors.black54),
            ),

            SizedBox(height: 4),

            Text(
              widget.fullPhoneNumber,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),

            SizedBox(height: 30),

            // OTP PIN INPUT
            Center(
              child: Pinput(
                length: 6,
                onChanged: (value) {
                  otpCode = value;
                },
                focusedPinTheme: PinTheme(
                  width: 55,
                  height: 55,
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                defaultPinTheme: PinTheme(
                  width: 55,
                  height: 55,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),

            SizedBox(height: 20),

            // TIMER + RESEND
            Center(
              child: _seconds > 0
                  ? Text(
                      "${Translator.translate('resend_code_in')} $_seconds s",
                      style: TextStyle(color: Colors.black54),
                    )
                  : TextButton(
                      onPressed: () {
                        // // Resend OTP API CALL here
                        // startTimer();
                        Navigation.goReplacePage(context: context, page: PhoneNumber());
                      },
                      child: Text(Translator.translate('try_again')),
                    ),
            ),

            SizedBox(height: 30),

            // VERIFY BUTTON
            ValueListenableBuilder(
              valueListenable: isVerify,
              builder: (context, value, child) {
                return SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: 16),
                      backgroundColor: Colors.blueAccent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: () async {
                      if (otpCode.length != 6) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(Translator.translate('please_enter_6_degit_code'))),
                        );
                        return;
                      }
                      await verifyOtp(
                        verificationId: widget.verificationId,
                        smsCode: otpCode,
                      ).then((value) async {
                     
                        if (value?.user != null) {
                
                          registeruser(
                            context: context,
                            userViewModel: userViewModel,
                            userName: widget.fullPhoneNumber,
                            phoneNumber: widget.fullPhoneNumber,
                            password: 'VC@_${widget.fullPhoneNumber}',
                          );
                          isVerify.value=false;
                        }
                      });
                    },
                    child: isVerify.value? Center(
                                  child: SizedBox(
                                    width: 18,
                                    height: 18,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.white,
                                    ),
                                  ),
                                ):Text(
                      Translator.translate('verify_code'),
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold,color: Colors.white),
                    ),
                  ),
                );
              }
            ),
          ],
        ),
      ),
    );
  }
}
