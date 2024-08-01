// ignore_for_file: library_private_types_in_public_api, use_build_context_synchronously, prefer_const_constructors, unused_import

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'home_screen.dart'; // Import the home screen after sign in
import 'sign_up_page.dart'; // Import the sign-up page
import 'package:provider/provider.dart';
import '../providers/theme_provider.dart'; // Import ThemeProvider
import '../providers/user_provider.dart'; // Import UserProvider
import 'package:flutter/foundation.dart' show kIsWeb, defaultTargetPlatform, TargetPlatform;

class SignInPage extends StatefulWidget {
  final VoidCallback? toggleTheme;
  final bool? isDarkMode;

  const SignInPage({super.key, this.toggleTheme, this.isDarkMode});

  @override
  _SignInPageState createState() => _SignInPageState();
}

class _SignInPageState extends State<SignInPage> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  Future<UserCredential> signInWithGoogle() async {
    GoogleSignIn googleSignIn;

    if (kIsWeb) {
      googleSignIn = GoogleSignIn(clientId: '32191230194-9iiolvll0holtfn00asistihge8oo9i7.apps.googleusercontent.com');
    } else {
      switch (defaultTargetPlatform) {
        case TargetPlatform.android:
          googleSignIn = GoogleSignIn(clientId: '32191230194-47sc3dfbopvvjvi9jmk99me9lkd0b706.apps.googleusercontent.com');
          break;
        case TargetPlatform.iOS:
          googleSignIn = GoogleSignIn(clientId: '32191230194-spb8h29m9mkqasu7ckpbbadt8fgs6e15.apps.googleusercontent.com');
          break;
        case TargetPlatform.macOS:
          googleSignIn = GoogleSignIn(clientId: '32191230194-spb8h29m9mkqasu7ckpbbadt8fgs6e15.apps.googleusercontent.com');
          break;
        default:
          throw UnsupportedError('Google Sign-In is not supported for this platform');
      }
    }

    final GoogleSignInAccount? googleUser = await googleSignIn.signIn();
    if (googleUser == null) {
      throw FirebaseAuthException(
        code: 'ERROR_ABORTED_BY_USER',
        message: 'Sign in aborted by user',
      );
    }
    final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );
    return await FirebaseAuth.instance.signInWithCredential(credential);
  }

  void signIn() async {
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: emailController.text,
        password: passwordController.text,
      );
      if (!mounted) return; // Check if the widget is still mounted
      Fluttertoast.showToast(msg: 'Signed in successfully', timeInSecForIosWeb: 5);
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => HomeScreen()),
      );
    } on FirebaseAuthException catch (e) {
      Fluttertoast.showToast(msg: e.message ?? 'Sign in failed', timeInSecForIosWeb: 5);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: isDarkMode ? Colors.black : Colors.pinkAccent,
        title: const Text('Sign In', style: TextStyle(color: Colors.white)),
        actions: [
          Consumer<ThemeProvider>(
            builder: (context, themeProvider, child) {
              return IconButton(
                icon: Icon(
                  themeProvider.isDarkMode ? Icons.light_mode : Icons.dark_mode,
                  color: Colors.white,
                ),
                onPressed: () {
                  themeProvider.toggleTheme();
                },
              );
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/images/background.jpg',
              fit: BoxFit.cover,
            ),
          ),
          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Consumer<ThemeProvider>(
                builder: (context, themeProvider, child) {
                  return Container(
                    decoration: BoxDecoration(
                      color: isDarkMode ? Colors.black54 : Colors.white.withOpacity(themeProvider.overlayOpacity),
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          spreadRadius: 3,
                          blurRadius: 5,
                          offset: Offset(0, 3),
                        ),
                      ],
                    ),
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const Text(
                          'Welcome Back!',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: Colors.pinkAccent,
                            fontFamily: 'Raleway',
                          ),
                        ),
                        const SizedBox(height: 32),
                        Container(
                          decoration: BoxDecoration(
                            color: isDarkMode ? Colors.grey[800] : Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.pinkAccent.withOpacity(0.1),
                                spreadRadius: 3,
                                blurRadius: 5,
                                offset: Offset(0, 3),
                              ),
                            ],
                          ),
                          child: TextField(
                            controller: emailController,
                            style: TextStyle(color: isDarkMode ? Colors.white : Colors.black),
                            decoration: InputDecoration(
                              prefixIcon: Icon(Icons.email, color: Colors.pinkAccent),
                              labelText: 'Email',
                              labelStyle: TextStyle(color: isDarkMode ? Colors.white54 : Colors.black54),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              filled: true,
                              fillColor: isDarkMode ? Colors.grey[800] : Colors.white,
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Container(
                          decoration: BoxDecoration(
                            color: isDarkMode ? Colors.grey[800] : Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.pinkAccent.withOpacity(0.1),
                                spreadRadius: 3,
                                blurRadius: 5,
                                offset: Offset(0, 3),
                              ),
                            ],
                          ),
                          child: TextField(
                            controller: passwordController,
                            obscureText: true,
                            style: TextStyle(color: isDarkMode ? Colors.white : Colors.black),
                            decoration: InputDecoration(
                              prefixIcon: Icon(Icons.lock, color: Colors.pinkAccent),
                              labelText: 'Password',
                              labelStyle: TextStyle(color: isDarkMode ? Colors.white54 : Colors.black54),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              filled: true,
                              fillColor: isDarkMode ? Colors.grey[800] : Colors.white,
                            ),
                          ),
                        ),
                        const SizedBox(height: 32),
                        ElevatedButton.icon(
                          onPressed: signIn,
                          icon: Icon(Icons.login, color: Colors.white),
                          label: const Text(
                            'Sign In',
                            style: TextStyle(fontSize: 18, fontFamily: 'Raleway'),
                          ),
                          style: ElevatedButton.styleFrom(
                            foregroundColor: Colors.white,
                            backgroundColor: Colors.pinkAccent,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        TextButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => SignUpPage(toggleTheme: widget.toggleTheme, isDarkMode: widget.isDarkMode)),
                            );
                          },
                          child: const Text(
                            'Don\'t have an account? Sign Up',
                            style: TextStyle(color: Colors.pinkAccent, fontFamily: 'Raleway'),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
