import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class HomeLogo extends StatelessWidget {
  const HomeLogo({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Align(
        alignment: Alignment.topCenter,
        child: Padding(
          padding: const EdgeInsets.only(top: 50.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.asset(
                'assets/images/salarypro_wallet.png',
                width: 150,
                height: 150,
                fit: BoxFit.contain,
              ),
              const SizedBox(height: 15),
              RichText(
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: 'Salary',
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontSize: 38,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    TextSpan(
                      text: 'Pro',
                      style: GoogleFonts.poppins(
                        color: const Color.fromARGB(255, 117, 19, 197),
                        fontSize: 38,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 8,),
              Text('Manage Salaries\nGrow Together',
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                letterSpacing: 0.5,
              ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
