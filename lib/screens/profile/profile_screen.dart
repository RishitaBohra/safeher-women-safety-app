import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../auth/login_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() =>
      _ProfileScreenState();
}

class _ProfileScreenState
    extends State<ProfileScreen> {

  bool notificationsEnabled = true;
  bool locationEnabled = true;

  bool isLoading = true;

  String name = "";
  String email = "";

  @override
  void initState() {
    super.initState();

    fetchUserData();
  }

  Future<void> fetchUserData() async {

    try {

      final user =
          FirebaseAuth.instance.currentUser;

      if (user != null) {

        final doc =
            await FirebaseFirestore.instance
                .collection('users')
                .doc(user.uid)
                .get();

        if (doc.exists) {

          setState(() {

            name = doc['name'] ?? '';
            email = doc['email'] ?? '';

            isLoading = false;
          });

        } else {

          setState(() {

            name = "SafeHer User";
            email = user.email ?? "";

            isLoading = false;
          });
        }
      }

    } catch (e) {

      print(e.toString());

      setState(() {

        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {

    if (isLoading) {

      return const Scaffold(
        body: Center(
          child:
              CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      backgroundColor:
          const Color(0xFFF7F8FC),

      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding:
                const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 10,
            ),

            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,

              children: [

                // ================= TOP BAR =================

                Row(
                  children: [

                    IconButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },

                      icon: const Icon(
                        Icons.arrow_back_ios,
                      ),
                    ),

                    const SizedBox(width: 6),

                    const Text(
                      "Profile",
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight:
                            FontWeight.bold,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                // ================= PROFILE CARD =================

                Container(
                  width: double.infinity,
                  padding:
                      const EdgeInsets.all(16),

                  decoration: BoxDecoration(
                    color: Colors.white,

                    borderRadius:
                        BorderRadius.circular(
                      32,
                    ),

                    boxShadow: [
                      BoxShadow(
                        color: Colors.black
                            .withOpacity(0.04),
                        blurRadius: 16,
                      ),
                    ],
                  ),

                  child: Column(
                    children: [

                      // PROFILE IMAGE

                      Container(
                        height: 85,
                        width: 85,

                        decoration: BoxDecoration(
                          shape: BoxShape.circle,

                          gradient:
                              const LinearGradient(
                            colors: [
                              Color(0xFFFF9A9E),
                              Color(0xFFFF6A88),
                            ],
                            begin:
                                Alignment.topLeft,
                            end: Alignment
                                .bottomRight,
                          ),

                          boxShadow: [
                            BoxShadow(
                              color: Colors
                                  .pink
                                  .withOpacity(
                                0.25,
                              ),
                              blurRadius: 20,
                              spreadRadius: 4,
                            ),
                          ],
                        ),

                        child: const Icon(
                          Icons.person,
                          color: Colors.white,
                          size: 60,
                        ),
                      ),

                      const SizedBox(height: 20),

                      // NAME

                      Text(
                        name,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight:
                              FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 8),

                      // EMAIL

                      Text(
                        email,
                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 15,
                        ),
                      ),

                      const SizedBox(height: 22),

                      // EDIT BUTTON

                      Container(
                        padding:
                            const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 10,
                        ),

                        decoration: BoxDecoration(
                          color:
                              const Color(
                            0xFFFFF3F5,
                          ),

                          borderRadius:
                              BorderRadius.circular(
                            20,
                          ),
                        ),

                        child: const Row(
                          mainAxisSize:
                              MainAxisSize.min,

                          children: [

                            Icon(
                              Icons.edit,
                              color: Color(
                                0xFFFF6A88,
                              ),
                              size: 18,
                            ),

                            SizedBox(width: 8),

                            Text(
                              "Edit Profile",
                              style: TextStyle(
                                color: Color(
                                  0xFFFF6A88,
                                ),
                                fontWeight:
                                    FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 28),

                      // STATS

                      Row(
                        mainAxisAlignment:
                            MainAxisAlignment
                                .spaceAround,

                        children: [

                          profileStat(
                            "4",
                            "Contacts",
                          ),

                          profileStat(
                            "12",
                            "Alerts",
                          ),

                          profileStat(
                            "24/7",
                            "Protected",
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 18),

                // ================= SAFETY STATUS =================

                Container(
                  padding: const EdgeInsets.all(22),

                  decoration: BoxDecoration(
                    gradient:
                        const LinearGradient(
                      colors: [
                        Color(0xFFFF9A9E),
                        Color(0xFFFF6A88),
                      ],
                    ),

                    borderRadius:
                        BorderRadius.circular(
                      30,
                    ),
                  ),

                  child: Row(
                    children: [

                      Container(
                        padding:
                            const EdgeInsets.all(
                          16,
                        ),

                        decoration: BoxDecoration(
                          color: Colors.white
                              .withOpacity(0.18),

                          borderRadius:
                              BorderRadius.circular(
                            20,
                          ),
                        ),

                        child: const Icon(
                          Icons.shield,
                          color: Colors.white,
                          size: 34,
                        ),
                      ),

                      const SizedBox(width: 18),

                      const Expanded(
                        child: Column(
                          crossAxisAlignment:
                              CrossAxisAlignment
                                  .start,

                          children: [

                            Text(
                              "Safety Protection Active",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight:
                                    FontWeight.bold,
                              ),
                            ),

                            SizedBox(height: 8),

                            Text(
                              "Your emergency safety system is active and monitoring your protection.",
                              style: TextStyle(
                                color: Colors.white70,
                                height: 1.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 28),

                // ================= LOGOUT =================

                SizedBox(
                  width: double.infinity,
                  height: 56,

                  child: ElevatedButton(
                    style:
                        ElevatedButton.styleFrom(
                      backgroundColor:
                          Colors.red,

                      foregroundColor:
                          Colors.white,

                      shape:
                          RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(
                          22,
                        ),
                      ),
                    ),

                    onPressed: () async {

  await FirebaseAuth.instance.signOut();

  if (!mounted) return;

  Navigator.pushAndRemoveUntil(
    context,
    MaterialPageRoute(
      builder: (_) => const LoginScreen(),
    ),
    (route) => false,
  );
},

                    child: const Row(
                      mainAxisAlignment:
                          MainAxisAlignment
                              .center,

                      children: [

                        Icon(Icons.logout),

                        SizedBox(width: 10),

                        Text(
                          "Logout",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight:
                                FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 30),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget profileStat(
    String value,
    String label,
  ) {
    return Column(
      children: [

        Text(
          value,
          style: const TextStyle(
            fontSize: 24,
            fontWeight:
                FontWeight.bold,
            color: Color(0xFFFF6A88),
          ),
        ),

        const SizedBox(height: 6),

        Text(
          label,
          style: const TextStyle(
            color: Colors.grey,
          ),
        ),
      ],
    );
  }
}