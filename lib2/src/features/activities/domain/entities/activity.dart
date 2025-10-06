import 'package:hive/hive.dart';

part 'activity.g.dart';

@HiveType(typeId: 6)
class Activity extends HiveObject {
  @HiveField(0)
  String? id;

  @HiveField(1)
  int categoryId;

  @HiveField(2)
  String name;

  @HiveField(3)
  String description;

  @HiveField(4)
  DateTime deliveryDate;

  Activity({
    this.id,
    required this.categoryId,
    required this.name,
    required this.description,
    required this.deliveryDate,
  });

  Activity copyWith({
    String? id,
    int? categoryId,
    String? name,
    String? description,
    DateTime? deliveryDate,
  }) {
    return Activity(
      id: id ?? this.id,
      categoryId: categoryId ?? this.categoryId,
      name: name ?? this.name,
      description: description ?? this.description,
      deliveryDate: deliveryDate ?? this.deliveryDate,
    );
  }
}
