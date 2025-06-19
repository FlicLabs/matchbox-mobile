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
  FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  Map<String, dynamic> data = {};

  @override
  void initState() {
    getUserdata().then(
      (value) {
        data = value;
        setState(() {});
      },
    );

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: Drawer(
        child: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                AppColors.xlightback1,
                AppColors.xlightback2,
                AppColors.xlightback3 // End color
              ],
            ),
          ),
          child: SafeArea(
            child: SingleChildScrollView(
              child: Stack(
                children: [
                  Column(
                    children: [
                      ListTile(
                        leading:
                            const Icon(Icons.arrow_back, color: Colors.black),
                        title: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Hello, ${data["name"].toString()}',
                              style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold),
                            ),
                            SizedBox(
                              width: 30,
                            ),
                          ],
                        ),
                      ),
                      Card(
                        margin:
                            EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        color: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                              10), // Set the corner radius here
                        ),
                        child: InkWell(
                          onTap: () {
                            Get.to(EventList());
                          },
                          child: Container(
                            padding: EdgeInsets.all(10),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Image.asset(
                                  "assets/images/notificationicon.png",
                                  scale: 1.5,
                                ),
                                const SizedBox(
                                  width: 20,
                                ),
                                const Text(
                                  "Event",
                                  textAlign: TextAlign.start,
                                  style: TextStyle(
                                      fontSize: 15,
                                      color: Colors.black,
                                      fontWeight: FontWeight.normal),
                                ),
                                const SizedBox(
                                  width: 20,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      Card(
                        margin:
                            EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        color: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                              10), // Set the corner radius here
                        ),
                        child: InkWell(
                          onTap: () {
                            Get.to(ProfilePage(userId: data["uid"]));
                          },
                          child: Container(
                            padding: EdgeInsets.all(10),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Image.asset(
                                  "assets/images/person.png",
                                  scale: 1.5,
                                ),
                                const SizedBox(
                                  width: 20,
                                ),
                                Text(
                                  "Profile",
                                  style: TextStyle(
                                      fontSize: 15,
                                      color: Colors.black,
                                      fontWeight: FontWeight.normal),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      SizedBox(
                        height: Get.height / 1.6,
                      ),
                      Align(
                        alignment: Alignment.bottomLeft,
                        child: Card(
                          margin:
                              EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                          color: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(
                                10), // Set the corner radius here
                          ),
                          child: GestureDetector(
                            onTap: () async {
                              await SharedPrefService().clearUserDetails();
                              Get.offAll(SplashView());
                            },
                            child: Container(
                              padding: EdgeInsets.all(10),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Image.asset(
                                    "assets/images/logout.png",
                                    color: AppColors.xPrimaryColor,
                                    scale: 1.5,
                                  ),
                                  const SizedBox(
                                    width: 30,
                                  ),
                                  const Text(
                                    "Logout",
                                    style: TextStyle(
                                        fontSize: 15,
                                        color: Colors.black,
                                        fontWeight: FontWeight.normal),
                                  ),
                                ],
                              ),
                            ),
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
      ),
      body: Container(
        decoration: AppDecorations.gradientBackground,
        child: Column(
          children: [
            Constant.buildTransparentAppBar(),
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
                    itemCount: matchedUsers.length,
                    itemBuilder: (context, index) {
                      final user = matchedUsers[index];
                      return data["email"]!=user.email?Card(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(24),
                        ),
                        elevation: 6,
                        margin: EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            // Image Section
                            Stack(
                              alignment: Alignment.center,
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.vertical(
                                      top: Radius.circular(24)),
                                  child: Image.network(
                                    user.image,
                                    height: 250,
                                    width: double.infinity,
                                    fit: BoxFit.contain,
                                  ),
                                ),
                                // Play/Pause Button
                                Positioned(
                                  bottom: 12,
                                  child: Container(
                                    padding: EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      shape: BoxShape.circle,
                                      boxShadow: [
                                        BoxShadow(
                                            color: Colors.black26,
                                            blurRadius: 4),
                                      ],
                                    ),
                                    child: InkWell(
                                      onTap: () {
                                        Get.to(OneToOneChatPage(otherUserId: user.uid,));
                                      },
                                      child: Icon(Icons.chat,
                                          color: AppColors.xPrimaryColor,
                                          size: 30),
                                    ),
                                  ),
                                )
                              ],
                            ),

                            // Info Section
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 12),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Text(
                                    "${user.name}",
                                    style: TextStyle(
                                      fontSize: 22,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),

                                  // Row(
                                  //   mainAxisAlignment: MainAxisAlignment.center,
                                  //   children: [
                                  //     Icon(Icons.location_on, size: 16, color: Colors.orange),
                                  //     SizedBox(width: 4),
                                  //     Text(
                                  //       "${user.location} • ${user.distance} KM",
                                  //       style: TextStyle(color: Colors.grey[600]),
                                  //     )
                                  //   ],
                                  // ),
                                  SizedBox(height: 8),
                                  Text(
                                    "Match: ${user.matchPercent.toStringAsFixed(0)}%",
                                    style: TextStyle(color: Colors.grey[600]),
                                  ),
                                ],
                              ),
                            )
                          ],
                        ),
                      ):SizedBox();
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

  Future<Map<String, dynamic>> getUserdata() async {
    final User? user = _auth.currentUser;
    String uid = _auth.currentUser!.uid;

    DocumentSnapshot<Map<String, dynamic>> snapshot =
        await _firestore.collection('users').doc(uid).get();
    var userData = snapshot.data();
    return userData!;
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
