import 'package:flutter/material.dart';
import '../models/models.dart';
import '../services/firebase_service.dart';

class ProviderHomeScreen extends StatefulWidget {
  final AppUser user;
  const ProviderHomeScreen({super.key, required this.user});
  @override
  State<ProviderHomeScreen> createState() => _ProviderHomeScreenState();
}

class _ProviderHomeScreenState extends State<ProviderHomeScreen> {
  final serviceService = ServiceService();
  final requestService = ServiceRequestService();
  @override
  Widget build(BuildContext context) => DefaultTabController(
    length: 2,
    child: Scaffold(
      appBar: AppBar(
        title: const Text('Huduma Zangu'),
        bottom: const TabBar(tabs: [Tab(text: 'Huduma'), Tab(text: 'Requests')]),
      ),
      body: TabBarView(
        children: [
          StreamBuilder(
            stream: serviceService.getUserServices(widget.user.id),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return const Center(child: Text('Haina huduma'));
              }
              return ListView.builder(
                itemCount: snapshot.data!.length,
                itemBuilder: (context, index) {
                  final service = snapshot.data![index];
                  return Card(
                    margin: const EdgeInsets.all(8),
                    child: ListTile(
                      title: Text(service.title),
                      subtitle: Text('${service.priceFrom} - ${service.priceTo} TZS'),
                      trailing: service.isVerified ? const Icon(Icons.verified, color: Colors.green) : null,
                    ),
                  );
                },
              );
            },
          ),
          StreamBuilder(
            stream: requestService.getProviderRequests(widget.user.id),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return const Center(child: Text('Hakuna requests'));
              }
              return ListView.builder(
                itemCount: snapshot.data!.length,
                itemBuilder: (context, index) {
                  final request = snapshot.data![index];
                  return Card(
                    margin: const EdgeInsets.all(8),
                    child: ListTile(
                      title: Text('Request #${request.id.substring(0, 6)}'),
                      subtitle: Text(request.status),
                      trailing: PopupMenuButton(
                        itemBuilder: (context) => [
                          PopupMenuItem(child: const Text('Kubali'), onTap: () => requestService.updateRequestStatus(request.id, 'accepted')),
                          PopupMenuItem(child: const Text('Kataa'), onTap: () => requestService.updateRequestStatus(request.id, 'rejected')),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ],
      ),
    ),
  );
}
