import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Import Firebase Auth
import 'package:firebase_database/firebase_database.dart'; // Import Firebase Database
import 'package:google_sign_in/google_sign_in.dart'; // Import Google Sign-In
import 'sign_up_page.dart';
import 'admin_landing_page.dart';
import 'student_landing_page.dart';
import 'staff_landing_page.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _controller = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _passwordController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  // Function to store admin details in Firebase Realtime Database
  Future<void> _storeAdminData() async {
    DatabaseReference adminRef = FirebaseDatabase.instance.ref('users/admin');
    DataSnapshot snapshot = await adminRef.get();

    // Check if admin data already exists
    if (!snapshot.exists) {
      await adminRef.set({
        'role': 'admin',
        'name': 'Administrator',
        'email': 'admin@admin.com'
      });
    }
  }

  void _login() async {
    String input = _controller.text;
    String password = _passwordController.text;

    // Existing login code remains the same
    if (input == 'root' && password == 'adminonly123') {
      await _storeAdminData();
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => AdminLandingPage()),
      );
    } else {
      if (_formKey.currentState!.validate()) {
        try {
          UserCredential userCredential;
          if (RegExp(r'^[0-9]+$').hasMatch(input)) {
            int studentID = int.parse(input);
            if (studentID < 2018000000 || studentID > 2024999999) {
              _showErrorDialog(
                  'Invalid student ID. Must be within the allowed range.');
              return;
            }
            String email = '$input@university.edu';
            userCredential =
                await FirebaseAuth.instance.signInWithEmailAndPassword(
              email: email,
              password: password,
            );
          } else if (RegExp(r'^[a-zA-Z]+$').hasMatch(input)) {
            String email = '$input@staff.edu';
            userCredential =
                await FirebaseAuth.instance.signInWithEmailAndPassword(
              email: email,
              password: password,
            );
          } else {
            _showErrorDialog(
                'Invalid input. Please enter a valid student ID or staff name.');
            return;
          }
          DatabaseReference userRef = FirebaseDatabase.instance
              .ref('users/${userCredential.user!.uid}');
          DataSnapshot snapshot = await userRef.get();
          if (snapshot.exists) {
            String role = snapshot.child('role').value as String;
            switch (role) {
              case 'student':
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const StudentLandingPage()),
                );
                break;
              case 'staff':
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                      builder: (context) =>
                          const StaffLandingPage(isStaff: true)),
                );
                break;
              default:
                _showErrorDialog('Unknown user role');
            }
          } else {
            _showErrorDialog('User data not found in database');
          }
        } on FirebaseAuthException catch (e) {
          _showErrorDialog(e.message!);
        } catch (e) {
          _showErrorDialog('An error occurred: ${e.toString()}');
        }
      }
    }
  }

  Future<void> _signInWithGoogle() async {
    try {
      final GoogleSignIn googleSignIn = GoogleSignIn();
      final GoogleSignInAccount? googleUser = await googleSignIn.signIn();
      if (googleUser == null) {
        _showErrorDialog('Google Sign-In canceled.');
        return;
      }
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final userCredential =
          await FirebaseAuth.instance.signInWithCredential(credential);

      // Fetch the user's role from the database
      DatabaseReference userRef =
          FirebaseDatabase.instance.ref('users/${userCredential.user!.uid}');
      DataSnapshot snapshot = await userRef.get();

      if (snapshot.exists) {
        String role = snapshot.child('role').value as String;
        switch (role) {
          case 'student':
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                  builder: (context) => const StudentLandingPage()),
            );
            break;
          case 'staff':
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                  builder: (context) => const StaffLandingPage(isStaff: true)),
            );
            break;
          case 'admin':
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => AdminLandingPage()),
            );
            break;
          default:
            _showErrorDialog('Unknown user role');
        }
      } else {
        _showErrorDialog('User data not found in database');
      }
    } catch (e) {
      _showErrorDialog('Google Sign-In failed: ${e.toString()}');
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Error'),
          content: Text(message),
          actions: <Widget>[
            TextButton(
              child: Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(height: 40),
                Text(
                  'Welcome Back!',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                SizedBox(height: 20),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: 8,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  padding: EdgeInsets.symmetric(vertical: 20, horizontal: 16),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        TextFormField(
                          controller: _controller,
                          focusNode: _focusNode,
                          decoration: InputDecoration(
                            labelText: 'Staff Name/Student ID',
                            labelStyle: TextStyle(color: Colors.grey[600]),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide(
                                color: Colors.blueAccent,
                                width: 2,
                              ),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide(
                                color: Colors.grey[400]!,
                              ),
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter a value';
                            }
                            return null;
                          },
                        ),
                        SizedBox(height: 20),
                        TextFormField(
                          controller: _passwordController,
                          obscureText: true,
                          decoration: InputDecoration(
                            labelText: 'Password',
                            labelStyle: TextStyle(color: Colors.grey[600]),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide(
                                color: Colors.blueAccent,
                                width: 2,
                              ),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide(
                                color: Colors.grey[400]!,
                              ),
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter your password';
                            }
                            return null;
                          },
                        ),
                        SizedBox(height: 20),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: _login,
                            style: ElevatedButton.styleFrom(
                              padding: EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              backgroundColor: Colors.blueAccent,
                            ),
                            child: Text(
                              'Login',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: 10),
                        // Google Sign-In Button (size matched with Login button)
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: _signInWithGoogle,
                            style: ElevatedButton.styleFrom(
                              padding: EdgeInsets.symmetric(vertical: 16),
                              backgroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              side: BorderSide(color: Colors.grey[400]!),
                            ),
                            icon: Image.asset(
                              'assets/images/google_logo.png', // Add your Google logo path here
                              height: 24,
                            ),
                            label: Text(
                              'Sign in with Google',
                              style: TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => SignUpPage()),
                            );
                          },
                          child: Text('Don\'t have an account? Sign Up'),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 20),
                Text(
                  'LOGIN PAGE',
                  style: TextStyle(color: Colors.grey[600]),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
