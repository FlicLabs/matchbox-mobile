import 'dart:ui';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:matchbox/app/modules/home/views/profile_detail.dart';
import 'package:matchbox/app/modules/splash/views/splash_view.dart';
import 'package:matchbox/app/utils/app_colors.dart';

import '../../../utils/background_gradient.dart';
import '../../../utils/constant.dart';
import '../../../utils/sharedprefrence.dart';
import 'create_event_list.dart';
import '../model/matched_list.dart';
import 'eventList.dart';
import 'one_to_one_chat.dart';

class MatchedUsersView extends StatefulWidget {
  final String currentUserId;

  const MatchedUsersView({super.key, required this.currentUserId});

  @override
  State<MatchedUsersView> createState() => _MatchedUsersViewState();
}

class _MatchedUsersViewState extends State<MatchedUsersView> {
  final _firestore = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;
  Map<String, dynamic> data = {};

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  Future<void> _fetchUserData() async {
    final uid = _auth.currentUser!.uid;
    final snapshot = await _firestore.collection('users').doc(uid).get();
    setState(() => data = snapshot.data()!);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: _buildDrawer(),
      body: Container(
        decoration: AppDecorations.gradientBackground,
        child: Column(
          children: [
            Constant.buildTransparentAppBar(),
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                InkWell(
                  onTap: (){
                    Get.to(const EventList());

                  },
                  child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 14),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(26),
                        boxShadow: [
                          BoxShadow(color: Colors.black.withOpacity(0.25), blurRadius: 8, offset: const Offset(0, 6))
                        ],
                      ),

                      child:  ClipRRect(
                        borderRadius: BorderRadius.circular(26),
                        child: Stack(
                          children: [
                            // Profile Image
                            Image.asset(
                              "assets/images/image1.png",
                              height: 180,
                              width: 180,
                              fit: BoxFit.cover,
                              // loadingBuilder: (context, child, loadingProgress) =>
                              // loadingProgress == null
                              //     ? child
                              //     : Container(
                              //     height: 340,
                              //     color: Colors.black12,
                              //     child: const Center(child: CircularProgressIndicator())),
                            ),

                            // Gradient Overlay
                            Positioned(
                              bottom: 0,
                              left: 0,
                              right: 0,
                              height: 120,
                              child: Container(
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      Colors.black.withOpacity(0.0),
                                      Colors.black.withOpacity(0.65)
                                    ],
                                    begin: Alignment.topCenter,
                                    end: Alignment.bottomCenter,
                                  ),
                                ),
                              ),
                            ),

                            // Name & Match Text
                            const Positioned(
                              bottom: 24,
                              left: 20,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "Your Event",
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 22,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  SizedBox(height: 4),
                                  // Text(
                                  //   "Match: ${user.matchPercent.toStringAsFixed(0)}%",
                                  //   style: TextStyle(
                                  //     color: Colors.white.withOpacity(0.85),
                                  //     fontSize: 16,
                                  //   ),
                                  // ),
                                ],
                              ),
                            ),

                          ],
                        ),
                      )),
                ),
                InkWell(
                  onTap: (){
                    Get.to(ProfilePage(userId: data["uid"]));
                  },
                  child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 14),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(26),
                        boxShadow: [
                          BoxShadow(color: Colors.black.withOpacity(0.25), blurRadius: 8, offset: const Offset(0, 6))
                        ],
                      ),

                      child:  ClipRRect(
                        borderRadius: BorderRadius.circular(26),
                        child: Stack(
                          children: [
                            // Profile Image
                            Image.asset(
                              "assets/images/image2.png",
                              height: 180,
                              width: 180,
                              fit: BoxFit.cover,
                            ),

                            // Gradient Overlay
                            Positioned(
                              bottom: 0,
                              left: 0,
                              right: 0,
                              height: 120,
                              child: Container(
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      Colors.black.withOpacity(0.0),
                                      Colors.black.withOpacity(0.65)
                                    ],
                                    begin: Alignment.topCenter,
                                    end: Alignment.bottomCenter,
                                  ),
                                ),
                              ),
                            ),

                            // Name & Match Text
                            const Positioned(
                              bottom: 24,
                              left: 20,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "Profile",
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 22,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  SizedBox(height: 4),
                                  // Text(
                                  //   "Match: ${user.matchPercent.toStringAsFixed(0)}%",
                                  //   style: TextStyle(
                                  //     color: Colors.white.withOpacity(0.85),
                                  //     fontSize: 16,
                                  //   ),
                                  // ),
                                ],
                              ),
                            ),

                          ],
                        ),
                      )),
                ),
              ],
            ),
            Expanded(
              child: FutureBuilder<List<MatchedUser>>(
                future: getMatchedUsers(widget.currentUserId),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return const Center(child: Text("Something went wrong"));
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Center(child: Text("No matches found"));
                  }

                  final matchedUsers = snapshot.data!;
                  return ListView.builder(
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    itemCount: matchedUsers.length,
                    itemBuilder: (context, index) {
                      final user = matchedUsers[index];
                      if (data["email"] == user.email) return const SizedBox();
                      return _buildMatchedUserCard(user);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Drawer _buildDrawer() {
    return Drawer(
      child: Container(
        decoration: AppDecorations.gradientBackground,
        child: SafeArea(
          child: Column(
            children: [
              _buildDrawerHeader(),
              const Divider(color: Colors.white38),
              _buildDrawerItem("assets/images/notificationicon.png", "Events", () {
                Get.to(const EventList());
              }),
              _buildDrawerItem("assets/images/person.png", "Profile", () {
                Get.to(ProfilePage(userId: data["uid"]));
              }),
              const Spacer(),
              _buildLogoutItem(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDrawerHeader() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: Colors.white24,
            radius: 28,
            child: const Icon(Icons.person, color: Colors.white, size: 30),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              'Hello, ${data["name"] ?? ""}',
              style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w600),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDrawerItem(String iconPath, String label, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      splashColor: Colors.white10,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.1),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.white24),
        ),
        child: Row(
          children: [
            Image.asset(iconPath, color: Colors.white, scale: 1.5),
            const SizedBox(width: 18),
            Text(label, style: const TextStyle(color: Colors.white, fontSize: 16)),
          ],
        ),
      ),
    );
  }

  Widget _buildLogoutItem() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white24),
      ),child: ListTile(
        leading: Image.asset("assets/images/logout.png", color: AppColors.xwhite, scale: 1.5),
        title: const Text("Logout", style: TextStyle(fontSize: 16, color: Colors.white)),
        onTap: () async {
          await SharedPrefService().clearUserDetails();
          Get.offAll(const SplashView());
        },
      ),
    );
  }

  Widget _buildMatchedUserCard(MatchedUser user) {
    return GestureDetector(
      onTap: () => Get.to(OneToOneChatPage(otherUserId: user.uid)),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(26),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.25), blurRadius: 8, offset: const Offset(0, 6))
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(26),
          child: Stack(
            children: [
              // Profile Image
              Image.network(
                user.image,
                height: 340,
                width: double.infinity,
                fit: BoxFit.cover,
                loadingBuilder: (context, child, loadingProgress) =>
                loadingProgress == null
                    ? child
                    : Container(
                    height: 340,
                    color: Colors.black12,
                    child: const Center(child: CircularProgressIndicator())),
              ),

              // Gradient Overlay
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                height: 120,
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.black.withOpacity(0.0),
                        Colors.black.withOpacity(0.65)
                      ],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                  ),
                ),
              ),

              // Name & Match Text
              Positioned(
                bottom: 24,
                left: 20,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      user.name,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "Match: ${user.matchPercent.toStringAsFixed(0)}%",
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.85),
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),

              // Chat Button Floating
              Positioned(
                bottom: 20,
                right: 20,
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(30),
                    // gradient: AppDecorations.buttonGradient,
                    boxShadow: [
                      BoxShadow(color: Colors.black26, blurRadius: 4, offset: Offset(0, 2))
                    ],
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.chat, color: Colors.white, size: 28),
                    onPressed: () {
                      Get.to(OneToOneChatPage(otherUserId: user.uid));
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

///----Matching AI Logic (Simple Match Percentage)
Future<List<MatchedUser>> getMatchedUsers(String currentUserId) async {
  final currentUser = await FirebaseFirestore.instance
      .collection('users')
      .doc(currentUserId)
      .get();
  final currentAnswers = currentUser['questionAnswers'];

  final usersSnapshot =
      await FirebaseFirestore.instance.collection('users').get();

  List<MatchedUser> matches = [];

  for (var doc in usersSnapshot.docs) {
    if (doc.id == currentUserId) continue;

    final answers = doc['questionAnswers'];
    int score = 0;

    for (int i = 1; i <= 5; i++) {
      if (currentAnswers['question$i'] == answers['question$i']) {
        score++;
      }
    }

    double matchPercent = (score / 5) * 100;

    matches.add(MatchedUser(
      uid: doc['uid'],
      name: doc['name'],
      image: doc['photoURL'],
      email: doc['email'],
      matchPercent: matchPercent,
    ));
  }

  // Sort by highest match
  matches.sort((a, b) => b.matchPercent.compareTo(a.matchPercent));

  return matches;
}
