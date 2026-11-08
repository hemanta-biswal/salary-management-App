import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CustomButton extends StatelessWidget {
  final VoidCallback? onGetStarted;
  final VoidCallback? onSignIn;

  const CustomButton({
    super.key,
    this.onGetStarted,
    this.onSignIn,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: 80,
      left: 24,
      right: 24,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: double.infinity,
            height: 55,
            child: ElevatedButton.icon(
              onPressed: onGetStarted,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
              iconAlignment: IconAlignment.end,
              icon: const Icon(
                Icons.arrow_forward_rounded,
                color: Color.fromARGB(255, 5, 7, 105),
              ),
              label: Text(
                'Get Started',
                style: GoogleFonts.poppins(
                  color: const Color.fromARGB(255, 5, 7, 105),
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          TextButton(
            onPressed: onSignIn,
            child: Text(
              'Sign In',
              style: GoogleFonts.poppins(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
