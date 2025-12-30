import 'package:carousel_slider/carousel_slider.dart';
import 'package:findup_mvvm/Core/constants/app_color.dart';
import 'package:findup_mvvm/Core/constants/text_helper.dart';
import 'package:findup_mvvm/Core/services/helper.dart';
import 'package:findup_mvvm/Data/models/product_model.dart';
import 'package:findup_mvvm/Data/view_models/product_model_view_model.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';

class DialogMapShowLocationOfProperty extends StatefulWidget {
  final ProductModel productModel;

  const DialogMapShowLocationOfProperty({
    super.key,
    required this.productModel,
  });

  @override
  State<DialogMapShowLocationOfProperty> createState() =>
      _DialogMapShowLocationOfPropertyState();
}

class _DialogMapShowLocationOfPropertyState
    extends State<DialogMapShowLocationOfProperty> {
  GoogleMapController? _controller;
  TextHelper textHelper = TextHelper();
  ValueNotifier<bool> refersh = ValueNotifier(false);
  Helper helper = Helper();

  BitmapDescriptor? _remarkIcon;
  Set<Marker> _markers = {};

  static  CameraPosition _initialPosition = CameraPosition(
    target: LatLng(11.5564, 104.9282), // Phnom Penh
    zoom: 17,
  );

  @override
  void initState() {
    super.initState();
    _initialPosition = CameraPosition(
      target: LatLng(widget.productModel.lat, widget.productModel.lon), // Phnom Penh
      zoom: 17,
    );
    _setMarkers();
  }

  AssetMapBitmap assetMapBitmap = AssetMapBitmap(
    'assets/icons/remark_icon.png',
    width: 40,
  );

  /// ✅ Build markers only once after icon loaded
  Future<void> _setMarkers() async {
    // Create BitmapDescriptor from asset

    AssetMapBitmap assetMapBitmap = AssetMapBitmap(
      'assets/icons/remark_icon.png',
      width: 40,
    );

    // Create marker
    final marker = Marker(
      markerId: MarkerId(widget.productModel.id.toString()),
      position: LatLng(widget.productModel.lat, widget.productModel.lon),
      icon: assetMapBitmap,

      onTap: () async {
        await context.read<ProductModelViewModel>().getProductByID(
          productID: widget.productModel.id,
        );
        refersh.value = !refersh.value;
      },
    );
    setState(() {
      _markers.clear();
      _markers.add(marker);
    });
  }

  @override
  Widget build(BuildContext context) {
    final productModelViewModel = Provider.of<ProductModelViewModel>(
      context,
      listen: false,
    );

    return Material(
      child: Column(
        children: [
          // ✅ Map isolated in its own Expanded widget
          Expanded(child: _buildMap(context: context)),

          // ✅ Smooth bottom info card
          ValueListenableBuilder(
            valueListenable: refersh,
            builder: (context, value, child) {
              final list = productModelViewModel.listGetProductByID;
              if (list.isEmpty) return const SizedBox.shrink();
              return AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                child: bottomInfo(
                  productModel: list.first,
                  onHideForm: () {
                    productModelViewModel.listGetProductByID = [];
                    refersh.value = !refersh.value;
                  },
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  /// ✅ Separate map widget to prevent rebuild lag
  Widget _buildMap({required BuildContext context}) {
    Size size = MediaQuery.of(context).size;
    return Stack(
      children: [
        GoogleMap(
          mapType: MapType.hybrid,
          buildingsEnabled: true,
          trafficEnabled: false,
          indoorViewEnabled: true,
          initialCameraPosition: _initialPosition,
          onMapCreated: (controller) => _controller = controller,
          myLocationEnabled: true,
          myLocationButtonEnabled: true,
          zoomControlsEnabled: true,
          liteModeEnabled: false,
          markers: _markers,
        ),

        // ✅ FIXED: search box positioned correctly
        //Positioned(top: 10, left: 8, right: 8, child: DropDownSearchElement()),

        // ✅ close button
        Positioned(
          right: 10,
          top: 50,
          child: GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.grey, width: 2),
              ),
              child: const Icon(Icons.close, color: Colors.grey),
            ),
          ),
        ),
      ],
    );
  }

  /// ✅ Optimized bottom panel
  Widget bottomInfo({
    required ProductModel productModel,
    required Function() onHideForm,
  }) {
    List<String> listImage = helper.productModelSplitImage(
      path: 'property',
      product: productModel,
      context: context,
    );

    return Container(
      key: ValueKey(productModel.id),
      height: 150,
      decoration: const BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            offset: Offset(0, -2),
            blurRadius: 6,
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          children: [
            // ✅ Left image carousel
            Stack(
              children: [
                Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    color: Colors.black12,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  clipBehavior: Clip.hardEdge,
                  child: CarouselSlider(
                    options: CarouselOptions(
                      height: 120,
                      viewportFraction: 1.0,
                      enableInfiniteScroll: false,
                      enlargeCenterPage: false,
                    ),
                    items: listImage.map((imgUrl) {
                      return Image.network(
                        imgUrl,
                        fit: BoxFit.cover,
                        width: 120,
                        height: 120,
                        loadingBuilder: (context, child, progress) {
                          if (progress == null) return child;
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        },
                        errorBuilder: (context, error, stackTrace) =>
                            const Icon(Icons.broken_image, color: Colors.grey),
                      );
                    }).toList(),
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    onHideForm();
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Icon(Icons.cancel),
                  ),
                ),
              ],
            ),

            const SizedBox(width: 10),

            // ✅ Right product info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Text(
                    productModel.title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    productModel.subTitle,
                    style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "\$${productModel.basePrice}${productModel.billingPeriod}",
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
