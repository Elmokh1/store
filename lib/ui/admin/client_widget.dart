import 'package:agri_store/ui/home_screen.dart';
import 'package:flutter/material.dart';

import '../../data/model/user_model.dart';

class ClientListItem extends StatelessWidget {
  final UserModel client;
  bool? isStoreWorker;

  ClientListItem({Key? key, required this.client, this.isStoreWorker = false})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 4,
      child: InkWell(
        onTap: () {
          print(client.id);
          Navigator.push(
            context,
            MaterialPageRoute(
              builder:
                  (context) => HomeScreen(
                    uId: client.id,
                    isLoggedIn: false,
                    isStoreWorker: isStoreWorker,
                  ),
            ),
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              CircleAvatar(
                backgroundColor: Theme.of(
                  context,
                ).colorScheme.primary.withOpacity(0.1),
                child: Icon(
                  Icons.person_outline,
                  color: Theme.of(context).primaryColor,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  client.name ?? "عميل غير معروف", // Unknown Client
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              // Optional: Add more client details or actions here
              Icon(
                Icons.arrow_forward_ios,
                size: 18,
                color: Colors.grey.shade400,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
