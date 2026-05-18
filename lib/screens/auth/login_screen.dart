import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../home/home_screen.dart';
import 'signup_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() =>
      _LoginScreenState();
}

class _LoginScreenState
    extends State<LoginScreen> {

  final emailController =
      TextEditingController();

  final passwordController =
      TextEditingController();

  bool obscurePassword = true;
  bool rememberMe = false;
  bool isLoading = false;

  Future<void> loginUser() async {

    try {

      setState(() {
        isLoading = true;
      });

      await FirebaseAuth.instance
          .signInWithEmailAndPassword(
        email:
            emailController.text.trim(),

        password:
            passwordController.text.trim(),
      );

      if (!mounted) return;

      Navigator.pushReplacement(
        context,

        MaterialPageRoute(
          builder: (_) =>
              const HomeScreen(),
        ),
      );
    }

    on FirebaseAuthException catch (e) {

      String message =
          "Login failed";

      if (e.code ==
          'user-not-found') {

        message =
            "No user found";
      }

      else if (e.code ==
          'wrong-password') {

        message =
            "Wrong password";
      }

      else if (e.code ==
          'invalid-email') {

        message =
            "Invalid email";
      }

      ScaffoldMessenger.of(context)
          .showSnackBar(
        SnackBar(
          content: Text(message),
        ),
      );
    }

    finally {

      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {

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

                const SizedBox(height: 24),

                Center(
                  child: Column(
                    children: [

                      Container(
                        height: 90,
                        width: 90,

                        decoration: BoxDecoration(
                          shape: BoxShape.circle,

                          gradient:
                              const LinearGradient(
                            colors: [
                              Color(0xFFFF9A9E),
                              Color(0xFFFF6A88),
                            ],
                          ),
                        ),

                        child: const Icon(
                          Icons.shield_rounded,
                          color: Colors.white,
                          size: 45,
                        ),
                      ),

                      const SizedBox(height: 20),

                      const Text(
                        "Welcome Back",
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight:
                              FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 10),

                      const Text(
                        "Login to continue using SafeHer",
                        style: TextStyle(
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 30),

                buildLabel(
                  "Email Address",
                ),

                const SizedBox(height: 8),

                buildField(
                  controller:
                      emailController,

                  hint:
                      "Enter your email",

                  icon:
                      Icons.email_outlined,
                ),

                const SizedBox(height: 18),

                buildLabel("Password"),

                const SizedBox(height: 8),

                buildField(
                  controller:
                      passwordController,

                  hint:
                      "Enter your password",

                  icon:
                      Icons.lock_outline,

                  obscure:
                      obscurePassword,

                  suffix: IconButton(
                    onPressed: () {

                      setState(() {
                        obscurePassword =
                            !obscurePassword;
                      });
                    },

                    icon: Icon(
                      obscurePassword
                          ? Icons
                              .visibility_off
                          : Icons.visibility,
                    ),
                  ),
                ),

                const SizedBox(height: 10),

                Row(
                  mainAxisAlignment:
                      MainAxisAlignment
                          .spaceBetween,

                  children: [

                    Row(
                      children: [

                        Checkbox(
                          value: rememberMe,

                          activeColor:
                              const Color(
                            0xFFFF6A88,
                          ),

                          onChanged:
                              (value) {

                            setState(() {
                              rememberMe =
                                  value!;
                            });
                          },
                        ),

                        const Text(
                          "Remember Me",
                        ),
                      ],
                    ),

                    TextButton(
                      onPressed: () {},

                      child: const Text(
                        "Forgot Password?",
                        style: TextStyle(
                          color: Color(
                            0xFFFF6A88,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                SizedBox(
                  width: double.infinity,
                  height: 50,

                  child: ElevatedButton(
                    style:
                        ElevatedButton.styleFrom(
                      backgroundColor:
                          const Color(
                        0xFFFF6A88,
                      ),

                      foregroundColor:
                          Colors.white,

                      shape:
                          RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(
                          20,
                        ),
                      ),
                    ),

                    onPressed:
                        isLoading
                            ? null
                            : loginUser,

                    child:
                        isLoading
                            ? const CircularProgressIndicator(
                                color:
                                    Colors.white,
                              )
                            : const Text(
                                "Login",
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight:
                                      FontWeight
                                          .bold,
                                ),
                              ),
                  ),
                ),

                const SizedBox(height: 24),

                Row(
                  mainAxisAlignment:
                      MainAxisAlignment.center,

                  children: [

                    const Text(
                      "Don't have an account?",
                    ),

                    TextButton(
                      onPressed: () {

                        Navigator.push(
                          context,

                          MaterialPageRoute(
                            builder: (_) =>
                                const SignupScreen(),
                          ),
                        );
                      },

                      child: const Text(
                        "Sign Up",
                        style: TextStyle(
                          color: Color(
                            0xFFFF6A88,
                          ),
                          fontWeight:
                              FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget buildLabel(
    String text,
  ) {
    return Text(
      text,
      style: const TextStyle(
        fontWeight:
            FontWeight.w600,
      ),
    );
  }

  Widget buildField({
    required TextEditingController
        controller,

    required String hint,

    required IconData icon,

    bool obscure = false,

    Widget? suffix,
  }) {
    return TextField(
      controller: controller,

      obscureText: obscure,

      decoration: InputDecoration(
        hintText: hint,

        prefixIcon: Icon(icon),

        suffixIcon: suffix,

        filled: true,
        fillColor: Colors.white,

        border: OutlineInputBorder(
          borderRadius:
              BorderRadius.circular(
            18,
          ),

          borderSide:
              BorderSide.none,
        ),
      ),
    );
  }
}