import 'package:flutter/material.dart';
import 'package:flutter/services.dart';


/// Input de 6 dígitos para el código TOTP durante el setup.
class TotpCodeInput extends StatelessWidget {
  final TextEditingController controller;
  const TotpCodeInput({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      keyboardType: TextInputType.number,
      inputFormatters: [
        FilteringTextInputFormatter.digitsOnly,
        LengthLimitingTextInputFormatter(6),
      ],
      textAlign: TextAlign.center,
      style: const TextStyle(
        fontSize: 28,
        letterSpacing: 12,
        fontWeight: FontWeight.w700,
      ),
      decoration: const InputDecoration(hintText: '000000'),
    );
  }
}