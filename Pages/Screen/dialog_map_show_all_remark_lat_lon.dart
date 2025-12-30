import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:findup_mvvm/Core/constants/app_color.dart';
import 'package:findup_mvvm/Core/constants/text_helper.dart';
import 'package:findup_mvvm/Core/navigation/navigation.dart';
import 'package:findup_mvvm/Core/services/helper.dart';
import 'package:findup_mvvm/Core/services/translate.dart';
import 'package:findup_mvvm/Data/models/product_model.dart';
import 'package:findup_mvvm/Data/view_models/product_model_view_model.dart';
import 'package:findup_mvvm/Pages/to_view_user_post_profile_page.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';

class DialogMapShowAllRemarkLatLon extends StatefulWidget {
  final List<ProductModel> listLatLong;

  const DialogMapShowAllRemarkLatLon({super.key, required this.listLatLong});

  @override
  State<DialogMapShowAllRemarkLatLon> createState() =>
      _DialogMapShowAllRemarkLatLonState();
}

class _DialogMapShowAllRemarkLatLonState
    extends State<DialogMapShowAllRemarkLatLon> {
  GoogleMapController? _controller;
  ProductModel? detailProduct;

  Set<Marker> _markers = {};
  List<MarkerLabel> _markerLabels = [];

  final ValueNotifier<bool> refersh = ValueNotifier(false);
  final Helper helper = Helper();
  final TextHelper textHelper = TextHelper();

  static const CameraPosition _initialPosition = CameraPosition(
    target: LatLng(11.5564, 104.9282),
    zoom: 10,
  );

  // ✅ YOUR CUSTOM HOME ICON (NOT REMOVED)
  final AssetMapBitmap assetMapBitmap = AssetMapBitmap(
    'assets/icons/remark_icon.png',
    width: 40,
  );

  // ✅ MAP STYLE: REMOVE ONLY GOOGLE POI ICONS
  static const String _mapStyle = '''
[
  {
    "featureType": "poi",
    "elementType": "all",
    "stylers": [{ "visibility": "off" }]
  },
  {
    "featureType": "transit",
    "elementType": "all",
    "stylers": [{ "visibility": "off" }]
  }
]
''';

  @override
  void initState() {
    super.initState();
    _setMarkers();
  }

  // ---------------------------------------------------------------------------
  // CREATE MARKERS (YOUR HOME ICONS)
  // ---------------------------------------------------------------------------
  void _setMarkers() {
    final markers = widget.listLatLong.map((loc) {
      return Marker(
        markerId: MarkerId(loc.id.toString()),
        position: LatLng(loc.lat, loc.lon),
        icon: assetMapBitmap,
        infoWindow: const InfoWindow(title: ""),
        onTap: () {
          detailProduct = loc;
          refersh.value = !refersh.value;
        },
      );
    }).toSet();

    setState(() => _markers = markers);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _updateMarkerLabels();
    });
  }

  // ---------------------------------------------------------------------------
  // UPDATE PRICE LABEL POSITIONS
  // ---------------------------------------------------------------------------
  Future<void> _updateMarkerLabels() async {
    if (_controller == null) return;

    List<MarkerLabel> temp = [];

    for (var loc in widget.listLatLong) {
      final point = await _controller!.getScreenCoordinate(
        LatLng(loc.lat, loc.lon),
      );

      temp.add(
        MarkerLabel(
          product: loc,
          offset: Offset(point.x.toDouble(), point.y.toDouble()),
        ),
      );
    }

    if (mounted) {
      setState(() => _markerLabels = temp);
    }
  }

  // ---------------------------------------------------------------------------
  // UI
  // ---------------------------------------------------------------------------
  @override
  Widget build(BuildContext context) {
    return Material(
      child: Column(
        children: [
          Expanded(child: _buildMap(context)),
          ValueListenableBuilder(
            valueListenable: refersh,
            builder: (_, __, ___) {
              if (detailProduct == null) return const SizedBox.shrink();
              return _bottomInfo(
                productModel: detailProduct!,
                onHideForm: () {
                  detailProduct = null;
                  refersh.value = !refersh.value;
                },
              );
            },
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // MAP + PRICE LABELS
  // ---------------------------------------------------------------------------
  Widget _buildMap(BuildContext context) {
    return Stack(
      children: [
        GoogleMap(
          mapType: MapType.hybrid, // keep your preferred map type
          initialCameraPosition: _initialPosition,
          markers: _markers,
          onMapCreated: (controller) {
            _controller = controller;
            controller.setMapStyle(_mapStyle);
            _updateMarkerLabels();
          },
          onCameraMove: (_) => _updateMarkerLabels(),
          myLocationEnabled: true,
          zoomControlsEnabled: true,
        ),

        // ---------------- PRICE LABELS ($4.00) ----------------
        ..._markerLabels.map((label) {
          return Positioned(
            left: label.offset.dx - 40,
            top: label.offset.dy - 60,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.75),
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: Colors.amber),
              ),
              child: Text(
                helper.currencyFormat(number: label.product.basePrice),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          );
        }),

        // ---------------- CLOSE BUTTON ----------------
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

  // ---------------------------------------------------------------------------
  // BOTTOM INFO CARD
  // ---------------------------------------------------------------------------
  Widget _bottomInfo({
    required ProductModel productModel,
    required VoidCallback onHideForm,
  }) {
    List<String> listImage = helper.productModelSplitImage(
      path: 'property',
      product: productModel,
      context: context,
    );

    return GestureDetector(
      onTap: () => helper.showItemPopupDetail(
        context: context,
        productModel: productModel,
        onTabProfile: (ProductModel p) {
          Navigation.goPage(
            context: context,
            page: ToViewUserPostProfilePage(paramProductModel: p),
          );
        },
      ),
      child: Container(
        height: 150,
        decoration: const BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 6,
              offset: Offset(0, -2),
            ),
          ],
        ),
        child: Row(
          children: [
            Padding(
              padding: const EdgeInsets.all(10),
              child: Container(
                width: 120,
                height: 120,
                clipBehavior: Clip.hardEdge,
                decoration: BoxDecoration(
                  color: Colors.black12,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: CarouselSlider(
                  options: CarouselOptions(
                    height: 120,
                    viewportFraction: 1,
                    autoPlay: true,
                  ),
                  items: listImage.map((url) {
                    return CachedNetworkImage(imageUrl: url, fit: BoxFit.cover);
                  }).toList(),
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(top: 10, right: 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      Translator.translate(productModel.keyTranslate),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      productModel.subTitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                    helper.timneAgo(productModel: productModel),
                    const SizedBox(height: 4),
                    helper.locationWidget(productModel: productModel),
                    const SizedBox(height: 8),
                    Text(
                      helper.currencyFormat(number: productModel.basePrice),
                      style: const TextStyle(
                        color: Colors.green,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// PRICE LABEL MODEL
// ---------------------------------------------------------------------------
class MarkerLabel {
  final ProductModel product;
  Offset offset;

  MarkerLabel({required this.product, required this.offset});
}
