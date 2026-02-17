import 'package:flutter/material.dart';

class AppAnimations {
  // Animation Durations
  static const Duration fast = Duration(milliseconds: 150);
  static const Duration standard = Duration(milliseconds: 300);
  static const Duration slow = Duration(milliseconds: 500);
  static const Duration verySlow = Duration(milliseconds: 800);
  
  // Animation Curves
  static const Curve easeIn = Curves.easeIn;
  static const Curve easeOut = Curves.easeOut;
  static const Curve easeInOut = Curves.easeInOut;
  static const Curve bounceOut = Curves.bounceOut;
  static const Curve elasticOut = Curves.elasticOut;
  static const Curve decelerate = Curves.decelerate;
  
  // Page Transition
  static const Curve pageTransitionCurve = Curves.easeInOutCubic;
  static const Duration pageTransitionDuration = Duration(milliseconds: 400);
  
  // Shimmer
  static const Duration shimmerDuration = Duration(milliseconds: 1500);
  
  // Achievement Unlock
  static const Duration achievementDuration = Duration(milliseconds: 1200);
}
