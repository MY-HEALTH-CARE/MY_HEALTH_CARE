import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'firebase_options.dart';
import 'dashboard_screen.dart';
import 'profile_setup_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'My Health Care',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF0077B6)),
        useMaterial3: true,
      ),
      home: const SplashScreen(),
    );
  }
}

// ===================== SHARED UI HELPERS =====================

class FadeSlideIn extends StatefulWidget {
  final Widget child;
  final Duration delay;
  final double offsetY;

  const FadeSlideIn({
    super.key,
    required this.child,
    this.delay = Duration.zero,
    this.offsetY = 24,
  });

  @override
  State<FadeSlideIn> createState() => _FadeSlideInState();
}

class _FadeSlideInState extends State<FadeSlideIn> {
  bool _visible = false;

  @override
  void initState() {
    super.initState();
    Future.delayed(widget.delay, () {
      if (mounted) setState(() => _visible = true);
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      opacity: _visible ? 1 : 0,
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeOut,
      child: AnimatedSlide(
        offset: _visible ? Offset.zero : Offset(0, widget.offsetY / 100),
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeOutCubic,
        child: widget.child,
      ),
    );
  }
}

class MedicalHeaderIllustration extends StatefulWidget {
  final double size;
  const MedicalHeaderIllustration({super.key, this.size = 150});

  @override
  State<MedicalHeaderIllustration> createState() =>
      _MedicalHeaderIllustrationState();
}

class _MedicalHeaderIllustrationState extends State<MedicalHeaderIllustration>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Widget _badge(IconData icon, Color color, double phase) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final bob = 6 * (_controller.value - 0.5) * (phase.isNegative ? -1 : 1);
        return Transform.translate(offset: Offset(0, bob), child: child);
      },
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.12),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Icon(icon, color: color, size: 18),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.size + 60,
      height: widget.size + 40,
      child: Stack(
        alignment: Alignment.center,
        children: [
          AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              final scale = 1 + 0.06 * _controller.value;
              return Transform.scale(scale: scale, child: child);
            },
            child: Container(
              width: widget.size,
              height: widget.size,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.18),
              ),
            ),
          ),
          Container(
            width: widget.size * 0.72,
            height: widget.size * 0.72,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.15),
                  blurRadius: 16,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: const Icon(
              Icons.local_hospital_rounded,
              color: Color(0xFF0077B6),
              size: 46,
            ),
          ),
          Positioned(
              top: 6,
              left: 10,
              child: _badge(Icons.favorite_rounded, Colors.redAccent, 1)),
          Positioned(
              bottom: 10,
              right: 6,
              child: _badge(
                  Icons.medication_rounded, const Color(0xFF00B4D8), -1)),
          Positioned(
              top: 20,
              right: 0,
              child: _badge(
                  Icons.monitor_heart_rounded, Colors.deepPurple, 1)),
        ],
      ),
    );
  }
}

class AuthTextField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final IconData icon;
  final bool obscureText;
  final TextInputType keyboardType;

  const AuthTextField({
    super.key,
    required this.controller,
    required this.label,
    required this.icon,
    this.obscureText = false,
    this.keyboardType = TextInputType.text,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        filled: true,
        fillColor: const Color(0xFFF5F8FA),
        prefixIcon: Icon(icon, color: const Color(0xFF0077B6)),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xFF0077B6), width: 2),
        ),
      ),
    );
  }
}

class PrimaryGradientButton extends StatelessWidget {
  final String label;
  final bool isLoading;
  final VoidCallback? onPressed;

  const PrimaryGradientButton({
    super.key,
    required this.label,
    required this.isLoading,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          gradient: const LinearGradient(
            colors: [Color(0xFF0077B6), Color(0xFF00B4D8)],
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF0077B6).withValues(alpha: 0.35),
              blurRadius: 14,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: ElevatedButton(
          onPressed: isLoading ? null : onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent,
            shadowColor: Colors.transparent,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14)),
          ),
          child: isLoading
              ? const SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(
                      color: Colors.white, strokeWidth: 2.4),
                )
              : Text(label,
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.bold)),
        ),
      ),
    );
  }
}

Widget _errorBanner(String message) {
  return Container(
    margin: const EdgeInsets.only(bottom: 12),
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(
      color: Colors.red.shade50,
      borderRadius: BorderRadius.circular(10),
      border: Border.all(color: Colors.red.shade100),
    ),
    child: Row(
      children: [
        const Icon(Icons.error_outline, color: Colors.red, size: 18),
        const SizedBox(width: 8),
        Expanded(
            child: Text(message, style: const TextStyle(color: Colors.red))),
      ],
    ),
  );
}

