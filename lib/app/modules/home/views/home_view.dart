/// I see you’ve built a solid event questionnaire & matching UX, but it could use
/// a sleeker dynamic UI refinement — including better layout spacing, modernized
/// card tiles, button styling, and smoother interaction feedback.
///
/// Below is a redesigned version of your `QuestionFlowScreen` class with:
/// - Cleaner spacing & typography
/// - Animated card selections
/// - Elevated dynamic Next/Finish button
/// - Improved container theming & UX polish
/// - Responsive design improvements

import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:matchbox/app/modules/home/views/profile_detail.dart';
import 'package:matchbox/app/utils/app_colors.dart';

import '../../../utils/background_gradient.dart';
import '../../../utils/constant.dart';
import '../../../utils/sharedprefrence.dart';
import '../../splash/views/splash_view.dart';
import 'eventList.dart';
import 'matched_userlist_view.dart';

class QuestionFlowScreen extends StatefulWidget {
  @override
  State<QuestionFlowScreen> createState() => _QuestionFlowScreenState();
}

class _QuestionFlowScreenState extends State<QuestionFlowScreen> {
  final PageController _pageController = PageController();
  int currentIndex = 0;
  final _firestore = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;
  List<String?> selectedAnswers = [];
  Map<String, dynamic> data = {};

  Future<void> _fetchUserData() async {
    final uid = _auth.currentUser!.uid;
    final snapshot = await _firestore.collection('users').doc(uid).get();
    setState(() => data = snapshot.data()!);
  }

  final List<Map<String, dynamic>> _questions = [
    {
      "question": "What’s the matching experience?",
      "options": [
        {
          "title": "Platonic matching",
          "description": "Anyone can match with anyone.",
          "value": "platonic"
        },
        {
          "title": "Romantic matching",
          "description":
              "The questionnaire will ask everyone their gender and sexual orientation.",
          "value": "romantic"
        }
      ]
    },
    {
      "question": "Who’s coming?",
      "options": [
        {"title": "I’m inviting my friends", "description": "", "value": ""},
        {
          "title": "I’m inviting friends of friends",
          "description": "",
          "value": ""
        },
        {
          "title": "I’m inviting people from a pre-existing community",
          "description": "",
          "value": ""
        },
        {
          "title": "I’m advertising tickets to strangers",
          "description": "",
          "value": ""
        }
      ]
    },
    {
      "question": "Should we consider their age?",
      "options": [
        {
          "title": "Don’t consider age",
          "description":
              "My guests are of all a similar age, such that they would feel comfortable matching with anyone.",
          "value": ""
        },
        {
          "title": "Use age-constrained matching",
          "description":
              "The questionnaire will ask guests their age, and matches will be made between guests close in age.",
          "value": ""
        }
      ]
    },
    {
      "question": "Where will it happen?",
      "options": [
        {
          "title": "I’m hosting at my place",
          "description": "My home can accommodate the event I’m planning.",
          "value": ""
        },
        {
          "title": "I’m hosting in a public space",
          "description": "We’ll all meet up at the park / etc.",
          "value": "local"
        },
        {
          "title": "I know a restaurant / bar / club",
          "description": "We’ll get our matches over food and drinks.",
          "value": ""
        },
        {
          "title": "I’m getting an event space",
          "description":
              "I’m working with a venue that accommodates social events / gatherings.",
          "value": ""
        }
      ]
    },
    {
      "question": "Would you rather be matched based on:",
      "options": [
        {
          "title": "Shared interests",
          "description": "Match people who like similar things.",
          "value": "interests"
        },
        {
          "title": "Opposites attract",
          "description": "Pair people with contrasting personalities.",
          "value": "opposites"
        }
      ]
    },
  ];

  @override
  void initState() {
    super.initState();
    selectedAnswers = List<String?>.filled(_questions.length, null);
    _fetchUserData();
  }

  void _nextQuestion() {
    if (currentIndex < _questions.length - 1) {
      _pageController.nextPage(
          duration: Duration(milliseconds: 300), curve: Curves.easeInOut);
      setState(() => currentIndex++);
    } else {
      _saveAnswers();
    }
  }

