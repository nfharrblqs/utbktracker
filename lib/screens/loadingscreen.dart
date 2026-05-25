import 'package:flutter/material.dart';
import 'loginscreen.dart';

class LoadingScreen extends StatefulWidget {
  const LoadingScreen({super.key});

  @override
  State<LoadingScreen> createState() => _LoadingScreenState();
}

class _LoadingScreenState extends State<LoadingScreen> {
  @override
  void initState() {
    super.initState();
    _navigateToLogin();
  }

  _navigateToLogin() async {
    await Future.delayed(const Duration(seconds: 3));
    if (!mounted) return;

    Navigator.pushReplacement( 
    context,
    PageRouteBuilder( 
      pageBuilder: (context, animation, secondaryAnimation) => const LoginScreen(),
      transitionBuilder: (context, animation, secondaryAnimation, child){
        return FadeTransition(opacity: animation, child: child);
      },
      transitionDuration: const Duration(milliseconds: 800)
     ),
  )  
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Container(
          width:180,
          height: 180,
          decoration: const BoxDecoration(
            color: Color(0xFF9BC8EB),
            shape: BoxShape.circle,
          ),
          child: const Center(
            child: Text(
              'UTBK TRACKER',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold
              )
            )),
        ),
      ),
    );
  }
}
