import 'dart:io';

import 'package:dio/dio.dart';
import 'package:findup_mvvm/Core/network/api_client.dart';
import 'package:findup_mvvm/Data/view_models/app_config_view_model.dart';
import 'package:findup_mvvm/Firebase/firebase_service.dart';
import 'package:findup_mvvm/Core/navigation/navigation.dart';
import 'package:findup_mvvm/Core/services/local_storage.dart';
import 'package:findup_mvvm/Data/models/user_model.dart';
import 'package:findup_mvvm/Data/view/user_view.dart';
import 'package:findup_mvvm/Pages/home_page.dart';
import 'package:findup_mvvm/Pages/_Profile/profile_page.dart';
import 'package:findup_mvvm/Pages/splash_page.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class UserViewModel extends ChangeNotifier {
  UserView userView = UserView();
  List<UserModel> listChatUser = [];
  List<UserModel> listNewUser = [];
  UserModel? userModel;
  UserModel? userAdmin;
  bool isLoading = false;
  ApiClient apiClient = ApiClient();

  Future<void> updateBioUser({required int userID,required String userBio}) async {
    isLoading = true;
    notifyListeners();

    try {
      await userView.updateUserBio(userID: userID, userBio: userBio);
      await getUserInfo(userID: userID);
    } catch (e, stackTrace) {
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> uploadCoverProfile({
    required String imagePath,
    required String username,
    required int userID,
  }) async {
    final api = ApiClient();
    try {
      FormData formData = FormData.fromMap({
        "username": username,
        "image": await MultipartFile.fromFile(imagePath),
        'user_id': userID,
      });

      final response = await api.post("upload_cover_image", formData);

      if (response.statusCode == 200 && response.data["success"] == true) {
        getUserInfo(userID: userID);
        return true;
      } else {
        return false;
      }
    } catch (e) {
      return false;
    }
  }

  Future<bool> uploadImageProfile({
    required String imagePath,
    required String username,
    required int userID,
  }) async {
    final api = ApiClient();
    try {
      FormData formData = FormData.fromMap({
        "username": username,
        "image": await MultipartFile.fromFile(imagePath),
        'user_id': userID,
      });

      final response = await api.post("upload_profile_image", formData);

      if (response.statusCode == 200 && response.data["success"] == true) {
        getUserInfo(userID: userID);
        return true;
      } else {
        return false;
      }
    } catch (e) {
      return false;
    }
  }

  Future<void> approveUser({required int userID}) async {
    isLoading = true;
    notifyListeners();

    try {
      listNewUser = await userView.approveUser(userID: userID);
    } catch (e) {
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> rejectUser({required int userID}) async {
    isLoading = true;
    notifyListeners();

    try {
      listNewUser = await userView.rejectUser(userID: userID);
    } catch (e) {
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> getNewUser() async {
    isLoading = true;
    notifyListeners();

    try {
      listNewUser = await userView.getNewUser();
    } catch (e) {
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> getAdminInfo() async {
    isLoading = true;
    notifyListeners();

    try {
      userAdmin = await userView.getAdminInfo();
    } catch (e, stackTrace) {
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> chatGetUser() async {
    isLoading = true;
    notifyListeners();

    try {
      listChatUser = (await userView.chatGetUser())!;
    } catch (e, stackTrace) {
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> closeAccount({
    required int userID,
    required BuildContext context,
  }) async {
    // isLoading = true;
    // notifyListeners();

    try {
      await userView.closeAccount(userID: userID);
      LocalStorage.userModel = null;
      await LocalStorage.remove("user");
      await LocalStorage.remove("api_token");
      await FirebaseService.logout();
      Navigation.goReplacePage(context: context, page: SplashPage());
    } catch (e, stackTrace) {
    } finally {
      // isLoading = false;
      // notifyListeners();
    }
  }

  Future<UserModel?> getUserInfo({required int userID}) async {
    isLoading = true;
    notifyListeners();

    try {
      userModel = await userView.getUserInfo(userID: userID);

      return userModel;
    } catch (e) {
      return null;
    } finally {
      isLoading = false;
      notifyListeners();
      return null;
    }
  }

  Future<bool> sentCodeToPhoneNumber({required String phoneNumber}) async {
    try {
      Map<String, dynamic> mapSent = {'phone': phoneNumber};

      var responseData = await apiClient.post('sms_otp', mapSent);
      if (responseData.statusCode == 200) {
        return true;
      } else {
        return false;
      }
    } catch (e) {
      return false;
    }
  }

  Future<bool> verifyPhoneSMSCode({
    required String phoneNumber,
    required String code,
  }) async {
    try {
      Map<String, dynamic> mapSent = {'phone': phoneNumber, 'code': code};

      var responseData = await apiClient.post('sms_verify_otp', mapSent);
      if (responseData.statusCode == 200) {
        return true;
      } else {
        return false;
      }
    } catch (e) {
      return false;
    }
  }

  Future<UserModel?> continueWithUserInfo({
    required String name,
    required String email,
    required String userProfile,
    required String password,
    required String confirmPassword,
    required String fcmToken,
    required String phoneNumber,
    required BuildContext context,
  }) async {
    isLoading = true;
    notifyListeners();

    try {
      final user = await userView.continueWithUserInfo(
        phoneNumber: phoneNumber,
        name: name,
        email: email,
        userProfile: userProfile,
        password: password,
        confirm_password: confirmPassword,
        fcmToken: fcmToken,
      );

      if (user != null) {
        await LocalStorage.remove("user");
        await LocalStorage.remove("api_token");
        await LocalStorage.saveMap('user', user.toJson());
        await LocalStorage.saveMap('api_token', {'api_token': user.apiToken});
        Navigation.goReplacePage(context: context, page: SplashPage());
        return user;
      } else {
        return null;
      }
    } catch (e) {
      return null;
    } finally {
      // Always stop loading when done
      isLoading = false;
      notifyListeners();
    }
  }

  Future<UserModel?> continueWithTherdPartyV2({
    required String name,
    required String email,
    required String userProfile,
    required String password,
    required String confirmPassword,
    required String fcmToken,
  }) async {
    isLoading = true;
    notifyListeners();

    try {
      final user = await userView.continueWithTherdPartyV2(
        name: name,
        email: email,
        userProfile: userProfile,
        password: password,
        confirm_password: confirmPassword,
        fcmToken: fcmToken,
      );

      if (user != null) {
        if (user.status == 1) {
          await LocalStorage.remove("user");
          await LocalStorage.remove("api_token");
          await LocalStorage.saveMap('user', user.toJson());
          await LocalStorage.saveMap('api_token', {'api_token': user.apiToken});
        } else {
          return null;
        }

        return user;
      } else {
        return null;
      }
    } catch (e) {
      return null;
    } finally {
      // Always stop loading when done
      isLoading = false;
      notifyListeners();
    }
  }

  Future<UserModel?> updateUser({
    required String name,
    required String email,
    dynamic userProfile, // can be File or null or existing URL string
  }) async {
    isLoading = true;
    notifyListeners();

    try {
      final userId = LocalStorage.userModel?.id;
      if (userId == null) return null;

      final Map<String, dynamic> data = {
        'user_id': userId,
        'user_name': name,
        'user_email': email,
      };

      FormData formData;

      if (userProfile != null && userProfile is File) {
        // New image selected, upload as multipart
        formData = FormData.fromMap({
          ...data,
          'user_profile': await MultipartFile.fromFile(
            userProfile.path,
            filename: 'user_$userId.${userProfile.path.split('.').last}',
          ),
        });
      } else if (userProfile != null && userProfile is String) {
        // Existing URL
        formData = FormData.fromMap({...data, 'user_profile': userProfile});
      } else {
        formData = FormData.fromMap(data);
      }

      final response = await apiClient.post('user_update_profile', formData);

      if (response.statusCode == 200) {
        final user = UserModel.fromJson(response.data['data'][0]);

        LocalStorage.remove("user");
        LocalStorage.remove("api_token");
        await LocalStorage.saveMap('user', user.toJson());
        await LocalStorage.saveMap('api_token', {'api_token': user.apiToken});
        LocalStorage.userModel = user;
        LocalStorage.userModel!.apiToken = user.apiToken;
        return user;
      }

      return null;
    } catch (e) {
      return null;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<UserModel?> continueWithTherdParty({
    required String name,
    required String email,
    required String userProfile,
    required String password,
    required String confirmPassword,
  }) async {
    isLoading = true;
    notifyListeners();

    try {
      final user = await userView.continueWithTherdParty(
        name: name,
        email: email,
        userProfile: userProfile,
        password: password,
        confirm_password: confirmPassword,
      );
      if (user != null) {
        LocalStorage.remove("user");
        LocalStorage.remove("api_token");
        await LocalStorage.saveMap('user', user.toJson());
        await LocalStorage.saveMap('api_token', {'api_token': user.apiToken});
        return user;
      } else {
        return null;
      }
    } catch (e) {
      return null;
    } finally {
      // Always stop loading when done
      isLoading = false;
      notifyListeners();
    }
  }

  Future<UserModel?> register({
    required String name,
    required String email,
    required String userProfile,
    required String password,
    required String confirmPassword,
  }) async {
    isLoading = true;
    notifyListeners();

    try {
      final user = await userView.register(
        name: name,
        email: email,
        userProfile: userProfile,
        password: password,
        confirm_password: confirmPassword,
      );
      if (user != null) {
        LocalStorage.remove("user");
        LocalStorage.remove("api_token");
        await LocalStorage.saveMap('user', user.toJson());
        await LocalStorage.saveMap('api_token', {'api_token': user.apiToken});
        return user;
      } else {
        return null;
      }
    } catch (e) {
      return null;
    } finally {
      // Always stop loading when done
      isLoading = false;
      notifyListeners();
    }
  }

  Future<UserModel?> login({required String email}) async {
    isLoading = true;
    notifyListeners();

    try {
      final user = await userView.login(email: email);
      if (user != null) {
        LocalStorage.remove("user");
        LocalStorage.remove("api_token");
        await LocalStorage.saveMap('user', user.toJson());
        await LocalStorage.saveMap('api_token', {'api_token': user.apiToken});
        return user;
      } else {
        return null;
      }
    } catch (e) {
      return null;
    } finally {
      // Always stop loading when done
      isLoading = false;
      notifyListeners();
    }
  }

  // ✅ Auto check if user already logged in
  Future<bool> checkLoginStatus() async {
    final savedUser = await LocalStorage.getMap('user');
    if (savedUser != null) {
      UserModel.fromJson(savedUser);
      notifyListeners();
      return true;
    }
    return false;
  }

  Future<void> logout({
    required BuildContext context,
    required int userID,
  }) async {
    await userView.userLogOut(userID: userID);
    LocalStorage.userModel = null;

    await LocalStorage.remove("user");
    await LocalStorage.remove("api_token");
    await FirebaseService.logout();
  }
}
