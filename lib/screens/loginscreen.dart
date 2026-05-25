import 'package:flutter/material.dart';
import 'dashboardscreen.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context){
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column (
          children: [
            const SizedBox(height: 80),
            CircleAvatar(
              radius: 65,
              backgroundColor: const Color(0xFF9BC8EB),
              child:CircleAvatar(
                radius: 60,
                backgroundColor: Colors.white,
                child: Icon(Icons.menu_book, size: 60, color: Colors.blue[800]),
              ),
            ),
            const SizedBox(height: 40),
            const Text( 
              'LOGIN',
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Color(0xFF2B4C7E))
            ),
            const SizedBox(height:30),
            Container (
              margin: const EdgeInsets.symmetric(horizontal: 30),
              padding: const EdgeInsets.all(25),
              decoration: BoxDecoration(
                color: const Color(0xFF9BC8EB).withOpacity(0.7),
                borderRadius: BorderRadius.circular(40),
              ),
              child: Column(
                children: [
                  TextField(
                    decoration: InputDecoration(
                      hintText: 'Email',
                      prefixIcon: const Icon(Icons.email, color: Color(0xFF2B4C7E)),
                      filled: true,
                      fillColor: const Color(0xFFF7F9FA),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(20), borderSide: BorderSide.none),
                    ),
                  ),
                  const SizedBox(height: 15),
                  TextField(
                    obscureText: true,
                    decoration: InputDecoration( 
                      hintText: 'Password',
                      prefixIcon: const Icon(Icons.lock, color: Color(0xFF2B4C7E)),
                      filled: true,
                      fillColor: const Color(0xFFF7F9FA),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(20), borderSide: BorderSide.none),
                    ),
                  ),  
                  const SizedBox(height: 20),
                  ElevatedButton( 
                    style: ElevatedButton.styleFrom( 
                      backgroundColor: const Color(0xFF2B4C7E),
                      minimumSize: const Size(double.infinity, 45),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                    ),
                    onPressed: () {
                      Navigator.push(context, MaterialPageRoute(builder: (context) => const DashboardScreen()));
                    },
                    child: const Text('Login', style: TextStyle(color: Color(0xFFF7F9FA), fontSize: 12)),
                  ),
                  const SizedBox(height: 15),
                  const Text('Or Login With', style: TextStyle(color: Color(0xFF2B4C7E), fontSize: 12)),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _socialIcon(Icons.g_mobiledata),
                      const SizedBox(width: 15),
                      _socialIcon(Icons.facebook),
                      const SizedBox(width: 15),
                      _socialIcon(Icons.close),
                    ],
                  ),
                  const SizedBox(height: 15),
                  GestureDetector(
                    onTap: (){},
                    child: const Text('Create account', style: TextStyle(color: Color(0xFF2B4C7E), decoration: TextDecoration.underline)),
                  ),
                ],
                )
            ),
          ],
        ),
      ),
    );
  }

  Widget _socialIcon(IconData icon) {
    return CircleAvatar(
      radius: 20,
      backgroundColor: const Color(0xFFF7F9FA),
      child: Icon(icon, color: Colors.white),
    );
  }
}
