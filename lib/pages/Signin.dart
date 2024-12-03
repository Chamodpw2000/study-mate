import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class Signin extends StatefulWidget {
  const Signin({super.key});

  @override
  State<Signin> createState() => _SigninState();
}

class _SigninState extends State<Signin> {
  TextEditingController emailc = TextEditingController();
  TextEditingController passwordc = TextEditingController();
  String? errorMessage;

  Future<void> login() async {
    final auth = FirebaseAuth.instance;
    await auth.signInWithEmailAndPassword(
      email: emailc.text,
      password: passwordc.text,
    );
  }

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
              SizedBox(height: 20.0),
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
              SizedBox(height: 50.0),
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
                  {
                    // Clear previous error message
                    setState(() {
                      errorMessage = null;
                    });

                    // Validate fields
                    if (emailc.text.isEmpty) {
                      setState(() {
                        errorMessage = 'Please enter your email.';
                      });
                      return;
                    }

                    if (passwordc.text.isEmpty || passwordc.text.length < 6) {
                      setState(() {
                        errorMessage =
                            'Please enter a valid password (min 6 characters).';
                      });
                      return;
                    }

                    // Attempt to log in
                    try {
                      await login();
                      // If login successful, clear fields
                      emailc.clear();
                      passwordc.clear();
                    } on FirebaseAuthException catch (e) {
                      // Handle Firebase authentication errors
                      setState(() {
                        print(e.code);
                        switch (e.code) {
                          case 'invalid-credential':
                            errorMessage =
                                'User name and password do not match. Please try again.';
                            break;
                          case 'wrong-password':
                            errorMessage =
                                'Incorrect password. Please try again.';
                            break;
                          case 'invalid-email':
                            errorMessage =
                                'Invalid email format. Please check your email.';
                            break;
                          case 'user-disabled':
                            errorMessage =
                                'This user account has been disabled.';
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
                            "Sign In",
                            style: GoogleFonts.poppins(
                              color: const Color.fromARGB(255, 207, 197, 197),
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
            ],
          ),
        ),
      ),
    );
  }
}
