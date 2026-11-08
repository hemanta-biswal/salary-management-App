import 'package:flutter/material.dart';
import 'package:salary_managenmnet_system/screens/login_screen.dart';
import 'package:salary_managenmnet_system/screens/signup_screen.dart';
import 'package:salary_managenmnet_system/widgets/custom_button.dart';
import 'package:salary_managenmnet_system/widgets/wallet_logo.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            width: double.infinity,
            height: double.infinity,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color.fromARGB(255, 43, 6, 93),
                  Color.fromARGB(255, 67, 18, 157),
                  Color.fromARGB(255, 145, 69, 211),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: const HomeLogo(),
          ),
          CustomButton(
            onSignIn: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const LoginScreen()),
              );
            },
            onGetStarted: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SignUpScreen()),
              );
            },
          ),
        ],
      ),
    );
  }
}
