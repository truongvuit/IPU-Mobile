import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class OtpInputField extends StatefulWidget {
  final int length;
  final void Function(String)? onCompleted;
  final void Function(String)? onChanged;

  const OtpInputField({
    super.key,
    this.length = 6,
    this.onCompleted,
    this.onChanged,
  });

  @override
  State<OtpInputField> createState() => _OtpInputFieldState();
}

class _OtpInputFieldState extends State<OtpInputField> {
  late List<TextEditingController> _controllers;
  late List<FocusNode> _focusNodes;

  @override
  void initState() {
    super.initState();
    _controllers = List.generate(
      widget.length,
      (index) => TextEditingController(),
    );
    _focusNodes = List.generate(widget.length, (index) => FocusNode());
  }

  @override
  void dispose() {
    for (var controller in _controllers) {
      controller.dispose();
    }
    for (var node in _focusNodes) {
      node.dispose();
    }
    super.dispose();
  }

  String _getOtpValue() {
    return _controllers.map((c) => c.text).join();
  }

  void _onChanged(int index, String value) {
    if (value.isNotEmpty && index < widget.length - 1) {
      _focusNodes[index + 1].requestFocus();
    }

    final otp = _getOtpValue();
    widget.onChanged?.call(otp);

    if (otp.length == widget.length) {
      widget.onCompleted?.call(otp);
    }
  }

  void _onKeyEvent(int index, KeyEvent event) {
    if (event is KeyDownEvent &&
        event.logicalKey == LogicalKeyboardKey.backspace) {
      if (_controllers[index].text.isEmpty && index > 0) {
        _focusNodes[index - 1].requestFocus();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(
        widget.length,
        (index) => Padding(
          padding: EdgeInsets.symmetric(
            horizontal: MediaQuery.of(context).size.width > 600 ? 8 : 4,
          ),
          child: SizedBox(
            width: 48,
            height: 56,
            child: KeyboardListener(
              focusNode: FocusNode(),
              onKeyEvent: (event) => _onKeyEvent(index, event),
              child: TextField(
                controller: _controllers[index],
                focusNode: _focusNodes[index],
                textAlign: TextAlign.center,
                keyboardType: TextInputType.number,
                maxLength: 1,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: isDark ? Colors.white : const Color(0xFF0F172A),
                  fontFamily: 'Lexend',
                ),
                decoration: InputDecoration(
                  counterText: '',
                  filled: true,
                  fillColor: Colors.transparent,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(
                      color: isDark
                          ? const Color(0xFF4B5563)
                          : const Color(0xFFD1D5DB),
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(
                      color: isDark
                          ? const Color(0xFF4B5563)
                          : const Color(0xFFD1D5DB),
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(
                      color: Color(0xFF135BEC),
                      width: 2,
                    ),
                  ),
                  contentPadding: EdgeInsets.zero,
                ),
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                onChanged: (value) => _onChanged(index, value),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
