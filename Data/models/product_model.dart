class ProductModel {
  final String subCategory;
  final String saleType;
  final String userGmail;
  final String groupPlace;
  final String subPlace;
  final String userName;
  final int id;
  final int userId;
  final int groupCategoryId;
  final int subCategoryId;
  final int groupPlaceId;
  final int subPlaceId;
  final String title;
  final String subTitle;
  final double basePrice;
  final String billingPeriod;
  final int bedCount;
  final int bathCount;
  final String size;
  final int likeCount;
  final int report;
  final int alertStatus;
  final String alertTitle;
  final int reNewStatus;
  final int reNewCount;
  final int reNewLimit;
  final int boostStatus;
  final int filterRange;
  final double lat;
  final double lon;
  final String mapDefaultUrl;
  final String imageShow;
  final String imageList;
  final String createdAt;
  final String updatedAt;
  final int status;
  final int allowBoost;
  final String userProfile;
  final int isTopShow;
  final String timeAgo;
  final String reportBy;
  final String keyTranslate;
  final String actionStatus;
  final int boostPendingDay;
  final double boostPendingTotal;
  final String boostPendingStatus;
  final int isBoostPending;
  final String boostImageVerify;
  final int userBoostID;
  final String userFirstPhoneNumber;
  final String fullAddress;
  final String groupCategoryRole;
  final String userCovertImg;
  final String userBioTitle;
  


  ProductModel({
    required this.subCategory,
    required this.saleType,
    required this.userGmail,
    required this.groupPlace,
    required this.subPlace,
    required this.userName,
    required this.id,
    required this.userId,
    required this.groupCategoryId,
    required this.subCategoryId,
    required this.groupPlaceId,
    required this.subPlaceId,
    required this.title,
    required this.subTitle,
    required this.basePrice,
    required this.billingPeriod,
    required this.bedCount,
    required this.bathCount,
    required this.size,
    required this.likeCount,
    required this.report,
    required this.alertStatus,
    required this.alertTitle,
    required this.reNewStatus,
    required this.reNewCount,
    required this.reNewLimit,
    required this.boostStatus,
    required this.filterRange,
    required this.lat,
    required this.lon,
    required this.mapDefaultUrl,
    required this.imageShow,
    required this.imageList,
    required this.createdAt,
    required this.updatedAt,
    required this.status,
    required this.userProfile,
    required this.isTopShow,
    required this.timeAgo,
    required this.reportBy,
    required this.keyTranslate,
    required this.actionStatus,
    required this.boostPendingDay,
    required this.boostPendingStatus,
    required this.boostPendingTotal,
    required this.isBoostPending,
    required this.boostImageVerify,
    required this.userBoostID,
    required this.allowBoost,
    required this.userFirstPhoneNumber,
    required this.fullAddress,
    required this.groupCategoryRole,
    required this.userCovertImg,
    required this.userBioTitle
    


  });

  // ✅ Map → Model
  factory ProductModel.fromJson(Map<String, dynamic> json) {
    return ProductModel(
      subCategory: json['xx'] ?? '',
      saleType: json['x']??'',
      userGmail: json['x'] ?? 'xx',
      groupPlace: json['xx'] ?? '',
      subPlace: json['xx'] ?? '',
      userName: json['xx']??'Tester',
      id: json['xx'] ?? 0,
      userId: json['xx'] ?? 0,
      groupCategoryId: json['xx'] ?? 0,
      subCategoryId: json['xx'] ?? 0,
      groupPlaceId: json['xx'] ?? 0,
      subPlaceId: json['xx'] ?? 0,
      title: json['xx'] ?? '',
      subTitle: json['xx'] ?? '',
      basePrice: (json['xx'] ?? 0).toDouble(),
      billingPeriod: json['xx'] ?? '',
      bedCount: json['xx'] ?? 0,
      bathCount: json['xx'] ?? 0,
      size: json['xx'] ?? '',
      likeCount: json['xx'] ?? 0,
      report: json['xx'] ?? 0,
      alertStatus: json['xx'] ?? 0,
      alertTitle: json['xx'] ?? '',
      reNewStatus: json['xx'] ?? 0,
      reNewCount: json['xx'] ?? 0,
      reNewLimit: json['xx'] ?? 0,
      boostStatus: json['xx'] ?? 0,
      filterRange: json['xx'] ?? 0,
      lat: (json['xx'] ?? 0).toDouble(),
      lon: (json['xx'] ?? 0).toDouble(),
      mapDefaultUrl: json['xx'] ?? '',
      imageShow: json['xx'] ?? '',
      imageList: json['x'] ?? '',
      createdAt: json['x'] ?? '',
      updatedAt: json['x'] ?? '',
      status: json['x'] ?? 0,
      userProfile: json['x'] ?? 'https://static.vecteezy.com/system/resources/thumbnails/009/292/244/small/default-avatar-icon-of-social-media-user-vector.jpg',
      isTopShow: json['x']??0,
      timeAgo: json['x']??'0',
      reportBy: json['x']??'',
      keyTranslate: json['x'] ??'',
      actionStatus: json['x']??'',//
      boostPendingDay: json['x']??0,//
      boostPendingStatus: json['x']??'',
      boostPendingTotal: (json['x'] ?? 0).toDouble(),
      isBoostPending: json['x']??0,
      boostImageVerify: json['x']??'default.jpg',
      userBoostID: json['x']??0,
      allowBoost: json['x']??0,
      userFirstPhoneNumber: json['x']??'none',
      fullAddress: json['x']??'',
      groupCategoryRole: json['x']?? '',
      userCovertImg: json['x']??'',
      userBioTitle: json['x']??''
    );
  }

  // ✅ Model → Map
  Map<String, dynamic> toJson() {
    return {
      'x':keyTranslate,
      'x':subCategory,
      'x':saleType,
      'x':userGmail,
      'x':groupPlace,
      'x':subPlace,
      'x':userName,
      'x': id,
      'x': userId,
      'x': groupCategoryId,
      'x': subCategoryId,
      'x': groupPlaceId,
      'x': subPlaceId,
      'x': title,
      'x': subTitle,
      'x': basePrice,
      'x': billingPeriod,
      'x': bedCount,
      'x': bathCount,
      'x': size,
      'x': likeCount,
      'x': report,
      'x': alertStatus,
      'x': alertTitle,
      'x': reNewStatus,
      'x': reNewCount,
      'x': reNewLimit,
      'x': boostStatus,
      'x': filterRange,
      'x': lat,
      'x': lon,
      'x': mapDefaultUrl,
      'x': imageShow,
      'x': imageList,
      'x': createdAt,
      'x': updatedAt,
      'x': status,
      'x':userProfile,
      'x':isTopShow,
      'x':timeAgo,
      'x':reportBy,
      'x':actionStatus,
      'x':boostPendingDay,
      'x':boostPendingStatus,
      'x':double.parse(boostPendingTotal.toString()),
      'x':isBoostPending,
      'x':boostImageVerify,
      'x':userBoostID,
      'x':allowBoost,
      'x':userFirstPhoneNumber,
      'x':fullAddress,
      'x':groupCategoryRole,
      'x':userCovertImg,
      'x':userBioTitle
      
    };
  }
}
