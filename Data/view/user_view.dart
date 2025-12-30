import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:findup_mvvm/Core/network/api_client.dart';
import 'package:findup_mvvm/Data/models/user_model.dart';

class UserView {
  ApiClient apiClient = ApiClient();

  Future<UserModel?> updateUserBio({
    required int userID,
    required String userBio,
  }) async {
    try {
      var response = await apiClient.post('fake_endpoint', {

      });
      List<Map<String, dynamic>> listUser = List<Map<String, dynamic>>.from(
        response.data['data'],
      );

      if (listUser.isNotEmpty) {
        return UserModel.fromJson(listUser.first);
      } else {
        return null;
      }
    } catch (e) {}
  }

  Future<List<UserModel>> approveUser({required int userID}) async {
    try {
      var response = await apiClient.post('fake_endpoint', {});
      if (response.statusCode == 200) {
        List<Map<String, dynamic>> listUser = List<Map<String, dynamic>>.from(
          response.data['data'],
        );
        return listUser.map((e) => UserModel.fromJson(e)).toList();
      } else {
        return [];
      }
    } catch (e) {
      return [];
    }
  }

  Future<List<UserModel>> rejectUser({required int userID}) async {
    try {
      var response = await apiClient.post('fake_endpoint', {});
      if (response.statusCode == 200) {
        List<Map<String, dynamic>> listUser = List<Map<String, dynamic>>.from(
          response.data['data'],
        );
        return listUser.map((e) => UserModel.fromJson(e)).toList();
      } else {
        return [];
      }
    } catch (e) {
      return [];
    }
  }

  Future<List<UserModel>> getNewUser() async {
    try {
      var response = await apiClient.post('fake_endpoint', {});
      if (response.statusCode == 200) {
        List<Map<String, dynamic>> listUser = List<Map<String, dynamic>>.from(
          response.data['data'],
        );
        return listUser.map((e) => UserModel.fromJson(e)).toList();
      } else {
        return [];
      }
    } catch (e) {
      return [];
    }
  }

  Future<bool> userLogOut({required int userID}) async {
    try {
      var response = await apiClient.post('fake_endpoint', {});
      if (response.statusCode == 200) {
        return true;
      } else {
        return false;
      }
    } catch (e) {
      return false;
    }
  }

  Future<UserModel?> getAdminInfo() async {
    try {
      var response = await apiClient.post('fake_endpoint', {});
      if (response.statusCode == 200) {
        List<Map<String, dynamic>> listUser = List<Map<String, dynamic>>.from(
          response.data['data'],
        );

        return UserModel.fromJson(listUser.first);
      } else {
        return null;
      }
    } catch (e) {
      return null;
    }
  }

  Future<UserModel?> verifyPhoneOTP({
    required String name,
    required String email,
    required String userProfile,
    required String password,
    required String confirm_password,
    required String fcmToken,
    required String phoneNumber,
  }) async {
    try {
      Map<String, dynamic> mapSent = {

      };

      var responseData = await apiClient.post(
        'fake_endpoint',
        mapSent,
      );

      final token = responseData.data['token'];
      final userData = responseData.data['data'];
      if (token != null && userData != null) {
        await apiClient.saveToken(token);
        return UserModel.fromJson(userData);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  Future<UserModel?> continueWithUserInfo({
    required String name,
    required String email,
    required String userProfile,
    required String password,
    required String confirm_password,
    required String fcmToken,
    required String phoneNumber,
  }) async {
    try {
      Map<String, dynamic> mapSent = {

      };

      var responseData = await apiClient.post(
        'fake_endpoint',
        mapSent,
      );

      final token = responseData.data['token'];
      final userData = responseData.data['data'];
      if (token != null && userData != null) {
        await apiClient.saveToken(token);
        return UserModel.fromJson(userData);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  Future<UserModel?> continueWithTherdPartyV2({
    required String name,
    required String email,
    required String userProfile,
    required String password,
    required String confirm_password,
    required String fcmToken,
  }) async {
    try {
      Map<String, dynamic> mapSent = {
      
      };
      var responseData = await apiClient.post(
        'fake_endpoint',
        mapSent,
      );

      final token = responseData.data['token'];
      final userData = responseData.data['data'];
      if (token != null && userData != null) {
        await apiClient.saveToken(token);
        return UserModel.fromJson(userData);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  Future<bool> closeAccount({required int userID}) async {
    try {
      var response = await apiClient.post('fake_endpoint', {});
      if (response.statusCode == 200) {
        return true;
      } else {
        return false;
      }
    } catch (e) {
      return false;
    }
  }

  Future<UserModel?> continueWithTherdParty({
    required String name,
    required String email,
    required String userProfile,
    required String password,
    required String confirm_password,
  }) async {
    try {
      Map<String, dynamic> mapSent = {

      };
      var responseData = await apiClient.post(
        'fake_endpoint',
        mapSent,
      );
      final userData = responseData.data['data'];
      if (userData != null) {
        return UserModel.fromJson(userData);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  Future<List<UserModel>?> chatGetUser() async {
    try {
      var response = await apiClient.post('fake_endpoint', {});
      List<Map<String, dynamic>> listUser = List<Map<String, dynamic>>.from(
        response.data['data'],
      );

      if (listUser.isNotEmpty) {
        return listUser.map((e) => UserModel.fromJson(e)).toList();
      } else {
        return [];
      }
    } catch (e) {}
  }

  Future<UserModel?> getUserInfo({required int userID}) async {
    try {
      var response = await apiClient.post('fake_endpoint', {});
      List<Map<String, dynamic>> listUser = List<Map<String, dynamic>>.from(
        response.data['data'],
      );

      if (listUser.isNotEmpty) {
        return UserModel.fromJson(listUser.first);
      } else {
        return null;
      }
    } catch (e) {}
  }

  Future<UserModel?> update({required Map<String, dynamic> jsonBody}) async {
    try {
      dynamic response;

      if (jsonBody['xx'] is File) {
        // 🟢 File upload (multipart)
        final formData = FormData.fromMap({
         
        });

        response = await apiClient.post('fake_endpoint', formData);
      } else {
        // 🟡 JSON data (no new image)
        response = await apiClient.post('fake_endpoint', {

        });
      }

      // Parse response
      final userData = response.data['data'];
      if (userData != null) {
        if (userData is List && userData.isNotEmpty) {
          return UserModel.fromJson(userData.first);
        } else if (userData is Map<String, dynamic>) {
          return UserModel.fromJson(userData);
        }
      }

      return null;
    } catch (e) {
      return null;
    }
  }

  Future<UserModel?> register({
    required String name,
    required String email,
    required String userProfile,
    required String password,
    required String confirm_password,
  }) async {
    try {
      Map<String, dynamic> mapSent = {

      };
      var responseData = await apiClient.post('fake_endpoint', mapSent);
      final userData = responseData.data['data'];
      if (userData != null) {
        return UserModel.fromJson(userData);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  Future<UserModel?> login({required String email}) async {
    try {
      Map<String, dynamic> bodySend = {};
      var responseData = await apiClient.post('fake_endpoint', bodySend);
      final token = responseData.data['token'];
      final userData = responseData.data['data'];
      if (token != null && userData != null) {
        await apiClient.saveToken(token);
        return UserModel.fromJson(userData);
      }
      return null;
    } catch (e) {
      return null;
    }
  }
}
