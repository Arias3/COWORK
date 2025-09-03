class Activity {
  Activity({
    this.id,
    required this.name,
    required this.description,
    required this.members,
  });

  String? id;
  String name;
  String description;
  List<String> members;

  factory Activity.fromJson(Map<String, dynamic> json) => Activity(
    id: json["_id"],
    name: json["name"] ?? "---",
    description: json["description"] ?? "---",
    members: (json["members"] as List<dynamic>? ?? [])
        .map((e) => e.toString())
        .toList(),
  );

  Map<String, dynamic> toJson() => {
    "_id": id ?? "0",
    "name": name,
    "description": description,
    "members": members,
  };

  Map<String, dynamic> toJsonNoId() => {
    "name": name,
    "description": description,
    "members": members,
  };

  @override
  String toString() {
    return 'Activity{entry_id: $id, name: $name, description: $description, members: $members}';
  }
}
