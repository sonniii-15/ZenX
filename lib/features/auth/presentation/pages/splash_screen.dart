import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../../core/theme/zenx_colors.dart';
import 'package:flutter_animate/flutter_animate.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkAuth();
  }

  Future<void> _checkAuth() async {
    // Slight delay for splash screen aesthetic
    await Future.delayed(const Duration(milliseconds: 1500));
    
    if (!mounted) return;
    
    // Check if user is authenticated
    if (FirebaseAuth.instance.currentUser != null) {
      context.go('/home');
    }
  }

  void _handleTap() {
    // If user is already authenticated, the timer will push to home.
    // If they tap, we go to login (assuming they are unauthenticated)
    if (FirebaseAuth.instance.currentUser == null) {
      context.go('/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: _handleTap,
        child: Stack(
          children: [
            // Center Logo and text
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Logo with pulse glow
                  Container(
                    width: 280,
                    height: 280,
                    decoration: BoxDecoration(
                      boxShadow: [
                        BoxShadow(
                          color: ZenXColors.primary.withValues(alpha: 0.3),
                          blurRadius: 80,
                          spreadRadius: 20,
                        ),
                      ],
                    ),
                    child: Image.asset(
                      'assets/images/zenx_logo_red.jpg',
                      fit: BoxFit.contain,
                    ),
                  )
                  .animate(onPlay: (controller) => controller.repeat(reverse: true))
                  .scale(begin: const Offset(1.0, 1.0), end: const Offset(1.05, 1.05), duration: 2.seconds),
                  
                  const SizedBox(height: 16),
                  
                ],
              ),
            ),
            
            // Bottom "TAP ANYWHERE" text and glow
            Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: const EdgeInsets.only(bottom: 60.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      'TAP ANYWHERE TO CONTINUE',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        letterSpacing: 2,
                        fontWeight: FontWeight.bold,
                      ),
                    ).animate(onPlay: (controller) => controller.repeat())
                     .fadeIn(duration: 1.seconds)
                     .then(delay: 500.ms)
                     .fadeOut(duration: 1.seconds),
                    
                    const SizedBox(height: 30),
                    // Bottom red glow
                    Container(
                      width: 150,
                      height: 4,
                      decoration: BoxDecoration(
                        color: ZenXColors.primary,
                        boxShadow: const [
                          BoxShadow(
                            color: ZenXColors.primary,
                            blurRadius: 20,
                            spreadRadius: 5,
                          ),
                        ],
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
