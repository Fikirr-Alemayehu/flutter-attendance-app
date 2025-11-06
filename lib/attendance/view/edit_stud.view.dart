import 'package:flutter/material.dart';
import 'package:glc/attendance/models/contact_model.dart';
import 'package:glc/attendance/models/student_model.dart';
import 'package:glc/attendance/viewModel/contact.viewmodel.dart';
import 'package:glc/attendance/viewModel/home.viewModel.dart';
import 'package:intl_phone_number_input/intl_phone_number_input.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:provider/provider.dart';

class EditStudentView extends StatefulWidget {
  final Student student;

  const EditStudentView({super.key, required this.student});

  @override
  State<EditStudentView> createState() => _EditStudentViewState();
}

class _EditStudentViewState extends State<EditStudentView> {
  late TextEditingController nameController;
  PhoneNumber number = PhoneNumber(isoCode: 'ET');
  late TextEditingController addressController;

  String? selectedContactId;
  @override
  void initState() {
    super.initState();
    nameController = TextEditingController(text: widget.student.name);
    String initialPhone = widget.student.phone ?? '';
    number = PhoneNumber(isoCode: 'ET', phoneNumber: initialPhone);
    addressController = TextEditingController(text: widget.student.address);
    final currentContactId = widget.student.contactId;
    selectedContactId = currentContactId != null && currentContactId.isNotEmpty
        ? currentContactId
        : null;
  }

  @override
  Widget build(BuildContext context) {
    final vm = Provider.of<HomeViewModel>(context, listen: false);
    final contactVm = Provider.of<ContactViewModel>(context);
    final contacts = contactVm.contacts;
    final List<Contact> contactOptions = [
      Contact(id: '', name: 'No Contact Assigned', phone: ''),
      ...contacts,
    ];

    return Scaffold(
      backgroundColor: Colors.blueGrey[100],
      appBar: AppBar(
        title: const Text("Edit Student"),
        backgroundColor: Colors.blueGrey[400],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: "Name",
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
              ),
            ),
            const SizedBox(height: 12),
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
                        labelText: 'Phone',
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
            const SizedBox(height: 12),
            TextField(
              controller: addressController,
              decoration: const InputDecoration(
                labelText: "Address",
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Assigned Follower',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              dropdownColor: const Color.fromARGB(255, 188, 211, 223),
              borderRadius: BorderRadius.circular(25),
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
              ),
              value: selectedContactId,
              items: contactOptions.map((Contact contact) {
                return DropdownMenuItem<String>(
                  value: contact.id.isEmpty ? null : contact.id,
                  child: Text(
                    contact.name.isEmpty
                        ? 'Not Assigned'
                        : '${contact.name} (${contact.phone})',
                  ),
                );
              }).toList(),
              onChanged: (String? newValue) {
                setState(() {
                  selectedContactId = newValue;
                });
              },
            ),
            const SizedBox(height: 20),
            Container(
              padding: EdgeInsets.symmetric(vertical: 10, horizontal: 100),
              child: Card(
                color: Colors.blueGrey[400],
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25),
                ),
                child: IconButton(
                  onPressed: () {
                    final name = nameController.text.trim();
                    final phone = number.phoneNumber;
                    final address = addressController.text.trim();
                    final contactId = selectedContactId;

                    if (name.isNotEmpty &&
                        address.isNotEmpty &&
                        phone != null) {
                      vm.editStudent(
                        widget.student.id,
                        name,
                        phone,
                        address,
                        contactId,
                      );
                      Navigator.pop(context);
                    }
                  },
                  icon: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(LucideIcons.save, size: 20),
                      SizedBox(width: 4),
                      Text(
                        "Save Changes",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
