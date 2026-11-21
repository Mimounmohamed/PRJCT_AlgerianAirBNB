import 'package:flutter/material.dart';
import '../../services/user_session.dart';
import '../../services/review_service.dart';
import '../../models/review_model.dart';

class AddReviewSheet extends StatefulWidget {
  final String listingId;
  final String hostId;
  final String listingTitle;

  const AddReviewSheet({
    super.key,
    required this.listingId,
    required this.hostId,
    required this.listingTitle,
  });

  static Future<ReviewModel?> show(
    BuildContext context, {
    required String listingId,
    required String hostId,
    required String listingTitle,
  }) {
    return showModalBottomSheet<ReviewModel>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => AddReviewSheet(
        listingId: listingId,
        hostId: hostId,
        listingTitle: listingTitle,
      ),
    );
  }

  @override
  State<AddReviewSheet> createState() => _AddReviewSheetState();
}

class _AddReviewSheetState extends State<AddReviewSheet> {
  int _overallRating = 5;
  int _cleanliness = 5;
  int _communication = 5;
  int _checkIn = 5;
  int _location = 5;
  int _value = 5;

  bool _showDetailedRatings = false;
  bool _isSubmitting = false;

  final TextEditingController _commentController = TextEditingController();

  static const Color _teal = Color(0xFF006972);
  static const Color _dark = Color(0xFF2A1B12);
  static const Color _starGold = Color(0xFFE5A93C);

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  String get _ratingLabel {
    switch (_overallRating) {
      case 1:
        return 'Disappointing';
      case 2:
        return 'Fair';
      case 3:
        return 'Good';
      case 4:
        return 'Very Good';
      case 5:
      default:
        return 'Exceptional';
    }
  }

  Future<void> _submit() async {
    final currentUserId = UserSession.instance.currentUser?.id;
    if (currentUserId != null && widget.hostId.isNotEmpty && currentUserId == widget.hostId) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Hosts cannot write a review on their own listing.'),
          backgroundColor: _dark,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }
    final token = UserSession.instance.token;
    if (token == null || token.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please log in to submit a review.'),
          backgroundColor: _dark,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    final comment = _commentController.text.trim();
    if (comment.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please write a short comment about your experience.'),
          backgroundColor: _dark,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final review = await ReviewService.submitReview(
        token: token,
        listingId: widget.listingId,
        hostId: widget.hostId,
        rating: _overallRating.toDouble(),
        comment: comment,
        categoryRatings: {
          'cleanliness': _cleanliness.toDouble(),
          'communication': _communication.toDouble(),
          'checkIn': _checkIn.toDouble(),
          'location': _location.toDouble(),
          'value': _value.toDouble(),
        },
      );

      if (!mounted) return;
      Navigator.of(context).pop(review);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to submit review: $e'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  Widget _buildStarPicker() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(5, (index) {
            final starNumber = index + 1;
            final isFilled = starNumber <= _overallRating;
            return GestureDetector(
              onTap: () {
                setState(() {
                  _overallRating = starNumber;
                  // Sync sub-ratings with overall if not customized yet
                  if (!_showDetailedRatings) {
                    _cleanliness = starNumber;
                    _communication = starNumber;
                    _checkIn = starNumber;
                    _location = starNumber;
                    _value = starNumber;
                  }
                });
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 6),
                child: Icon(
                  isFilled ? Icons.star_rounded : Icons.star_outline_rounded,
                  size: 40,
                  color: isFilled ? _starGold : const Color(0xFFD4C9BC),
                ),
              ),
            );
          }),
        ),
        const SizedBox(height: 8),
        Text(
          '$_overallRating / 5 — $_ratingLabel',
          style: const TextStyle(
            color: _dark,
            fontSize: 16,
            fontWeight: FontWeight.w700,
            fontFamily: 'HankenGrotesk',
          ),
        ),
      ],
    );
  }

  Widget _buildSubCategoryRow(String label, int value, ValueChanged<int> onChanged) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: _dark,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          Row(
            children: List.generate(5, (i) {
              final star = i + 1;
              return GestureDetector(
                onTap: () => onChanged(star),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 2),
                  child: Icon(
                    star <= value ? Icons.star_rounded : Icons.star_outline_rounded,
                    size: 22,
                    color: star <= value ? _starGold : const Color(0xFFD4C9BC),
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Padding(
      padding: EdgeInsets.only(bottom: bottomInset),
      child: Container(
        decoration: const BoxDecoration(
          color: Color(0xFFFBF3E7),
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 28),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Drag handle
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: const Color(0xFFD4C9BC),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Title row with close icon
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Write a Review',
                    style: TextStyle(
                      color: _dark,
                      fontSize: 22,
                      fontFamily: 'CormorantGaramond',
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close, color: _dark, size: 22),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                widget.listingTitle,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Color(0xFF8A7B6E),
                  fontSize: 13,
                  fontFamily: 'HankenGrotesk',
                ),
              ),
              const SizedBox(height: 20),

              // Overall Star Picker
              _buildStarPicker(),
              const SizedBox(height: 16),

              // Detailed category accordion toggle
              Center(
                child: TextButton.icon(
                  onPressed: () => setState(() => _showDetailedRatings = !_showDetailedRatings),
                  icon: Icon(
                    _showDetailedRatings ? Icons.keyboard_arrow_up : Icons.tune,
                    size: 16,
                    color: _teal,
                  ),
                  label: Text(
                    _showDetailedRatings ? 'Hide category ratings' : 'Rate categories (Cleanliness, Check-in...)',
                    style: const TextStyle(
                      color: _teal,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      fontFamily: 'HankenGrotesk',
                    ),
                  ),
                ),
              ),

              if (_showDetailedRatings) ...[
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFFE7DCCB)),
                  ),
                  child: Column(
                    children: [
                      _buildSubCategoryRow('Cleanliness', _cleanliness, (v) => setState(() => _cleanliness = v)),
                      _buildSubCategoryRow('Communication', _communication, (v) => setState(() => _communication = v)),
                      _buildSubCategoryRow('Check-in', _checkIn, (v) => setState(() => _checkIn = v)),
                      _buildSubCategoryRow('Location', _location, (v) => setState(() => _location = v)),
                      _buildSubCategoryRow('Value', _value, (v) => setState(() => _value = v)),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
              ],

              // Comment input
              const Text(
                'Your Review',
                style: TextStyle(
                  color: _dark,
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  fontFamily: 'HankenGrotesk',
                ),
              ),
              const SizedBox(height: 8),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFE7DCCB)),
                ),
                child: TextField(
                  controller: _commentController,
                  maxLines: 4,
                  cursorColor: _teal,
                  style: const TextStyle(
                    color: _dark,
                    fontSize: 14,
                    fontFamily: 'HankenGrotesk',
                  ),
                  decoration: const InputDecoration(
                    contentPadding: EdgeInsets.all(14),
                    border: InputBorder.none,
                    hintText: 'Share your experience: what did you love about this stay? How was the host?',
                    hintStyle: TextStyle(
                      color: Color(0xFF8A7B6E),
                      fontSize: 13,
                      fontFamily: 'HankenGrotesk',
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Submit Button
              ElevatedButton(
                onPressed: _isSubmitting ? null : _submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _teal,
                  disabledBackgroundColor: _teal.withValues(alpha: 0.5),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  elevation: 0,
                ),
                child: _isSubmitting
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.5,
                          color: Colors.white,
                        ),
                      )
                    : const Text(
                        'Submit Review',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          fontFamily: 'HankenGrotesk',
                        ),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
