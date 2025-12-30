import 'package:findup_mvvm/Core/constants/app_color.dart';
import 'package:findup_mvvm/Core/constants/text_helper.dart';
import 'package:findup_mvvm/Data/view_models/product_model_view_model.dart';
import 'package:findup_mvvm/Data/view_models/user_view_model.dart';
import 'package:findup_mvvm/Pages/_Profile/Verify_Center/Screen/boost_list_verify_screen.dart';
import 'package:findup_mvvm/Pages/_Profile/Verify_Center/Screen/new_post_list_screen.dart';
import 'package:findup_mvvm/Pages/_Profile/Verify_Center/Screen/user_list_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class VerifyCenterPage extends StatefulWidget {
  const VerifyCenterPage({super.key});

  @override
  State<VerifyCenterPage> createState() => _VerifyCenterPageState();
}

class _VerifyCenterPageState extends State<VerifyCenterPage> {
  TextHelper textHelper = TextHelper();
  ValueNotifier<int> currentIndex = ValueNotifier(0);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      context.read<UserViewModel>().getNewUser();
      context.read<ProductModelViewModel>().newPostListing();
      context.read<ProductModelViewModel>().adminGetVerifyAllBoostPending();
    });
  }

  @override
  Widget build(BuildContext context) {
    UserViewModel userViewModel = Provider.of<UserViewModel>(context);
    ProductModelViewModel productModelViewModel =
        Provider.of<ProductModelViewModel>(context);

    return Scaffold(
      backgroundColor: Colors.grey.shade100,

      appBar: AppBar(
        centerTitle: true,
        backgroundColor: AppColor.appBarColor,
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
        title: Text('Verification Center', style: textHelper.textAppBarStyle()),
      ),

      body: ValueListenableBuilder(
        valueListenable: currentIndex,
        builder: (context, value, _) {
          return AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            child: _buildBody(
              index: value,
              userViewModel: userViewModel,
              productModelViewModel: productModelViewModel,
            ),
          );
        },
      ),

      bottomNavigationBar: ValueListenableBuilder(
        valueListenable: currentIndex,
        builder: (context, index, _) {
          return BottomNavigationBar(
            currentIndex: index,
            backgroundColor: Colors.white,
            selectedItemColor: Colors.orange,
            unselectedItemColor: Colors.grey.shade600,
            elevation: 15,
            selectedLabelStyle: const TextStyle(
              fontFamily: "Poppins",
              fontWeight: FontWeight.bold,
            ),
            unselectedLabelStyle: const TextStyle(fontFamily: "Poppins"),
            onTap: (value) => currentIndex.value = value,
            items: const [
              BottomNavigationBarItem(
                icon: Icon(Icons.person_rounded),
                label: "New User",
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.post_add_rounded),
                label: "New Post",
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.flash_on_rounded),
                label: "New Boost",
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildBody({
    required int index,
    required UserViewModel userViewModel,
    required ProductModelViewModel productModelViewModel,
  }) {
    switch (index) {
      case 0:
        return userViewModel.isLoading
            ? const Center(child: CircularProgressIndicator())
            : UserListScreen(
                listUser: userViewModel.listNewUser,
                onConFirm: (user) async {
                  await userViewModel.approveUser(userID: user.id);
                },
                onReject: (user) async {
                  await userViewModel.rejectUser(userID: user.id);
                },
              );

      case 1:
        return productModelViewModel.isLoading
            ? Center(child: CircularProgressIndicator())
            : NewPostListScreen(
                listProduct: productModelViewModel.listNewPostProduct,
                onConFirm: (product) async {
                  await productModelViewModel.confirmNewProduct(
                    productID: product.id,
                  );
                },
                onReject: (product) async {
                  await productModelViewModel.regectNewProductListing(
                    productID: product.id,
                  );
                },
              );

      case 2:
        return productModelViewModel.isLoading
            ? Center(child: CircularProgressIndicator())
            : BoostListVerifyScreen(
                listProductBoostPending:
                    productModelViewModel.adminlistAllBoostForVerify,
                onConFirm: (product) async {
                  Map<String, dynamic> jsonBody = {};
                  jsonBody['user_id'] = product.userBoostID;
                  jsonBody['product_id'] = product.id;

                  jsonBody['day_count'] = product.boostPendingDay;
                  jsonBody['point_deduct'] = 0;
                  await productModelViewModel
                      .boostProduct(jsonBody: jsonBody);
                },
                onReject: (product) {},
              );

      default:
        return const SizedBox();
    }
  }
}
