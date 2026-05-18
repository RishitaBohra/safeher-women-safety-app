import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../home/home_screen.dart';
import 'login_screen.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() =>
      _SignupScreenState();
}

class _SignupScreenState
    extends State<SignupScreen> {

  final nameController =
      TextEditingController();

  final emailController =
      TextEditingController();

  final passwordController =
      TextEditingController();

  final confirmPasswordController =
      TextEditingController();

  bool obscurePassword = true;
  bool obscureConfirmPassword = true;

  bool isLoading = false;

  Future<void> signUpUser() async {

    if (passwordController.text !=
        confirmPasswordController.text) {

      ScaffoldMessenger.of(context)
          .showSnackBar(
        const SnackBar(
          content:
              Text("Passwords do not match"),
        ),
      );

      return;
    }

  try {

  setState(() {
    isLoading = true;
  });

  UserCredential userCredential =
      await FirebaseAuth.instance
          .createUserWithEmailAndPassword(

    email:
        emailController.text.trim(),

    password:
        passwordController.text.trim(),
  );

  await FirebaseFirestore.instance
      .collection('users')
      .doc(userCredential.user!.uid)
      .set({

    'uid':
        userCredential.user!.uid,

    'name':
        nameController.text.trim(),

    'email':
        emailController.text.trim(),

    'createdAt':
        Timestamp.now(),
  });

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
          "Signup failed";

      if (e.code ==
          'email-already-in-use') {

        message =
            "Email already exists";
      }

      else if (e.code ==
          'weak-password') {

        message =
            "Password is too weak";
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

                IconButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },

                  icon: const Icon(
                    Icons.arrow_back_ios,
                  ),
                ),

                const SizedBox(height: 10),

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
                          Icons.person_add,
                          color: Colors.white,
                          size: 45,
                        ),
                      ),

                      const SizedBox(height: 20),

                      const Text(
                        "Create Account",
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight:
                              FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 10),

                      const Text(
                        "Signup to continue using SafeHer",
                        style: TextStyle(
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 28),

                buildLabel("Full Name"),

                const SizedBox(height: 8),

                buildField(
                  controller:
                      nameController,

                  hint:
                      "Enter your name",

                  icon:
                      Icons.person_outline,
                ),

                const SizedBox(height: 18),

                buildLabel("Email"),

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
                      "Enter password",

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

                const SizedBox(height: 18),

                buildLabel(
                  "Confirm Password",
                ),

                const SizedBox(height: 8),

                buildField(
                  controller:
                      confirmPasswordController,

                  hint:
                      "Confirm password",

                  icon:
                      Icons.lock_outline,

                  obscure:
                      obscureConfirmPassword,

                  suffix: IconButton(
                    onPressed: () {

                      setState(() {
                        obscureConfirmPassword =
                            !obscureConfirmPassword;
                      });
                    },

                    icon: Icon(
                      obscureConfirmPassword
                          ? Icons
                              .visibility_off
                          : Icons.visibility,
                    ),
                  ),
                ),

                const SizedBox(height: 28),

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
                            : signUpUser,

                    child:
                        isLoading
                            ? const CircularProgressIndicator(
                                color:
                                    Colors.white,
                              )
                            : const Text(
                                "Sign Up",
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
                      "Already have an account?",
                    ),

                    TextButton(
                      onPressed: () {

                        Navigator.pushReplacement(
                          context,

                          MaterialPageRoute(
                            builder: (_) =>
                                const LoginScreen(),
                          ),
                        );
                      },

                      child: const Text(
                        "Login",
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