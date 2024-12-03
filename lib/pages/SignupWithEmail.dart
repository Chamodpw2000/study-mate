import "package:cloud_firestore/cloud_firestore.dart";
import "package:firebase_auth/firebase_auth.dart";
import "package:flutter/material.dart";
import "package:google_fonts/google_fonts.dart";

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
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          image: DecorationImage(
              image: AssetImage('assets/b.jpg'),
              fit: BoxFit.cover,
              alignment: Alignment(-0.21, 0),
              opacity: 0.7 //
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
                    color: Colors.black.withOpacity(0.7), // Label color
                    fontSize: 20.0, // Label font size
                    fontWeight: FontWeight.bold, // Label font weight
                  ),
                  hintText: "Email",
                  fillColor: Colors.white, // Background color
                  filled: true, // Enable the background color
                ),
              ),
              const SizedBox(height: 20.0),
              TextField(
                controller: passwordc,
                obscureText:
                    true, // This makes the input field a password field

                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20.0),
                  ),

                  hintStyle: GoogleFonts.poppins(
                    color: Colors.black.withOpacity(0.7), // Label color
                    fontSize: 20.0, // Label font size
                    fontWeight: FontWeight.bold, // Label font weight
                  ),
                  hintText: "Password",
                  fillColor: Colors.white, // Background color
                  filled: true, // Enable the background color
                ),
              ),
              const SizedBox(height: 20.0),
              TextField(
                controller: cpasswordc,
                obscureText:
                    true, // This makes the input field a password field

                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20.0),
                  ),

                  hintStyle: GoogleFonts.poppins(
                    color: Colors.black.withOpacity(0.7), // Label color
                    fontSize: 20.0, // Label font size
                    fontWeight: FontWeight.bold, // Label font weight
                  ),
                  hintText: "Confrim Password",
                  fillColor: Colors.white, // Background color
                  filled: true, // Enable the background color
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
                    color: Colors.black.withOpacity(0.7), // Label color
                    fontSize: 20.0, // Label font size
                    fontWeight: FontWeight.bold, // Label font weight
                  ),
                  hintText: "First Name",
                  fillColor: Colors.white, // Background color
                  filled: true, // Enable the background color
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
                    color: Colors.black.withOpacity(0.7), // Label color
                    fontSize: 20.0, // Label font size
                    fontWeight: FontWeight.bold, // Label font weight
                  ),
                  hintText: "Last Name",
                  fillColor: Colors.white, // Background color
                  filled: true, // Enable the background color
                ),
              ),
              const SizedBox(height: 20.0),
              if (errorMessage != null) // Show error message if available
                Container(
                  alignment: Alignment
                      .center, // Center-aligns the text within the container
                  decoration: BoxDecoration(
                    color:
                        Colors.white.withOpacity(0.5), // White with 50% opacity
                    borderRadius: BorderRadius.circular(
                        8.0), // Rounded corners (optional)
                  ),
                  padding: EdgeInsets.symmetric(
                      horizontal: 8.0,
                      vertical: 4.0), // Padding around the text
                  child: Text(
                    errorMessage!,
                    textAlign:
                        TextAlign.center, // Center-aligns the text itself
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
                  // Clear any previous error message
                  setState(() {
                    errorMessage = null;
                  });

                  // Validate first name and last name fields
                  if (fnamec.text.isEmpty ||
                      lnamec.text.isEmpty ||
                      emailc.text.isEmpty ||
                      passwordc.text.isEmpty ||
                      cpasswordc.text.isEmpty) {
                    setState(() {
                      errorMessage = 'Please fill all fields.';
                    });
                    return; // Stop further execution if validation fails
                  }

                  // Proceed with sign-up process if validation passes
                  try {
                    // Attempt to create a user with email and password, and await its result
                    await signUp();

                    // If successful, navigate to the Login page (or any other action)
                  } on FirebaseAuthException catch (e) {
                    // If an error occurs, display the error message
                    setState(() {
                      switch (e.code) {
                        case 'invalid-email':
                          errorMessage =
                              'The email address is not valid. Please check the format.';
                          break;
                        case 'weak-password':
                          errorMessage =
                              'Your password is too weak. It should be at least 6 characters long.';
                          break;
                        case 'email-already-in-use':
                          errorMessage =
                              'This email is already registered. Please try logging in.';
                          break;
                        case 'operation-not-allowed':
                          errorMessage =
                              'Email/password accounts are not enabled. Please contact support.';
                          break;
                        case 'network-request-failed':
                          errorMessage =
                              'Network error! Please check your connection.';
                          break;
                        default:
                          errorMessage =
                              'An unexpected error occurred. Please try again.';
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
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 20),
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
    );
  }

  Future signUp() async {
    if (passwordConfrimed()) {
      final auth = FirebaseAuth.instance;

      await auth.createUserWithEmailAndPassword(
        email: emailc.text,
        password: passwordc.text,
      );

      //add user details
      addDetails();
    }
  }

  Future addDetails() async {
    print("Adding user details");
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

  bool passwordConfrimed() {
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
