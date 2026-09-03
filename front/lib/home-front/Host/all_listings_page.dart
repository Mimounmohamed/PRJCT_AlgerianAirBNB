import 'package:flutter/material.dart';
import '../../models/host_listing_summary_model.dart'; // adjust path to match your project structure
import 'create_listing_intro_page.dart'; // adjust path if you placed this elsewhere
import 'manage_listing_page.dart'; // adjust path if you placed this elsewhere

/// Full list of the host's listings — shown from "View all" on the Host
/// dashboard. Takes the already-fetched list from HostDashboardPage rather
/// than refetching, since the data's already there. Adds a search field,
/// status filter pills, and a floating "List a new place" button.
class AllListingsPage extends StatefulWidget {
  final List<HostListingSummaryModel> listings;
  final String authToken;

  const AllListingsPage({
    super.key,
    required this.listings,
    required this.authToken,
  });

  @override
  State<AllListingsPage> createState() => _AllListingsPageState();
}

/// 'all' plus the raw `status` values worth filtering on from the UI.
enum _StatusFilter { all, active, pendingReview, inactive }

extension on _StatusFilter {
  String get label {
    switch (this) {
      case _StatusFilter.all: return 'All';
      case _StatusFilter.active: return 'Active';
      case _StatusFilter.pendingReview: return 'In Review';
      case _StatusFilter.inactive: return 'Paused';
    }
  }

  String? get statusValue {
    switch (this) {
      case _StatusFilter.all: return null;
      case _StatusFilter.active: return 'active';
      case _StatusFilter.pendingReview: return 'pending_review';
      case _StatusFilter.inactive: return 'inactive';
    }
  }
}

class _AllListingsPageState extends State<AllListingsPage> {
  static const Color _cream = Color(0xFFFBF3E7);
  static const Color _dark = Color(0xFF2A1B12);
  static const Color _teal = Color(0xFF006972);
  static const Color _muted = Color(0xFF8A7B6E);
  static const Color _border = Color(0xFFE7DCCB);

  final TextEditingController _searchController = TextEditingController();
  String _query = '';
  _StatusFilter _filter = _StatusFilter.all;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'active': return _teal;
      case 'pending_review': return const Color(0xFFB8860B);
      case 'inactive': return const Color(0xFF9A8C7F);
      case 'rejected': return const Color(0xFFB3261E);
      default: return _muted;
    }
  }

  List<HostListingSummaryModel> get _filtered {
    final normalizedQuery = _query.trim().toLowerCase();
    return widget.listings.where((listing) {
      final matchesFilter = _filter.statusValue == null || listing.status == _filter.statusValue;
      final matchesQuery = normalizedQuery.isEmpty || listing.title.toLowerCase().contains(normalizedQuery);
      return matchesFilter && matchesQuery;
    }).toList();
  }

  void _openManageListing(HostListingSummaryModel listing) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ManageListingPage(
          authToken: widget.authToken,
          listingId: listing.id,
        ),
      ),
    );
  }

  Widget _filterPill(_StatusFilter filter) {
    final selected = _filter == filter;
    return GestureDetector(
      onTap: () => setState(() => _filter = filter),
      child: Container(
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
        decoration: BoxDecoration(
          color: selected ? _teal : Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: selected ? _teal : _border),
        ),
        child: Text(
          filter.label,
          style: TextStyle(
            color: selected ? Colors.white : _dark,
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget _listingRow(HostListingSummaryModel listing) {
    final statusColor = _statusColor(listing.status);

    return GestureDetector(
      onTap: () => _openManageListing(listing),
      child: Container(
        margin: const EdgeInsets.only(bottom: 14),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: _border),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(14),
              child: SizedBox(
                width: 72,
                height: 72,
                child: listing.coverPhotoUrl != null
                    ? Image.network(listing.coverPhotoUrl!, fit: BoxFit.cover)
                    : Container(color: _border),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          listing.title,
                          style: const TextStyle(color: _dark, fontSize: 16, fontWeight: FontWeight.w700),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                        decoration: BoxDecoration(
                          color: statusColor.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          listing.statusLabel,
                          style: TextStyle(color: statusColor, fontSize: 10, fontWeight: FontWeight.w700),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${listing.propertyType}, ${listing.city}',
                    style: const TextStyle(color: _muted, fontSize: 13),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        listing.formattedPricePerNight,
                        style: const TextStyle(color: _teal, fontSize: 14, fontWeight: FontWeight.w700),
                      ),
                      const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'MANAGE',
                            style: TextStyle(color: _teal, fontSize: 12, fontWeight: FontWeight.w700, letterSpacing: 0.4),
                          ),
                          Icon(Icons.chevron_right, size: 16, color: _teal),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _filtered;

    return Scaffold(
      backgroundColor: _cream,
      appBar: AppBar(
        backgroundColor: _cream,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: _teal),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Your Listings',
          style: TextStyle(
            color: _dark,
            fontSize: 29,
            fontFamily: 'CormorantGaramond',
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 4, 20, 12),
                child: Column(
                  children: [
                    // ── Search ─────────────────────────────
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(28),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.06),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: TextField(
                        controller: _searchController,
                        onChanged: (value) => setState(() => _query = value),
                        style: const TextStyle(color: _dark, fontSize: 15),
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          isDense: true,
                          contentPadding: const EdgeInsets.symmetric(vertical: 15),
                          hintText: 'Search your listings...',
                          hintStyle: const TextStyle(color: _muted),
                          prefixIcon: const Icon(Icons.search, size: 28, color: _teal),
                          suffixIcon: _query.isNotEmpty
                              ? IconButton(
                                  icon: const Icon(Icons.close, size: 18, color: _muted),
                                  onPressed: () => setState(() {
                                    _searchController.clear();
                                    _query = '';
                                  }),
                                )
                              : null,
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),

                    // ── Filter pills ────────────────────────
                    SizedBox(
                      width: double.infinity,
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: _StatusFilter.values.map(_filterPill).toList(),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // ── Listings ───────────────────────────────────
              Expanded(
                child: filtered.isEmpty
                    ? Center(
                        child: Text(
                          widget.listings.isEmpty
                              ? "You haven't listed a place yet."
                              : 'No listings match your search.',
                          style: const TextStyle(color: _muted),
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
                        itemCount: filtered.length,
                        itemBuilder: (context, index) => _listingRow(filtered[index]),
                      ),
              ),
            ],
          ),

          // ── Floating "List a new place" button ───────────
          Positioned(
            left: 24,
            right: 24,
            bottom: 28,
            child: ElevatedButton.icon(
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const CreateListingIntroPage()),
              ),
              icon: const Icon(Icons.add, color: Colors.white, size: 18),
              label: const Text(
                'List a new place',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 16),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: _teal,
                elevation: 6,
                shadowColor: Colors.black.withValues(alpha: 0.3),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
          ),
        ],
      ),
    );
  }
}