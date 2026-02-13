class Student {
  final String id;
  final String name;
  final String phone;
  final String address;
  final String? contactId;

  Student({
    required this.id,
    required this.name,
    required this.phone,
    required this.address,
    this.contactId,
  });

  factory Student.fromMap(String id, Map<String, dynamic> data) {
    return Student(
      id: id,
      name: data['name'] ?? '',
      phone: data['phone'] ?? '',
      address: data['address'] ?? '',
      contactId: data['contactId'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'phone': phone,
      'address': address,
      'contactId': contactId,
      'updatedAt': DateTime.now(),
    };
  }
}