// ===================== SPLASH SCREEN =====================
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scale;
  late final Animation<double> _fade;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..forward();
    _scale = CurvedAnimation(parent: _controller, curve: Curves.easeOutBack);
    _fade = CurvedAnimation(parent: _controller, curve: Curves.easeIn);

    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const LoginScreen()),
        );
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF0077B6), Color(0xFF00B4D8)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ScaleTransition(
                scale: _scale,
                child: FadeTransition(
                  opacity: _fade,
                  child: const MedicalHeaderIllustration(size: 140),
                ),
              ),
              const SizedBox(height: 15),
              FadeTransition(
                opacity: _fade,
                child: const Text('My Health Care',
                    style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        letterSpacing: 1.2)),
              ),
              const SizedBox(height: 8),
              FadeTransition(
                opacity: _fade,
                child: const Text('Your Health, Our Priority',
                    style: TextStyle(fontSize: 15, color: Colors.white70)),
              ),
              const SizedBox(height: 50),
              const CircularProgressIndicator(
                  color: Colors.white, strokeWidth: 2),
            ],
          ),
        ),
      ),
    );
  }
}

// ===================== LOGIN SCREEN =====================
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  bool isLoading = false;
  String errorMessage = '';

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  Future<void> signIn() async {
    final email = emailController.text.trim();
    final password = passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      setState(() => errorMessage = 'Please fill in all fields!');
      return;
    }

    setState(() {
      isLoading = true;
      errorMessage = '';
    });

    try {
      final userCredential =
          await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (!userCredential.user!.emailVerified) {
        await userCredential.user!.sendEmailVerification();
        await FirebaseAuth.instance.signOut();
        setState(() => errorMessage =
            'Email not verified! A new verification email has been sent. Please check your inbox.');
        return;
      }

      if (mounted) {
        final uid = userCredential.user!.uid;
        final doc = await FirebaseFirestore.instance
            .collection('users')
            .doc(uid)
            .get();
        final data = doc.data();
        final bool profileCompleted =
            data != null && data['profileCompleted'] == true;

        if (!mounted) return;
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => profileCompleted
                ? const DashboardScreen()
                : const ProfileSetupScreen(),
          ),
        );
      }
    } on FirebaseAuthException catch (e) {
      String message = 'Something went wrong!';
      if (e.code == 'user-not-found') {
        message = 'No account found with this email!';
      } else if (e.code == 'wrong-password') {
        message = 'Incorrect password!';
      } else if (e.code == 'invalid-email') {
        message = 'Invalid email address!';
      } else if (e.code == 'invalid-credential') {
        message = 'Invalid email or password!';
      }
      setState(() => errorMessage = message);
    } catch (e) {
      setState(() => errorMessage = 'Error: $e');
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  void showForgotPasswordDialog() {
    final resetEmailController = TextEditingController();
    String dialogError = '';
    bool isSending = false;

    showDialog(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (dialogContext, setDialogState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15)),
              title: const Row(
                children: [
                  Icon(Icons.lock_reset, color: Color(0xFF0077B6)),
                  SizedBox(width: 10),
                  Text('Reset Password'),
                ],
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Enter your registered email. We will send a password reset link.',
                    style: TextStyle(fontSize: 13, color: Colors.grey),
                  ),
                  const SizedBox(height: 15),
                  TextField(
                    controller: resetEmailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: InputDecoration(
                      labelText: 'Email',
                      prefixIcon: const Icon(Icons.email_outlined,
                          color: Color(0xFF0077B6)),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                  if (dialogError.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 10),
                      child: Text(dialogError,
                          style:
                              const TextStyle(color: Colors.red, fontSize: 12)),
                    ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext),
                  child:
                      const Text('Cancel', style: TextStyle(color: Colors.grey)),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0077B6),
                      foregroundColor: Colors.white),
                  onPressed: isSending
                      ? null
                      : () async {
                          final email = resetEmailController.text.trim();
                          if (email.isEmpty) {
                            setDialogState(
                                () => dialogError = 'Please enter your email!');
                            return;
                          }
                          setDialogState(() {
                            isSending = true;
                            dialogError = '';
                          });
                          try {
                            await FirebaseAuth.instance
                                .sendPasswordResetEmail(email: email);
                            if (mounted) {
                              Navigator.pop(dialogContext);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                    content: Text(
                                        'Password reset link sent to $email.')),
                              );
                            }
                          } on FirebaseAuthException catch (e) {
                            String msg = 'Something went wrong!';
                            if (e.code == 'user-not-found') {
                              msg = 'No account found with this email!';
                            } else if (e.code == 'invalid-email') {
                              msg = 'Please enter a valid email!';
                            }
                            setDialogState(() {
                              dialogError = msg;
                              isSending = false;
                            });
                          } catch (e) {
                            setDialogState(() {
                              dialogError = 'Error: $e';
                              isSending = false;
                            });
                          }
                        },
                  child: isSending
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                              color: Colors.white, strokeWidth: 2))
                      : const Text('Send'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF0077B6), Color(0xFF00B4D8)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              const SizedBox(height: 20),
              const MedicalHeaderIllustration(size: 120),
              const SizedBox(height: 6),
              const Text('My Health Care',
                  style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.white)),
              const SizedBox(height: 4),
              const Text('Your Health, Our Priority',
                  style: TextStyle(fontSize: 13, color: Colors.white70)),
              const SizedBox(height: 20),
              Expanded(
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.fromLTRB(25, 30, 25, 10),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(35),
                      topRight: Radius.circular(35),
                    ),
                  ),
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const FadeSlideIn(
                          delay: Duration(milliseconds: 50),
                          child: Text('Welcome Back! 👋',
                              style: TextStyle(
                                  fontSize: 22, fontWeight: FontWeight.bold)),
                        ),
                        const SizedBox(height: 5),
                        const FadeSlideIn(
                          delay: Duration(milliseconds: 100),
                          child: Text('Login to your account',
                              style:
                                  TextStyle(fontSize: 14, color: Colors.grey)),
                        ),
                        const SizedBox(height: 25),
                        FadeSlideIn(
                          delay: const Duration(milliseconds: 150),
                          child: AuthTextField(
                            controller: emailController,
                            label: 'Email',
                            icon: Icons.email_outlined,
                            keyboardType: TextInputType.emailAddress,
                          ),
                        ),
                        const SizedBox(height: 15),
                        FadeSlideIn(
                          delay: const Duration(milliseconds: 200),
                          child: AuthTextField(
                            controller: passwordController,
                            label: 'Password',
                            icon: Icons.lock_outline,
                            obscureText: true,
                          ),
                        ),
                        FadeSlideIn(
                          delay: const Duration(milliseconds: 220),
                          child: Align(
                            alignment: Alignment.centerRight,
                            child: TextButton(
                              onPressed: showForgotPasswordDialog,
                              child: const Text('Forgot Password?',
                                  style: TextStyle(color: Color(0xFF0077B6))),
                            ),
                          ),
                        ),
                        if (errorMessage.isNotEmpty) _errorBanner(errorMessage),
                        const SizedBox(height: 6),
                        FadeSlideIn(
                          delay: const Duration(milliseconds: 260),
                          child: PrimaryGradientButton(
                            label: 'Sign In',
                            isLoading: isLoading,
                            onPressed: signIn,
                          ),
                        ),
                        const SizedBox(height: 20),
                        FadeSlideIn(
                          delay: const Duration(milliseconds: 300),
                          child: Row(
                            children: [
                              Expanded(
                                  child: Divider(color: Colors.grey.shade300)),
                              const Padding(
                                padding: EdgeInsets.symmetric(horizontal: 10),
                                child: Text('or',
                                    style: TextStyle(color: Colors.grey)),
                              ),
                              Expanded(
                                  child: Divider(color: Colors.grey.shade300)),
                            ],
                          ),
                        ),
                        const SizedBox(height: 15),
                        FadeSlideIn(
                          delay: const Duration(milliseconds: 340),
                          child: Center(
                            child: TextButton(
                              onPressed: () {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (_) => const SignUpScreen()));
                              },
                              child: RichText(
                                text: const TextSpan(
                                  text: "Don't have an account? ",
                                  style: TextStyle(color: Colors.grey),
                                  children: [
                                    TextSpan(
                                      text: 'Sign Up',
                                      style: TextStyle(
                                          color: Color(0xFF0077B6),
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 15),
                      ],
                    ),
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

// ===================== SIGN UP SCREEN =====================
class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  bool isLoading = false;
  String errorMessage = '';

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> signUp() async {
    final name = nameController.text.trim();
    final email = emailController.text.trim();
    final password = passwordController.text.trim();
    final confirmPassword = confirmPasswordController.text.trim();

    if (name.isEmpty ||
        email.isEmpty ||
        password.isEmpty ||
        confirmPassword.isEmpty) {
      setState(() => errorMessage = 'Please fill in all fields!');
      return;
    }
    if (!RegExp(r'^[\w\-\.]+@([\w\-]+\.)+[\w\-]{2,4}$').hasMatch(email)) {
      setState(() => errorMessage = 'Please enter a valid email!');
      return;
    }
    if (password.length < 6) {
      setState(() => errorMessage = 'Password must be at least 6 characters!');
      return;
    }
    if (password != confirmPassword) {
      setState(() => errorMessage = 'Passwords do not match!');
      return;
    }

    setState(() {
      isLoading = true;
      errorMessage = '';
    });

    try {
      final userCredential =
          await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      await FirebaseFirestore.instance
          .collection('users')
          .doc(userCredential.user!.uid)
          .set({
        'name': name,
        'email': email,
        'points': 0,
        'profileCompleted': false,
        'createdAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      await userCredential.user!.sendEmailVerification();
      if (mounted) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (_) => AlertDialog(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15)),
            title: const Row(
              children: [
                Icon(Icons.mark_email_unread, color: Color(0xFF0077B6)),
                SizedBox(width: 10),
                Text('Verify Your Email'),
              ],
            ),
            content: Text(
                'A verification link has been sent to $email.\n\nPlease verify your email before logging in.'),
            actions: [
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0077B6),
                    foregroundColor: Colors.white),
                child: const Text('OK'),
              ),
            ],
          ),
        );
      }
    } on FirebaseAuthException catch (e) {
      String message = 'Something went wrong!';
      if (e.code == 'email-already-in-use') {
        message = 'An account already exists with this email!';
      } else if (e.code == 'invalid-email') {
        message = 'Invalid email address!';
      } else if (e.code == 'weak-password') {
        message = 'Password is too weak!';
      }
      setState(() => errorMessage = message);
    } catch (e) {
      setState(() => errorMessage = 'Error: $e');
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF0077B6), Color(0xFF00B4D8)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              const SizedBox(height: 10),
              const MedicalHeaderIllustration(size: 100),
              const SizedBox(height: 4),
              const Text('My Health Care',
                  style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.white)),
              const SizedBox(height: 4),
              const Text('Join us and take charge of your health',
                  style: TextStyle(fontSize: 13, color: Colors.white70)),
              const SizedBox(height: 14),
              Expanded(
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.fromLTRB(25, 25, 25, 10),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(35),
                      topRight: Radius.circular(35),
                    ),
                  ),
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const FadeSlideIn(
                          delay: Duration(milliseconds: 50),
                          child: Text('Create Account',
                              style: TextStyle(
                                  fontSize: 22, fontWeight: FontWeight.bold)),
                        ),
                        const SizedBox(height: 5),
                        const FadeSlideIn(
                          delay: Duration(milliseconds: 100),
                          child: Text('Sign up to get started',
                              style:
                                  TextStyle(fontSize: 14, color: Colors.grey)),
                        ),
                        const SizedBox(height: 20),
                        FadeSlideIn(
                          delay: const Duration(milliseconds: 130),
                          child: AuthTextField(
                            controller: nameController,
                            label: 'Full Name',
                            icon: Icons.person_outline,
                          ),
                        ),
                        const SizedBox(height: 14),
                        FadeSlideIn(
                          delay: const Duration(milliseconds: 160),
                          child: AuthTextField(
                            controller: emailController,
                            label: 'Email',
                            icon: Icons.email_outlined,
                            keyboardType: TextInputType.emailAddress,
                          ),
                        ),
                        const SizedBox(height: 14),
                        FadeSlideIn(
                          delay: const Duration(milliseconds: 190),
                          child: AuthTextField(
                            controller: passwordController,
                            label: 'Password',
                            icon: Icons.lock_outline,
                            obscureText: true,
                          ),
                        ),
                        const SizedBox(height: 14),
                        FadeSlideIn(
                          delay: const Duration(milliseconds: 230),
                          child: AuthTextField(
                            controller: confirmPasswordController,
                            label: 'Confirm Password',
                            icon: Icons.lock_outline,
                            obscureText: true,
                          ),
                        ),
                        const SizedBox(height: 14),
                        if (errorMessage.isNotEmpty) _errorBanner(errorMessage),
                        FadeSlideIn(
                          delay: const Duration(milliseconds: 270),
                          child: PrimaryGradientButton(
                            label: 'Sign Up',
                            isLoading: isLoading,
                            onPressed: signUp,
                          ),
                        ),
                        const SizedBox(height: 12),
                        FadeSlideIn(
                          delay: const Duration(milliseconds: 310),
                          child: Center(
                            child: TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: RichText(
                                text: const TextSpan(
                                  text: 'Already have an account? ',
                                  style: TextStyle(color: Colors.grey),
                                  children: [
                                    TextSpan(
                                      text: 'Login',
                                      style: TextStyle(
                                          color: Color(0xFF0077B6),
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
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