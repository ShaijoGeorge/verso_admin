import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Centralized page transition factory for Verso Admin.
///
/// Transitions live here at the routing layer so the navigation act owns
/// the animation.
class AppPageTransitions {
  AppPageTransitions._();

  static const Duration _slide = Duration(milliseconds: 350);
  static const Duration _ceremonial = Duration(milliseconds: 500);
  static const Duration _fastReverse = Duration(milliseconds: 250);

  /// Pure opacity fade. Reserved for ceremonial one-shots (splash → home).
  static CustomTransitionPage<T> fade<T>({
    required LocalKey key,
    required Widget child,
  }) {
    return CustomTransitionPage<T>(
      key: key,
      child: child,
      transitionDuration: _ceremonial,
      transitionsBuilder: (_, animation, __, child) {
        return FadeTransition(
          opacity: CurvedAnimation(
            parent: animation,
            curve: Curves.easeInOutCubic,
          ),
          child: child,
        );
      },
    );
  }

  /// Material 3 fade-through pattern: outgoing page fades out while incoming
  /// page fades in with subtle scale (0.94 -> 1.0).
  static CustomTransitionPage<T> fadeThrough<T>({
    required LocalKey key,
    required Widget child,
  }) {
    return CustomTransitionPage<T>(
      key: key,
      child: child,
      reverseTransitionDuration: _fastReverse,
      transitionsBuilder: (_, animation, secondaryAnimation, child) {
        final enter = CurvedAnimation(
          parent: animation,
          curve: Curves.easeOutCubic,
          reverseCurve: Curves.easeInCubic,
        );
        final exit = CurvedAnimation(
          parent: secondaryAnimation,
          curve: Curves.easeInCubic,
        );
        return FadeTransition(
          opacity: Tween<double>(begin: 1, end: 0).animate(exit),
          child: FadeTransition(
            opacity: enter,
            child: ScaleTransition(
              scale: Tween<double>(begin: 0.94, end: 1).animate(enter),
              child: child,
            ),
          ),
        );
      },
    );
  }

  /// Horizontal push: incoming slides in from right edge while outgoing parallax-slides left.
  static CustomTransitionPage<T> slideFromRight<T>({
    required LocalKey key,
    required Widget child,
  }) {
    return CustomTransitionPage<T>(
      key: key,
      child: child,
      transitionDuration: _slide,
      reverseTransitionDuration: _fastReverse,
      transitionsBuilder: (_, animation, secondaryAnimation, child) {
        final enter = CurvedAnimation(
          parent: animation,
          curve: Curves.easeOutCubic,
          reverseCurve: Curves.easeInCubic,
        );
        final exit = CurvedAnimation(
          parent: secondaryAnimation,
          curve: Curves.easeInOutCubic,
        );
        return SlideTransition(
          position: Tween<Offset>(
            begin: Offset.zero,
            end: const Offset(-0.25, 0),
          ).animate(exit),
          child: FadeTransition(
            opacity: Tween<double>(begin: 1, end: 0.7).animate(exit),
            child: SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(1, 0),
                end: Offset.zero,
              ).animate(enter),
              child: child,
            ),
          ),
        );
      },
    );
  }

  /// Vertical sheet-style presentation: slides up from bottom with coupled fade-in.
  static CustomTransitionPage<T> slideFromBottom<T>({
    required LocalKey key,
    required Widget child,
  }) {
    return CustomTransitionPage<T>(
      key: key,
      child: child,
      transitionDuration: _slide,
      reverseTransitionDuration: _fastReverse,
      transitionsBuilder: (_, animation, __, child) {
        final enter = CurvedAnimation(
          parent: animation,
          curve: Curves.easeOutCubic,
          reverseCurve: Curves.easeInCubic,
        );
        return SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0, 1),
            end: Offset.zero,
          ).animate(enter),
          child: FadeTransition(
            opacity: Tween<double>(begin: 0, end: 1).animate(enter),
            child: child,
          ),
        );
      },
    );
  }
}
