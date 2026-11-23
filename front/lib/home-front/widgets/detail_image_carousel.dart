import 'package:flutter/material.dart';
import '../../services/saved_service.dart';
import '../../widgets/app_toast.dart';

/// Swipeable photo carousel for the top of the Listing Detail page —
/// back / share / favorite overlay buttons and a "1 / 12" counter.
///
/// With [listingId], the heart saves/unsaves that listing for the
/// logged-in guest (SavedService); without it, it's local state only.
class DetailImageCarousel extends StatefulWidget {
  final List<String> photoUrls;
  final String? listingId;
  final bool initialIsFavorite;
  final VoidCallback? onBackTap;
  final VoidCallback? onShareTap;
  final ValueChanged<bool>? onFavoriteToggle;

  const DetailImageCarousel({
    super.key,
    required this.photoUrls,
    this.listingId,
    this.initialIsFavorite = false,
    this.onBackTap,
    this.onShareTap,
    this.onFavoriteToggle,
  });

  @override
  State<DetailImageCarousel> createState() => _DetailImageCarouselState();
}

class _DetailImageCarouselState extends State<DetailImageCarousel> {
  final PageController _controller = PageController();
  int _currentPage = 0;
  late bool _isFavorite;

  static const Color _teal = Color(0xFF006972);

  @override
  void initState() {
    super.initState();
    _isFavorite = widget.initialIsFavorite;
    if (widget.listingId != null) SavedService.instance.ensureLoaded();
  }

  Future<void> _toggleSaved(bool save) async {
    try {
      await SavedService.instance.setSaved(widget.listingId!, save);
      widget.onFavoriteToggle?.call(save);
    } catch (e) {
      if (mounted) AppToast.show(context, e.toString(), type: AppToastType.info);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Widget _circleButton({required IconData icon, required VoidCallback? onTap, Color? iconColor}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.35),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, size: 22, color: iconColor ?? Colors.white),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final photos = widget.photoUrls.isEmpty ? [''] : widget.photoUrls;

    return AspectRatio(
      aspectRatio: 1.05,
      child: Stack(
        fit: StackFit.expand,
        children: [
          PageView.builder(
            controller: _controller,
            itemCount: photos.length,
            onPageChanged: (index) => setState(() => _currentPage = index),
            itemBuilder: (context, index) {
              final url = photos[index];
              if (url.isEmpty) {
                return Container(color: const Color(0xFFE7DCCB));
              }
              return Image.network(
                url,
                fit: BoxFit.cover,
                loadingBuilder: (context, child, progress) {
                  if (progress == null) return child;
                  return Container(color: const Color(0xFFE7DCCB));
                },
                errorBuilder: (context, error, stackTrace) =>
                    Container(color: const Color(0xFFE7DCCB)),
              );
            },
          ),

          // Top overlay row: back button (left), share + favorite (right)
          Positioned(
            top: 12,
            left: 12,
            right: 12,
            child: SafeArea(
              bottom: false,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _circleButton(icon: Icons.arrow_back, onTap: widget.onBackTap),
                  Row(
                    children: [
                      _circleButton(icon: Icons.share, onTap: widget.onShareTap),
                      const SizedBox(width: 8),
                      if (widget.listingId == null)
                        _circleButton(
                          icon: _isFavorite ? Icons.favorite : Icons.favorite_border,
                          iconColor: _isFavorite ? const Color(0xFFE8543E) : Colors.white,
                          onTap: () {
                            setState(() => _isFavorite = !_isFavorite);
                            widget.onFavoriteToggle?.call(_isFavorite);
                          },
                        )
                      else
                        ValueListenableBuilder<Set<String>>(
                          valueListenable: SavedService.instance.ids,
                          builder: (context, savedIds, _) {
                            final saved = savedIds.contains(widget.listingId);
                            return _circleButton(
                              icon: saved ? Icons.favorite : Icons.favorite_border,
                              iconColor: saved ? const Color(0xFFE8543E) : Colors.white,
                              onTap: () => _toggleSaved(!saved),
                            );
                          },
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // Photo counter, bottom-right
          if (photos.length > 1)
            Positioned(
              bottom: 12,
              right: 12,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${_currentPage + 1} / ${photos.length}',
                  style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600),
                ),
              ),
            ),
        ],
      ),
    );
  }
}