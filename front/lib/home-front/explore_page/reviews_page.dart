import 'package:flutter/material.dart';
import '../../models/review_model.dart';
import '../../services/review_service.dart';
import '../../services/user_session.dart';
import '../widgets/add_review_sheet.dart';
import '../../widgets/app_toast.dart';

class ReviewsPage extends StatefulWidget {
  final String listingId;
  final String hostId;
  final String listingTitle;
  final double ratingOverall;
  final int reviewCount;

  const ReviewsPage({
    super.key,
    this.listingId = '',
    this.hostId = '',
    required this.listingTitle,
    required this.ratingOverall,
    required this.reviewCount,
  });

  @override
  State<ReviewsPage> createState() => _ReviewsPageState();
}

class _ReviewsPageState extends State<ReviewsPage> {
  late Future<List<ReviewModel>> _reviewsFuture;
  List<ReviewModel> _reviews = [];
  bool _hasLoaded = false;

  late double _currentRating;
  late int _currentReviewCount;

  static const Color _dark = Color(0xFF2A1B12);
  static const Color _teal = Color(0xFF006972);
  static const Color _starGold = Color(0xFFE5A93C);

  @override
  void initState() {
    super.initState();
    _currentRating = widget.ratingOverall;
    _currentReviewCount = widget.reviewCount;
    _loadReviews();
  }

  bool get _isHost {
    final currentUserId = UserSession.instance.currentUser?.id;
    if (currentUserId == null || currentUserId.isEmpty) return false;
    if (widget.hostId.isNotEmpty && widget.hostId == currentUserId) return true;
    if (_reviews.isNotEmpty && _reviews.any((r) => r.hostId != null && r.hostId == currentUserId)) {
      return true;
    }
    return false;
  }

  void _loadReviews() {
    if (widget.listingId.isEmpty) {
      _hasLoaded = true;
      _reviewsFuture = Future.value(<ReviewModel>[]);
      return;
    }
    _reviewsFuture = ReviewService.fetchReviews(widget.listingId).then((list) {
      if (mounted) {
        setState(() {
          _reviews = list;
          _hasLoaded = true;
          if (list.isNotEmpty) {
            final avg = list.map((r) => r.ratingOverall).reduce((a, b) => a + b) / list.length;
            _currentRating = avg;
            _currentReviewCount = list.length;
          }
        });
      }
      return list;
    });
  }

  Future<void> _openAddReview() async {
    if (_isHost) {
      AppToast.show(context, 'Hosts cannot write a review on their own listing.', type: AppToastType.error);
      return;
    }

    final newReview = await AddReviewSheet.show(
      context,
      listingId: widget.listingId,
      hostId: widget.hostId,
      listingTitle: widget.listingTitle,
    );

    if (newReview != null && mounted) {
      setState(() {
        _reviews.insert(0, newReview);
        _currentReviewCount = _reviews.length;
        final sum = _reviews.fold<double>(0, (prev, r) => prev + r.ratingOverall);
        _currentRating = sum / _reviews.length;
      });
      AppToast.show(context, 'Thank you! Your review has been published.', type: AppToastType.success);
    }
  }

