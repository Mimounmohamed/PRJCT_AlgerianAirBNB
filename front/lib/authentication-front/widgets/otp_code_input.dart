import 'package:flutter/material.dart';
import 'package:flutter/services.dart';


class OtpCodeInput extends StatefulWidget {
  const OtpCodeInput({
    super.key,
    this.length = 6,
    required this.onCompleted,
    this.onChanged,
    this.fillColor = const Color(0xFFFBF3E7),
    this.errorText,
    this.markAllRed = false,
  });

  final int length;
  final ValueChanged<String> onCompleted;
  final ValueChanged<String>? onChanged;
  final Color fillColor;

  /// When non-null, the field is in an error state and this text is shown
  /// below the boxes.
  final String? errorText;

  /// When true (e.g. a full code was submitted and rejected by the server),
  /// every box is highlighted red. When false, only the empty boxes are
  /// highlighted red (e.g. the user tried to submit an incomplete code).
  final bool markAllRed;

  @override
  State<OtpCodeInput> createState() => _OtpCodeInputState();
}

class _OtpCodeInputState extends State<OtpCodeInput> {
  late final List<TextEditingController> _controllers = List.generate(
    widget.length,
    (_) => TextEditingController(),
  );
  late final List<FocusNode> _focusNodes = List.generate(
    widget.length,
    (_) => FocusNode(),
  );

  @override
  void dispose() {
    for (final c in _controllers) {
      c.dispose();
    }
    for (final f in _focusNodes) {
      f.dispose();
    }
    super.dispose();
  }

  void _onDigitChanged(int index, String value) {
    if (value.isNotEmpty && index < widget.length - 1) {
      _focusNodes[index + 1].requestFocus();
    } else if (value.isEmpty && index > 0) {
      _focusNodes[index - 1].requestFocus();
    }

    final code = _controllers.map((c) => c.text).join();
    setState(() {});
    widget.onChanged?.call(code);
    if (code.length == widget.length) {
      FocusScope.of(context).unfocus();
      widget.onCompleted(code);
    }
  }

  @override
  Widget build(BuildContext context) {
    final hasError = widget.errorText != null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: List.generate(widget.length, (index) {
            final isBoxEmpty = _controllers[index].text.isEmpty;
            final isBoxRed = hasError && (widget.markAllRed || isBoxEmpty);

            return SizedBox(
              width: 44,
              height: 52,
              child: TextField(
                controller: _controllers[index],
                focusNode: _focusNodes[index],
                textAlign: TextAlign.center,
                keyboardType: TextInputType.number,
                maxLength: 1,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF1A1A1A),
                ),
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                decoration: InputDecoration(
                  counterText: '',
                  filled: true,
                  fillColor: widget.fillColor,
                  contentPadding: EdgeInsets.zero,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: isBoxRed ? Colors.red : const Color(0xFFD9CDB5),
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: isBoxRed ? Colors.red : const Color(0xFFD9CDB5),
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: isBoxRed ? Colors.red : const Color(0xFF006972),
                    ),
                  ),
                ),
                onChanged: (value) => _onDigitChanged(index, value),
              ),
            );
          }),
        ),
        if (hasError)
          Padding(
            padding: const EdgeInsets.only(top: 10),
            child: Center(
              child: Text(
                widget.errorText!,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.red,
                  fontSize: 12,
                ),
              ),
            ),
          ),
      ],
    );
  }
}