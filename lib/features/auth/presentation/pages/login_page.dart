import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:recipe_app/config/app_analytics.dart';
import 'package:recipe_app/features/auth/presentation/components/box_shadow.dart';
import 'package:recipe_app/features/auth/presentation/components/my_button.dart';
import 'package:recipe_app/features/auth/presentation/components/my_text_field.dart';
import 'package:recipe_app/features/auth/presentation/cubits/auth_cubit.dart';
import 'package:recipe_app/features/auth/presentation/pages/forgot_password_page.dart';

class LoginPage extends StatefulWidget {
  final void Function()? togglePages;
  const LoginPage({super.key, required this.togglePages});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final emailController = TextEditingController();
  final pwController = TextEditingController();

  void login() async {
    final String email = emailController.text.trim();
    final String pw = pwController.text;

    final authCubit = context.read<AuthCubit>();

    await AppAnalytics.logLoginAttempt(emailEntered: email.isNotEmpty);

    if (email.isNotEmpty && pw.isNotEmpty) {
      authCubit.login(email, pw);
      await AppAnalytics.logAndroidDeviceInfo();
      await AppAnalytics.logLoginSuccess(method: 'email');
    } else {
      showDialog(
        context: context,
        builder: (context) {
          return const AlertDialog(
            content: Text('Please enter email and password'),
          );
        },
      );
      await AppAnalytics.logLoginFailedEmptyFields();
    }
  }

  @override
  void dispose() {
    emailController.dispose();
    pwController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('assets/images/background.jpg'),
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
          Center(
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.max,
                children: <Widget>[
                  Padding(
                    padding: EdgeInsets.only(top: screenHeight * 0.03),
                    child: const Text(
                      'Sign In',
                      style: TextStyle(
                        fontSize: 50,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.only(top: screenHeight * 0.05),
                    padding: const EdgeInsets.all(20),
                    width: screenWidth * 0.85,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF5F5DC).withValues(alpha: 0.7),
                      borderRadius: BorderRadius.circular(15),
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.black26,
                          spreadRadius: 2,
                          blurRadius: 5,
                          offset: Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        BoxShadowContainer(
                          width: double.infinity,
                          height: 60,
                          child: MyTextField(
                            controller: emailController,
                            hintText: 'Enter Email',
                            obscureText: false,
                            icon: Icons.email,
                          ),
                        ),
                        SizedBox(height: screenHeight * 0.02),
                        BoxShadowContainer(
                          width: double.infinity,
                          height: 60,
                          child: MyTextField(
                            controller: pwController,
                            hintText: 'Password',
                            obscureText: true,
                            icon: Icons.lock,
                          ),
                        ),
                        SizedBox(height: screenHeight * 0.015),
                        Align(
                          alignment: Alignment.bottomRight,
                          child: GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const ForgotPasswordPage(),
                                ),
                              );
                            },
                            child: const Text(
                              'Forgot Password?',
                              style: TextStyle(color: Color(0xFF333333)),
                            ),
                          ),
                        ),
                        SizedBox(height: screenHeight * 0.02),
                        MyButton(
                          onTap: login,
                          text: 'login',
                          icon: const Icon(Icons.login),
                        ),
                        SizedBox(height: screenHeight * 0.02),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text(
                              "Not a member?",
                              style: TextStyle(color: Colors.black),
                            ),
                            GestureDetector(
                              onTap: widget.togglePages,
                              child: const Text(
                                " Register now",
                                style: TextStyle(
                                  color: Colors.black,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
