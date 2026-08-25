import 'package:flutter/material.dart';
import '../../services/host_service.dart'; // adjust path to match your project structure
import '../../models/host_dashboard_model.dart';
import 'become_host_page.dart';
import 'host_dashboard_page.dart';

/// Entry point for the Host tab. Calls GET /api/host/dashboard once —
/// a 403 (not a host yet) shows [BecomeHostPage]; success shows
/// [HostDashboardPage]. This avoids depending on a possibly-stale cached
/// isHost flag on the client.
class HostTabEntry extends StatefulWidget {
  final String authToken;
  final String hostFirstName;

  const HostTabEntry({
    super.key,
    required this.authToken,
    required this.hostFirstName,
  });

  @override
  State<HostTabEntry> createState() => _HostTabEntryState();
}

class _HostTabEntryState extends State<HostTabEntry> {
  late Future<HostDashboardModel?> _future;

  @override
  void initState() {
    super.initState();
    _future = HostService.fetchDashboard(authToken: widget.authToken);
  }

  void _refetch() {
    setState(() {
      _future = HostService.fetchDashboard(authToken: widget.authToken);
    });
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<HostDashboardModel?>(
      future: _future,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator(color: Color(0xFF006972)));
        }

        if (snapshot.hasError) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text("Couldn't check host status.", style: TextStyle(color: Color(0xFF2A1B12), fontWeight: FontWeight.w600)),
                  const SizedBox(height: 8),
                  Text('${snapshot.error}', textAlign: TextAlign.center, style: const TextStyle(color: Color(0xFF8A7B6E), fontSize: 12)),
                  const SizedBox(height: 16),
                  TextButton(onPressed: _refetch, child: const Text('Retry', style: TextStyle(color: Color(0xFF006972)))),
                ],
              ),
            ),
          );
        }

        // null means the dashboard fetch returned 403 — not a host yet.
        if (snapshot.data == null) {
          return BecomeHostPage(
            authToken: widget.authToken,
            onBecameHost: _refetch,
          );
        }

        return HostDashboardPage(
          authToken: widget.authToken,
          hostFirstName: widget.hostFirstName,
        );
      },
    );
  }
}