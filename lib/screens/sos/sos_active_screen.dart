import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:safeher/services/notification_service.dart';
import 'package:geolocator_android/geolocator_android.dart';
import 'package:url_launcher/url_launcher.dart';

class SosActiveScreen extends StatefulWidget {
  const SosActiveScreen({super.key});

  @override
  State<SosActiveScreen> createState() => _SosActiveScreenState();
}

class _SosActiveScreenState extends State<SosActiveScreen>
    with TickerProviderStateMixin {
  late AnimationController pulseController;

  bool sosActivated = false;

  int countdown = 5;

  Timer? timer;
StreamSubscription<Position>?
    locationStream;
  final currentUser = FirebaseAuth.instance.currentUser;

  @override
  void initState() {
    super.initState();

    pulseController = AnimationController(
      vsync: this,

      duration: const Duration(seconds: 1),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    pulseController.dispose();

    timer?.cancel();
    locationStream?.cancel();

    super.dispose();
  }

  Future<void> activateSOS() async {
    setState(() {
      sosActivated = true;
      countdown = 5;
    });

    timer = Timer.periodic(const Duration(seconds: 1), (timer) async {
      if (countdown == 0) {
        timer.cancel();

        await sendSOSAlert();

        return;
      }

      setState(() {
        countdown--;
      });
    });
  }

  Future<void> sendEmergencySMS(
  double latitude,
  double longitude,
) async {

  try {

    final contactsSnapshot =
        await FirebaseFirestore
            .instance
            .collection('users')
            .doc(currentUser!.uid)
            .collection('contacts')
            .get();

    if (contactsSnapshot.docs.isEmpty) {
      return;
    }

    final phones =
        contactsSnapshot.docs
            .map(
              (doc) =>
                  doc['phone']
                      .toString(),
            )
            .join(',');

    final message =
        "🚨 SOS Alert!\n"
        "I may be in danger.\n"
        "Live Location:\n"
        "https://maps.google.com/?q=$latitude,$longitude";

    final Uri smsUri =
        Uri.parse(
      "sms:$phones?body=${Uri.encodeComponent(message)}",
    );

    await launchUrl(
      smsUri,
    );

  } catch (e) {

    print(
      "SMS Error: $e",
    );
  }
}

Future<void> sendSOSAlert() async {
  await NotificationService
      .showSOSNotification();


  final existingAlert =
      await FirebaseFirestore
          .instance
          .collection('sos_alerts')
          .where(
            'uid',
            isEqualTo:
                currentUser!.uid,
          )
          .where(
            'status',
            isEqualTo:
                'active',
          )
          .limit(1)
          .get();
     print(
  "ACTIVE SOS COUNT = ${existingAlert.docs.length}",
);     

  if (existingAlert.docs.isNotEmpty) {

    if (!mounted) return;

    setState(() {
      sosActivated = false;
      countdown = 5;
    });

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(

      const SnackBar(
        content: Text(
          "SOS already active",
        ),
      ),
    );

    return;
  }

  await FirebaseFirestore
      .instance
      .collection(
          'sos_alerts')
      .add({

    'uid':
        currentUser!.uid,

    'email':
        currentUser!.email,

    'status':
        'active',

    'timestamp':
        Timestamp.now(),
  });
  await NotificationService
    .showSOSNotification();

  locationStream =
Geolocator.getPositionStream(
  locationSettings:
    AndroidSettings(

  accuracy:
      LocationAccuracy.high,

  distanceFilter: 5,

  foregroundNotificationConfig:
      const ForegroundNotificationConfig(

    notificationTitle:
        "SafeHer SOS Active",

    notificationText:
        "Location tracking is running",

    enableWakeLock: true,
  ),
),
).listen(

    (
      Position position,
    ) async {

      final snapshot =
          await FirebaseFirestore
              .instance
              .collection(
                  'sos_alerts')
              .where(
                'uid',
                isEqualTo:
                    currentUser!.uid,
              )
              .where(
                'status',
                isEqualTo:
                    'active',
              )
              .limit(1)
              .get();

      if (snapshot.docs.isNotEmpty) {

        await snapshot
    .docs
    .first
    .reference
    .update({

  'latitude':
      position.latitude,

  'longitude':
      position.longitude,
});

await sendEmergencySMS(
  position.latitude,
  position.longitude,
);
      }
    },
  );

  if (!mounted) return;

  showDialog(
    context: context,

    builder: (_) {

      return AlertDialog(

        shape:
            RoundedRectangleBorder(
          borderRadius:
              BorderRadius.circular(
                  24),
        ),

        title:
            const Text(
          "SOS Alert Sent",
        ),

        content:
            const Text(
          "Your emergency alert has been activated successfully.",
        ),

        actions: [

          TextButton(

            onPressed: () {

              Navigator.pop(
                context,
              );

              Navigator.pop(
                context,
              );
            },

            child:
                const Text(
              "OK",
            ),
          ),
        ],
      );
    },
  );
}

  Future<void> cancelSOS() async {
    timer?.cancel();

    final snapshot = await FirebaseFirestore.instance
        .collection('sos_alerts')
        .where('uid', isEqualTo: currentUser!.uid)
        .where('status', isEqualTo: 'active')
        .limit(1)
        .get();

   for (final doc in snapshot.docs) {
  await doc.reference.update({
    'status': 'resolved',
    'resolvedAt': FieldValue.serverTimestamp(),
  });
}
await NotificationService
    .cancelNotification();

    setState(() {
      sosActivated = false;
      countdown = 5;
    });

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          snapshot.docs.isEmpty
              ? "SOS cancelled before alert was sent"
              : "SOS stopped successfully",
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FC),

      appBar: AppBar(
        backgroundColor: Colors.transparent,

        elevation: 0,

        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black),

          onPressed: () {
            Navigator.pop(context);
          },
        ),

        title: const Text(
          "Emergency SOS",

          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),

        centerTitle: true,
      ),

      body: Padding(
        padding: const EdgeInsets.all(20),

        child: Column(
          children: [
            const SizedBox(height: 20),

            const Text(
              "Press and hold the SOS button during emergencies",

              textAlign: TextAlign.center,

              style: TextStyle(color: Colors.grey, fontSize: 16),
            ),

            const SizedBox(height: 50),

            Expanded(
              child: Center(
                child: AnimatedBuilder(
                  animation: pulseController,

                  builder: (context, child) {
                    double scale = sosActivated
                        ? 1 + pulseController.value * 0.1
                        : 1;

                    return Transform.scale(
                      scale: scale,

                      child: GestureDetector(
                        onLongPress: activateSOS,

                        child: Container(
                          height: 220,
                          width: 220,

                          decoration: BoxDecoration(
                            shape: BoxShape.circle,

                            gradient: LinearGradient(
                              colors: sosActivated
                                  ? [Colors.red.shade300, Colors.red]
                                  : [
                                      const Color(0xFFFF9A9E),

                                      const Color(0xFFFF6A88),
                                    ],
                            ),

                            boxShadow: [
                              BoxShadow(
                                color: Colors.red.withOpacity(0.35),

                                blurRadius: 30,

                                spreadRadius: 5,
                              ),
                            ],
                          ),

                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,

                            children: [
                              const Icon(
                                Icons.warning,
                                color: Colors.white,

                                size: 60,
                              ),

                              const SizedBox(height: 10),

                              Text(
                                sosActivated ? countdown.toString() : "SOS",

                                style: const TextStyle(
                                  color: Colors.white,

                                  fontSize: 42,

                                  fontWeight: FontWeight.bold,
                                ),
                              ),

                              const SizedBox(height: 8),

                              Text(
                                sosActivated
                                    ? "Sending Alert..."
                                    : "Hold to Activate",

                                style: const TextStyle(
                                  color: Colors.white70,

                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),

            if (sosActivated)
              SizedBox(
                width: double.infinity,
                height: 55,

                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,

                    foregroundColor: Colors.red,

                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),

                      side: const BorderSide(color: Colors.red),
                    ),
                  ),

                  onPressed: cancelSOS,

                  child: const Text(
                    "Cancel SOS",

                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                ),
              ),

            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}
