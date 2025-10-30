import 'package:hive/hive.dart';

part 'wallet_model.g.dart';

@HiveType(typeId: 4)
class Wallet {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String name;

  @HiveField(2)
  final double balance;

  @HiveField(3)
  final String iconPath;

  @HiveField(4)
  final String? image;

  Wallet({
    required this.id,
    required this.name,
    required this.balance,
    required this.iconPath,
    this.image,
  });
}
