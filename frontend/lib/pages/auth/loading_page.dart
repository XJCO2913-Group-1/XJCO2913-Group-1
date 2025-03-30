import 'package:flutter/material.dart';
import 'dart:async';
import 'sign_up_page.dart';
import 'login_page.dart';
import '../../components/page_title.dart';

class LoadingPage extends StatefulWidget {
  const LoadingPage({super.key});

  @override
  State<LoadingPage> createState() => _LoadingPageState();
}

class _LoadingPageState extends State<LoadingPage> {
  @override
  void initState() {
    super.initState();
    // 设置2秒后自动跳转到LoginPage
    Timer(const Duration(seconds: 2), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LoginPage()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(height: 100),
            // Logo or app name
            const Text(
              'Welcome To E-Scooter',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const Text(
              'Loading...',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 40),
            // Loading indicator
            const CircularProgressIndicator(),
            const Spacer(),
            // // Bottom buttons
            // Padding(
            //   padding: const EdgeInsets.all(20.0),
            //   child: Row(
            //     mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            //     children: [
            //       Expanded(
            //         child: ElevatedButton(
            //           onPressed: () {
            //             Navigator.push(
            //               context,
            //               MaterialPageRoute(
            //                 builder: (context) => const SignUpPage(),
            //               ),
            //             );
            //           },
            //           style: ElevatedButton.styleFrom(
            //             backgroundColor: const Color.fromARGB(255, 28, 49, 44),
            //             foregroundColor: Colors.white,
            //             padding: const EdgeInsets.symmetric(vertical: 15),
            //           ),
            //           child: const Text('Sign Up'),
            //         ),
            //       ),
            //       const SizedBox(width: 20),
            //       Expanded(
            //         child: ElevatedButton(
            //           onPressed: () {
            //             Navigator.push(
            //               context,
            //               MaterialPageRoute(
            //                 builder: (context) => const LoginPage(),
            //               ),
            //             );
            //           },
            //           style: ElevatedButton.styleFrom(
            //             backgroundColor: const Color.fromARGB(255, 28, 49, 44),
            //             foregroundColor: Colors.white,
            //             padding: const EdgeInsets.symmetric(vertical: 15),
            //           ),
            //           child: const Text('Log In'),
            //         ),
            //       ),
            //     ],
            //   ),
            // ),
          ],
        ),
      ),
    );
  }
}