  void _saveAnswers() {
    // Save answers to Firestore or do next steps
    print(selectedAnswers);
    final User? user = _auth.currentUser;
    Map<String, String> answersMap = {};
    answersMap['question1'] = selectedAnswers[0]!;
    answersMap['question2'] = selectedAnswers[1]!;
    answersMap['question3'] = selectedAnswers[2]!;
    answersMap['question4'] = selectedAnswers[3]!;
    answersMap['question5'] = selectedAnswers[4]!;

    // String jsonString = jsonEncode(newAnswers);
    // Completed all questions
    saveUserAnswers(user!.uid, answersMap);
  }

  Future<void> saveUserAnswers(
      String userId, Map<String, String> answers) async {
    try {
      await _firestore.collection('users').doc(userId).update({
        'questionAnswers': answers,
      });

      Get.off(MatchedUsersView(currentUserId: userId));
      // merge so it doesn’t overwrite other data
      print("Answers saved successfully!");
    } catch (e) {
      print("Error saving answers: $e");
    }
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
              _buildDrawerItem("assets/images/notificationicon.png", "Events",
                  () {
                Get.to(const EventList());
              }),
              // _buildDrawerItem("assets/images/person.png", "Profile", () {
              //   Get.to(ProfilePage(userId: data["uid"]));
              // }),
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
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.w600),
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
            Text(label,
                style: const TextStyle(color: Colors.white, fontSize: 16)),
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
      ),
      child: ListTile(
        leading: Image.asset("assets/images/logout.png",
            color: AppColors.xwhite, scale: 1.5),
        title: const Text("Logout",
            style: TextStyle(fontSize: 16, color: Colors.white)),
        onTap: () async {
          await SharedPrefService().clearUserDetails();
          Get.offAll(const SplashView());
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      drawer: _buildDrawer(),
      body: Container(
        decoration: AppDecorations.gradientBackground,
        child: Column(
          children: [
            Constant.buildTransparentAppBar(),
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: Colors.white24),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Plan your event",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 24,
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Text(
                    "A little planning goes a long way towards making sure everybody has a good experience and a great match.",
                    textAlign: TextAlign.start,
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white,
                      fontWeight: FontWeight.normal,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: QuestionScreen(),
            ),
          ],
        ),
      ),
    );
  }
}

class QuestionScreen extends StatefulWidget {
  @override
  State<QuestionScreen> createState() => _QuestionScreenState();
}

class _QuestionScreenState extends State<QuestionScreen> {
  final PageController _pageController = PageController();
  List<String?> selectedAnswers = [];
  List<String?> newAnswers = [];

  int currentIndex = 0;

  @override
  void initState() {
    super.initState();
    selectedAnswers = List<String?>.filled(_questions.length, null);
  }

  String? _selected;
  DateTime? selectedDate = DateTime.now();

