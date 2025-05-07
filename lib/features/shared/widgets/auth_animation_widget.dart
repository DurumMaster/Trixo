import 'package:flutter/material.dart';
import "package:rive/rive.dart";

class AuthAnimationWidget extends StatefulWidget {
  const AuthAnimationWidget({super.key});

  @override
  State<AuthAnimationWidget> createState() => AuthAnimationWidgetState();
}

class AuthAnimationWidgetState extends State<AuthAnimationWidget> {
  late RiveAnimationController _controller;
  String currentAnimation = "idle";

  @override
  void initState() {
    super.initState();
    _controller = SimpleAnimation(currentAnimation);
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 200,
      width: 200,
      child: RiveAnimation.asset(
        "assets/animations/click_for_hat.riv",
        controllers: [_controller],
      ),
    );
  }

  Future<void> switchAnimation(String animationName, int duration) async {
    if (animationName == currentAnimation) return;

    setState(() {
      _controller.isActive = false;
      _controller = SimpleAnimation(animationName);
      currentAnimation = animationName;
    });

    await Future.delayed(Duration(milliseconds: duration));
  }
}
