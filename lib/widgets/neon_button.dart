import 'package:flutter/material.dart';

import '../app/app.dart';
import '../utils/constants.dart';

class NeonButton extends StatefulWidget {
  const NeonButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.color = NeonColors.cyan,
    this.expanded = true,
    this.icon,
  });

  final String label;
  final VoidCallback? onPressed;
  final Color color;
  final bool expanded;
  final IconData? icon;

  @override
  State<NeonButton> createState() => _NeonButtonState();
}

class _NeonButtonState extends State<NeonButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final enabled = widget.onPressed != null;
    final button = AnimatedScale(
      duration: const Duration(milliseconds: 90),
      scale: _pressed ? 0.97 : 1,
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: widget.color.withValues(alpha: 0.9),
            width: 1.4,
          ),
          color: widget.color.withValues(alpha: enabled ? 0.12 : 0.05),
          boxShadow: [
            BoxShadow(
              color: widget.color.withValues(alpha: 0.18),
              blurRadius: 16,
              spreadRadius: 0.4,
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: widget.expanded ? MainAxisSize.max : MainAxisSize.min,
            children: [
              if (widget.icon != null) ...[
                Icon(widget.icon, color: widget.color, size: 20),
                const SizedBox(width: 10),
              ],
              Flexible(
                child: Text(
                  widget.label,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: enabled ? NeonColors.text : NeonColors.mutedText,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.4,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );

    return Semantics(
      button: true,
      label: widget.label,
      child: GestureDetector(
        onTapDown: enabled ? (_) => setState(() => _pressed = true) : null,
        onTapCancel: () => setState(() => _pressed = false),
        onTapUp: enabled
            ? (_) {
                setState(() => _pressed = false);
                AppScope.of(context).playTap();
                widget.onPressed?.call();
              }
            : null,
        child: widget.expanded
            ? SizedBox(width: double.infinity, child: button)
            : button,
      ),
    );
  }
}
