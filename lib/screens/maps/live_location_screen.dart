import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';

class LiveLocationScreen
    extends StatefulWidget {

  const LiveLocationScreen({
    super.key,
  });

  @override
  State<LiveLocationScreen>
      createState() =>
          _LiveLocationScreenState();
}

class _LiveLocationScreenState
    extends State<
        LiveLocationScreen> {

  final Completer<
      GoogleMapController> controller =
      Completer();

  LatLng currentLatLng =
      const LatLng(
    26.9124,
    75.7873,
  );

  bool isLoading = true;

  String currentAddress =
      "Fetching location...";

  @override
  void initState() {

    super.initState();

    getCurrentLocation();
  }

  Future<void> getCurrentLocation()
      async {

    bool serviceEnabled;

    LocationPermission permission;

    serviceEnabled =
        await Geolocator
            .isLocationServiceEnabled();

    if (!serviceEnabled) {

      ScaffoldMessenger.of(context)
          .showSnackBar(
        const SnackBar(
          content: Text(
            "Enable location services",
          ),
        ),
      );

      return;
    }

    permission =
        await Geolocator
            .checkPermission();

    if (permission ==
        LocationPermission.denied) {

      permission =
          await Geolocator
              .requestPermission();
    }

    if (permission ==
            LocationPermission
                .denied ||
        permission ==
            LocationPermission
                .deniedForever) {

      ScaffoldMessenger.of(context)
          .showSnackBar(
        const SnackBar(
          content: Text(
            "Location permission denied",
          ),
        ),
      );

      return;
    }

    Position position =
        await Geolocator
            .getCurrentPosition(
      desiredAccuracy:
          LocationAccuracy.high,
    );

    currentLatLng = LatLng(
      position.latitude,
      position.longitude,
    );

    currentAddress =
        "Lat: ${position.latitude.toStringAsFixed(4)}, "
        "Lng: ${position.longitude.toStringAsFixed(4)}";

    setState(() {
      isLoading = false;
    });

    final GoogleMapController
        mapController =
        await controller.future;

    mapController.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(
          target: currentLatLng,
          zoom: 16,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor:
          Colors.white,

      appBar: AppBar(
        backgroundColor:
            Colors.white,

        elevation: 0,

        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios,
            color: Colors.black,
          ),

          onPressed: () {
            Navigator.pop(context);
          },
        ),

        title: const Text(
          "Live Location",

          style: TextStyle(
            color: Colors.black,
            fontWeight:
                FontWeight.bold,
          ),
        ),

        centerTitle: true,
      ),

      body: isLoading
          ? const Center(
              child:
                  CircularProgressIndicator(),
            )
          : Stack(
              children: [

                GoogleMap(
                  initialCameraPosition:
                      CameraPosition(
                    target:
                        currentLatLng,

                    zoom: 15,
                  ),

                  myLocationEnabled:
                      true,

                  myLocationButtonEnabled:
                      false,

                  zoomControlsEnabled:
                      false,

                  mapToolbarEnabled:
                      false,

                  onMapCreated:
                      (GoogleMapController
                          mapController) {

                    controller.complete(
                      mapController,
                    );
                  },

                  markers: {

                    Marker(
                      markerId:
                          const MarkerId(
                        "currentLocation",
                      ),

                      position:
                          currentLatLng,

                      infoWindow:
                          const InfoWindow(
                        title:
                            "You are here",
                      ),
                    ),
                  },
                ),

                Positioned(
                  top: 20,
                  left: 16,
                  right: 16,

                  child: Container(
                    padding:
                        const EdgeInsets.all(
                      16,
                    ),

                    decoration:
                        BoxDecoration(
                      color:
                          Colors.white,

                      borderRadius:
                          BorderRadius.circular(
                        20,
                      ),

                      boxShadow: [

                        BoxShadow(
                          color:
                              Colors.black
                                  .withOpacity(
                            0.08,
                          ),

                          blurRadius: 10,
                        ),
                      ],
                    ),

                    child: Row(
                      children: [

                        Container(
                          padding:
                              const EdgeInsets
                                  .all(
                            12,
                          ),

                          decoration:
                              BoxDecoration(
                            color: Colors
                                .pink.shade50,

                            shape:
                                BoxShape.circle,
                          ),

                          child: const Icon(
                            Icons.location_on,

                            color:
                                Color(
                              0xFFFF6A88,
                            ),
                          ),
                        ),

                        const SizedBox(
                          width: 12,
                        ),

                        Expanded(
                          child: Column(
                            crossAxisAlignment:
                                CrossAxisAlignment
                                    .start,

                            children: [

                              const Text(
                                "Current Location",

                                style:
                                    TextStyle(
                                  fontWeight:
                                      FontWeight
                                          .bold,
                                ),
                              ),

                              const SizedBox(
                                height: 4,
                              ),

                              Text(
                                currentAddress,

                                style:
                                    TextStyle(
                                  color: Colors
                                      .grey
                                      .shade700,

                                  fontSize:
                                      13,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                Positioned(
                  bottom: 30,
                  right: 20,

                  child: FloatingActionButton(
                    backgroundColor:
                        const Color(
                      0xFFFF6A88,
                    ),

                    onPressed:
                        getCurrentLocation,

                    child: const Icon(
                      Icons.my_location,
                      color:
                          Colors.white,
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}