import 'package:flutter/material.dart';
import 'package:glc/attendance/models/contact_model.dart';
import 'package:glc/attendance/models/student_model.dart';
import 'package:glc/attendance/viewModel/contact.viewmodel.dart';
import 'package:glc/attendance/viewModel/home.viewModel.dart';
import 'package:glc/constants/colors.dart';
import 'package:intl_phone_number_input/intl_phone_number_input.dart';
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
    addressController = TextEditingController(text: widget.student.address);
    number = PhoneNumber(isoCode: 'ET', phoneNumber: widget.student.phone);
    selectedContactId = (widget.student.contactId?.isNotEmpty ?? false)
        ? widget.student.contactId
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
      backgroundColor: kcAppBg,
      appBar: AppBar(
        title: const Text("Edit Student"),
        backgroundColor: kcPrimary,
        elevation: 0,
        foregroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with Avatar
              Center(
                child: Column(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [kcPrimaryLight, kcPrimary],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: kcPrimary.withValues(alpha:0.3),
                            blurRadius: 20,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: CircleAvatar(
                        radius: 45,
                        backgroundColor: Colors.transparent,
                        child: Text(
                          widget.student.name.isNotEmpty
                              ? widget.student.name[0].toUpperCase()
                              : "?",
                          style: const TextStyle(
                            fontSize: 48,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      widget.student.name ?? 'Unknown Student',
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: kcFontBold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "ID: ${widget.student.id.substring(0, 8)}...",
                      style: TextStyle(
                        fontSize: 12,
                        color: kcFont,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 28),

              // Name
              _buildLabel("Full Name", Icons.person),
              const SizedBox(height: 8),
              TextField(
                controller: nameController,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: kcSurface,
                  prefixIcon: const Icon(Icons.person_outline, color: kcOutline),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(color: kcOutlineVariant, width: 1),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(color: kcPrimary, width: 2),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 16,
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Phone
              _buildLabel("Phone Number", Icons.phone),
              const SizedBox(height: 8),
              Container(
                decoration: BoxDecoration(
                  color: kcSurface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: kcOutlineVariant, width: 1),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: InternationalPhoneNumberInput(
                    onInputChanged: (PhoneNumber num) => number = num,
                    selectorConfig: const SelectorConfig(
                      selectorType: PhoneInputSelectorType.BOTTOM_SHEET,
                    ),
                    initialValue: number,
                    inputDecoration: const InputDecoration(
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 16,
                      ),
                    ),
                    formatInput: true,
                    keyboardType: TextInputType.phone,
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Address
              _buildLabel("Address", Icons.location_on),
              const SizedBox(height: 8),
              TextField(
                controller: addressController,
                maxLines: 2,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: kcSurface,
                  prefixIcon: const Icon(Icons.location_on_outlined, color: kcOutline),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(color: kcOutlineVariant, width: 1),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(color: kcPrimary, width: 2),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 16,
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Follower
              _buildLabel("Assigned Follower", Icons.supervisor_account),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                decoration: BoxDecoration(
                  color: kcSurface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: kcOutlineVariant, width: 1),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    isExpanded: true,
                    value: selectedContactId,
                    hint: Row(
                      children: [
                        Icon(Icons.people_outline, color: kcOutline, size: 20),
                        const SizedBox(width: 12),
                        const Text("Select Follower"),
                      ],
                    ),
                    items: contactOptions.map((contact) {
                      return DropdownMenuItem<String>(
                        value: contact.id.isEmpty ? null : contact.id,
                        child: Row(
                          children: [
                            Icon(
                              contact.id.isEmpty ? Icons.person_outline : Icons.person,
                              color: kcOutline,
                              size: 20,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                contact.name.isEmpty ? 'Not Assigned' : contact.name,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                    onChanged: (val) => setState(() => selectedContactId = val),
                  ),
                ),
              ),
              const SizedBox(height: 32),

              // Buttons
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: kcOutlineVariant),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        foregroundColor: kcFont,
                      ),
                      onPressed: () => Navigator.pop(context),
                      child: const Text(
                        "Cancel",
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 2,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: kcPrimary,
                        foregroundColor: Colors.white,
                        elevation: 2,
                        shadowColor: kcPrimary.withValues(alpha:0.4),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      icon: const Icon(Icons.update_rounded, size: 22),
                      label: const Text(
                        "Update Student",
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.5,
                        ),
                      ),
                      onPressed: () {
                        final name = nameController.text.trim();
                        final phone =
                            number.phoneNumber ?? widget.student.phone;
                        final address = addressController.text.trim();

                        if (name.isNotEmpty && address.isNotEmpty) {
                          vm.editStudent(
                            widget.student.id,
                            name,
                            phone,
                            address,
                            selectedContactId,
                          );
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Row(
                                children: [
                                  const Icon(Icons.check_circle, color: Colors.white),
                                  const SizedBox(width: 12),
                                  const Text("Student updated successfully!"),
                                ],
                              ),
                              backgroundColor: kcGreen,
                              behavior: SnackBarBehavior.floating,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              duration: const Duration(seconds: 2),
                            ),
                          );
                          Navigator.pop(context);
                        }
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String label, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 18, color: kcPrimary),
        const SizedBox(width: 8),
        Text(
          label,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 14,
            color: kcFontBold,
          ),
        ),
      ],
    );
  }
}
