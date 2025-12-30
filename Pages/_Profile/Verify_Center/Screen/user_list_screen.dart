import 'package:cached_network_image/cached_network_image.dart';
import 'package:findup_mvvm/Data/models/user_model.dart';
import 'package:flutter/material.dart';

class UserListScreen extends StatelessWidget {
  final List<UserModel> listUser;
  Function(UserModel user) onReject;
  Function(UserModel user) onConFirm;
  UserListScreen({super.key, required this.listUser,required this.onConFirm,required this.onReject});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.grey.shade100,
      child: ListView.builder(
        itemCount: listUser.length,
        padding: const EdgeInsets.all(10),
        itemBuilder: (context, index) {
          UserModel user = listUser[index];

          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 6,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Row(
              children: [
                // PROFILE IMAGE
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: CachedNetworkImage(
                    imageUrl: user.userProfile,
                    width: 70,
                    height: 70,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => Container(
                      width: 70,
                      height: 70,
                      color: Colors.grey.shade300,
                      child: const Center(
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    ),
                    errorWidget: (context, url, error) => Container(
                      width: 70,
                      height: 70,
                      color: Colors.grey.shade300,
                      child: const Icon(Icons.person, color: Colors.grey),
                    ),
                  ),
                ),

                const SizedBox(width: 14),

                // USER INFO
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        user.name,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          fontFamily: "Poppins",
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "Email: ${user.email}",
                        style: TextStyle(
                          color: Colors.grey.shade700,
                          fontSize: 13,
                          fontFamily: "Poppins",
                        ),
                      ),
                      Text(
                        "Phone: ${user.firstPhoneNumber}",
                        style: TextStyle(
                          color: Colors.grey.shade700,
                          fontSize: 13,
                          fontFamily: "Poppins",
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(width: 10),

                // ACTION BUTTONS
                Column(
                  children: [
                    GestureDetector(
                      onTap: () {
                        onConFirm(user);
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.green,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Text(
                          "Confirm",
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                            fontFamily: "Poppins",
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 6),

                    GestureDetector(
                      onTap: () {
                        onReject(user);
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Text(
                          "Reject",
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                            fontFamily: "Poppins",
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
