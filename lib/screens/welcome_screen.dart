import 'dart:ui';
import 'package:cms/screens/signin_screen.dart';
import 'package:cms/screens/signup_screen.dart';
import 'package:cms/widgets/custom_scaffold.dart';
import 'package:cms/widgets/welcome_button.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return CustomScaffold(
      child: Column(
        children: [
          Flexible(
            flex: 8,
            child: Container(
              padding: const EdgeInsets.symmetric(
                vertical: 0.0,
                horizontal: 40.0,
              ),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Add the image here
                    Image.asset(
                      'assets/images/newlogo.png',
                      height: 500, // Adjust the height of the image
                    ),
                    // RichText(
                    //   textAlign: TextAlign.center,
                    //   text: const TextSpan(
                    //     children: [
                    //       TextSpan(
                    //         text: '\nWelcome!\n\n',
                    //         style: TextStyle(
                    //           fontSize: 45.0,
                    //           fontWeight: FontWeight.w600,
                    //           shadows: [
                    //             Shadow(
                    //               offset: Offset(3.0, 3.0), // Position of the shadow
                    //               blurRadius: 1.0, // How much the shadow should be blurred
                    //               color: Color.fromARGB(200, 0, 0, 0), // Shadow color with full opacity
                    //             ),
                    //           ],
                    //         ),
                    //       ),
                    //       TextSpan(
                    //         text: '\n', //write here
                    //         style: TextStyle(
                    //           fontSize: 20.0,
                    //           shadows: [
                    //             Shadow(
                    //               offset: Offset(1.5, 1.5), // Position of the shadow
                    //               blurRadius: 3.0, // How much the shadow should be blurred
                    //               color: Color.fromARGB(170, 0, 0, 0), // Shadow color with full opacity
                    //             ),
                    //           ],
                    //           // fontWeight:FontWeight.w600,
                    //         ),
                    //       ),
                    //     ],
                    //   ),
                    // ),
                  ],
                ),
              ),
            ),
          ),
          const Flexible(
            flex: 1,
            child: Align(
              alignment: Alignment.bottomRight,
              child: Row(
                children: [
                  Expanded(
                    child: WelcomeButton(
                      buttonText: 'Sign In',
                      onTap: SignInScreen(),
                      color: Colors.transparent,
                      textColor: Color(0xFF00c896),

                    ),
                  ),
                  Expanded(
                    child: WelcomeButton(
                      buttonText: 'Sign Up',
                      onTap: SignupScreen(),
                      color: Color(0xFF00c896),
                      textColor: Color(0xFFF5F5F5),
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
