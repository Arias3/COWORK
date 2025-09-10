class Activity {
  String? id;
  int categoryId;
  String name;
  String description;
  DateTime deliveryDate;

  Activity({
    this.id,
    required this.categoryId,
    required this.name,
    required this.description,
    required this.deliveryDate,
  });

  // 🔹 copyWith
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

  factory Activity.fromJson(Map<String, dynamic> json) => Activity(
        id: json["_id"],
        categoryId: json["categoryId"] ?? 0,
        name: json["name"] ?? "---",
        description: json["description"] ?? "---",
        deliveryDate: json["delivery_date"] != null
            ? DateTime.parse(json["delivery_date"])
            : DateTime.now(),
      );

  Map<String, dynamic> toJson() => {
        "_id": id ?? "0",
        "categoryId": categoryId,
        "name": name,
        "description": description,
        "delivery_date": deliveryDate.toIso8601String(),
      };

  Map<String, dynamic> toJsonNoId() => {
        "categoryId": categoryId,
        "name": name,
        "description": description,
        "delivery_date": deliveryDate.toIso8601String(),
      };

  @override
  String toString() {
    return 'Activity{id: $id, categoryId: $categoryId, name: $name, description: $description, deliveryDate: $deliveryDate}';
  }
}
