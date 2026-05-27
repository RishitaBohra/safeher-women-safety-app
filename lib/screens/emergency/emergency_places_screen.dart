import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:url_launcher/url_launcher.dart';

class EmergencyPlacesScreen extends StatefulWidget {
  const EmergencyPlacesScreen({super.key});

  @override
  State<EmergencyPlacesScreen> createState() =>
      _EmergencyPlacesScreenState();
}

class _EmergencyPlacesScreenState
    extends State<EmergencyPlacesScreen> {

  bool isLoading = true;

  double latitude = 0;
  double longitude = 0;

  @override
  void initState() {
    super.initState();

    getCurrentLocation();
  }

  Future<void>
      getCurrentLocation() async {

    try {

      Position position =
          await Geolocator
              .getCurrentPosition(
        desiredAccuracy:
            LocationAccuracy.high,
      );

      if (!mounted) return;

      setState(() {

        latitude =
            position.latitude;

        longitude =
            position.longitude;

        isLoading = false;
      });

    } catch (e) {

      if (!mounted) return;

      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> openMaps(
      String type) async {

    final Uri url =
        Uri.parse(

      "https://www.google.com/maps/search/$type/@$latitude,$longitude,14z",
    );

    await launchUrl(
      url,
      mode:
          LaunchMode.externalApplication,
    );
  }

  Widget emergencyCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    required Color color,
  }) {

    return GestureDetector(

      onTap: onTap,

      child: Container(

        margin:
            const EdgeInsets.only(
          bottom: 18,
        ),

        padding:
            const EdgeInsets.all(
          18,
        ),

        decoration:
            BoxDecoration(

          color: Colors.white,

          borderRadius:
              BorderRadius.circular(
                  28),

          boxShadow: [

            BoxShadow(
              color: Colors.black
                  .withOpacity(
                      0.05),

              blurRadius: 10,

              offset:
                  const Offset(
                0,
                4,
              ),
            ),
          ],
        ),

        child: Row(
          children: [

            Container(

              height: 65,
              width: 65,

              decoration:
                  BoxDecoration(

                color:
                    color.withOpacity(
                        0.15),

                shape:
                    BoxShape.circle,
              ),

              child: Icon(
                icon,
                color: color,
                size: 34,
              ),
            ),

            const SizedBox(
              width: 18,
            ),

            Expanded(
              child: Column(

                crossAxisAlignment:
                    CrossAxisAlignment
                        .start,

                children: [

                  Text(
                    title,

                    style:
                        const TextStyle(

                      fontSize: 18,

                      fontWeight:
                          FontWeight.bold,
                    ),
                  ),

                  const SizedBox(
                    height: 6,
                  ),

                  Text(
                    subtitle,

                    style:
                        TextStyle(
                      color: Colors
                          .grey.shade600,
                    ),
                  ),
                ],
              ),
            ),

            const Icon(
              Icons.arrow_forward_ios,
              size: 18,
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(
      BuildContext context) {

    return Scaffold(

      backgroundColor:
          const Color(
        0xFFF7F8FC,
      ),

      appBar: AppBar(

        backgroundColor:
            Colors.transparent,

        elevation: 0,

        centerTitle: true,

        title: const Text(
          "Emergency Help",

          style: TextStyle(
            color: Colors.black,
            fontWeight:
                FontWeight.bold,
          ),
        ),

        iconTheme:
            const IconThemeData(
          color: Colors.black,
        ),
      ),

      body: isLoading

          ? const Center(
              child:
                  CircularProgressIndicator(),
            )

          : Padding(

              padding:
                  const EdgeInsets.all(
                16,
              ),

              child: Column(

                children: [

                  emergencyCard(

                    icon:
                        Icons.local_hospital,

                    title:
                        "Nearby Hospitals",

                    subtitle:
                        "Find hospitals near your location",

                    color:
                        Colors.red,

                    onTap: () {

                      openMaps(
                          "hospital");
                    },
                  ),

                  emergencyCard(

                    icon:
                        Icons.local_police,

                    title:
                        "Nearby Police",

                    subtitle:
                        "Find nearby police stations",

                    color:
                        Colors.blue,

                    onTap: () {

                      openMaps(
                          "police station");
                    },
                  ),
                ],
              ),
            ),
    );
  }
}