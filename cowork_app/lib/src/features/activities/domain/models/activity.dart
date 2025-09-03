class Activity {
  Activity({
    this.id,
    required this.name,
    required this.description,
    required this.members,
    required this.delivery_date,
  });

  String? id;
  String name;
  String description;
  DateTime delivery_date;
  List<String> members;

  factory Activity.fromJson(Map<String, dynamic> json) => Activity(
    id: json["_id"],
    name: json["name"] ?? "---",
    description: json["description"] ?? "---",
    delivery_date: json["delivery_date"] != null
        ? DateTime.parse(json["delivery_date"])
        : DateTime.now(),
    members: (json["members"] as List<dynamic>? ?? [])
        .map((e) => e.toString())
        .toList(),
  );

  Map<String, dynamic> toJson() => {
    "_id": id ?? "0",
    "name": name,
    "description": description,
    "delivery_date": delivery_date.toIso8601String(),
    "members": members,
  };

  Map<String, dynamic> toJsonNoId() => {
    "name": name,
    "description": description,
    "delivery_date": delivery_date.toIso8601String(),
    "members": members,
  };

  @override
  String toString() {
    return 'Activity{entry_id: $id, name: $name, description: $description, members: $members, delivery_date: $delivery_date}';
  }
}
