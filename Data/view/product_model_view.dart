import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:findup_mvvm/Core/network/api_client.dart';
import 'package:findup_mvvm/Core/services/local_storage.dart';
import 'package:findup_mvvm/Data/models/product_model.dart';
import 'package:findup_mvvm/Data/view_models/app_config_view_model.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ProductModelView {
  final ApiClient apiClient = ApiClient();

  Future<List<ProductModel>> filterProductByRangePrice({
    required int subCategoryID,
    required int groupPlaceID,
    required int userId,
    required double minPrice,
    required double maxPrice,
  }) async {
    try {
      final jsonBody = {

      };
  
      final response = await apiClient.post(
        'fake_endpoint',
        jsonBody,
      );

      if (response.statusCode == 200) {
        final List<Map<String, dynamic>> listJsonResponse =
            List<Map<String, dynamic>>.from(response.data['data']);
        return listJsonResponse.map((e) => ProductModel.fromJson(e)).toList();
      }
    } catch (e) {}
    return [];
  }

  Future<List<ProductModel>> filterproductBySubCategoryAndGroupPlace({
    required int subCategoryID,
    required int groupPlaceID,
    required int userId,
  }) async {
    try {
      final jsonBody = {
 
      };
      final response = await apiClient.post(
        'fake_endpoint',
        jsonBody,
      );

      if (response.statusCode == 200) {
        final List<Map<String, dynamic>> listJsonResponse =
            List<Map<String, dynamic>>.from(response.data['data']);
        return listJsonResponse.map((e) => ProductModel.fromJson(e)).toList();
      }
    } catch (e) {}
    return [];
  }

  Future<List<ProductModel>> filterLatLong({
    required int userID,
    required int subCategoryID,
    required int groupPlaceID,
  }) async {
    try {
      Map<String, dynamic> body = {

      };
      final response = await apiClient.post('fake_endpoint', body);

      if (response.statusCode == 200) {
        final List<Map<String, dynamic>> listJsonResponse =
            List<Map<String, dynamic>>.from(response.data['data']);

        return listJsonResponse.map((e) => ProductModel.fromJson(e)).toList();
      }
    } catch (e) {
      return [];
    }
    return [];
  }

  Future<List<ProductModel>> getTopProductBySubCategory({
    required int userID,
    required int subCategoryID,
  }) async {
    try {
      final jsonBody = {};

      final response = await apiClient.post(
        'fake_endpoint',
        jsonBody,
      );

      if (response.statusCode == 200) {
        final List<Map<String, dynamic>> listJsonResponse =
            List<Map<String, dynamic>>.from(response.data['data']);
        return listJsonResponse.map((e) => ProductModel.fromJson(e)).toList();
      }
    } catch (e) {}
    return [];
  }

  Future<List<ProductModel>> adminGetAllBoostVerify() async {
    try {
      final response = await apiClient.post(
        'fake_endpoint',
        {},
      );
      if (response.statusCode == 200) {
        final List<Map<String, dynamic>> listJsonResponse =
            List<Map<String, dynamic>>.from(response.data['data']);

        return listJsonResponse.map((e) => ProductModel.fromJson(e)).toList();
      }
    } catch (e) {}
    return [];
  }

  Future<List<ProductModel>> regectNewProductListing({
    required int productId,
  }) async {
    try {
      final response = await apiClient.post('fake_endpoint', {
     
      });

      if (response.statusCode == 200) {
        final List<Map<String, dynamic>> listJsonResponse =
            List<Map<String, dynamic>>.from(response.data['data']);

        return listJsonResponse.map((e) => ProductModel.fromJson(e)).toList();
      }
    } catch (e) {}
    return [];
  }

  Future<List<ProductModel>> confirmNewProductListing({
    required int productId,
  }) async {
    try {
      final response = await apiClient.post('fake_endpoint', {
   
      });

      if (response.statusCode == 200) {
        final List<Map<String, dynamic>> listJsonResponse =
            List<Map<String, dynamic>>.from(response.data['data']);

        return listJsonResponse.map((e) => ProductModel.fromJson(e)).toList();
      }
    } catch (e) {}
    return [];
  }

  Future<List<ProductModel>> newPostListing() async {
    try {
      final response = await apiClient.post('fake_endpoint', {});

      if (response.statusCode == 200) {
        final List<Map<String, dynamic>> listJsonResponse =
            List<Map<String, dynamic>>.from(response.data['data']);

        return listJsonResponse.map((e) => ProductModel.fromJson(e)).toList();
      }
    } catch (e) {}
    return [];
  }

  Future<List<ProductModel>> toViewUserProductProfile({
    required int userViewID,
    required int userOwnerProfileID,
  }) async {
    try {
      final jsonBody = {
   
      };
      final response = await apiClient.post('fake_endpoint', jsonBody);

      if (response.statusCode == 200) {
        final List<Map<String, dynamic>> listJsonResponse =
            List<Map<String, dynamic>>.from(response.data['data']);

        return listJsonResponse.map((e) => ProductModel.fromJson(e)).toList();
      }
    } catch (e) {}
    return [];
  }

  Future<bool> removeBoostPending({required int productID}) async {
    try {
      final jsonBody = {};
      final response = await apiClient.post('fake_endpoint', jsonBody);

      if (response.statusCode == 200) {
        return true;
      }
    } catch (e) {}
    return false;
  }

  Future<bool> boostPenddingInsert({
    required int productID,
    required int userId,
    required int boostDay,
    required double total,
  }) async {
    try {
      final jsonBody = {
       
      };
      final response = await apiClient.post('fake_endpoint', jsonBody);
      if (response.statusCode == 200) {
        return true;
      }
    } catch (e) {}
    return false;
  }

  Future<List<ProductModel>> getAllBoostPending({required int userId}) async {
    try {
      final jsonBody = {};
      final response = await apiClient.post('fake_endpoint', jsonBody);
      if (response.statusCode == 200) {
        final List<Map<String, dynamic>> listJsonResponse =
            List<Map<String, dynamic>>.from(response.data['data']);
        return listJsonResponse.map((e) => ProductModel.fromJson(e)).toList();
      }
    } catch (e) {}
    return [];
  }

  Future<List<ProductModel>> searchAllProductV2({
    required int userID,
    required String keyWord,
    required int offset,
    required int limit,
    int? minPrice,
    int? maxPrice,
  }) async {
    try {
      final jsonBody = {
       
      };

      // ADD PRICE FILTERS
      if (minPrice != null) jsonBody['min_price'] = minPrice;
      if (maxPrice != null) jsonBody['max_price'] = maxPrice;
      final response = await apiClient.post('fake_endpoint', jsonBody);

      if (response.statusCode == 200) {
        final List<Map<String, dynamic>> listJsonResponse =
            List<Map<String, dynamic>>.from(response.data['data']);

        return listJsonResponse.map((e) => ProductModel.fromJson(e)).toList();
      }
    } catch (e) {}

    return [];
  }

  Future<List<ProductModel>> filterProduct({
    required int userID,
    required String keyWord,
    required int offset,
    required int limit,
    required int subCategoryID,
    required int groupPlaceID,
  }) async {
    try {
      final jsonBody = {
        
      };

      final response = await apiClient.post('fake_endpoint', jsonBody);

      if (response.statusCode == 200) {
        final List<Map<String, dynamic>> listJsonResponse =
            List<Map<String, dynamic>>.from(response.data['data']);

        return listJsonResponse.map((e) => ProductModel.fromJson(e)).toList();
      }
    } catch (e) {}

    return [];
  }

  Future<List<ProductModel>> seeAllSearchProduct({
    required int userID,
    required String keyWord,
    required int offset,
    required int limit,
    required int groupCategoryID,
    int? minPrice,
    int? maxPrice,
  }) async {
    try {
      final jsonBody = {

      };

      final response = await apiClient.post('fake_endpoint', jsonBody);

      if (response.statusCode == 200) {
        final List<Map<String, dynamic>> listJsonResponse =
            List<Map<String, dynamic>>.from(response.data['data']);

        return listJsonResponse.map((e) => ProductModel.fromJson(e)).toList();
      }
    } catch (e) {}

    return [];
  }

  Future<List<ProductModel>> searchAllProduct({
    required int userID,
    required String keyWord,
    required int offset,
    required int limit,
    int? minPrice,
    int? maxPrice,
  }) async {
    try {
      final jsonBody = {
    
      };

      final response = await apiClient.post('fake_endpoint', jsonBody);

      if (response.statusCode == 200) {
        final List<Map<String, dynamic>> listJsonResponse =
            List<Map<String, dynamic>>.from(response.data['data']);

        return listJsonResponse.map((e) => ProductModel.fromJson(e)).toList();
      }
    } catch (e) {}

    return [];
  }

  Future<List<ProductModel>> getProductBySubCategory({
    required int userID,
    required int subCategoryID,
  }) async {
    try {
      final jsonBody = {};

      final response = await apiClient.post(
        'fake_endpoint',
        jsonBody,
      );

      if (response.statusCode == 200) {
        final List<Map<String, dynamic>> listJsonResponse =
            List<Map<String, dynamic>>.from(response.data['data']);
        return listJsonResponse.map((e) => ProductModel.fromJson(e)).toList();
      }
    } catch (e) {}
    return [];
  }

  Future<void> hideAllProductOfUser({
    required Map<String, dynamic> jsonBody,
  }) async {
    try {
      final response = await apiClient.post(
        'fake_endpoint',
        jsonBody,
      );
      if (response.statusCode == 200) {}
    } catch (e) {}
  }

  Future<List<ProductModel>> reportProduct({
    required Map<String, dynamic> jsonBody,
  }) async {
    try {
      final response = await apiClient.post('fake_endpoint', jsonBody);
      if (response.statusCode == 200) {
        final List<Map<String, dynamic>> listJsonResponse =
            List<Map<String, dynamic>>.from(response.data['data']);

        return listJsonResponse.map((e) => ProductModel.fromJson(e)).toList();
      }
    } catch (e) {
      return [];
    }
    return [];
  }

  Future<List<ProductModel>> getProductByID({required int productID}) async {
    try {
      final response = await apiClient.post('fake_endpoint', {
 
      });

      if (response.statusCode == 200) {
        final List<Map<String, dynamic>> listJsonResponse =
            List<Map<String, dynamic>>.from(response.data['data']);
        return listJsonResponse.map((e) => ProductModel.fromJson(e)).toList();
      }
    } catch (e) {
      return [];
    }
    return [];
  }


  Future<List<ProductModel>> boostProduct({
    required Map<String, dynamic> jsonBody,
  }) async {
    try {
      final response = await apiClient.post('fake_endpoint', jsonBody);

      if (response.statusCode == 200) {
        List<Map<String, dynamic>> listResponse =
            List<Map<String, dynamic>>.from(response.data['data']);
        return listResponse.map((e) => ProductModel.fromJson(e)).toList();
      }
    } catch (e) {
      return [];
    }
    return [];
  }

  Future<bool> renewProduct({required int product_id}) async {
    try {
      final jsonBody = {};
      final response = await apiClient.post('fake_endpoint', jsonBody);

      if (response.statusCode == 200) {
        return true;
      }
    } catch (e) {
      return false;
    }
    return false;
  }

  Future<List<ProductModel>> getProductByGroupCategory({
    required int groupCategoryID,
    required int userId,
  }) async {
    try {
      final jsonBody = {
       
      };
      final response = await apiClient.post(
        'fake_endpoint',
        jsonBody,
      );

      if (response.statusCode == 200) {
        final List<Map<String, dynamic>> listJsonResponse =
            List<Map<String, dynamic>>.from(response.data['data']);
        return listJsonResponse.map((e) => ProductModel.fromJson(e)).toList();
      }
    } catch (e) {}
    return [];
  }

  /// Upload multiple images and product data
  Future<Response> postMultipart(
    String path,
    Map<String, dynamic> data,
    List<File> files, {
    String filesFieldName = 'images[]',
    String fileNamePrefix = 'image_',
    required BuildContext context,
  }) async {
    AppConfigViewModel appConfigViewModel = Provider.of<AppConfigViewModel>(
      context,
      listen: false,
    );
    FormData formData = FormData.fromMap(data);

    for (var i = 0; i < files.length; i++) {
      final fileName =
          '$fileNamePrefix$i.jpg'; // or you can omit this to let server handle naming
      formData.files.add(
        MapEntry(
          filesFieldName,
          await MultipartFile.fromFile(files[i].path, filename: fileName),
        ),
      );
    }

    return apiClient.post(
      'fake_endpoint',
      formData,
    );
  }

  Future<Response> postSinglePart(
    String path,
    Map<String, dynamic> data,
    List<File> files, {
    String filesFieldName = 'images[]',
    String fileNamePrefix = 'image_',
    required BuildContext context,
  }) async {
    AppConfigViewModel appConfigViewModel = Provider.of<AppConfigViewModel>(
      context,
    );
    FormData formData = FormData.fromMap(data);

    for (var i = 0; i < files.length; i++) {
      final fileName =
          '$fileNamePrefix$i.jpg'; // or you can omit this to let server handle naming
      formData.files.add(
        MapEntry(
          filesFieldName,
          await MultipartFile.fromFile(files[i].path, filename: fileName),
        ),
      );
    }

    return apiClient.post(
      'fake_endpoint',
      formData,
    );
  }

  Future<bool> editProductWithImages({
    required Map<String, dynamic> productData,
    required List<File> images,
    required String oldFileName,
    required BuildContext context,
  }) async {
    try {
      final response = await postMultipart(
        'fake_endpoint',
        productData,
        images,
        filesFieldName: '',
        fileNamePrefix: '',
        context: context,
      );

      if (response.statusCode == 200) {
        await removeImageFromServer(fileName: oldFileName);
        final data = response.data;
        if (data is Map<String, dynamic> && data['status'] == 'success') {
          return true;
        } else {}
      } else {}
      return false;
    } on DioException catch (e) {
      return false;
    } catch (e) {
      return false;
    }
  }

  /// Upload product + images and handle response
  Future<bool> postProductWithImages({
    required Map<String, dynamic> productData,
    required List<File> images,
    required BuildContext context,
  }) async {
    try {
      final response = await postMultipart(
        'fake_endpoint',
        productData,
        images,
        filesFieldName: '',
        fileNamePrefix: '',
        context: context,
      );

      if (response.statusCode == 200) {
        final data = response.data;
        if (data is Map<String, dynamic> && data['status'] == 'success') {
          return true;
        } else {}
      } else {}
      return false;
    } on DioException catch (e) {
    
      return false;
    } catch (e) {

      return false;
    }
  }

  /// Get user's products
  Future<List<ProductModel>> getUserProduct({required int userID}) async {
    try {
      final jsonBody = {};
      final response = await apiClient.post('fake_endpoint', jsonBody);
      if (response.statusCode == 200) {
        final List<Map<String, dynamic>> listJsonResponse =
            List<Map<String, dynamic>>.from(response.data['data']);
        return listJsonResponse.map((e) => ProductModel.fromJson(e)).toList();
      }
    } catch (e) {}
    return [];
  }

  /// Get products by sub-place
  Future<List<ProductModel>> getProductBySubPlace({
    required int subPlaceID,
    required int userID,
  }) async {
    try {
      final jsonBody = {};
      final response = await apiClient.post(
        'fake_endpoint',
        jsonBody,
      );

      if (response.statusCode == 200) {
        final List<Map<String, dynamic>> listJsonResponse =
            List<Map<String, dynamic>>.from(response.data['data']);
        return listJsonResponse.map((e) => ProductModel.fromJson(e)).toList();
      }
    } catch (e) {}
    return [];
  }

  /// Get products by sub-place
  Future<List<ProductModel>> removeProductItem({
    required int userID,
    required int productID,
    required String fileName,
  }) async {
    try {
      final jsonBody = {};
      final response = await apiClient.post('fake_endpoint', jsonBody);

      if (response.statusCode == 200) {
        final List<Map<String, dynamic>> listJsonResponse =
            List<Map<String, dynamic>>.from(response.data['data']);
        await removeImageFromServer(fileName: fileName);
        return listJsonResponse.map((e) => ProductModel.fromJson(e)).toList();
      }
    } catch (e) {}
    return [];
  }

  Future<void> removeImageFromServer({required String fileName}) async {
    try {
      final jsonBody = {};
      final response = await apiClient.post('fake_endpoint', jsonBody);

      if (response.statusCode == 200) {}
    } catch (e) {}
  }

  Future<List<ProductModel>> showProductFilter({
    required int userID,
    required int subCategoryID,
    required int groupPlaceID,
    required int subPlaceID,
  }) async {
    try {
      final jsonBody = {

      };

      final response = await apiClient.post('fake_endpoint', jsonBody);
      if (response.statusCode == 200) {
        final List<Map<String, dynamic>> listJsonResponse =
            List<Map<String, dynamic>>.from(response.data['data']);
        return listJsonResponse.map((e) => ProductModel.fromJson(e)).toList();
      }
    } catch (e) {}
    return [];
  }
}
