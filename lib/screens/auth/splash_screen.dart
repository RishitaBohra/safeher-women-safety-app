import 'dart:async';
import 'package:flutter/material.dart';
import 'login_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../home/home_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() =>
      _SplashScreenState();
}

class _SplashScreenState
    extends State<SplashScreen>
    with SingleTickerProviderStateMixin {

  late AnimationController _controller;

  late Animation<double>
      fadeAnimation;

  late Animation<double>
      scaleAnimation;

  @override
  void initState() {
    super.initState();

    // ================= ANIMATION =================

    _controller = AnimationController(
      vsync: this,
      duration:
          const Duration(seconds: 2),
    );

    fadeAnimation =
        Tween<double>(
      begin: 0,
      end: 1,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeIn,
      ),
    );

    scaleAnimation =
        Tween<double>(
      begin: 0.7,
      end: 1,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.elasticOut,
      ),
    );

    _controller.forward();

    // ================= NAVIGATION =================

    Timer(
  const Duration(seconds: 4),
  () {

    final user =
        FirebaseAuth.instance.currentUser;

    if (!mounted) return;

    if (user != null) {

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) =>
              const HomeScreen(),
        ),
      );

    } else {

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) =>
              const LoginScreen(),
        ),
      );
    }
  },
);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      body: Container(
        width: double.infinity,
        height: double.infinity,

        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [

              Color(0xFFFF9A9E),
              Color(0xFFFF6A88),
              Color(0xFFFF3B5F),
            ],

            begin: Alignment.topLeft,
            end:
                Alignment.bottomRight,
          ),
        ),

        child: SafeArea(
          child: Column(
            children: [

              const Spacer(),

              // ================= LOGO SECTION =================

              FadeTransition(
                opacity: fadeAnimation,

                child: ScaleTransition(
                  scale: scaleAnimation,

                  child: Column(
                    children: [

                      // LOGO CIRCLE

                      Container(
                        height: 150,
                        width: 150,

                        decoration:
                            BoxDecoration(
                          shape:
                              BoxShape.circle,

                          color: Colors.white
                              .withOpacity(
                            0.15,
                          ),

                          border:
                              Border.all(
                            color: Colors
                                .white
                                .withOpacity(
                              0.2,
                            ),

                            width: 2,
                          ),

                          boxShadow: [
                            BoxShadow(
                              color: Colors
                                  .white
                                  .withOpacity(
                                0.12,
                              ),
                              blurRadius:
                                  25,
                              spreadRadius:
                                  4,
                            ),
                          ],
                        ),

                        child: Center(
  child: ClipRRect(
    borderRadius:
        BorderRadius.circular(20),

    child: Image.asset(
      "assets/images/logo.png",
      height: 90,
      width: 90,
      fit: BoxFit.cover,
    ),
  ),
),
                      ),

                      const SizedBox(
                        height: 34,
                      ),

                      // APP NAME

                      const Text(
                        "SafeHer",
                        style: TextStyle(
                          color:
                              Colors.white,
                          fontSize: 46,
                          fontWeight:
                              FontWeight
                                  .bold,
                          letterSpacing:
                              1,
                        ),
                      ),

                      const SizedBox(
                        height: 12,
                      ),

                      // TAGLINE

                      const Padding(
                        padding:
                            EdgeInsets.symmetric(
                          horizontal: 30,
                        ),

                        child: Text(
                          "Women Safety & Emergency Assistance",
                          textAlign:
                              TextAlign.center,

                          style:
                              TextStyle(
                            color:
                                Colors.white70,
                            fontSize: 16,
                            height: 1.5,
                            letterSpacing:
                                0.5,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const Spacer(),

              // ================= SAFETY CARD =================

              Container(
                margin:
                    const EdgeInsets.symmetric(
                  horizontal: 28,
                ),

                padding:
                    const EdgeInsets.all(
                  20,
                ),

                decoration:
                    BoxDecoration(
                  color: Colors.white
                      .withOpacity(
                    0.12,
                  ),

                  borderRadius:
                      BorderRadius.circular(
                    28,
                  ),

                  border: Border.all(
                    color: Colors.white
                        .withOpacity(
                      0.15,
                    ),
                  ),
                ),

                child: const Row(
                  children: [

                    Icon(
                      Icons.favorite,
                      color:
                          Colors.white,
                    ),

                    SizedBox(
                      width: 14,
                    ),

                    Expanded(
                      child: Text(
                        "Your safety is our highest priority.",
                        style: TextStyle(
                          color:
                              Colors.white,
                          fontSize: 15,
                          height: 1.5,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(
                height: 40,
              ),

              // ================= LOADING =================

              Column(
                children: [

                  SizedBox(
                    width: 34,
                    height: 34,

                    child:
                        CircularProgressIndicator(
                      strokeWidth: 3,

                      valueColor:
                          AlwaysStoppedAnimation(
                        Colors.white,
                      ),
                    ),
                  ),

                  const SizedBox(
                    height: 18,
                  ),

                  const Text(
                    "Initializing Safety Services...",
                    style: TextStyle(
                      color:
                          Colors.white70,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),

              const SizedBox(
                height: 50,
              ),
            ],
          ),
        ),
      ),
    );
  }
}