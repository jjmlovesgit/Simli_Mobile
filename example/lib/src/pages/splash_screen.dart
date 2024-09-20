import 'package:example/src/widgets/bg.dart';
import 'package:flutter/material.dart';
import 'package:example/src/core/routes/router.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();

    navigate();
  }

  CarouselController carouselController = CarouselController();
  @override
  Widget build(BuildContext context) => const Scaffold(
        body: Bg(
            child: Center(
          child: CircularProgressIndicator(
            color: Colors.white,
            backgroundColor: Colors.white24,
          ),
        )),
      );

  void navigate() {
    Future.delayed(const Duration(seconds: 1)).then((value) {
      AppRouter.goToAvatarSelection();
    });
  }
}
