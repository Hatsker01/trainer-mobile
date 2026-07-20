import 'package:flutter/material.dart';

/// T0 vaqtinchalik ekrani — sessiya tekshiruvi T2 da qo'shiladi.
class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: SafeArea(
        child: Center(
          child: Text(
            'USTOZ',
            style: TextStyle(
              fontFamily: 'Unbounded',
              fontWeight: FontWeight.w700,
              fontSize: 32,
              letterSpacing: 1,
            ),
          ),
        ),
      ),
    );
  }
}
