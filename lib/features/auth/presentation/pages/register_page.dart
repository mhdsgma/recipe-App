import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:recipe_app/features/auth/presentation/components/box_shadow.dart';
import 'package:recipe_app/features/auth/presentation/components/my_button.dart';
import 'package:recipe_app/features/auth/presentation/components/my_text_field.dart';
import 'package:recipe_app/features/auth/presentation/cubits/auth_cubit.dart';
import 'package:recipe_app/features/auth/presentation/pages/forgot_password_page.dart';

class RegisterPage extends StatefulWidget {
  final void Function()? togglePages;
  const RegisterPage({super.key, required this.togglePages});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final emailController = TextEditingController();
  final pwController = TextEditingController();
  final confirmPwController = TextEditingController();
  final nameController = TextEditingController();

  void signup() {
    final String name = nameController.text;
    final String email = emailController.text;
    final String pw = pwController.text;
    final String confirmPw = confirmPwController.text;

    final authCubit = context.read<AuthCubit>();

    if (email.isNotEmpty &&
        name.isNotEmpty &&
        pw.isNotEmpty &&
        confirmPw.isNotEmpty) {
      if (pw == confirmPw) {
        authCubit.register(email, pw, name);
      } else {
        showDialog(
          context: context,
          builder: (context) {
            return const AlertDialog(content: Text("Passwords don't match!"));
          },
        );
      }
    } else {
      showDialog(
        context: context,
        builder: (context) {
          return const AlertDialog(
            content: Text('Please fill out all fields!'),
          );
        },
      );
    }
  }

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    pwController.dispose();
    confirmPwController.dispose();
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
              decoration: BoxDecoration(
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
                    child: Text(
                      'Sign Up',
                      style: TextStyle(
                        fontSize: 50,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.only(top: screenHeight * 0.05),
                    padding: EdgeInsets.all(20),
                    width: screenWidth * 0.85,
                    decoration: BoxDecoration(
                      color: Color(0xFFF5F5DC).withValues(alpha: 0.7),
                      borderRadius: BorderRadius.circular(15),
                      boxShadow: [
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
                            controller: nameController,
                            hintText: 'Enter your name',
                            obscureText: false,
                            icon: Icons.person,
                          ),
                        ),
                        SizedBox(height: screenHeight * 0.02),
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
                            hintText: 'Enter Password',
                            obscureText: true,
                            icon: Icons.lock,
                          ),
                        ),
                        SizedBox(height: screenHeight * 0.02),
                        BoxShadowContainer(
                          width: double.infinity,
                          height: 60,
                          child: MyTextField(
                            controller: confirmPwController,
                            hintText: 'Confirm Password',
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
                                  builder: (context) {
                                    return ForgotPasswordPage();
                                  },
                                ),
                              );
                            },
                            child: Text(
                              'Forgot Password?',
                              style: TextStyle(color: Color(0xFF333333)),
                            ),
                          ),
                        ),
                        SizedBox(height: screenHeight * 0.02),
                        MyButton(
                          onTap: signup,
                          text: 'Sign Up',
                          icon: Icon(Icons.person_add),
                        ),
                        SizedBox(height: screenHeight * 0.02),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              "Already a member? ",
                              style: TextStyle(color: Colors.black),
                            ),
                            GestureDetector(
                              onTap: widget.togglePages,
                              child: Text(
                                " Log In",
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
