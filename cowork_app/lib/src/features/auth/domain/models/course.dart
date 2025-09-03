class Course {
  Course({
    this.id,
    required this.name,
    required this.description,
    required this.members,
  });

  String? id;
  String name;
  String description;
  List<String> members;

  factory Course.fromJson(Map<String, dynamic> json) => Course(
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
    return 'Course{entry_id: $id, name: $name, description: $description, members: $members}';
  }
}
