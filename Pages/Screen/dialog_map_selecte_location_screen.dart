import 'package:findup_mvvm/Core/services/translate.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class DialogMapSelecteLocationScreen extends StatefulWidget {
  double defaultLat;
  double defaultLon;
  Function(Map<String, dynamic> mapSelectedLatLong) selectedCalBack;

  DialogMapSelecteLocationScreen({
    super.key,
    required this.selectedCalBack,
    required this.defaultLat,
    required this.defaultLon,
  });

  @override
  State<DialogMapSelecteLocationScreen> createState() =>
      _DialogMapSelecteLocationScreenState();
}

class _DialogMapSelecteLocationScreenState
    extends State<DialogMapSelecteLocationScreen> {
  GoogleMapController? _controller;

  double latTemp = 0.0;
  double lonTemp = 0.0;

  late Set<Marker> _markers;
  ValueNotifier<bool> mapRefresh = ValueNotifier(false);

  static const CameraPosition _initialPosition = CameraPosition(
    target: LatLng(11.5564, 104.9282),
    zoom: 10,
  );

  @override
  void initState() {
    latTemp=widget.defaultLat;
    lonTemp=widget.defaultLon;
    _markers = {
      Marker(
        markerId: const MarkerId("selected_location"),
        position: LatLng(widget.defaultLat, widget.defaultLon),
        icon: AssetMapBitmap('assets/icons/remark_icon.png', width: 40),
      )
    };

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: mapRefresh,
      builder: (context, value, child) {
        return Material(
          child: Stack(
            children: [
              GoogleMap(
                mapType: MapType.hybrid,
                initialCameraPosition: _initialPosition,
                onMapCreated: (controller) => _controller = controller,
                myLocationEnabled: true,
                myLocationButtonEnabled: true,
                zoomControlsEnabled: true,
                markers: _markers,
                onTap: _handleTap,
              ),

              // Bottom Buttons
              Positioned(
                bottom: 20,
                child: SizedBox(
                  width: MediaQuery.of(context).size.width,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // CLEAR
                      GestureDetector(
                        onTap: () {
                          widget.selectedCalBack({
                            'lat': 0.0,
                            'lon': 0.0,
                            'full_address': '',
                          });
                          Navigator.pop(context);
                        },
                        child: Container(
                          width: 100,
                          height: 40,
                          decoration: BoxDecoration(
                            color: Colors.black,
                            borderRadius: BorderRadius.circular(50),
                          ),
                          child:  Center(
                            child:
                                Text(Translator.translate('clear'), style: TextStyle(color: Colors.white)),
                          ),
                        ),
                      ),
                      const SizedBox(width: 20),

                      // CONFIRM
                      GestureDetector(
                        onTap: () async {
                          List<Placemark> placemarks =
                              await placemarkFromCoordinates(latTemp, lonTemp);
                          Placemark place = placemarks.first;

                          String fullAddress =
                              "${place.locality ?? ''} • ${place.subLocality ?? ''}${(place.street ?? '').isEmpty ? '' : ' • ${place.street}'}";

                          widget.selectedCalBack({
                            'lat': latTemp,
                            'lon': lonTemp,
                            'full_address': fullAddress,
                          });

                          Navigator.pop(context);
                        },
                        child: Container(
                          width: 100,
                          height: 40,
                          decoration: BoxDecoration(
                            color: Colors.blue,
                            borderRadius: BorderRadius.circular(50),
                          ),
                          child:  Center(
                            child: Text(Translator.translate('confirm'),
                                style: TextStyle(color: Colors.white)),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // ===========================
  // HANDLE MAP TAP
  // ===========================
  Future<void> _handleTap(LatLng position) async {
    latTemp = position.latitude;
    lonTemp = position.longitude;

    List<Placemark> placemarks =
        await placemarkFromCoordinates(latTemp, lonTemp);
    Placemark place = placemarks.first;

    String fullAddress =
        "${place.locality ?? ''} • ${place.subLocality ?? ''}${(place.street ?? '').isEmpty ? '' : ' • ${place.street}'}";

    widget.selectedCalBack({
      'lat': latTemp,
      'lon': lonTemp,
      'full_address': fullAddress,
      'city': place.locality,
      'district': place.subLocality,
      'street': place.street,
    });

    // Update marker with your remark icon
    _markers = {
      Marker(
        markerId: const MarkerId("selected_location"),
        position: position,
        icon: AssetMapBitmap('assets/icons/remark_icon.png', width: 40),
        infoWindow: InfoWindow(
          title: '',
          snippet: fullAddress,
        ),
      )
    };

    mapRefresh.value = !mapRefresh.value;

    // Move camera to the new marker
    _controller?.animateCamera(
      CameraUpdate.newLatLng(position),
    );

    // Open InfoWindow automatically
    Future.delayed(const Duration(milliseconds: 300), () {
      _controller?.showMarkerInfoWindow(const MarkerId("selected_location"));
    });
  }
}
