import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

class SOSHistoryScreen extends StatelessWidget {
  const SOSHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FC),

      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,

        iconTheme: const IconThemeData(
          color: Colors.black,
        ),

        title: const Text(
          "SOS Alert History",
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),

        centerTitle: true,
      ),

      body: StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection('sos_alerts')
            .where(
              'uid',
              isEqualTo: user?.uid,
            )
            .orderBy(
              'timestamp',
              descending: true,
            )
            .snapshots(),

        builder: (context, snapshot) {

          if (snapshot.connectionState ==
              ConnectionState.waiting) {

            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (!snapshot.hasData ||
              snapshot.data!.docs.isEmpty) {

            return Center(
              child: Column(
                mainAxisAlignment:
                    MainAxisAlignment.center,

                children: [

                  Container(
                    height: 100,
                    width: 100,

                    decoration: BoxDecoration(
                      color: Colors.pink.shade50,
                      shape: BoxShape.circle,
                    ),

                    child: const Icon(
                      Icons.history,
                      size: 50,
                      color: Color(0xFFFF6A88),
                    ),
                  ),

                  const SizedBox(
                    height: 20,
                  ),

                  const Text(
                    "No SOS History",
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight:
                          FontWeight.bold,
                    ),
                  ),

                  const SizedBox(
                    height: 10,
                  ),

                  const Text(
                    "Your emergency alerts will appear here",
                    style: TextStyle(
                      color: Colors.grey,
                    ),
                  ),
                ],
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
                  "dd MMM yyyy • hh:mm a",
                ).format(
                  timestamp.toDate(),
                );
              }

              final status =
                  data['status'];

              String city = "Unknown Location";

if (data.data().containsKey('city') &&
    data['city'] != null &&
    data['city'].toString().isNotEmpty) {

  city = data['city'];

} else if (
    data.data().containsKey('latitude') &&
    data.data().containsKey('longitude')) {

  city =
      "${data['latitude'].toStringAsFixed(2)}, "
      "${data['longitude'].toStringAsFixed(2)}";
}

              final bool active =
                  status == "active";

              return Container(
                margin:
                    const EdgeInsets.only(
                  bottom: 16,
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
                          24),

                  boxShadow: [
                    BoxShadow(
                      color: Colors.black
                          .withOpacity(
                              0.04),

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
                      height: 60,
                      width: 60,

                      decoration:
                          BoxDecoration(
                        color: active
                            ? Colors.red
                                .shade50
                            : Colors
                                .grey
                                .shade200,

                        shape:
                            BoxShape.circle,
                      ),

                      child: Icon(
                        Icons.warning,

                        color: active
                            ? Colors.red
                            : Colors.grey,

                        size: 30,
                      ),
                    ),

                    const SizedBox(
                      width: 16,
                    ),

                    Expanded(
                      child: Column(
                        crossAxisAlignment:
                            CrossAxisAlignment
                                .start,

                        children: [

                          Row(
                            children: [

                              const Text(
                                "SOS Alert",

                                style:
                                    TextStyle(
                                  fontWeight:
                                      FontWeight
                                          .bold,

                                  fontSize:
                                      17,
                                ),
                              ),

                              const Spacer(),

                              Container(
                                padding:
                                    const EdgeInsets
                                        .symmetric(
                                  horizontal:
                                      12,
                                  vertical:
                                      5,
                                ),

                                decoration:
                                    BoxDecoration(
                                  color: active
                                      ? Colors
                                          .red
                                          .shade50
                                      : Colors
                                          .green
                                          .shade50,

                                  borderRadius:
                                      BorderRadius
                                          .circular(
                                              20),
                                ),

                                child: Text(
                                  active
                                      ? "Active"
                                      : "Resolved",

                                  style:
                                      TextStyle(
                                    color: active
                                        ? Colors
                                            .red
                                        : Colors
                                            .green,

                                    fontWeight:
                                        FontWeight
                                            .bold,
                                  ),
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(
                            height: 8,
                          ),

                          Row(
                            children: [

                              const Icon(
                                Icons.location_on,
                                color: Color(
                                  0xFFFF6A88,
                                ),
                                size: 18,
                              ),

                              const SizedBox(
                                  width: 4),

                              Expanded(
                                child: Text(
                                  city,
                                  style:
                                      TextStyle(
                                    color: Colors
                                        .grey
                                        .shade700,
                                  ),
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(
                            height: 6,
                          ),

                          Row(
                            children: [

                              const Icon(
                                Icons.access_time,
                                size: 18,
                                color:
                                    Colors.grey,
                              ),

                              const SizedBox(
                                  width: 4),

                              Expanded(
                                child: Text(
                                  formattedDate,

                                  style:
                                      const TextStyle(
                                    color: Colors
                                        .grey,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}