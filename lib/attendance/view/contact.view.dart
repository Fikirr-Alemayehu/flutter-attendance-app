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
          title: Text("FollowUp Team"),
          centerTitle: true,
        ),
        body: Stack(
          children: [
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
}
