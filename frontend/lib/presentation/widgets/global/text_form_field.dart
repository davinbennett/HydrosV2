import 'package:flutter/material.dart';
import 'package:frontend/core/themes/radius_size.dart';
import 'package:frontend/core/themes/spacing_size.dart';
import 'package:frontend/core/themes/colors.dart';
import 'package:frontend/core/themes/font_size.dart';

class TextFormFieldWidget extends StatelessWidget {
  final String label;
  final IconData? icon;
  final bool isPassword;
  final TextEditingController? controller;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;
  final void Function(String)? onChanged;

  const TextFormFieldWidget({
    super.key,
    required this.label,
    this.icon,
    this.isPassword = false,
    this.controller,
    this.keyboardType,
    this.validator,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      obscureText: isPassword,
      onChanged: onChanged,
      validator: validator,
      style: TextStyle(
        fontSize: AppFontSize.s,
        color: AppColors.black,
      ),
      cursorColor: AppColors.orange,
      decoration: InputDecoration(
        contentPadding: EdgeInsets.symmetric(
          horizontal: AppSpacingSize.m, // padding kiri-kanan teks
          vertical: AppFontSize.m, // padding atas-bawah teks
        ),
        labelText: label,
        labelStyle: TextStyle(
          color: AppColors.grayLight,
          fontSize: AppFontSize.m,
        ),
        floatingLabelStyle: TextStyle(color: AppColors.orange),
        prefixIcon:
            icon != null
                ? Padding(
                  padding: EdgeInsets.only(left: AppSpacingSize.m),
                  child: Icon(icon),
                )
                : null,
        prefixIconColor: WidgetStateColor.resolveWith((states) {
          if (states.contains(WidgetState.focused)) {
            return AppColors.orange;
          }
          return AppColors.grayLight;
        }),
        filled: true,
        fillColor: Colors.white,
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.rm),
          borderSide: BorderSide(width: 0.7, color: AppColors.grayLight),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.rm),
          borderSide: BorderSide(width: 1.5, color: AppColors.orange),
        ),
        focusColor: AppColors.orange,
        errorStyle: TextStyle(
          color: AppColors.danger,
          fontSize: AppFontSize.s,
        ),
        errorMaxLines: 2,
        focusedErrorBorder: OutlineInputBorder(
          borderSide: BorderSide(width: 1.5, color: AppColors.orange),
          borderRadius: BorderRadius.circular(AppRadius.rm),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.rm),
          borderSide: BorderSide(width: 0.7, color: AppColors.grayLight),
        ),
        
      ),
    );

  }
}
