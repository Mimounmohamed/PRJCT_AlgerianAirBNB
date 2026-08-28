import 'package:flutter/material.dart';
import '../../models/host_listing_summary_model.dart'; // adjust path to match your project structure
import '../widgets/host_listing_row.dart';

/// Full list of the host's listings — shown from "View all" on the Host
/// dashboard. Takes the already-fetched list from HostDashboardPage rather
/// than refetching, since the data's already there.
///
/// TODO: each row's tap still just has a placeholder — wire to a real
/// host-facing listing detail/edit screen once one exists (same TODO as
/// the dashboard's own listing rows).
class AllListingsPage extends StatelessWidget {
  final List<HostListingSummaryModel> listings;

  const AllListingsPage({super.key, required this.listings});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFBF3E7),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFBF3E7),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF2A1B12)),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Your Listings',
          style: TextStyle(
            color: Color(0xFF2A1B12),
            fontSize: 18,
            fontFamily: 'CormorantGaramond',
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: listings.isEmpty
          ? const Center(
              child: Text(
                "You haven't listed a place yet.",
                style: TextStyle(color: Color(0xFF8A7B6E)),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(20),
              itemCount: listings.length,
              itemBuilder: (context, index) {
                return HostListingRow(
                  listing: listings[index],
                  onTap: () {
                    // TODO: push a host-facing listing detail/edit screen
                  },
                );
              },
            ),
    );
  }
}