  Future<void> _openHostReplyModal(ReviewModel review) async {
    final token = UserSession.instance.token;
    if (token == null || token.isEmpty) {
      AppToast.show(context, 'Please log in to reply.', type: AppToastType.info);
      return;
    }

    final controller = TextEditingController(text: review.hostReplyComment ?? '');

    final result = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(ctx).viewInsets.bottom,
        ),
        child: Container(
          decoration: const BoxDecoration(
            color: Color(0xFFFBF3E7),
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE7DCCB),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Reply to ${review.reviewerName}',
                    style: const TextStyle(
                      color: _dark,
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      fontFamily: 'CormorantGaramond',
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: _dark, size: 20),
                    onPressed: () => Navigator.of(ctx).pop(),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              if (review.comment.isNotEmpty)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFE7DCCB)),
                  ),
                  child: Text(
                    '"${review.comment}"',
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Color(0xFF61564D),
                      fontSize: 13,
                      fontStyle: FontStyle.italic,
                      fontFamily: 'HankenGrotesk',
                    ),
                  ),
                ),
              const SizedBox(height: 14),
              TextField(
                controller: controller,
                maxLines: 4,
                autofocus: true,
                style: const TextStyle(
                  color: _dark,
                  fontSize: 14,
                  fontFamily: 'HankenGrotesk',
                ),
                decoration: InputDecoration(
                  hintText: 'Write your response to the guest...',
                  hintStyle: const TextStyle(color: Color(0xFF8A7B6E), fontSize: 14),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: const BorderSide(color: Color(0xFFE7DCCB)),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: const BorderSide(color: Color(0xFFE7DCCB)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: const BorderSide(color: _teal, width: 1.5),
                  ),
                ),
              ),
              const SizedBox(height: 18),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    final text = controller.text.trim();
                    if (text.isNotEmpty) {
                      Navigator.of(ctx).pop(text);
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _teal,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    elevation: 0,
                  ),
                  child: const Text(
                    'Post Response',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      fontFamily: 'HankenGrotesk',
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );

    if (result != null && result.isNotEmpty && mounted) {
      try {
        final updatedReview = await ReviewService.replyToReview(
          token: token,
          reviewId: review.id,
          comment: result,
        );

        if (!mounted) return;
        setState(() {
          final index = _reviews.indexWhere((r) => r.id == review.id);
          if (index != -1) {
            _reviews[index] = updatedReview;
          }
        });

        AppToast.show(context, 'Response posted successfully!', type: AppToastType.success);
      } catch (e) {
        if (!mounted) return;
        AppToast.show(context, e.toString().replaceAll('Exception: ', ''), type: AppToastType.error);
      }
    }
  }

  double _categoryAverage(double Function(ReviewModel) selector) {
    if (_reviews.isEmpty) return _currentRating > 0 ? _currentRating : 5.0;
    final total = _reviews.fold<double>(0, (sum, r) => sum + selector(r));
    return total / _reviews.length;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFBF3E7),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFBF3E7),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: _dark),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          widget.listingTitle,
          style: const TextStyle(
            color: _dark,
            fontSize: 15,
            fontWeight: FontWeight.w600,
            fontFamily: 'HankenGrotesk',
          ),
        ),
        centerTitle: true,
      ),
      bottomNavigationBar: _isHost
          ? null
          : SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 10, 20, 16),
                child: ElevatedButton.icon(
                  onPressed: _openAddReview,
                  icon: const Icon(Icons.rate_review_outlined, color: Colors.white, size: 20),
                  label: const Text(
                    'Write a Review',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      fontFamily: 'HankenGrotesk',
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _teal,
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                    elevation: 0,
                  ),
                ),
              ),
            ),
      body: FutureBuilder<List<ReviewModel>>(
        future: _reviewsFuture,
        builder: (context, snapshot) {
          final isLoading = snapshot.connectionState == ConnectionState.waiting && !_hasLoaded;

          if (isLoading) {
            return const Center(child: CircularProgressIndicator(color: _teal));
          }

          return ListView(
            padding: const EdgeInsets.fromLTRB(20, 10, 20, 20),
            children: [
              // Overall rating score
              Center(
                child: Column(
                  children: [
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.star_rounded, size: 36, color: _starGold),
                        const SizedBox(width: 8),
                        Text(
                          _currentRating > 0 ? _currentRating.toStringAsFixed(2) : 'New',
                          style: const TextStyle(
                            color: _dark,
                            fontSize: 36,
                            fontFamily: 'CormorantGaramond',
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _currentReviewCount > 0
                          ? '$_currentReviewCount review${_currentReviewCount == 1 ? '' : 's'}'
                          : 'No reviews yet',
                      style: const TextStyle(
                        color: Color(0xFF8A7B6E),
                        fontSize: 14,
                        fontFamily: 'HankenGrotesk',
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              const Divider(height: 1, color: Color(0xFFE7DCCB)),
              const SizedBox(height: 20),

              // Rating breakdown subcategories
              if (_reviews.isNotEmpty) ...[
                const Text(
                  'Rating breakdown',
                  style: TextStyle(
                    color: _dark,
                    fontSize: 20,
                    fontFamily: 'CormorantGaramond',
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 14),
                _breakdownRow('Cleanliness', _categoryAverage((r) => r.cleanliness)),
                _breakdownRow('Communication', _categoryAverage((r) => r.communication)),
                _breakdownRow('Check-in', _categoryAverage((r) => r.checkIn)),
                _breakdownRow('Location', _categoryAverage((r) => r.location)),
                _breakdownRow('Value', _categoryAverage((r) => r.value)),
                const SizedBox(height: 20),
                const Divider(height: 1, color: Color(0xFFE7DCCB)),
                const SizedBox(height: 20),
              ],

              // Guest Reviews list
              Text(
                _reviews.isNotEmpty ? 'What guests are saying' : 'Reviews',
                style: const TextStyle(
                  color: _dark,
                  fontSize: 20,
                  fontFamily: 'CormorantGaramond',
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 16),

              if (_reviews.isEmpty)
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: const Color(0xFFE7DCCB)),
                  ),
                  child: Column(
                    children: [
                      const Icon(Icons.reviews_outlined, size: 48, color: Color(0xFF8A7B6E)),
                      const SizedBox(height: 12),
                      const Text(
                        'No reviews yet',
                        style: TextStyle(
                          color: _dark,
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          fontFamily: 'HankenGrotesk',
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        _isHost
                            ? 'Reviews from your guests will appear here.'
                            : 'Be the first to share your experience staying at this place!',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Color(0xFF8A7B6E),
                          fontSize: 13,
                          fontFamily: 'HankenGrotesk',
                        ),
                      ),
                    ],
                  ),
                )
              else
                ..._reviews.map((r) => _buildReviewCard(r)),
            ],
          );
        },
      ),
    );
  }

  Widget _breakdownRow(String label, double rating) {
    final clampedRating = rating.clamp(0.0, 5.0);
    final ratio = clampedRating / 5.0;

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: const TextStyle(
                color: _dark,
                fontSize: 13,
                fontWeight: FontWeight.w600,
                fontFamily: 'HankenGrotesk',
              ),
            ),
          ),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: ratio,
                backgroundColor: const Color(0xFFE7DCCB),
                color: _teal,
                minHeight: 6,
              ),
            ),
          ),
          const SizedBox(width: 14),
          SizedBox(
            width: 30,
            child: Text(
              clampedRating.toStringAsFixed(1),
              textAlign: TextAlign.right,
              style: const TextStyle(
                color: _dark,
                fontSize: 13,
                fontWeight: FontWeight.w700,
                fontFamily: 'HankenGrotesk',
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReviewCard(ReviewModel review) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: const Color(0xFFE7DCCB),
                backgroundImage: review.reviewerPhotoUrl != null
                    ? NetworkImage(review.reviewerPhotoUrl!)
                    : null,
                child: review.reviewerPhotoUrl == null
                    ? Text(
                        review.reviewerInitials,
                        style: const TextStyle(
                          color: _dark,
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                        ),
                      )
                    : null,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      review.reviewerName,
                      style: const TextStyle(
                        color: _dark,
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        fontFamily: 'HankenGrotesk',
                      ),
                    ),
                    if (review.formattedDate.isNotEmpty)
                      Text(
                        review.formattedDate,
                        style: const TextStyle(
                          color: Color(0xFF8A7B6E),
                          fontSize: 12,
                          fontFamily: 'HankenGrotesk',
                        ),
                      ),
                  ],
                ),
              ),
              Row(
                children: [
                  const Icon(Icons.star_rounded, size: 18, color: _starGold),
                  const SizedBox(width: 3),
                  Text(
                    review.ratingOverall.toStringAsFixed(1),
                    style: const TextStyle(
                      color: _dark,
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      fontFamily: 'HankenGrotesk',
                    ),
                  ),
                ],
              ),
            ],
          ),
          if (review.comment.isNotEmpty) ...[
            const SizedBox(height: 12),
            Text(
              review.comment,
              style: const TextStyle(
                color: Color(0xFF4F4540),
                fontSize: 14,
                height: 1.45,
                fontFamily: 'HankenGrotesk',
              ),
            ),
          ],
          if (review.hasHostReply) ...[
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFFBF3E7),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFE7DCCB)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.reply_rounded, size: 16, color: _teal),
                      const SizedBox(width: 6),
                      const Text(
                        'Response from host',
                        style: TextStyle(
                          color: _dark,
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          fontFamily: 'HankenGrotesk',
                        ),
                      ),
                      if (review.formattedHostReplyDate.isNotEmpty) ...[
                        const SizedBox(width: 6),
                        Text(
                          '• ${review.formattedHostReplyDate}',
                          style: const TextStyle(
                            color: Color(0xFF8A7B6E),
                            fontSize: 12,
                            fontFamily: 'HankenGrotesk',
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    review.hostReplyComment!,
                    style: const TextStyle(
                      color: Color(0xFF4F4540),
                      fontSize: 13.5,
                      height: 1.4,
                      fontFamily: 'HankenGrotesk',
                    ),
                  ),
                ],
              ),
            ),
          ],
          if (_isHost) ...[
            const SizedBox(height: 10),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton.icon(
                onPressed: () => _openHostReplyModal(review),
                icon: Icon(
                  review.hasHostReply ? Icons.edit_note_rounded : Icons.reply_rounded,
                  size: 16,
                  color: _teal,
                ),
                label: Text(
                  review.hasHostReply ? 'Edit response' : 'Reply to review',
                  style: const TextStyle(
                    color: _teal,
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    fontFamily: 'HankenGrotesk',
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
