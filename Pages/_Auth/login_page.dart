import 'dart:io';
import 'package:findup_mvvm/Core/Storage/pref_storage.dart';
import 'package:findup_mvvm/Core/navigation/navigation.dart';
import 'package:findup_mvvm/Core/services/translate.dart';
import 'package:findup_mvvm/Data/view_models/user_view_model.dart';
import 'package:findup_mvvm/Pages/_Auth/phone_number.dart';
import 'package:findup_mvvm/Pages/splash_page.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_auth/firebase_auth.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: ['email'],
    serverClientId:
        "605260406155-8i1ah607of07polbinpe4n9f8r0f3r3c.apps.googleusercontent.com",
  );

  bool _isLoading = false;
  PrefStorage prefStorage = PrefStorage();

  // ---------------- GOOGLE LOGIN ----------------
  Future<void> _loginWithGoogle(UserViewModel userViewModel) async {
    String fcmTokenKey = await prefStorage.getFCMToken();
    setState(() => _isLoading = true);
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        setState(() => _isLoading = false);
        return;
      }

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final userCredential = await _auth.signInWithCredential(credential);
      final user = userCredential.user;
      if (fcmTokenKey != '') {
        if (user != null) {
          userViewModel.userModel = await userViewModel
              .continueWithTherdPartyV2(
                name: user.displayName ?? '',
                email: user.email ?? '',
                userProfile: user.photoURL ?? '',
                password: 'uid_${user.uid}',
                confirmPassword: 'uid_${user.uid}',
                fcmToken: fcmTokenKey,
              );

          Navigation.goReplacePage(context: context, page: const SplashPage());
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Google sign-in failed: $e')));
    } finally {
      setState(() => _isLoading = false);
    }
  }

  // ---------------- APPLE LOGIN ----------------
  Future<void> _loginWithApple(UserViewModel userViewModel) async {
    String fcmTokenKey = await prefStorage.getFCMToken();
    setState(() => _isLoading = true);
    try {
      final credential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
      );

      final oauthCredential = OAuthProvider("apple.com").credential(
        idToken: credential.identityToken,
        accessToken: credential.authorizationCode,
      );

      final userCredential = await _auth.signInWithCredential(oauthCredential);
      final user = userCredential.user;
      if (user != null) {
        userViewModel.userModel = await userViewModel.continueWithTherdPartyV2(
          name:
              credential.givenName ??
              user.displayName ??
              user.email.toString().split("@")[0],
          email: user.email ?? '',
          userProfile: '',
          password: 'uid_${user.uid}',
          confirmPassword: 'uid_${user.uid}',
          fcmToken: fcmTokenKey,
        );

        Navigation.goReplacePage(context: context, page: const SplashPage());
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Apple sign-in failed: $e')));
    } finally {
      setState(() => _isLoading = false);
    }
  }

  // ---------------- UI ----------------
  @override
  Widget build(BuildContext context) {
    final userViewModel = Provider.of<UserViewModel>(context);

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 0,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.login_rounded,
                      color: Colors.blueAccent.shade200,
                      size: 64,
                    ),
                    const SizedBox(height: 20),
                    Text(
                      "${Translator.translate('welcome_to_findup')} 👋",
                      style: GoogleFonts.poppins(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      Translator.translate(
                        'login_or_create_an_account_to_continue',
                      ),
                      textAlign: TextAlign.center,
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 40),
                    _buildSocialButton(
                      onPressed: () {
                        Navigation.goPage(context: context, page: PhoneNumber());
                      },
                      label: Translator.translate('continue_with_phone_number'),
                      icon: Image.asset("assets/icons/personal_info.png", height: 22),
                    ),
                    const SizedBox(height: 16),

                    // Google Button
                    _buildSocialButton(
                      onPressed: () => _loginWithGoogle(userViewModel),
                      label: Translator.translate('continue_with_google'),
                      icon: Image.asset("assets/images/google.png", height: 22),
                    ),
                    const SizedBox(height: 16),

                    // Facebook Button
                    // _buildSocialButton(
                    //   onPressed: () => _loginWithFacebook(userViewModel),
                    //   label: "Continue with Facebook",
                    //   icon: Image.asset("assets/images/facebook.png", height: 22),
                    //   color: const Color(0xFF1877F2),
                    //   textColor: Colors.white,
                    // ),
                    // const SizedBox(height: 16),

                    // Apple Button (iOS only)
                    if (Platform.isIOS)
                      _buildSocialButton(
                        onPressed: () => _loginWithApple(userViewModel),
                        label: Translator.translate('continue_with_apple'),
                        icon: const Icon(
                          Icons.apple,
                          color: Colors.white,
                          size: 24,
                        ),
                        color: Colors.black,
                        textColor: Colors.white,
                      ),

                    const SizedBox(height: 40),
                    Text(
                      Translator.translate(
                        'by_continuing_you_agree_too_our_terms_of_service_and_privacy_policy',
                      ),
                      textAlign: TextAlign.center,
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),

                  ],
                ),
              ),
            ),
          ),

          // Loading Overlay
          if (_isLoading)
            Container(
              color: Colors.black.withOpacity(0.2),
              child: const Center(
                child: CircularProgressIndicator(color: Colors.blueAccent),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildSocialButton({
    required VoidCallback onPressed,
    required String label,
    required Widget icon,
    Color color = Colors.white,
    Color textColor = Colors.black87,
  }) {
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: ElevatedButton.icon(
        onPressed: onPressed,
        icon: icon,
        label: Text(
          label,
          style: GoogleFonts.poppins(
            color: textColor,
            fontWeight: FontWeight.w500,
            fontSize: 15,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: color == Colors.white
                ? const BorderSide(color: Colors.grey)
                : BorderSide.none,
          ),
        ),
      ),
    );
  }
}
