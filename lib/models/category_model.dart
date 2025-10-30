import 'package:hive/hive.dart';

part 'category_model.g.dart';

@HiveType(typeId: 1)
class Category {
  @HiveField(0)
  final String name;

  @HiveField(1)
  final String iconPath;

  @HiveField(2)
  final int colorValue;

  Category({
    required this.name,
    required this.iconPath,
    required this.colorValue,
  });
}
