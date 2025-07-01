import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:matchbox/app/utils/app_colors.dart';

class ProfilePage extends StatefulWidget {
  final String userId;

  const ProfilePage({super.key, required this.userId});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  File? _image;
  final picker = ImagePicker();
  bool _isUploading = false;

  Future<void> _getImageFromGallery() async {
   /* final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
        _uploadImageToFirebase();
      });
    }*/
  }

  Future<void> _uploadImageToFirebase() async {
    if (_image == null) return;

    setState(() {
      _isUploading = true;
    });

    try {
      final storageRef = FirebaseStorage.instance
          .ref()
          .child('profile_images')
          .child('${widget.userId}.jpg');

      await storageRef.putFile(_image!);

      final downloadUrl = await storageRef.getDownloadURL();

      // Update Firestore user document
      await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.userId)
          .update({'photoUrl': downloadUrl});

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Profile photo updated successfully!')),
      );
    } catch (e) {
      print('Upload error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to upload image.')),
      );
    } finally {
      setState(() {
        _isUploading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    CollectionReference users = FirebaseFirestore.instance.collection('users');

    return Scaffold(
      backgroundColor: Colors.transparent,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text("Profile", style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.transparent,
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
      ),
      body: Container(
        width: Get.width,
        height: Get.height,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF0F2027), Color(0xFF203A43), Color(0xFF2C5364)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: FutureBuilder<DocumentSnapshot>(
          future: users.doc(widget.userId).get(),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return const Center(
                  child: Text("Something went wrong",
                      style: TextStyle(color: Colors.white)));
            }
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                  child: CircularProgressIndicator(color: Colors.white));
            }
            if (!snapshot.hasData || !snapshot.data!.exists) {
              return const Center(
                  child: Text("User not found",
                      style: TextStyle(color: Colors.white)));
            }

            var data = snapshot.data!.data() as Map<String, dynamic>;

            return SafeArea(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Column(
                  children: [
                    const SizedBox(height: 80),
                    Stack(
                      alignment: Alignment.bottomCenter,
                      children: [
                        InkWell(
                          onTap: _getImageFromGallery,
                          child: _image != null
                              ? ClipOval(
                                  child: Image.file(_image!,
                                      width: 140,height: 140,fit: BoxFit.cover,))
                              : ClipOval(
                                  child: Image.network(
                                    data["photoURL"],
                                    height: 140,
                                    width: 140,
                                    fit: BoxFit.cover,
                                    loadingBuilder: (context, child, progress) {
                                      if (progress == null) return child;
                                      return Container(
                                        height: 140,
                                        width: 140,
                                        alignment: Alignment.center,
                                        child: const CircularProgressIndicator(
                                            color: Colors.white),
                                      );
                                    },
                                  ),
                                ),
                        ),
                        Positioned(
                          bottom: 0,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  Colors.black.withOpacity(0.7),
                                  Colors.black.withOpacity(0.4)
                                ],
                                begin: Alignment.bottomCenter,
                                end: Alignment.topCenter,
                              ),
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: Text(
                              data['name'],
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 30),

                    // Email
                    _profileInfoTile(Icons.email, data['email'] ?? 'N/A'),

                    const SizedBox(height: 20),

                    // Last Sign In
                    _profileInfoTile(
                      Icons.access_time,
                      "Last Signed In: ${data['lastSignIn'].toDate().toLocal()}",
                    ),

                    const SizedBox(height: 30),

                    Image.asset(
                      "assets/images/tran_logo.png",
                      scale: 2.5,
                      color: Colors.white.withOpacity(0.7),
                    ),

                    const SizedBox(height: 40),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _profileInfoTile(IconData icon, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white24),
        ),
        child: Row(
          children: [
            Icon(icon, color: Colors.white70),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                value,
                style: const TextStyle(color: Colors.white, fontSize: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
