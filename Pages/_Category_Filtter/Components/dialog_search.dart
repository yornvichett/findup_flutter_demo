import 'dart:async';
import 'package:findup_mvvm/Core/navigation/navigation.dart';
import 'package:findup_mvvm/Core/services/local_storage.dart';
import 'package:findup_mvvm/Core/services/translate.dart';
import 'package:findup_mvvm/Core/utils/product_item_card.dart';
import 'package:findup_mvvm/Data/models/group_place_model.dart';
import 'package:findup_mvvm/Data/models/product_model.dart';
import 'package:findup_mvvm/Data/models/sub_category_model.dart';
import 'package:findup_mvvm/Data/view_models/product_model_view_model.dart';
import 'package:findup_mvvm/Pages/product_item_detail_page.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class DialogSearch extends StatefulWidget {
  final String title;
  final SubCategoryModel subCategoryModel;
  final GroupPlaceModel groupPlaceModel;

  const DialogSearch({super.key, required this.title,required this.subCategoryModel,required this.groupPlaceModel});

  @override
  State<DialogSearch> createState() => _DialogSearchState();
}

class _DialogSearchState extends State<DialogSearch> {
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  Timer? _debounce;

  static const int _pageSize = 20;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  // SEARCH INPUT LISTENER
  void _onSearchChanged(String value) {
    final vm = Provider.of<ProductModelViewModel>(context, listen: false);
    if (_debounce?.isActive ?? false) _debounce!.cancel();

    _debounce = Timer(const Duration(milliseconds: 350), () {
      if (value.trim().isEmpty) {
        vm.clearSearch();
        return;
      }

      vm.currentKeyword = value;

      vm.filterroduct(
        keyword: value,
        offset: 0,
        limit: _pageSize,
        userID: LocalStorage.userModel == null ? 0 : LocalStorage.userModel!.id,
        subCategoryID: widget.subCategoryModel.id,
        groupPlaceID: widget.groupPlaceModel.id
      );
    });
  }

  // PAGINATION
  void _onScroll() {
    final vm = Provider.of<ProductModelViewModel>(context, listen: false);

    if (!_scrollController.hasClients) return;

    final threshold = 200;
    if (_scrollController.position.maxScrollExtent -
            _scrollController.position.pixels <=
        threshold) {
      if (!vm.isLoadingMore && vm.hasMore && vm.currentKeyword.isNotEmpty) {
        vm.searchAllProduct(
          keyword: vm.currentKeyword,
          offset: vm.listSearchAllProduct.length,
          limit: _pageSize,
          userID: LocalStorage.userModel == null ? 0 : LocalStorage.userModel!.id,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final vm = Provider.of<ProductModelViewModel>(context);

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            Expanded(child: _buildBody(vm)),
          ],
        ),
      ),
    );
  }

  // ========================= HEADER =========================
  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Icon(Icons.location_city,color: Colors.grey,),
              SizedBox(width: 5,),
              Text('${widget.groupPlaceModel.name} > ${Translator.translate(widget.subCategoryModel.keyTranslate)}',style: TextStyle(color: Colors.grey,),),
            ],
          ),
          SizedBox(height: 10,),
          Row(
            children: [
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(CupertinoIcons.back, size: 20),
                ),
              ),
              const SizedBox(width: 10),
              
              Expanded(
                child: Container(
                  height: 45,
                  padding: const EdgeInsets.symmetric(horizontal: 15),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.search, color: Colors.grey.shade700),
                      const SizedBox(width: 10),
                      Expanded(
                        child: TextField(
                          controller: _searchController,
                          onChanged: _onSearchChanged,
                          decoration: InputDecoration(
                            hintText: Translator.translate(widget.title),
                            border: InputBorder.none,
                          ),
                        ),
                      ),
                      if (_searchController.text.isNotEmpty)
                        GestureDetector(
                          onTap: () {
                            _searchController.clear();
                            Provider.of<ProductModelViewModel>(context, listen: false)
                                .clearSearch();
                            setState(() {});
                          },
                          child: Icon(Icons.close,
                              size: 18, color: Colors.grey.shade600),
                        ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ========================= BODY =========================
  Widget _buildBody(ProductModelViewModel vm) {
    if (vm.isFirstLoad && vm.isLoading) {
      return ListView.builder(
        itemCount: 6,
        itemBuilder: (_, __) => _skeletonItem(),
      );
    }

    if (vm.currentKeyword.isNotEmpty && vm.listSearchAllProduct.isEmpty) {
      return const Center(child: Text("No results found."));
    }

    return ListView.builder(
      controller: _scrollController,
      itemCount:
          vm.listSearchAllProduct.length + (vm.isLoadingMore ? 1 : 0),
      itemBuilder: (context, i) {
        if (i == vm.listSearchAllProduct.length) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(12),
              child: CircularProgressIndicator(),
            ),
          );
        }

        final product = vm.listSearchAllProduct[i];

        return ProductItemCard(
          product: product,
          onTap: () => Navigation.goPage(
            context: context,
            page: ProductItemDetailPage(productModel: product),
          ),
        );
      },
    );
  }

  // skeleton
  Widget _skeletonItem() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      height: 110,
      decoration: BoxDecoration(
        color: Colors.grey.shade300,
        borderRadius: BorderRadius.circular(14),
      ),
    );
  }
}
