import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
class SOSHistoryScreen extends StatelessWidget {
  const SOSHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {

    final user =
        FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(
        title:
            const Text(
          "SOS Alert History",
        ),
      ),

      body: StreamBuilder(
        stream:
            FirebaseFirestore.instance
                .collection(
                    'sos_alerts')
                .where(
                  'uid',
                  isEqualTo:
                      user?.uid,
                )
                .orderBy(
                  'timestamp',
                  descending: true,
                )
                .snapshots(),

        builder:
            (context, snapshot) {

          if (snapshot.connectionState ==
              ConnectionState.waiting) {

            return const Center(
              child:
                  CircularProgressIndicator(),
            );
          }

          if (!snapshot.hasData ||
              snapshot.data!.docs
                  .isEmpty) {

            return const Center(
              child: Text(
                "No SOS alerts found",
                style: TextStyle(
                  fontSize: 18,
                ),
              ),
            );
          }

          final alerts =
              snapshot.data!.docs;

          return ListView.builder(
            padding:
                const EdgeInsets.all(
              16,
            ),

            itemCount:
                alerts.length,

            itemBuilder:
                (context, index) {

              final data =
                  alerts[index];
                  final timestamp =
    data['timestamp'];

String formattedDate =
    "No Date";

if (timestamp != null) {

  formattedDate =
      DateFormat(
        "dd MMM yyyy, hh:mm a",
      ).format(
        timestamp.toDate(),
      );
}

              return Card(
                margin:
                    const EdgeInsets.only(
                  bottom: 16,
                ),

                child: ListTile(

                  leading:
                      const CircleAvatar(
                    child: Icon(
                      Icons.warning,
                      color:
                          Colors.red,
                    ),
                  ),

                  title: Text(
  "SOS Alert",
  style: const TextStyle(
    fontWeight: FontWeight.bold,
  ),
),

                  subtitle: Text(
  "Status: ${data['status']}\n"
  "Date: $formattedDate\n"
  "Lat: ${data.data().containsKey('latitude') ? data['latitude'] : 'N/A'}\n"
  "Lng: ${data.data().containsKey('longitude') ? data['longitude'] : 'N/A'}",
),
                ),
              );
            },
          );
        },
      ),
    );
  }
}