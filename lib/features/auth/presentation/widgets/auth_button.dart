import 'package:flutter/material.dart';

class AuthButton extends StatefulWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;

  const AuthButton({
    super.key,
    required this.text,
    this.onPressed,
    this.isLoading = false,
  });

  @override
  State<AuthButton> createState() => _AuthButtonState();
}

class _AuthButtonState extends State<AuthButton> {
  bool _isPressed = false;

  void _handlePressDown() {
    if (!widget.isLoading) {
      setState(() => _isPressed = true);
    }
  }

  void _handlePressUp() async {
    if (_isPressed) {
      // Small delay to ensure the animation is visible even on quick taps
      await Future.delayed(const Duration(milliseconds: 50));
      if (mounted) {
        setState(() => _isPressed = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: IntrinsicWidth(
        child: GestureDetector(
          onTapDown: (_) => _handlePressDown(),
          onTapUp: (_) => _handlePressUp(),
          onTapCancel: () => _handlePressUp(),
          onTap: widget.isLoading ? null : widget.onPressed,
          behavior: HitTestBehavior.opaque,
          child: AnimatedScale(
            duration: const Duration(milliseconds: 80),
            scale: _isPressed ? 0.96 : 1.0,
            curve: Curves.easeOut,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              padding: const EdgeInsets.symmetric(horizontal: 40),
              height: 55,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(30),
                gradient: _isPressed
                    ? const LinearGradient(
                        colors: [Color(0xFF6366F1), Color(0xFFA855F7)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      )
                    : const LinearGradient(
                        colors: [Colors.white, Colors.white],
                      ),
                boxShadow: [
                  BoxShadow(
                    color: (_isPressed ? const Color(0xFF6366F1) : Colors.black)
                        .withOpacity(0.2),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              alignment: Alignment.center,
              child: widget.isLoading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.blue,
                      ),
                    )
                  : Text(
                      widget.text,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: _isPressed ? Colors.white : Colors.black,
                      ),
                    ),
            ),
          ),
        ),
      ),
    );
  }
}
