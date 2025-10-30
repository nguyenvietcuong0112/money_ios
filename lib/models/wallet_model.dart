import 'package:flutter/material.dart';

class Wallet {
  final String id;
  final String name;
  final double balance;
  final IconData icon;
  final String? image;

  Wallet(
      {required this.id,
      required this.name,
      required this.balance,
      required this.icon,
      this.image});
}
