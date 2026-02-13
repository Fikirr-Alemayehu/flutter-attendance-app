class Contact {
  final String id;
  String name;
  String phone;

  Contact({required this.id, required this.name, required this.phone});

  factory Contact.fromMap(String id, Map<String, dynamic> data) {
    return Contact(
      id: id,
      name: data['name'] ?? '',
      phone: data['phone'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {'name': name, 'phone': phone};
  }
}
