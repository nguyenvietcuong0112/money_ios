import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTextStyles {
  // Private constructor to prevent instantiation
  AppTextStyles._();

  static TextStyle get heading1 => GoogleFonts.lato(
    fontSize: 24,
    fontWeight: FontWeight.bold,
    color: Colors.black,
  );

  static TextStyle get heading2 => GoogleFonts.lato(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    color: Colors.black87,
  );

  static TextStyle get title => GoogleFonts.lato(
    fontSize: 18,
    fontWeight: FontWeight.bold,
    color: Colors.black,
  );

  static TextStyle get subtitle => GoogleFonts.lato(
    fontSize: 16,
    fontWeight: FontWeight.normal,
    color: Colors.black54,
  );

  static TextStyle get body => GoogleFonts.lato(
    fontSize: 14,
    fontWeight: FontWeight.normal,
    color: Colors.black87,
  );

  static TextStyle get caption => GoogleFonts.lato(
    fontSize: 12,
    fontWeight: FontWeight.normal,
    color: Colors.grey,
  );

  static TextStyle get button => GoogleFonts.lato(
    fontSize: 16,
    fontWeight: FontWeight.bold,
    color: Colors.white,
  );

  // Special styles for transaction amounts
  static TextStyle get incomeAmount => GoogleFonts.lato(
    fontSize: 16,
    fontWeight: FontWeight.bold,
    color: Colors.green,
  );

  static TextStyle get expenseAmount => GoogleFonts.lato(
    fontSize: 16,
    fontWeight: FontWeight.bold,
    color: Colors.red,
  );

  static TextStyle get totalAmount => GoogleFonts.lato(
    fontSize: 22,
    fontWeight: FontWeight.bold,
    color: Colors.black,
  );
}
