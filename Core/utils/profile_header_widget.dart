import 'package:findup_mvvm/Core/constants/app_color.dart';
import 'package:findup_mvvm/Core/services/helper.dart';
import 'package:findup_mvvm/Core/services/local_storage.dart';
import 'package:findup_mvvm/Core/services/translate.dart';
import 'package:findup_mvvm/Core/utils/cache_profile_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ProfileHeaderWidget extends StatelessWidget {
  Function() addSaleTab;
  Function() addRentTab;
  Function() onEdit;

  int postCount;
  String userProfile;
  bool isAssets;
  String userName;
  String userEmail;
  String userPoint;
  ProfileHeaderWidget({
    super.key,
    required this.addSaleTab,
    required this.addRentTab,
    this.isAssets = true,
    required this.postCount,
    required this.userProfile,
    required this.userName,
    required this.userEmail,
    required this.userPoint,
    required this.onEdit
  });

  Helper helper=Helper();

  @override
  Widget build(BuildContext context) {
    return _buildProfileHeader();
  }

  Widget _buildProfileHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 40),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.grey.shade100,
            Color(0xFFE3F2FD), // very soft blue
            Color(0xFFBBDEFB), // soft premium blue
            Color(0xFF90CAF9), // slightly stronger blue
          ],
          begin: Alignment.bottomCenter,
          end: Alignment.topCenter,
        ),
      ),
      child: Stack(
        children: [
          // Floating dots (premium effect)
          Positioned(
            top: 30,
            left: 50,
            child: _floatingDot(16, Colors.white70),
          ),
          Positioned(
            top: 120,
            right: 40,
            child: _floatingDot(22, Colors.white54),
          ),
          Positioned(
            bottom: 60,
            left: 80,
            child: _floatingDot(12, Colors.white60),
          ),
          Positioned(
            bottom: 20,
            right: 90,
            child: _floatingDot(18, Colors.white54),
          ),

          // MAIN CONTENT
          Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              CircleAvatar(
                radius: 57,
                backgroundColor: Color.fromARGB(117, 52, 74, 88),
                child: CacheProfileImage(
                  userProfileImage: userProfile,
                  radius: 55,
                ),
              ),
           
              const SizedBox(height: 12),

              // Name + points
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 20),
                    child: Text(
                      userName,
                      style: GoogleFonts.poppins(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF0D47A1), // premium navy
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: onEdit,
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Icon(Icons.edit,color: Colors.green,),
                    ),
                  )
                ],
              ),

              const SizedBox(height: 5),

              // Email
              Text(
                userEmail,
                style: TextStyle(fontSize: 13, color: Colors.grey[700]),
              ),

              const SizedBox(height: 20),

              // Better contrast buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _profileButton(
                    text: Translator.translate('add_sale'),
                    icon: Icons.sell_outlined,
                    onPressed: addSaleTab,
                    color: Colors.blue[800]!,
                    textColor: Colors.white,
                  ),
                  SizedBox(width: 10),
                  _profileButton(
                    text: Translator.translate('add_rent'),
                    icon: Icons.vpn_key_outlined,
                    onPressed: addRentTab,
                    color: Colors.blue[800]!,
                    textColor: Colors.white,
                  ),
                ],
              ),

              const SizedBox(height: 20),
            ],
          ),
        ],
      ),
    );
  }

  Widget _floatingDot(double size, Color color) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        boxShadow: [BoxShadow(color: color, blurRadius: 12, spreadRadius: 5)],
      ),
    );
  }

  Widget _profileButton({
    required String text,
    required IconData icon,
    required VoidCallback onPressed,
    required Color color,
    Color textColor = Colors.white,
  }) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: Colors.blue, width: 2),
          color: Color(0xff344a58),
          borderRadius: BorderRadius.circular(20),
        ),

        child: Padding(
          padding: const EdgeInsets.only(
            left: 20,
            right: 20,
            top: 10,
            bottom: 10,
          ),
          child: Row(
            children: [
              Icon(icon, size: 18, color: textColor),
              SizedBox(width: 10),
              Text(
                text,
                style: TextStyle(color: textColor, fontWeight: FontWeight.w600),
              ),
            ],
          ),
        ),
      ),
    );

  }
}
