import 'package:hive/hive.dart';

part 'contact_model.g.dart';

@HiveType(typeId: 2)
class Contact extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  String name;

  @HiveField(2)
  String phone;

  Contact({required this.id, required this.name, required this.phone});
}
