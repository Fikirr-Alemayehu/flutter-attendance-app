import 'dart:math';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:intl_phone_number_input/intl_phone_number_input.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/contact_model.dart';

class ContactViewModel extends ChangeNotifier {
  late Box<Contact> _contactBox;

  ContactViewModel() {
    _initBox();
  }

  List<Contact> get contacts => _contactBox.values.toList();

  Future<void> _initBox() async {
    _contactBox = Hive.box<Contact>('contact');
    notifyListeners();
  }

  Future<void> addContact(String name, String phone) async {
    final newContact = Contact(
      id: Random().nextInt(10000).toString(),
      name: name,
      phone: phone,
    );
    await _contactBox.add(newContact);
    notifyListeners();
  }

  Future<void> updateContact(String id, String name, String phone) async {
    final key = _contactBox.keys.firstWhere(
      (key) => _contactBox.get(key)!.id == id,
      orElse: () => null,
    );

    if (key != null) {
      final updated = Contact(id: id, name: name, phone: phone);
      await _contactBox.put(key, updated);
      notifyListeners();
    }
  }

  Future<void> removeContact(String id) async {
    final key = _contactBox.keys.firstWhere(
      (key) => _contactBox.get(key)!.id == id,
      orElse: () => null,
    );

    if (key != null) {
      await _contactBox.delete(key);
      notifyListeners();
    }
  }

  Future<void> launchDialer(String phone) async {
    final Uri url = Uri(scheme: 'tel', path: phone);
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    } else {
      debugPrint('Could not launch dialer for $phone');
    }
  }

  Contact? getContactById(String id) {
    try {
      return _contactBox.values.firstWhere((contact) => contact.id == id);
    } catch (e) {
      return null;
    }
  }

  void showContactDialog(BuildContext context, {Contact? contact}) {
    final nameController = TextEditingController(text: contact?.name ?? '');
    PhoneNumber number = PhoneNumber(
      phoneNumber: contact?.phone ?? '',
      isoCode: 'ET',
    );
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(contact == null ? 'Add Contact' : 'Edit Contact'),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: nameController,
                decoration: const InputDecoration(
                  hintText: 'Name',
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return "Name is required";
                  }
                  return null;
                },
              ),
              const SizedBox(height: 8),
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(
                    color: const Color.fromARGB(255, 122, 119, 119),
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: InternationalPhoneNumberInput(
                        onInputChanged: (PhoneNumber num) {
                          number = num;
                        },
                        selectorConfig: const SelectorConfig(
                          selectorType: PhoneInputSelectorType.DIALOG,
                          setSelectorButtonAsPrefixIcon: true,
                          leadingPadding: 2,
                        ),
                        initialValue: number,
                        textFieldController: TextEditingController(),
                        inputDecoration: const InputDecoration(
                          isDense: true,
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 4,
                          ),
                        ),
                        formatInput: true,
                        keyboardType: TextInputType.phone,
                        selectorTextStyle: const TextStyle(color: Colors.black),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () async {
              final name = nameController.text.trim();
              if (name.isEmpty || number.phoneNumber == null) return;
              final vm = Provider.of<ContactViewModel>(context, listen: false);
              if (contact == null) {
                await vm.addContact(name, number.phoneNumber!);
              } else {
                await updateContact(contact.id, name, number.phoneNumber!);
              }

              Navigator.pop(context);
            },
            child: Text(contact == null ? 'Add' : 'Save'),
          ),
        ],
      ),
    );
  }
}
