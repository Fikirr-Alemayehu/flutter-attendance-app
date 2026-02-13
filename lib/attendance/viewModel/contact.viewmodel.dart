import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/contact_model.dart';

class ContactViewModel extends ChangeNotifier {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  List<Contact> contacts = [];
  bool loading = true;

  ContactViewModel() {
    _listenToContacts();
  }

  void _listenToContacts() {
    _db.collection('contacts').snapshots().listen((snapshot) {
      contacts = snapshot.docs
          .map((doc) => Contact.fromMap(doc.id, doc.data() ?? {}))
          .toList();
      loading = false;
      notifyListeners();
    });
  }

  Future<void> addContact(String name, String phone) async {
    await _db.collection('contacts').add({
      'name': name,
      'phone': phone,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> updateContact(String id, String name, String phone) async {
    await _db.collection('contacts').doc(id).update({
      'name': name,
      'phone': phone,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> removeContact(String id) async {
    await _db.collection('contacts').doc(id).delete();
  }

  Future<void> launchDialer(String phone) async {
    final uri = Uri(scheme: 'tel', path: phone);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  Contact? getContactById(String id) {
    try {
      return contacts.firstWhere((c) => c.id == id);
    } catch (_) {
      return null;
    }
  }
}
