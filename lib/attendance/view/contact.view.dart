import 'package:flutter/material.dart';
import 'package:glc/attendance/viewModel/contact.viewmodel.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:provider/provider.dart';

class ContactView extends StatelessWidget {
  const ContactView({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = Provider.of<ContactViewModel>(context);

    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.blueGrey[100],
        appBar: AppBar(
          backgroundColor: Colors.blueGrey[400],
          title: Text('Contact List'),
          centerTitle: true,
        ),
        body: Stack(
          children: [
            // Contact list
            ListView.builder(
              itemCount: vm.contacts.length,
              itemBuilder: (context, index) {
                final contact = vm.contacts[index];
                return Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 1,
                  ),
                  child: Card(
                    color: Colors.blueGrey[50],
                    elevation: 3,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: ListTile(
                      title: Text(contact.name),
                      subtitle: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          InkWell(
                            onTap: () => vm.launchDialer(contact.phone),
                            child: Text(
                              contact.phone,
                              style: const TextStyle(
                                color: Colors.blue,
                                decoration: TextDecoration.underline,
                              ),
                            ),
                          ),
                        ],
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit, color: Colors.blue),
                            onPressed: () =>
                                vm.showContactDialog(context, contact: contact),
                          ),
                          IconButton(
                            icon: const Icon(
                              Icons.delete_forever,
                              color: Colors.red,
                            ),
                            onPressed: () => vm.removeContact(contact.id),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),

            Positioned(
              bottom: 16,
              right: 16,
              child: FloatingActionButton(
                backgroundColor: Colors.blueGrey[400],
                onPressed: () => vm.showContactDialog(context),
                child: const Icon(LucideIcons.bookmarkPlus),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // void _showAddDialog(BuildContext context, ContactViewModel vm) {
  //   final nameController = TextEditingController();
  //   final phoneController = TextEditingController();
  //   PhoneNumber number = PhoneNumber(isoCode: 'ET'); // Default Ethiopia

  //   showDialog(
  //     context: context,
  //     builder: (_) => AlertDialog(
  //       title: const Text('Add Contact'),
  //       content: Column(
  //         mainAxisSize: MainAxisSize.min,
  //         children: [
  //           TextField(
  //             controller: nameController,
  //             decoration: const InputDecoration(
  //               labelText: "Name",
  //               border: OutlineInputBorder(),
  //               contentPadding: EdgeInsets.symmetric(
  //                 horizontal: 12,
  //                 vertical: 8,
  //               ),
  //             ),
  //           ),
  //           const SizedBox(height: 8),
  //           Container(
  //             decoration: BoxDecoration(
  //               borderRadius: BorderRadius.circular(8),
  //               border: Border.all(color: Colors.grey.shade400),
  //             ),
  //             child: InternationalPhoneNumberInput(
  //               onInputChanged: (PhoneNumber num) => number = num,
  //               textFieldController: phoneController, // use this controller
  //               initialValue: number,
  //               selectorConfig: const SelectorConfig(
  //                 selectorType: PhoneInputSelectorType.DROPDOWN,
  //               ),
  //               inputDecoration: const InputDecoration(
  //                 border: InputBorder.none,
  //                 contentPadding: EdgeInsets.symmetric(
  //                   horizontal: 8,
  //                   vertical: 12,
  //                 ),
  //               ),
  //               formatInput: true,
  //               keyboardType: TextInputType.phone,
  //               selectorTextStyle: const TextStyle(color: Colors.black),
  //             ),
  //           ),
  //         ],
  //       ),
  //       actions: [
  //         TextButton(
  //           onPressed: () async {
  //             final name = nameController.text.trim();
  //             if (name.isNotEmpty && number.phoneNumber != null) {
  //               await vm.addContact(name, number.phoneNumber!);
  //               Navigator.pop(context);
  //             }
  //           },
  //           child: const Text('Add'),
  //         ),
  //       ],
  //     ),
  //   );
  // }
}
