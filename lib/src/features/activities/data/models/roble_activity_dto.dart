import '../../domain/entities/activity.dart';

class RobleActivityDto {
  final String? id;
  final int categoryId;
  final String name;
  final String description;
  final String deliveryDate;

  RobleActivityDto({
    this.id,
    required this.categoryId,
    required this.name,
    required this.description,
    required this.deliveryDate,
  });

  Map<String, dynamic> toJson() => {
    if (id != null) 'id': id,
    'category_id': categoryId,
    'name': name,
    'description': description,
    'delivery_date': deliveryDate,
  };

  factory RobleActivityDto.fromJson(Map<String, dynamic> json) => RobleActivityDto(
    id: json['id'],
    categoryId: json['category_id'],
    name: json['name'],
    description: json['description'],
    deliveryDate: json['delivery_date'],
  );

  factory RobleActivityDto.fromEntity(Activity activity) => RobleActivityDto(
    id: activity.id,
    categoryId: activity.categoryId,
    name: activity.name,
    description: activity.description,
    deliveryDate: activity.deliveryDate.toIso8601String(),
  );

  Activity toEntity() => Activity(
    id: id,
    categoryId: categoryId,
    name: name,
    description: description,
    deliveryDate: DateTime.parse(deliveryDate),
  );
}