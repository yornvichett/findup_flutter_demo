import 'dart:io';
import 'package:dio/dio.dart';
import 'package:findup_mvvm/Core/Storage/pref_storage.dart';
import 'package:findup_mvvm/Core/network/api_client.dart';
import 'package:findup_mvvm/Core/services/editable_image.dart';
import 'package:findup_mvvm/Core/services/local_storage.dart';
import 'package:findup_mvvm/Data/models/product_model.dart';
import 'package:findup_mvvm/Data/view/product_model_view.dart';
import 'package:findup_mvvm/Pages/to_view_user_post_profile_page.dart';
import 'package:flutter/material.dart';

class ProductModelViewModel extends ChangeNotifier {
  PrefStorage prefStorage = PrefStorage();
  final ProductModelView productModelView = ProductModelView();

  List<ProductModel> listUserProduct = [];
  List<ProductModel> listFilterProductBySubPlace = [];
  List<ProductModel> listProductByGroupCategory = [];
  List<ProductModel> listProductFilter = [];

  List<ProductModel> listTopShowHomePage = [];
  List<ProductModel> listTopShowBySubCategoryFilter = [];

  // List<ProductModel> latLongProduct = [];
  // List<ProductModel> listFilterLatLong = [];
  List<ProductModel> listGetProductByID = [];
  List<ProductModel> listGetProductBySubCategory = [];
  List<ProductModel> listSearchAllProduct = [];
  List<ProductModel> listToViewProductUserProfile = [];
  List<ProductModel> listUserGetAllBoostPending = [];
  List<ProductModel> listNewPostProduct = [];
  List<ProductModel> adminlistAllBoostForVerify = [];

  List<ProductModel> listProductOfSubCategoryAndGroupPlace = [];
  List<ProductModel> listFilterProductByRangePrice = [];

  bool isLoading = false;
  bool isFirstLoad = true; // 👈 Added flag to track first load only

  bool isLoadingMore = false;
  bool hasMore = true;
  String currentKeyword = '';
  int? minPrice;
  int? maxPrice;

  void clearSearch() {
    currentKeyword = '';
    listSearchAllProduct = [];
    isFirstLoad = false;
    isLoading = false;
    isLoadingMore = false;
    hasMore = true;
    notifyListeners();
  }

  Future<void> filterroduct({
    required int userID,
    required String keyword,
    required int offset,
    required int limit,
    required int subCategoryID,
    required int groupPlaceID,
  }) async {
    currentKeyword = keyword;

    if (offset == 0) {
      isFirstLoad = true;
      isLoading = true;
      hasMore = true;
      listSearchAllProduct = [];
      notifyListeners();
    } else {
      isLoadingMore = true;
      notifyListeners();
    }

    try {
      final List<ProductModel> newItems = await productModelView.filterProduct(
        keyWord: keyword,
        offset: offset,
        limit: limit,
        userID: userID,
        subCategoryID: subCategoryID,
        groupPlaceID: groupPlaceID,
      );

      if (offset == 0) {
        listSearchAllProduct = newItems;
        isFirstLoad = false;
        isLoading = false;
      } else {
        listSearchAllProduct.addAll(newItems);
        isLoadingMore = false;
      }

      hasMore = newItems.length == limit;
    } catch (e) {
      isLoading = false;
      isLoadingMore = false;
    }

    notifyListeners();
  }

  Future<void> filterProductByRangePrice({
    required int subCategoryID,
    required int groupPlaceID,
    required int userId,
    required double minPrice,
    required double maxPrice,
  }) async {
    if (isFirstLoad) {
      isLoading = true;
      notifyListeners();
    }

    try {
      listFilterProductByRangePrice = await productModelView
          .filterProductByRangePrice(
            subCategoryID: subCategoryID,
            groupPlaceID: groupPlaceID,
            userId: userId,
            minPrice: minPrice,
            maxPrice: maxPrice,
          );
      
    } catch (e) {
    } finally {
      isLoading = false;
      if (isFirstLoad) isFirstLoad = false;
      notifyListeners();
    }
  }

  Future<void> filterproductBySubCategoryAndGroupPlace({
    required int subCategoryID,
    required int groupPlaceID,
    required int userId,
  }) async {
    if (isFirstLoad) {
      isLoading = true;
      notifyListeners();
    }

    try {
      listProductOfSubCategoryAndGroupPlace = await productModelView
          .filterproductBySubCategoryAndGroupPlace(
            subCategoryID: subCategoryID,
            groupPlaceID: groupPlaceID,
            userId: userId,
          );

      listTopShowHomePage = listProductOfSubCategoryAndGroupPlace
          .where((element) => element.boostStatus == 1)
          .toList();
    } catch (e) {
    } finally {
      isLoading = false;
      if (isFirstLoad) isFirstLoad = false;
      notifyListeners();
    }
  }

