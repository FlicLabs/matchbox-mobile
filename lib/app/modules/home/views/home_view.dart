import 'dart:convert';
import 'dart:ui';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:matchbox/app/modules/home/views/matched_userlist_view.dart';
import 'package:matchbox/app/modules/home/views/profile_detail.dart';

import '../../../routes/app_pages.dart';
import '../../../utils/app_colors.dart';
import '../../../utils/background_gradient.dart';
import '../../../utils/sharedprefrence.dart';
import '../../splash/views/splash_view.dart';
import 'create_event_list.dart';
import 'eventList.dart';

class HomeView extends StatefulWidget {
  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  Map<String, dynamic> data = {};

  @override
  void initState() {
    getUserdata().then((value) {
      data= value;
      setState(() {
      });
    },);

    super.initState();
  }
  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: buildTransparentAppBar(),
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
                      SizedBox(height: Get.height/1.6,),
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
        color: AppColors.xlightback1,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.all(Radius.circular(10))),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              margin: EdgeInsets.all(10),
              alignment: Alignment.topLeft,
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Plan your event",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 24,
                      color: Colors.black,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Text(
                    "A little planning goes a long way towards making sure everybody has a good experience and a great match.",
                    textAlign: TextAlign.start,
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey,
                      fontWeight: FontWeight.normal,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(flex: 2, child: QuestionFlowScreen()),
          ],
        ),
      ),
    );
  }

  AppBar buildTransparentAppBar() {
    return AppBar(
      backgroundColor: AppColors.xlightback1,
      elevation: 0,
      flexibleSpace: ClipRRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
          child: Container(
            color: Colors.white.withOpacity(0.2),
          ),
        ),
      ),
      title: Text("Matchbox", style: TextStyle(color: Colors.black)),
      actions: [
        IconButton(
          icon: Icon(Icons.notifications, color: Colors.black),
          onPressed: () {},
        ),
      ],
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

class QuestionFlowScreen extends StatefulWidget {
  @override
  State<QuestionFlowScreen> createState() => _QuestionFlowScreenState();
}

