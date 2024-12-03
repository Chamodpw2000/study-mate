import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class Signupwithemail extends StatefulWidget {
  const Signupwithemail({super.key});

  @override
  State<Signupwithemail> createState() => _SignupwithemailState();
}

class _SignupwithemailState extends State<Signupwithemail> {
  TextEditingController emailc = TextEditingController();
  TextEditingController passwordc = TextEditingController();
  TextEditingController cpasswordc = TextEditingController();
  TextEditingController fnamec = TextEditingController();
  TextEditingController lnamec = TextEditingController();
  String? errorMessage;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        // Wrap the body with SingleChildScrollView
        child: Container(
          width: double.infinity,
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: AssetImage('assets/b.jpg'),
              fit: BoxFit.cover,
              alignment: Alignment(-0.21, 0),
              opacity: 0.7,
            ),
          ),
          child: Padding(
            padding: EdgeInsets.all(18.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TextField(
                  controller: emailc,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20.0),
                    ),
                    hintStyle: GoogleFonts.poppins(
                      color: Colors.black.withOpacity(0.7),
                      fontSize: 20.0,
                      fontWeight: FontWeight.bold,
                    ),
                    hintText: "Email",
                    fillColor: Colors.white,
                    filled: true,
                  ),
                ),
                const SizedBox(height: 20.0),
                TextField(
                  controller: passwordc,
                  obscureText: true,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20.0),
                    ),
                    hintStyle: GoogleFonts.poppins(
                      color: Colors.black.withOpacity(0.7),
                      fontSize: 20.0,
                      fontWeight: FontWeight.bold,
                    ),
                    hintText: "Password",
                    fillColor: Colors.white,
                    filled: true,
                  ),
                ),
                const SizedBox(height: 20.0),
                TextField(
                  controller: cpasswordc,
                  obscureText: true,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20.0),
                    ),
                    hintStyle: GoogleFonts.poppins(
                      color: Colors.black.withOpacity(0.7),
                      fontSize: 20.0,
                      fontWeight: FontWeight.bold,
                    ),
                    hintText: "Confirm Password",
                    fillColor: Colors.white,
                    filled: true,
                  ),
                ),
                const SizedBox(height: 20.0),
                TextField(
                  controller: fnamec,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20.0),
                    ),
                    hintStyle: GoogleFonts.poppins(
                      color: Colors.black.withOpacity(0.7),
                      fontSize: 20.0,
                      fontWeight: FontWeight.bold,
                    ),
                    hintText: "First Name",
                    fillColor: Colors.white,
                    filled: true,
                  ),
                ),
                const SizedBox(height: 20.0),
                TextField(
                  controller: lnamec,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20.0),
                    ),
                    hintStyle: GoogleFonts.poppins(
                      color: Colors.black.withOpacity(0.7),
                      fontSize: 20.0,
                      fontWeight: FontWeight.bold,
                    ),
                    hintText: "Last Name",
                    fillColor: Colors.white,
                    filled: true,
                  ),
                ),
                const SizedBox(height: 20.0),
                if (errorMessage != null)
                  Container(
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.5),
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    padding:
                        EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                    child: Text(
                      errorMessage!,
                      textAlign: TextAlign.center,
                      style: GoogleFonts.poppins(
                        color: Colors.red,
                        fontSize: 20.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                const SizedBox(height: 20.0),
                ElevatedButton(
                  onPressed: () async {
                    setState(() {
                      errorMessage = null;
                    });

                    if (fnamec.text.isEmpty ||
                        lnamec.text.isEmpty ||
                        emailc.text.isEmpty ||
                        passwordc.text.isEmpty ||
                        cpasswordc.text.isEmpty) {
                      setState(() {
                        errorMessage = 'Please fill all fields.';
                      });
                      return;
                    }

                    try {
                      await signUp();
                    } on FirebaseAuthException catch (e) {
                      setState(() {
                        switch (e.code) {
                          case 'invalid-email':
                            errorMessage = 'The email address is not valid.';
                            break;
                          case 'weak-password':
                            errorMessage = 'Your password is too weak.';
                            break;
                          case 'email-already-in-use':
                            errorMessage = 'This email is already registered.';
                            break;
                          case 'operation-not-allowed':
                            errorMessage =
                                'Email/password accounts are not enabled.';
                            break;
                          case 'network-request-failed':
                            errorMessage =
                                'Network error! Please check your connection.';
                            break;
                          default:
                            errorMessage = 'An unexpected error occurred.';
                        }
                      });
                    } catch (e) {
                      setState(() {
                        errorMessage =
                            'An error occurred. Please try again later.';
                      });
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 20),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Expanded(
                          child: Center(
                            child: Text(
                              "Sign Up",
                              style: GoogleFonts.poppins(
                                color: Colors.white,
                                fontSize: 30,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.grey[200],
                            shape: BoxShape.circle,
                          ),
                          padding: const EdgeInsets.all(8.0),
                          child: const Icon(
                            Icons.arrow_forward,
                            color: Colors.black,
                            size: 30,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future signUp() async {
    if (passwordConfirmed()) {
      final auth = FirebaseAuth.instance;

      await auth.createUserWithEmailAndPassword(
        email: emailc.text,
        password: passwordc.text,
      );

      addDetails();
      //hi
    }
  }

  Future addDetails() async {
    try {
      await FirebaseFirestore.instance.collection("users").add({
        "email": emailc.text,
        "fname": fnamec.text,
        "lname": lnamec.text,
      });
    } catch (e) {
      print(e);
    }
  }

  bool passwordConfirmed() {
    if (passwordc.text == cpasswordc.text) {
      return true;
    } else {
      setState(() {
        errorMessage = 'Passwords do not match';
      });
      return false;
    }
  }
}