  Future<void> getTopProductBySubCategory({
    required int userID,
    required int subCategoryID,
  }) async {
    isLoading = true;
    notifyListeners();

    try {
      listTopShowBySubCategoryFilter = await productModelView
          .getTopProductBySubCategory(
            userID: userID,
            subCategoryID: subCategoryID,
          );
    } catch (e) {
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> adminGetVerifyAllBoostPending() async {
    // ✅ Only show shimmer if it's the first load

    isLoading = true;
    notifyListeners();

    try {
      adminlistAllBoostForVerify = await productModelView
          .adminGetAllBoostVerify();
    } catch (e) {
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  //regectNewProductListing
  Future<void> regectNewProductListing({required int productID}) async {
    // ✅ Only show shimmer if it's the first load

    isLoading = true;
    notifyListeners();

    try {
      listNewPostProduct = await productModelView.regectNewProductListing(
        productId: productID,
      );
    } catch (e) {
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> confirmNewProduct({required int productID}) async {
    // ✅ Only show shimmer if it's the first load

    isLoading = true;
    notifyListeners();

    try {
      listNewPostProduct = await productModelView.confirmNewProductListing(
        productId: productID,
      );
    } catch (e) {
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  //newPostListing
  Future<void> newPostListing() async {
    // ✅ Only show shimmer if it's the first load

    isLoading = true;
    notifyListeners();

    try {
      listNewPostProduct = await productModelView.newPostListing();
    } catch (e) {
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> uploadBoostPayment({
    required int productID,
    required String message,
    required String imagePah,
    required int userID,
    required String userName,
  }) async {
    final api = ApiClient();

    FormData formData = FormData.fromMap({
      "product_id": productID,
      "username": userName,
      "image": await MultipartFile.fromFile(imagePah),
      'message': message,
    });

    final response = await api.post("upload_boost_payment", formData);
    if (response.statusCode == 200 && response.data["success"] == true) {
      getAllBoostPending(userID: userID);
      getUserProduct(userID: userID);
      return true;
    } else {
      return false;
    }
  }

  Future<bool> removeBoostPending({
    required int productID,
    required int userID,
  }) async {
    // isLoading = true;
    // notifyListeners();
    try {
      bool isSuccess = await productModelView.removeBoostPending(
        productID: productID,
      );
      if (isSuccess) {
        listUserGetAllBoostPending.removeWhere(
          (element) => element.id == productID,
        );
        await getUserProduct(userID: userID);
      }
      return isSuccess;
    } catch (e) {
    } finally {
      // isLoading = false;
      // notifyListeners();
      return false;
    }
  }

  //
  Future<bool> boostPenddingInsert({
    required int productID,
    required int userID,
    required int boostDay,
    required double total,
  }) async {
    isLoading = true;
    notifyListeners();

    try {
      bool isSuccess = await productModelView.boostPenddingInsert(
        userId: userID,
        productID: productID,
        boostDay: boostDay,
        total: total,
      );
      if (isSuccess) {
        await getUserProduct(userID: userID);
      }
      return isSuccess;
    } catch (e) {
    } finally {
      isLoading = false;
      notifyListeners();
      return false;
    }
  }
  //removeBoostPending

  Future<void> getAllBoostPending({required int userID}) async {
    // ✅ Only show shimmer if it's the first load

    isLoading = true;
    notifyListeners();

    try {
      listUserGetAllBoostPending = await productModelView.getAllBoostPending(
        userId: userID,
      );
    } catch (e) {
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> toViewUserPostProfilePage({
    required int userViewID,
    required int userOwnerProfileID,
  }) async {
    isLoading = true;
    notifyListeners();

    try {
      listToViewProductUserProfile = await productModelView
          .toViewUserProductProfile(
            userViewID: userViewID,
            userOwnerProfileID: userOwnerProfileID,
          );
    } catch (e) {
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  // Future<void> searchAllProduct({
  //   required int userID,
  //   required String keyword,
  //   required int offset,
  //   required int limit,
  // }) async {
  //   currentKeyword = keyword; // FIXED

  //   if (offset == 0) {
  //     isFirstLoad = true;
  //     isLoading = true;
  //     hasMore = true;
  //     listSearchAllProduct = [];
  //     notifyListeners();
  //   } else {
  //     isLoadingMore = true;
  //     notifyListeners();
  //   }

  //   try {
  //     // REAL API CALL (must implement)
  //     final List<ProductModel> newItems = await productModelView
  //         .searchAllProduct(
  //           keyWord: keyword,
  //           offset: offset,
  //           limit: limit,
  //           userID: userID,
  //         );

  //     if (offset == 0) {
  //       listSearchAllProduct = newItems;
  //       isFirstLoad = false;
  //       isLoading = false;
  //     } else {
  //       listSearchAllProduct.addAll(newItems);
  //       isLoadingMore = false;
  //     }

  //     if (newItems.length < limit) {
  //       hasMore = false;
  //     }
  //   } catch (e) {}

  //   notifyListeners();
  // }
  Future<void> searchAllProduct({
    required int userID,
    required String keyword,
    required int offset,
    required int limit,
    int? minPrice,
    int? maxPrice,
  }) async {
    this.minPrice = minPrice;
    this.maxPrice = maxPrice;

    currentKeyword = keyword;

    if (offset == 0) {
      isFirstLoad = true;
      isLoading = true;
      hasMore = true;
      listSearchAllProduct = [];
      notifyListeners();
    } else {
      isLoadingMore = true;
      notifyListeners();
    }

    try {
      final List<ProductModel> newItems = await productModelView
          .searchAllProduct(
            keyWord: keyword,
            offset: offset,
            limit: limit,
            userID: userID,
            minPrice: minPrice,
            maxPrice: maxPrice,
          );

      if (offset == 0) {
        listSearchAllProduct = newItems;
        isFirstLoad = false;
        isLoading = false;
      } else {
        listSearchAllProduct.addAll(newItems);
        isLoadingMore = false;
      }

      hasMore = newItems.length == limit;
    } catch (e) {
      isLoading = false;
      isLoadingMore = false;
    }

    notifyListeners();
  }

  Future<void> seeAllsearchProduct({
    required int userID,
    required String keyword,
    required int offset,
    required int limit,
    required int groupCategoryID,
    int? minPrice,
    int? maxPrice,
  }) async {
    this.minPrice = minPrice;
    this.maxPrice = maxPrice;

    currentKeyword = keyword;

    if (offset == 0) {
      isFirstLoad = true;
      isLoading = true;
      hasMore = true;
      listSearchAllProduct = [];
      notifyListeners();
    } else {
      isLoadingMore = true;
      notifyListeners();
    }

    try {
      final List<ProductModel> newItems = await productModelView
          .seeAllSearchProduct(
            keyWord: keyword,
            offset: offset,
            limit: limit,
            userID: userID,
            minPrice: minPrice,
            maxPrice: maxPrice,
            groupCategoryID: groupCategoryID,
          );

      if (offset == 0) {
        listSearchAllProduct = newItems;
        isFirstLoad = false;
        isLoading = false;
      } else {
        listSearchAllProduct.addAll(newItems);
        isLoadingMore = false;
      }

      hasMore = newItems.length == limit;
    } catch (e) {
      isLoading = false;
      isLoadingMore = false;
    }

    notifyListeners();
  }

  Future<void> getProductBySubCategory({
    required int userID,
    required int subCategoryID,
  }) async {
    isLoading = true;
    notifyListeners();

    try {
      listGetProductBySubCategory = await productModelView
          .getProductBySubCategory(
            userID: userID,
            subCategoryID: subCategoryID,
          );
    } catch (e) {
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> hideAllProductOfUser({
    required Map<String, dynamic> jsonBody,
  }) async {
    isLoading = true;
    notifyListeners();

    try {
      await productModelView.hideAllProductOfUser(jsonBody: jsonBody);
    } catch (e) {
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> reportProduct({required Map<String, dynamic> jsonBody}) async {
    isLoading = true;
    notifyListeners();

    try {
      await productModelView.reportProduct(jsonBody: jsonBody);
    } catch (e) {
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> getProductByID({required int productID}) async {
    // isLoading = true;
    // notifyListeners();

    try {
      listGetProductByID = await productModelView.getProductByID(
        productID: productID,
      );
    } catch (e) {
    } finally {
      // isLoading = false;
      // notifyListeners();
    }
  }

  // Future<List<ProductModel>> getAllLatLong() async {
  //   isLoading = true;
  //   notifyListeners();

  //   try {
  //     latLongProduct = await productModelView.getAllLatLong();

  //     return latLongProduct;
  //   } catch (e) {
  //     return [];
  //   } finally {
  //     isLoading = false;
  //     notifyListeners();
  //     return [];
  //   }
  // }

  Future<void> boostProduct({required Map<String, dynamic> jsonBody}) async {
    if (isFirstLoad) {
      isLoading = true;
      notifyListeners();
    }

    try {
      adminlistAllBoostForVerify = await productModelView.boostProduct(
        jsonBody: jsonBody,
      );
    } catch (e) {
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> renewProduct({required int product_id}) async {
    if (isFirstLoad) {
      isLoading = true;
      notifyListeners();
    }

    try {
      return await productModelView.renewProduct(product_id: product_id);
    } catch (e) {
      return false;
    } finally {
      isLoading = false;
      if (isFirstLoad) isFirstLoad = false;
      notifyListeners();
    }
  }

  Future<void> getProductFilter({
    required int userID,
    required int subCategoryID,
    required int groupPlaceID,
    required int subPlaceID,
  }) async {
    if (isFirstLoad) {
      isLoading = true;
      notifyListeners();
    }

    try {
      listProductFilter = await productModelView.showProductFilter(
        userID: userID,
        subCategoryID: subCategoryID,
        groupPlaceID: groupPlaceID,
        subPlaceID: subPlaceID,
      );

      // listTopShowHomePage = listProductFilter
      //     .where((element) => element.boostStatus == 1)
      //     .toList();
    } catch (e) {
    } finally {
      isLoading = false;
      if (isFirstLoad) isFirstLoad = false;
      notifyListeners();
    }
  }

  /// POST PRODUCT WITH IMAGES
  Future<bool> postProduct({
    required Map<String, dynamic> jsonBody,
    required List<File> images,
    required int userID,
    required BuildContext context,
  }) async {
    isLoading = true;
    notifyListeners();

    try {
      if (images.isEmpty) {
        return false;
      }

      if (images.length > 10) {
        return false;
      }

      final success = await productModelView.postProductWithImages(
        productData: jsonBody,
        images: images,
        context: context,
      );

      return success;
    } catch (e) {
   
      return false;
    } finally {
      try {
        await getUserProduct(userID: userID);
      } catch (err) {
    
      }

      isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> editProduct({
    required Map<String, dynamic> jsonBody,
    required List<File> images,
    required int userID,
    required String oldFileName,
    required BuildContext context,
  }) async {
    isLoading = true;
    notifyListeners();

    try {
      if (images.isEmpty) {
        return false;
      }

      if (images.length > 10) {
        return false;
      }

      final success = await productModelView.editProductWithImages(
        productData: jsonBody,
        images: images,
        oldFileName: oldFileName,
        context: context,
      );

      return success;
    } catch (e) {
      return false;
    } finally {
      try {
        getUserProduct(userID: userID);
      } catch (err) {}

      isLoading = false;
      notifyListeners();
    }
  }

  /// GET USER PRODUCTS
  Future<void> getUserProduct({required int userID}) async {
    isLoading = true;
    notifyListeners();
    // ✅ Only show shimmer if it's the first load
    if (isFirstLoad) {
      isLoading = true;
      notifyListeners();
    }

    try {
      listUserProduct = await productModelView.getUserProduct(userID: userID);
    } catch (e) {
    } finally {
      isLoading = false;
      if (isFirstLoad) {
        isFirstLoad = false; // 👈 Disable shimmer after first load
      }
      notifyListeners();
    }
  }

  /// GET PRODUCT BY GROUP CATEGORY
  Future<void> getProductByGroupCategory({
    required int groupCategoryID,
    required int userId,
  }) async {
    if (isFirstLoad) {
      isLoading = true;
      notifyListeners();
    }

    try {
      listProductByGroupCategory = await productModelView
          .getProductByGroupCategory(
            groupCategoryID: groupCategoryID,
            userId: userId,
          );

      listTopShowHomePage = listProductByGroupCategory
          .where((element) => element.boostStatus == 1)
          .toList();
    } catch (e) {
    } finally {
      isLoading = false;
      if (isFirstLoad) isFirstLoad = false;
      notifyListeners();
    }
  }

  /// GET PRODUCT BY SUB PLACE
  Future<void> getProductBySubPlace({
    required int subPlaceID,
    required int userID,
  }) async {
    if (isFirstLoad) {
      isLoading = true;
      notifyListeners();
    }

    try {
      listFilterProductBySubPlace = await productModelView.getProductBySubPlace(
        subPlaceID: subPlaceID,
        userID: userID,
      );
    } catch (e) {
    } finally {
      isLoading = false;
      if (isFirstLoad) isFirstLoad = false;
      notifyListeners();
    }
  }

  Future<bool> removeProduct({
    required int userID,
    required int productID,
    required String fileName,
  }) async {
    if (isFirstLoad) {
      isLoading = true;
      notifyListeners();
    }

    try {
      productModelView.removeProductItem(
        userID: userID,
        productID: productID,
        fileName: fileName,
      );
      listUserProduct.removeWhere((element) => element.id == productID);
      return true;
    } catch (e) {
      return false;
    } finally {
      isLoading = false;
      if (isFirstLoad) isFirstLoad = false;
      notifyListeners();
    }
  }
}