class _QuestionFlowScreenState extends State<QuestionFlowScreen> {
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
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              height: Get.height / 1.1,
              decoration: AppDecorations.gradientBackground,
              child: PageView.builder(
                controller: _pageController,
                physics: NeverScrollableScrollPhysics(),
                onPageChanged: (index) => setState(() => currentIndex = index),
                itemCount: _questions.length,
                itemBuilder: (context, index) {
                  final question = _questions[index];
                  return Padding(
                    padding: const EdgeInsets.all(15.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(height: 20),
                        Text(question['question'],
                            style: TextStyle(
                                fontSize: 24, fontWeight: FontWeight.w600)),
                        SizedBox(height: 15),
                        ...List.generate(question['options'].length, (i) {
                          final option = question['options'][i];
                          final isSelected =
                              selectedAnswers[index] == option["title"];
                          return GestureDetector(
                            onTap: () {
                              setState(() {
                                selectedAnswers[index] = option["title"];
                              });
                            },
                            child: AnimatedContainer(
                              duration: Duration(milliseconds: 100),
                              margin: EdgeInsets.only(bottom: 12),
                              padding: EdgeInsets.all(14),
                              decoration: BoxDecoration(
                                gradient: isSelected
                                    ? LinearGradient(colors: [
                                        AppColors.xlightback10,
                                        AppColors.xPrimaryDimColor
                                      ])
                                    : null,
                                color: isSelected ? null : Colors.transparent,
                                border: Border.all(
                                  color: isSelected
                                      ? Colors.white
                                      : Colors.grey[700]!,
                                  width: 1.4,
                                ),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(option['title'],
                                      style: TextStyle(
                                          fontSize: 18,
                                          color: isSelected
                                              ? AppColors.xlightwhite
                                              : AppColors.xblack,
                                          fontWeight: FontWeight.w600)),
                                  if (option['description'].isNotEmpty)
                                    SizedBox(height: 8),
                                  if (option['description'].isNotEmpty)
                                    Text(option['description'],
                                        style: TextStyle(
                                            fontSize: 14,
                                            color: Colors.grey[400])),
                                ],
                              ),
                            ),
                          );
                        }),
                        SizedBox(
                          height: 20,
                        ),
                        Align(
                          alignment: Alignment.topRight,
                          child: ElevatedButton(
                            onPressed: selectedAnswers[index] == null
                                ? null
                                : _nextQuestion,
                            child: Text(index == _questions.length - 1
                                ? "Finish"
                                : "Next"),
                          ),
                        ),
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
//
// class QuestionScreen extends StatefulWidget {
//   final int index;
//   final List<String?> selectedAnswers;
//
//   const QuestionScreen({
//     required this.index,
//     required this.selectedAnswers,
//   });
//
//   @override
//   _QuestionScreenState createState() => _QuestionScreenState();
// }
//
// class _QuestionScreenState extends State<QuestionScreen> {
//   String? _selected;
//   DateTime? selectedDate = DateTime.now();
//
//   Future<void> _pickDate(BuildContext context) async {
//     final picked = await showDatePicker(
//       context: context,
//       initialDate: selectedDate ?? DateTime.now(),
//       firstDate: DateTime(2020),
//       lastDate: DateTime(2035),
//       builder: (context, child) {
//         return Theme(
//           data: ThemeData.dark(), // dark calendar
//           child: child!,
//         );
//       },
//     );
//
//     if (picked != null && picked != selectedDate) {
//       setState(() {
//         selectedDate = picked;
//       });
//     }
//   }
//
//   final List<Map<String, dynamic>> _questions = [
//     {
//       "question": "What’s the matching experience?",
//       "options": [
//         {
//           "title": "Platonic matching",
//           "description": "Anyone can match with anyone.",
//           "value": "platonic"
//         },
//         {
//           "title": "Romantic matching",
//           "description":
//               "The questionnaire will ask everyone their gender and sexual orientation.",
//           "value": "romantic"
//         }
//       ]
//     },
//     {
//       "question": "Who’s coming?",
//       "options": [
//         {"title": "I’m inviting my friends", "description": "", "value": ""},
//         {
//           "title": "I’m inviting friends of friends",
//           "description": "",
//           "value": ""
//         },
//         {
//           "title": "I’m inviting people from a pre-existing community",
//           "description": "",
//           "value": ""
//         },
//         {
//           "title": "I’m advertising tickets to strangers",
//           "description": "",
//           "value": ""
//         }
//       ]
//     },
//     {
//       "question": "Should we consider their age?",
//       "options": [
//         {
//           "title": "Don’t consider age",
//           "description":
//               "My guests are of all a similar age, such that they would feel comfortable matching with anyone.",
//           "value": ""
//         },
//         {
//           "title": "Use age-constrained matching",
//           "description":
//               "The questionnaire will ask guests their age, and matches will be made between guests close in age.",
//           "value": ""
//         }
//       ]
//     },
//     {
//       "question": "Where will it happen?",
//       "options": [
//         {
//           "title": "I’m hosting at my place",
//           "description": "My home can accommodate the event I’m planning.",
//           "value": ""
//         },
//         {
//           "title": "I’m hosting in a public space",
//           "description": "We’ll all meet up at the park / etc.",
//           "value": "local"
//         },
//         {
//           "title": "I know a restaurant / bar / club",
//           "description": "We’ll get our matches over food and drinks.",
//           "value": ""
//         },
//         {
//           "title": "I’m getting an event space",
//           "description":
//               "I’m working with a venue that accommodates social events / gatherings.",
//           "value": ""
//         }
//       ]
//     },
//     {
//       "question": "Would you rather be matched based on:",
//       "options": [
//         {
//           "title": "Shared interests",
//           "description": "Match people who like similar things.",
//           "value": "interests"
//         },
//         {
//           "title": "Opposites attract",
//           "description": "Pair people with contrasting personalities.",
//           "value": "opposites"
//         }
//       ]
//     },
//   ];
//   FirebaseFirestore _firestore = FirebaseFirestore.instance;
//   final FirebaseAuth _auth = FirebaseAuth.instance;
//
//   @override
//   Widget build(BuildContext context) {
//     final currentQ = _questions[widget.index];
//     final dateStr = selectedDate != null
//         ? DateFormat('dd/MM/yyyy').format(selectedDate!)
//         : 'Select date';
//     return Scaffold(
//       body: SafeArea(
//         child: Container(
//           decoration: AppDecorations.gradientBackground,
//           padding: const EdgeInsets.symmetric(horizontal: 24),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               SizedBox(
//                 height: 20,
//               ),
//               Text(
//                 currentQ["question"],
//                 textAlign: TextAlign.start,
//                 style: TextStyle(
//                   fontSize: 24,
//                   color: Colors.black,
//                   fontWeight: FontWeight.w600,
//                 ),
//               ),
//               const SizedBox(height: 30),
//               ...List.generate(currentQ["options"].length, (i) {
//                 final option = currentQ["options"][i];
//                 return Padding(
//                   padding: const EdgeInsets.only(bottom: 16),
//                   child: _buildOptionCard(
//                     title: option["title"],
//                     description: option["description"],
//                     value: option["value"],
//                   ),
//                 );
//               }),
//               Spacer(),
//               Align(
//                 alignment: Alignment.bottomRight,
//                 child: ElevatedButton(
//                   onPressed: _selected == null
//                       ? null
//                       : () {
//                           final newAnswers =
//                               List<String?>.from(widget.selectedAnswers);
//                           if (widget.index < newAnswers.length) {
//                             newAnswers[widget.index] = _selected;
//                           } else {
//                             newAnswers.add(_selected);
//                           }
//
//                           if (widget.index < _questions.length - 1) {
//                             Navigator.of(context).push(_createSlideRoute(
//                               QuestionScreen(
//                                   index: widget.index + 1,
//                                   selectedAnswers: newAnswers),
//                             ));
//                           } else {
//                             // User? user = FirebaseAuth.instance.currentUser;
//                             final User? user = _auth.currentUser;
//                             Map<String, String> answersMap = {};
//                             answersMap['question1'] = newAnswers[0]!;
//                             answersMap['question2'] = newAnswers[1]!;
//                             answersMap['question3'] = newAnswers[2]!;
//                             answersMap['question4'] = newAnswers[3]!;
//                             answersMap['question5'] = newAnswers[4]!;
//
//                             String jsonString = jsonEncode(newAnswers);
//                             // Completed all questions
//                             saveUserAnswers(user!.uid, answersMap);
//                           }
//                         },
//                   child: Text(widget.index == _questions.length - 1
//                       ? "Finish"
//                       : "Next"),
//                 ),
//               )
//             ],
//           ),
//         ),
//       ),
//     );
//   }
//

// Widget _buildOptionCard({
//   required String title,
//   required String description,
//   required String value,
// }) {
//   final isSelected = _selected == title;
//
//   return GestureDetector(
//     onTap: () {
//       setState(() {
//         _selected = title;
//       });
//     },
//     child: AnimatedContainer(
//       duration: Duration(milliseconds: 300),
//       padding: EdgeInsets.all(16),
//       decoration: BoxDecoration(
//         gradient: isSelected
//             ? LinearGradient(colors: [AppColors.xlightback10, AppColors.xPrimaryDimColor])
//             : null,
//         color: isSelected ? null : Colors.transparent,
//         border: Border.all(
//           color: isSelected ? Colors.white : Colors.grey[700]!,
//           width: 1.4,
//         ),
//         borderRadius: BorderRadius.circular(16),
//         boxShadow: isSelected
//             ? [BoxShadow(color: Colors.black26, blurRadius: 10)]
//             : [],
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Text(title, style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
//           if (description.isNotEmpty) ...[
//             SizedBox(height: 8),
//             Text(description, style: TextStyle(fontSize: 14, color: Colors.grey[400])),
//           ]
//         ],
//       ),
//     ),
//   );
// }
//
// Route _createSlideRoute(Widget nextScreen) {
//   return PageRouteBuilder(
//     pageBuilder: (context, animation, secondaryAnimation) => nextScreen,
//     transitionsBuilder: (context, animation, secondaryAnimation, child) {
//       final offsetAnimation =
//           Tween<Offset>(begin: Offset(1.0, 0.0), end: Offset.zero)
//               .chain(CurveTween(curve: Curves.easeInOut));
//       return SlideTransition(
//           position: animation.drive(offsetAnimation), child: child);
//     },
//   );
// }
// }
