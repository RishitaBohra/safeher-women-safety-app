import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class EmergencyContactsScreen extends StatefulWidget {
  const EmergencyContactsScreen({super.key});

  @override
  State<EmergencyContactsScreen> createState() =>
      _EmergencyContactsScreenState();
}

class _EmergencyContactsScreenState extends State<EmergencyContactsScreen> {
  final TextEditingController nameController = TextEditingController();

  final TextEditingController phoneController = TextEditingController();

  final relationController = TextEditingController();

  final currentUser = FirebaseAuth.instance.currentUser;

  Future<void> addContact() async {
    if (nameController.text.isEmpty ||
        phoneController.text.isEmpty ||
        relationController.text.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Fill all fields")));

      return;
    }

    await FirebaseFirestore.instance
        .collection('users')
        .doc(currentUser!.uid)
        .collection('contacts')
        .add({
          'name': nameController.text.trim(),

          'phone': phoneController.text.replaceAll(RegExp(r'[^0-9]'), ''),
          'relation': relationController.text.trim(),

          'createdAt': Timestamp.now(),
        });

    nameController.clear();
    phoneController.clear();
    relationController.clear();

    Navigator.pop(context);
  }

  Future<void> deleteContact(String docId) async {
    await FirebaseFirestore.instance
        .collection('users')
        .doc(currentUser!.uid)
        .collection('contacts')
        .doc(docId)
        .delete();
  }

  void showAddContactDialog() {
    showModalBottomSheet(
      context: context,

      isScrollControlled: true,

      backgroundColor: Colors.transparent,

      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),

          child: Container(
            padding: const EdgeInsets.all(20),

            decoration: const BoxDecoration(
              color: Colors.white,

              borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
            ),

            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,

                children: [
                  const Text(
                    "Add Emergency Contact",

                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),

                  const SizedBox(height: 24),

                  buildField(
                    controller: nameController,

                    hint: "Contact Name",

                    icon: Icons.person,
                  ),

                  const SizedBox(height: 16),

                  TextField(
                    controller: phoneController,
                    keyboardType: TextInputType.phone,
                    maxLength: 10,

                    decoration: InputDecoration(
                      hintText: "Phone Number",
                      prefixIcon: const Icon(Icons.phone),
                      counterText: "",
                      filled: true,
                      fillColor: const Color(0xFFF7F8FC),

                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(18),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  buildField(
                    controller: relationController,

                    hint: "Relation",

                    icon: Icons.favorite,
                  ),

                  const SizedBox(height: 24),

                  SizedBox(
                    width: double.infinity,

                    height: 50,

                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFF6A88),

                        foregroundColor: Colors.white,

                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18),
                        ),
                      ),

                      onPressed: addContact,

                      child: const Text("Save Contact"),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
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
          "Emergency Contacts",

          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),

        centerTitle: true,
      ),

      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFFFF6A88),

        onPressed: showAddContactDialog,

        child: const Icon(Icons.add, color: Colors.white),
      ),

      body: StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection('users')
            .doc(currentUser!.uid)
            .collection('contacts')
            .orderBy('createdAt', descending: true)
            .snapshots(),

        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,

                children: [
                  Container(
                    height: 100,
                    width: 100,

                    decoration: BoxDecoration(
                      color: Colors.pink.shade50,

                      shape: BoxShape.circle,
                    ),

                    child: const Icon(
                      Icons.contacts_rounded,

                      size: 50,

                      color: Color(0xFFFF6A88),
                    ),
                  ),

                  const SizedBox(height: 20),

                  const Text(
                    "No Contacts Added",

                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),

                  const SizedBox(height: 10),

                  const Text(
                    "Add trusted people for emergencies",

                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            );
          }

          final contacts = snapshot.data!.docs;

          return ListView.builder(
            padding: const EdgeInsets.all(16),

            itemCount: contacts.length,

            itemBuilder: (context, index) {
              final contact = contacts[index];

              return Container(
                margin: const EdgeInsets.only(bottom: 16),

                padding: const EdgeInsets.all(18),

                decoration: BoxDecoration(
                  color: Colors.white,

                  borderRadius: BorderRadius.circular(24),

                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.04),

                      blurRadius: 10,

                      offset: const Offset(0, 4),
                    ),
                  ],
                ),

                child: Row(
                  children: [
                    Container(
                      height: 60,
                      width: 60,

                      decoration: BoxDecoration(
                        color: Colors.pink.shade50,

                        shape: BoxShape.circle,
                      ),

                      child: Center(
                        child: Text(
                          contact['name'][0].toUpperCase(),

                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,

                            color: Color(0xFFFF6A88),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(width: 16),

                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,

                        children: [
                          Text(
                            contact['name'],

                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),

                          const SizedBox(height: 4),

                          Text(
                            contact['relation'],

                            style: TextStyle(color: Colors.grey.shade700),
                          ),

                          const SizedBox(height: 4),

                          Text(
                            contact['phone'],

                            style: TextStyle(color: Colors.grey.shade600),
                          ),
                        ],
                      ),
                    ),

                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          onPressed: () async {
                            final phone = contact['phone'];

                            final Uri callUri = Uri(
                              scheme: 'tel',
                              path: "+91$phone",
                            );

                            await launchUrl(callUri);
                          },

                          icon: const Icon(Icons.call, color: Colors.green),
                        ),

                        IconButton(
                          onPressed: () async {
                            final phone = contact['phone'];

                            final Uri smsUri = Uri(
                              scheme: 'sms',
                              path: "+91$phone",
                              queryParameters: {
                                'body':
                                    "🚨 SOS Alert! I may need help. Please check on me immediately.",
                              },
                            );

                            await launchUrl(smsUri);
                          },

                          icon: const Icon(Icons.message, color: Colors.blue),
                        ),

                        IconButton(
                          onPressed: () {
                            deleteContact(contact.id);
                          },

                          icon: const Icon(Icons.delete, color: Colors.red),
                        ),
                      ],
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

  Widget buildField({
    required TextEditingController controller,

    required String hint,

    required IconData icon,
  }) {
    return TextField(
      controller: controller,

      decoration: InputDecoration(
        hintText: hint,

        prefixIcon: Icon(icon),

        filled: true,
        fillColor: const Color(0xFFF7F8FC),

        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),

          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}
