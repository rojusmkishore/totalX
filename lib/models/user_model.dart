class UserModel {
  final String id;
  final String name;
  final String phoneNumber;
  final int age;
  final String imageUrl;
  final DateTime createdAt;

  UserModel({
    required this.id,
    required this.name,
    required this.phoneNumber,
    required this.age,
    required this.imageUrl,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'phoneNumber': phoneNumber,
      'age': age,
      'imageUrl': imageUrl,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      phoneNumber: map['phoneNumber'] ?? '',
      age: map['age'] ?? 0,
      imageUrl: map['imageUrl'] ?? '',
      createdAt: DateTime.parse(map['createdAt'] ?? DateTime.now().toIso8601String()),
    );
  }
}
