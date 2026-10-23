import 'package:flutter/material.dart';

/// Stacks every `StatefulShellRoute` branch navigator and cross-fades between
/// them on tab change.
class AnimatedBranchContainer extends StatelessWidget {
  const AnimatedBranchContainer({
    required this.currentIndex,
    required this.children,
    super.key,
  });

  final int currentIndex;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: List.generate(children.length, (index) {
        final isActive = index == currentIndex;
        return IgnorePointer(
          ignoring: !isActive,
          child: AnimatedOpacity(
            opacity: isActive ? 1.0 : 0.0,
            duration: const Duration(milliseconds: 220),
            curve: Curves.easeInOutCubic,
            child: TickerMode(
              enabled: isActive,
              child: children[index],
            ),
          ),
        );
      }),
    );
  }
}
