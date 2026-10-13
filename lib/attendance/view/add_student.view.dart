import 'package:flutter/material.dart';
import 'package:glc/attendance/models/contact_model.dart';
import 'package:glc/attendance/viewModel/contact.viewmodel.dart';
import 'package:glc/attendance/viewModel/home.viewModel.dart';
import 'package:glc/constants/colors.dart';
import 'package:intl_phone_number_input/intl_phone_number_input.dart';
import 'package:provider/provider.dart';

class AddStudentView extends StatefulWidget {
  const AddStudentView({super.key});

  @override
  State<AddStudentView> createState() => _AddStudentViewState();
}

class _AddStudentViewState extends State<AddStudentView> {
  final nameController = TextEditingController();
  PhoneNumber number = PhoneNumber(isoCode: 'ET');
  final addressController = TextEditingController();
  final formKey = GlobalKey<FormState>();
  String? _selectedContactId;

  @override
  Widget build(BuildContext context) {
    final contactVm = Provider.of<ContactViewModel>(context);
    final contacts = contactVm.contacts;
    final List<Contact> contactOptions = [
      Contact(id: '', name: 'No Contact Assigned', phone: ''),
      ...contacts,
    ];

    return SafeArea(
      child: Scaffold(
        backgroundColor: kcAppBg,
        appBar: AppBar(
          title: const Text('Add New Student'),
          centerTitle: true,
          backgroundColor: kcPrimary,
          elevation: 0,
          foregroundColor: Colors.white,
          iconTheme: const IconThemeData(color: Colors.white),
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Form(
              key: formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header Card
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [kcPrimaryLight.withValues(alpha: 0.1), kcPrimary.withValues(alpha: 0.05)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: kcPrimary.withValues(alpha: 0.2)),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: kcPrimary.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(Icons.person_add, color: kcPrimary, size: 28),
                        ),
                        const SizedBox(width: 16),
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "New Student",
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: kcPrimary,
                                ),
                              ),
                              SizedBox(height: 4),
                              Text(
                                "Fill in the student details below",
                                style: TextStyle(color: kcFont, fontSize: 13),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 28),

                  // Name Field
                  _buildLabel("Full Name", Icons.person),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: nameController,
                    decoration: InputDecoration(
                      hintText: "Enter student name",
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
                      errorBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide(color: kcRed, width: 1),
                      ),
                      focusedErrorBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide(color: kcRed, width: 2),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 16,
                      ),
                    ),
                    validator: (value) => value == null || value.trim().isEmpty
                        ? "Name is required"
                        : null,
                  ),
                  const SizedBox(height: 20),

                  // Phone Field
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
                        inputDecoration: InputDecoration(
                          hintText: "Enter phone number",
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(
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

                  // Address Field
                  _buildLabel("Address", Icons.location_on),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: addressController,
                    maxLines: 2,
                    decoration: InputDecoration(
                      hintText: "Enter address",
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
                      errorBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide(color: kcRed, width: 1),
                      ),
                      focusedErrorBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide(color: kcRed, width: 2),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 16,
                      ),
                    ),
                    validator: (value) => value == null || value.trim().isEmpty
                        ? "Address is required"
                        : null,
                  ),
                  const SizedBox(height: 20),

                  // Follower Section
                  _buildLabel("Assigned Follower (Optional)", Icons.supervisor_account),
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
                        value: _selectedContactId,
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
                                    contact.name.isEmpty
                                        ? 'Not Assigned'
                                        : contact.name,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                        onChanged: (val) => setState(() => _selectedContactId = val),
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Save Button
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: kcPrimary,
                        foregroundColor: Colors.white,
                        elevation: 2,
                        shadowColor: kcPrimary.withValues(alpha:0.4),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      icon: const Icon(Icons.save_rounded, size: 24),
                      label: const Text(
                        "Save Student",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.5,
                        ),
                      ),
                      onPressed: () {
                        if (formKey.currentState!.validate()) {
                          final phone = number.phoneNumber;
                          if (phone == null || phone.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: const Text("Phone number is required"),
                                backgroundColor: kcRed,
                                behavior: SnackBarBehavior.floating,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            );
                            return;
                          }
                          final vm = Provider.of<HomeViewModel>(
                            context,
                            listen: false,
                          );
                          vm.addStudentWithDetails(
                            nameController.text.trim(),
                            phone,
                            addressController.text.trim(),
                            _selectedContactId,
                          );
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Row(
                                children: [
                                  const Icon(Icons.check_circle, color: Colors.white),
                                  const SizedBox(width: 12),
                                  const Text("Student added successfully!"),
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
                  const SizedBox(height: 16),
                ],
              ),
            ),
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
