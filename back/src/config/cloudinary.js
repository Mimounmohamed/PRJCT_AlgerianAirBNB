const crypto = require('crypto');

const User = require('../models/User');
const Listing = require('../models/Listing');
const Message = require('../models/Message');
const Review = require('../models/Review');
const Incident = require('../models/Incident');

// Deleting from Cloudinary needs a signed request, so it lives here on the
// backend (uploads stay unsigned from the app via the `akrili_unsigned`
// preset). Needs these in .env:
//   CLOUDINARY_CLOUD_NAME=bcaeahkm
//   CLOUDINARY_API_KEY=...
//   CLOUDINARY_API_SECRET=...
// Without them every delete is skipped with a one-time warning; nothing
// else breaks.

let warnedMissingConfig = false;

function getConfig() {
  const cloudName = process.env.CLOUDINARY_CLOUD_NAME;
  const apiKey = process.env.CLOUDINARY_API_KEY;
  const apiSecret = process.env.CLOUDINARY_API_SECRET;
  if (!cloudName || !apiKey || !apiSecret) {
    if (!warnedMissingConfig) {
      console.warn('[cloudinary] CLOUDINARY_CLOUD_NAME / API_KEY / API_SECRET not set — skipping image deletes.');
      warnedMissingConfig = true;
    }
    return null;
  }
  return { cloudName, apiKey, apiSecret };
}

// "https://res.cloudinary.com/<cloud>/image/upload/<transforms>/v123/folder/name.jpg"
//   → { cloudName, version: 123, publicId: "folder/name" }
// Returns null for anything that isn't a Cloudinary image URL.
function parseCloudinaryUrl(url) {
  if (typeof url !== 'string') return null;
  const match = url.match(/^https?:\/\/res\.cloudinary\.com\/([^/]+)\/image\/upload\/(.+)$/);
  if (!match) return null;

  const [, cloudName, rest] = match;
  const parts = rest.split('/');
  const versionIndex = parts.findIndex((p) => /^v\d+$/.test(p));
  if (versionIndex === -1) return null;

  const version = parseInt(parts[versionIndex].slice(1), 10);
  const publicIdWithExt = parts.slice(versionIndex + 1).join('/');
  const publicId = decodeURIComponent(publicIdWithExt.replace(/\.[^/.]+$/, ''));
  if (!publicId) return null;

  return { cloudName, version, publicId };
}

// True if any document anywhere in the app still points at this URL —
// such an image must never be deleted.
async function isImageReferenced(url) {
  const checks = await Promise.all([
    Listing.exists({ 'photos.url': url }),
    User.exists({ $or: [{ profilePhoto: url }, { 'identityVerification.documentImageUrl': url }] }),
    Message.exists({ imageUrl: url }),
    Review.exists({ photos: url }),
    Incident.exists({ photoUrls: url }),
  ]);
  return checks.some(Boolean);
}

// Deletes one image from Cloudinary, but only if it's on our cloud and no
// document still references it. Never throws — returns true when deleted.
async function destroyImageIfUnused(url) {
  try {
    const config = getConfig();
    if (!config) return false;

    const parsed = parseCloudinaryUrl(url);
    if (!parsed || parsed.cloudName !== config.cloudName) return false;
    if (await isImageReferenced(url)) return false;

    const timestamp = Math.floor(Date.now() / 1000);
    const toSign = `public_id=${parsed.publicId}&timestamp=${timestamp}${config.apiSecret}`;
    const signature = crypto.createHash('sha1').update(toSign).digest('hex');

    const body = new URLSearchParams({
      public_id: parsed.publicId,
      timestamp: String(timestamp),
      api_key: config.apiKey,
      signature,
    });

    const response = await fetch(
      `https://api.cloudinary.com/v1_1/${config.cloudName}/image/destroy`,
      { method: 'POST', body }
    );
    const result = await response.json().catch(() => ({}));
    if (result.result !== 'ok' && result.result !== 'not found') {
      console.warn(`[cloudinary] destroy failed for ${parsed.publicId}:`, result);
      return false;
    }
    return result.result === 'ok';
  } catch (err) {
    console.warn('[cloudinary] destroy error:', err.message);
    return false;
  }
}

// Fire-and-forget helper for routes: deletes a batch in the background so
// the HTTP response never waits on Cloudinary.
function destroyImagesInBackground(urls) {
  const unique = [...new Set((urls || []).filter((u) => typeof u === 'string'))];
  if (unique.length === 0) return;
  Promise.all(unique.map(destroyImageIfUnused)).catch(() => {});
}

module.exports = { parseCloudinaryUrl, destroyImageIfUnused, destroyImagesInBackground };
