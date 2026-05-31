import 'package:flutter/material.dart';
import '../contacts/emergency_contacts_screen.dart';
import '../maps/live_location_screen.dart';
import '../profile/profile_screen.dart';
import '../sos/sos_active_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:geolocator/geolocator.dart';
import '../sos/sos_history_screen.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:geocoding/geocoding.dart';
import '../emergency/emergency_places_screen.dart';
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  bool isLoading = false;
  String currentCity = "Loading...";
  int currentIndex = 0;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
      lowerBound: 0.95,
      upperBound: 1.05,
    )..repeat(reverse: true);
    getCurrentLocationName();
  }

  Future<void> getCurrentLocationName() async {
  try {

    bool serviceEnabled =
        await Geolocator.isLocationServiceEnabled();

    if (!serviceEnabled) {
      setState(() {
        currentCity = "Enable GPS";
      });
      return;
    }

    LocationPermission permission =
        await Geolocator.checkPermission();

    if (permission ==
        LocationPermission.denied) {

      permission =
          await Geolocator.requestPermission();
    }

    if (permission ==
            LocationPermission.denied ||
        permission ==
            LocationPermission.deniedForever) {

      setState(() {
        currentCity = "Permission denied";
      });


  return;
}

    Position position =
        await Geolocator.getCurrentPosition(
      desiredAccuracy:
          LocationAccuracy.high,
    );
    print(
 "Lat:${position.latitude} Long:${position.longitude}"
);

    try {

      List<Placemark> placemarks =
          await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      if (placemarks.isNotEmpty &&
          placemarks.first.locality != null) {

        setState(() {

          currentCity =
              "${placemarks.first.locality}, ${placemarks.first.administrativeArea}";
        });

      } else {

        setState(() {
          currentCity =
              "${position.latitude.toStringAsFixed(2)}, ${position.longitude.toStringAsFixed(2)}";
        });
      }

    } catch (_) {

      setState(() {
        currentCity =
            "${position.latitude.toStringAsFixed(2)}, ${position.longitude.toStringAsFixed(2)}";
      });
    }

  } catch (e) {

    setState(() {
      currentCity = "Location unavailable";
    });
  }
}

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void showSOSDialog() {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(28),
          ),
          title: const Text(
            "Emergency SOS",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Your emergency alert and live location will instantly be shared with your trusted contacts.",
                style: TextStyle(height: 1.5),
              ),
              const SizedBox(height: 12),
              Text(
                "Stay Safe • Stay Connected",
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);
              },
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFF3B5F),
                foregroundColor: Colors.white,
              ),
              onPressed: () async {
                Navigator.pop(dialogContext);

                if (mounted) {
                  setState(() {
                    isLoading = true;
                  });
                }
  final contacts =
      await FirebaseFirestore
          .instance
          .collection('users')
          .doc(
            FirebaseAuth
                .instance
                .currentUser!
                .uid,
          )
          .collection(
            'contacts',
          )
          .get();

  if (contacts.docs.isEmpty) {

    if (!mounted) return;

    setState(() {
      isLoading = false;
    });

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(

      const SnackBar(
        content: Text(
          "Please add at least one emergency contact",
        ),
      ),
    );

    return;
  }
                try {
                  LocationPermission permission =
                      await Geolocator.checkPermission();

                  if (permission == LocationPermission.denied) {
                    permission = await Geolocator.requestPermission();
                  }

                  if (permission == LocationPermission.denied ||
                      permission == LocationPermission.deniedForever) {
                    if (!mounted) return;

                    setState(() {
                      isLoading = false;
                    });

                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("Location permission required"),
                      ),
                    );
                    return;
                  }

                  bool serviceEnabled =
                      await Geolocator.isLocationServiceEnabled();

                  if (!serviceEnabled) {
                    if (!mounted) return;

                    setState(() {
                      isLoading = false;
                    });

                    showDialog(
                      context: context,
                      builder: (_) {
                        return AlertDialog(
                          title: const Text("Location Disabled"),
                          content: const Text("Please enable GPS to use SOS."),
                          actions: [
                            TextButton(
                              onPressed: () {
                                Navigator.pop(context);
                              },
                              child: const Text("OK"),
                            ),
                          ],
                        );
                      },
                    );
                    return;
                  }

                  Position position = await Geolocator.getCurrentPosition(
                    desiredAccuracy: LocationAccuracy.high,
                  );

                  final user = FirebaseAuth.instance.currentUser;

                
                  final locationLink =
                      "https://maps.google.com/?q=${position.latitude},${position.longitude}";

                  final contactsSnapshot = await FirebaseFirestore.instance
                      .collection('users')
                      .doc(user!.uid)
                      .collection('contacts')
                      .get();

                  final phoneNumbers = contactsSnapshot.docs
                      .map((doc) => doc['phone'].toString())
                      .toList();

                  if (!mounted) return;

                  setState(() {
                    isLoading = false;
                  });

                 

                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Live Location Ready")),
                  );

                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const SosActiveScreen()),
                  );
                } catch (e) {
                  if (mounted) {
                    setState(() {
                      isLoading = false;
                    });
                  }

                  print(e.toString());
                }
              },
              child: const Text("Activate"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FC),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ================= TOP BAR =================
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Current Location",
                          style: TextStyle(color: Colors.grey, fontSize: 13),
                        ),

                        const SizedBox(height: 4),

                        Text(
                          currentCity,
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        topIcon(Icons.notifications_none),
                        const SizedBox(width: 10),
                        topIcon(Icons.person),
                      ],
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                // ================= INFO CARD =================
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(30),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.04),
                        blurRadius: 16,
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: const [
                            Text(
                              "Are you in an emergency?",
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                height: 1.4,
                              ),
                            ),
                            SizedBox(height: 12),
                            Text(
                              "Press the SOS button and your live location will instantly be shared with trusted contacts.",
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey,
                                height: 1.6,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      Image.asset(
                        "assets/images/homepageillustration.png",
                        height: 90,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 26),

                // ================= SOS CARD =================
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 28),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Colors.white, Color(0xFFFFF1F2)],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                    borderRadius: BorderRadius.circular(34),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.pink.withOpacity(0.08),
                        blurRadius: 18,
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      const Text(
                        "Tap in emergency",
                        style: TextStyle(color: Colors.grey, fontSize: 14),
                      ),
                      const SizedBox(height: 22),
                      GestureDetector(
                        onTap: () {
                          if (isLoading) return;

                          showSOSDialog();
                        },
                        child: ScaleTransition(
                          scale: _controller,
                          child: Container(
                            height: 200,
                            width: 200,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: const Color(0xFFFFEBEE),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.pink.withOpacity(0.18),
                                  blurRadius: 30,
                                  spreadRadius: 10,
                                ),
                              ],
                            ),
                            child: Center(
                              child: Container(
                                height: 145,
                                width: 145,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  gradient: const LinearGradient(
                                    colors: [
                                      Color(0xFFFF9A9E),
                                      Color(0xFFFF6A88),
                                    ],
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.pink.withOpacity(0.25),
                                      blurRadius: 25,
                                      spreadRadius: 5,
                                    ),
                                  ],
                                ),
                                child: Center(
                                  child: isLoading
                                      ? const CircularProgressIndicator(
                                          color: Colors.white,
                                        )
                                      : const Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Icon(
                                              Icons.warning,
                                              color: Colors.white,
                                              size: 34,
                                            ),
                                            SizedBox(height: 6),
                                            Text(
                                              "SOS",
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 34,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            SizedBox(height: 4),
                                            Text(
                                              "Press 3 seconds",
                                              style: TextStyle(
                                                color: Colors.white70,
                                                fontSize: 12,
                                              ),
                                            ),
                                          ],
                                        ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFF3F5),
                          borderRadius: BorderRadius.circular(18),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.location_on,
                              color: Color(0xFFFF6A88),
                              size: 18,
                            ),
                            SizedBox(width: 6),
                            Text(
                              "Live location enabled",
                              style: TextStyle(
                                color: Color(0xFFFF6A88),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 18),

                // ================= QUICK ACTIONS =================
                const Text(
                  "Quick Actions",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),

                const SizedBox(height: 18),

                GridView.count(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: 2,
                  crossAxisSpacing: 14,
                  mainAxisSpacing: 14,
                  childAspectRatio: 1.0,
                  children: [
                    actionCard(
                      icon: Icons.people,
                      title: "Emergency\nContacts",
                      color: Colors.orange,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const EmergencyContactsScreen(),
                          ),
                        );
                      },
                    ),
                    actionCard(
                      icon: Icons.location_on,
                      title: "Live\nLocation",
                      color: Colors.red,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const LiveLocationScreen(),
                          ),
                        );
                      },
                    ),
                    actionCard(
                      icon: Icons.local_police,
                      title: "Police\nSupport",
                      color: Colors.blue,
                      onTap: () async {
                        final Uri phoneUri = Uri(scheme: 'tel', path: '112');
                        await launchUrl(phoneUri);
                      },
                    ),
                    actionCard(
                      icon: Icons.local_hospital,
                      title: "Medical\nEmergency",
                      color: Colors.green,
                      onTap: () async {
                        final Uri phoneUri = Uri(scheme: 'tel', path: '108');
                        await launchUrl(phoneUri);
                      },
                    ),
                    actionCard(
                      icon: Icons.support_agent,
                      title: "Women\nHelpline",
                      color: Colors.pink,
                      onTap: () async {
                        final Uri phoneUri = Uri(scheme: 'tel', path: '1091');
                        await launchUrl(phoneUri);
                      },
                    ),
                    actionCard(
                      icon: Icons.history,
                      title: "SOS\nHistory",
                      color: Colors.purple,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const SOSHistoryScreen(),
                          ),
                        );
                      },
                    ),
                  ],
                ),

                const SizedBox(height: 18),

                // ================= SAFETY TIPS =================
                const Text(
                  "Safety Tips",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),

                const SizedBox(height: 18),

                safetyTip(
                  icon: Icons.shield,
                  title: "Stay Alert",
                  subtitle:
                      "Always share your live location with trusted contacts.",
                ),

                safetyTip(
                  icon: Icons.phone,
                  title: "Keep Phone Charged",
                  subtitle:
                      "Ensure your device has enough battery during travel.",
                ),

                safetyTip(
                  icon: Icons.nightlight_round,
                  title: "Avoid Isolated Areas",
                  subtitle: "Prefer well-lit and crowded places at night.",
                ),

                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),

      // ================= BOTTOM NAVIGATION =================
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: currentIndex,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: const Color(0xFFFF6A88),
        unselectedItemColor: Colors.grey,
        onTap: (index) {
          setState(() {
            currentIndex = index;
          });

          if (index == 1) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const EmergencyContactsScreen(),
              ),
            );
          }

          if (index == 2) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const LiveLocationScreen()),
            );
          }

          if (index == 3) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const ProfileScreen()),
            );
          }
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
          BottomNavigationBarItem(icon: Icon(Icons.people), label: "Contacts"),
          BottomNavigationBarItem(
            icon: Icon(Icons.location_on),
            label: "Location",
          ),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: "Profile"),
        ],
      ),
    );
  }

  Widget topIcon(IconData icon) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10),
        ],
      ),
      child: Icon(icon, color: Colors.black87),
    );
  }

  Widget actionCard({
    required IconData icon,
    required String title,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(28),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 12),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: color.withOpacity(0.12),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Icon(icon, color: color, size: 30),
            ),
            const SizedBox(height: 14),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget safetyTip({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFFFFF3F5),
              borderRadius: BorderRadius.circular(18),
            ),
            child: Icon(icon, color: const Color(0xFFFF6A88)),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: const TextStyle(color: Colors.grey, height: 1.4),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
