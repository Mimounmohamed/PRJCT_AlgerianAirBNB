import 'dart:async';
import 'package:flutter/material.dart';
import '../../models/listing_draft_model.dart';
import '../../services/host_service.dart';
import '../../services/user_session.dart';

/// "Exit flow" for the Create Listing wizard steps that hold a draft
/// (basics → location → amenities → review).
///
/// Asks before throwing the draft away. On confirm, any photos already
/// uploaded to Cloudinary for this draft are sent to the backend to delete
/// (they'd never be used — the listing wasn't published), then it goes back
/// to the screen the wizard was opened from.
Future<void> exitCreateListingFlow(BuildContext context, ListingDraft draft) async {
  const cream = Color(0xFFFBF3E7);
  const dark = Color(0xFF2A1B12);
  const teal = Color(0xFF006972);
  const muted = Color(0xFF8A7B6E);
  const danger = Color(0xFFB3261E);

  final leave = await showDialog<bool>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      backgroundColor: cream,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: const Text('Leave without publishing?', style: TextStyle(color: dark, fontWeight: FontWeight.w700)),
      content: Text(
        draft.photos.isEmpty
            ? "Your listing isn't saved yet — everything you've entered will be lost."
            : "Your listing isn't saved yet — everything you've entered, including the photos you uploaded, will be lost.",
        style: const TextStyle(color: muted, height: 1.4),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(dialogContext).pop(false),
          child: const Text('Keep editing', style: TextStyle(color: teal, fontWeight: FontWeight.w700)),
        ),
        TextButton(
          onPressed: () => Navigator.of(dialogContext).pop(true),
          child: const Text('Leave', style: TextStyle(color: danger, fontWeight: FontWeight.w700)),
        ),
      ],
    ),
  );
  if (leave != true || !context.mounted) return;

  discardDraftPhotos(draft.photos.map((p) => p['url']).whereType<String>().toList());
  draft.photos.clear();
  Navigator.of(context).popUntil((route) => route.isFirst);
}

/// Deletes never-published photo uploads from Cloudinary (best effort,
/// in the background — see POST /api/host/media/discard).
void discardDraftPhotos(List<String> urls) {
  final token = UserSession.instance.token;
  if (token == null || urls.isEmpty) return;
  unawaited(HostService.discardUploadedPhotos(authToken: token, urls: urls));
}