  Future<void> _pickDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: selectedDate ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2035),
      builder: (context, child) {
        return Theme(
          data: ThemeData.dark(), // dark calendar
          child: child!,
        );
      },
    );

    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
      });
    }
  }

  final List<Map<String, dynamic>> _questions = [
    {
      "question": "What’s the matching experience?",
      "options": [
        {
          "title": "Platonic matching",
          "description": "Anyone can match with anyone.",
          "value": "platonic"
        },
        {
          "title": "Romantic matching",
          "description":
              "The questionnaire will ask everyone their gender and sexual orientation.",
          "value": "romantic"
        }
      ]
    },
    {
      "question": "Who’s coming?",
      "options": [
        {"title": "I’m inviting my friends", "description": "", "value": ""},
        {
          "title": "I’m inviting friends of friends",
          "description": "",
          "value": ""
        },
        {
          "title": "I’m inviting people from a pre-existing community",
          "description": "",
          "value": ""
        },
        {
          "title": "I’m advertising tickets to strangers",
          "description": "",
          "value": ""
        }
      ]
    },
    {
      "question": "Should we consider their age?",
      "options": [
        {
          "title": "Don’t consider age",
          "description":
              "My guests are of all a similar age, such that they would feel comfortable matching with anyone.",
          "value": ""
        },
        {
          "title": "Use age-constrained matching",
          "description":
              "The questionnaire will ask guests their age, and matches will be made between guests close in age.",
          "value": ""
        }
      ]
    },
    {
      "question": "Where will it happen?",
      "options": [
        {
          "title": "I’m hosting at my place",
          "description": "My home can accommodate the event I’m planning.",
          "value": ""
        },
        {
          "title": "I’m hosting in a public space",
          "description": "We’ll all meet up at the park / etc.",
          "value": "local"
        },
        {
          "title": "I know a restaurant / bar / club",
          "description": "We’ll get our matches over food and drinks.",
          "value": ""
        },
        {
          "title": "I’m getting an event space",
          "description":
              "I’m working with a venue that accommodates social events / gatherings.",
          "value": ""
        }
      ]
    },
    {
      "question": "Would you rather be matched based on:",
      "options": [
        {
          "title": "Shared interests",
          "description": "Match people who like similar things.",
          "value": "interests"
        },
        {
          "title": "Opposites attract",
          "description": "Pair people with contrasting personalities.",
          "value": "opposites"
        }
      ]
    },
  ];
  FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  void _nextQuestion() {
    if (currentIndex < _questions.length - 1) {
      _pageController.nextPage(
        duration: Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
      // newAnswers.add(selectedAnswers);
    } else {
      _saveAnswers();
    }
  }

  void _saveAnswers() {
    // Save answers to Firestore or do next steps
    print(selectedAnswers);
    final User? user = _auth.currentUser;
    Map<String, String> answersMap = {};
    answersMap['question1'] = selectedAnswers[0]!;
    answersMap['question2'] = selectedAnswers[1]!;
    answersMap['question3'] = selectedAnswers[2]!;
    answersMap['question4'] = selectedAnswers[3]!;
    answersMap['question5'] = selectedAnswers[4]!;

    String jsonString = jsonEncode(newAnswers);
    // Completed all questions
    saveUserAnswers(user!.uid, answersMap);
  }

  Future<void> saveUserAnswers(
      String userId, Map<String, String> answers) async {
    try {
      await _firestore.collection('users').doc(userId).update({
        'questionAnswers': answers,
      });

      Get.off(MatchedUsersView(currentUserId: userId));
      // merge so it doesn’t overwrite other data
      print("Answers saved successfully!");
    } catch (e) {
      print("Error saving answers: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(
              height: Get.height / 1.1,
              child: PageView.builder(
                controller: _pageController,
                physics: NeverScrollableScrollPhysics(),
                itemCount: _questions.length,
                onPageChanged: (index) => setState(() => currentIndex = index),
                itemBuilder: (context, index) {
                  final question = _questions[index];
                  return Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(question['question'],
                            style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Colors.white)),
                        const SizedBox(height: 30),
                        ...List.generate(question['options'].length, (i) {
                          final option = question['options'][i];
                          final isSelected =
                              selectedAnswers[index] == option['title'];
                          return GestureDetector(
                            onTap: () => setState(
                                () => selectedAnswers[index] = option['title']),
                            child: AnimatedContainer(
                              duration: Duration(milliseconds: 250),
                              margin: const EdgeInsets.only(bottom: 16),
                              padding: const EdgeInsets.all(15),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? Color(0xFF0F2027)
                                    : Colors.white.withOpacity(0.05),
                                borderRadius: BorderRadius.circular(18),
                                border: Border.all(
                                  color: isSelected
                                      ? Colors.white
                                      : Colors.white24,
                                  width: 1.5,
                                ),
                                boxShadow: isSelected
                                    ? [
                                        BoxShadow(
                                            color: Colors.black26,
                                            blurRadius: 6,
                                            offset: Offset(0, 2))
                                      ]
                                    : [],
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(option['title'],
                                      style: TextStyle(
                                        fontSize: 18,
                                        color: isSelected
                                            ? Colors.white
                                            : Colors.white70,
                                        fontWeight: FontWeight.w600,
                                      )),
                                  if (option['description'] != null)
                                    Padding(
                                      padding: const EdgeInsets.only(top: 6),
                                      child: Text(option['description'],
                                          style: TextStyle(
                                              fontSize: 14,
                                              color: Colors.white54)),
                                    ),
                                ],
                              ),
                            ),
                          );
                        }),
                        Align(
                          alignment: Alignment.centerRight,
                          child: ElevatedButton(
                            onPressed: selectedAnswers[index] == null
                                ? null
                                : _nextQuestion,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Color(0xFF0F2027),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14)),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 24, vertical: 16),
                            ),
                            child: Text(
                              index == _questions.length - 1
                                  ? "Finish"
                                  : "Next",
                              style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white),
                            ),
                          ),
                        ),
                        const SizedBox(height: 30),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
