import 'package:findup_mvvm/Core/navigation/navigation.dart';
import 'package:findup_mvvm/Core/services/helper.dart';
import 'package:findup_mvvm/Core/services/translate.dart';
import 'package:findup_mvvm/Data/view_models/user_view_model.dart';
import 'package:findup_mvvm/Pages/_Auth/login_page.dart';
import 'package:findup_mvvm/Pages/_Auth/phone_otp_verify_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl_phone_field/intl_phone_field.dart';

class PhoneNumber extends StatefulWidget {
  @override
  _PhoneNumberState createState() =>
      _PhoneNumberState();
}

class _PhoneNumberState extends State<PhoneNumber> {
  String fullPhone = "";
  UserViewModel userViewModel = UserViewModel();
  FirebaseAuth auth = FirebaseAuth.instance;
  String storedVerificationId = "";
  int? _resendToken;
  ValueNotifier<bool> isSending = ValueNotifier(false);
  Helper helper = Helper();

  Future<void> sendOTP(String rawPhone) async {
    try {
      isSending.value = true;
      // Convert Cambodia number to international format
      // Example: 015555555 -> +85515555555
      String phoneNumber = rawPhone;

      await FirebaseAuth.instance.verifyPhoneNumber(
        phoneNumber: phoneNumber,
        timeout: const Duration(seconds: 60),

        forceResendingToken: _resendToken,

        verificationCompleted: (PhoneAuthCredential credential) {},

        verificationFailed: (FirebaseAuthException e) {},

        codeSent: (String verificationId, int? resendToken) {
          isSending.value = false;
          // print("📌 verificationId: $verificationId");
          // print("📌 resendToken: $resendToken");
          // print("📨 OTP Sent to $phoneNumber");
          Navigation.goPage(
            context: context,
            page: PhoneOtpVerifyPage(
              fullPhoneNumber: fullPhone,
              verificationId: verificationId,
            ),
          );

          storedVerificationId = verificationId;
          _resendToken = resendToken;
        },

        codeAutoRetrievalTimeout: (String verificationId) {
          storedVerificationId = verificationId;
        },
      );
    } catch (e) {

    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 40),

              // Title
              Text(
                Translator.translate('register_with_phone_number'),
                style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
              ),

              const SizedBox(height: 10),

              Text(
                Translator.translate('enter_your_phone_number_to_continue'),
                style: TextStyle(fontSize: 15, color: Colors.black54),
              ),

              const SizedBox(height: 30),

              // Phone Number Input
              IntlPhoneField(
                disableLengthCheck: true,
                initialCountryCode: "KH", // Cambodia default
                decoration: InputDecoration(
                  labelText: Translator.translate('phone_number'),
                  border: OutlineInputBorder(
                    borderSide: BorderSide(),
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onChanged: (phone) {
                  fullPhone = phone.completeNumber; // +855xxxx
                },
                inputFormatters: [
                  LengthLimitingTextInputFormatter(9), // cannot exceed 9
                  FilteringTextInputFormatter.digitsOnly,
                ],

                validator: (phone) {
                  if (phone == null)
                    return Translator.translate('please_enter_phone_number');

                  String number = phone.number;

                  if (number.length < 8) {
                    return Translator.translate(
                      'phone_number_at_lease_8_digits',
                    );
                  }
                  if (number.length > 9) {
                    return Translator.translate(
                      'phone_can_not_exceed_9_degits',
                    );
                  }

                  return null; // valid phones: 8 or 9 digits
                },
              ),

              const SizedBox(height: 30),

              // Button
              ValueListenableBuilder(
                valueListenable: isSending,
                builder: (context, value, child) {
                  return SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        backgroundColor: Colors.blueAccent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: () async {
                        //Navigation.goReplacePage(context: context, page: OtpVerifyPage(fullPhoneNumber: "+855962444219", verificationId: ""));
                        if (fullPhone.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                Translator.translate(
                                  'please_enter_phone_number',
                                ),
                              ),
                            ),
                          );
                          return;
                        }
                        sendOTP(fullPhone);
                      },
                      child: isSending.value
                          ? Center(
                              child: SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              ),
                            )
                          : Text(
                              Translator.translate('send_code'),
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 20),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  GestureDetector(
                    onTap: () {
                      Navigation.goReplacePage(
                        context: context,
                        page: LoginPage(),
                      );
                    },
                    child: Text(
                      Translator.translate('back'),
                      style: TextStyle(fontSize: 13, color: Colors.blue),
                    ),
                  ),
                ],
              ),

              const Spacer(),

              Center(
                child: Text(
                  Translator.translate(
                    'by_continuing_you_agree_to_our_terms_and_privacy',
                  ),
                  style: TextStyle(color: Colors.black54, fontSize: 13),
                  textAlign: TextAlign.center,
                ),
              ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
