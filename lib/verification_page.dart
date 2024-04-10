import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:web3dart/web3dart.dart';
import 'package:voting_blockchain/voting_page.dart';
import 'package:voting_blockchain/constants.dart';
import 'package:voting_blockchain/functions.dart';
import 'package:voting_blockchain/form_container_widget.dart';
import 'package:voting_blockchain/toast.dart';


class VerificationPage extends StatefulWidget {
  const VerificationPage({super.key});

  @override
  _VerificationState createState() => _VerificationState();
}

class _VerificationState extends State<VerificationPage> {
  Client? httpClient;
  Web3Client? ethClient;
  TextEditingController controller = TextEditingController();

  @override
  void initState() {
    httpClient = Client();
    ethClient = Web3Client(infura_url, httpClient!);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 63, 41, 120),
        automaticallyImplyLeading: false,
        title: Row(
          children: [
            IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
            const Text(
              'Verification',
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
      body: Container(
        padding: const EdgeInsets.all(14),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(height: 20),
            const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    CupertinoIcons.checkmark_shield,
                    size: 170,
                    color: Color.fromRGBO(131, 121, 205, 100),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),
            FormContainerWidget(
              controller: controller,
              hintText: "Enter Student ID",
              isPasswordField: false,
            ),
            const SizedBox(
              height: 20,
            ),
            Container(
              width: double.infinity,
              height: 45,
              decoration: BoxDecoration(
                color: const Color.fromARGB(255, 63, 41, 120),
                borderRadius: BorderRadius.circular(10),
              ),
              child: TextButton(
                onPressed: () async {
                  if (controller.text.isNotEmpty) {
                    // Retrieve current user's username from Firestore
                    String? currentUserUsername = await getCurrentUserUsername();
                    if (currentUserUsername != null && controller.text == currentUserUsername) {
                      bool isVerified = await verifyVoter(int.parse(controller.text), ethClient!);

                      if (isVerified) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => VotingPage(
                            ),
                          ),
                        );
                     } else {
                       showToast(message: "Verification failed");// Show error message or dialog indicating verification failed
                      }
                    } else {
                       showToast(message: "Your Student ID does not match with your account");// Show error message or dialog indicating invalid student ID
                    }
                  }
                },
                child: const Center(
                  child: Text(
                    'Verify',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
    Future<String?> getCurrentUserUsername() async {
    try {
      // Get current user's ID
      String? userId = FirebaseAuth.instance.currentUser!.uid;
      // Get current user's username from Firestore
      DocumentSnapshot snapshot = await FirebaseFirestore.instance.collection('users').doc(userId).get();
      // Return the username if the document exists, otherwise return null
      return snapshot.exists ? snapshot.get('username') : null;
    } catch (e) {
      print('Error getting current user username: $e');
      return null;
    }
  }
}