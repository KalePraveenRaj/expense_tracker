import 'package:flutter/material.dart';

class HoverElevatedCard extends StatefulWidget {
  final Widget child;
  final double normalElevation;
  final double hoverElevation;
  final BorderRadius borderRadius;
  final Color? shadowColor;

  const HoverElevatedCard({
    super.key,
    required this.child,
    this.normalElevation = 2,
    this.hoverElevation = 8,
    this.borderRadius = const BorderRadius.all(Radius.circular(16)),
    this.shadowColor,
  });

  @override
  State<HoverElevatedCard> createState() => _HoverElevatedCardState();
}

class _HoverElevatedCardState extends State<HoverElevatedCard> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: AnimatedPhysicalModel(
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOutCubic,
        elevation: _hovered ? widget.hoverElevation : widget.normalElevation,
        color: Theme.of(context).cardColor,
        shadowColor: widget.shadowColor ?? Colors.black.withOpacity(0.25),
        shape: BoxShape.rectangle,
        borderRadius: widget.borderRadius,
        child: widget.child,
      ),
    );
  }
}
