import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

part 'category_model.g.dart';

@HiveType(typeId: 1)
class Category {
  @HiveField(0)
  final String name;

  @HiveField(1)
  final IconData icon;

  @HiveField(2)
  final Color color;

  Category({required this.name, required this.icon, required this.color});
}
