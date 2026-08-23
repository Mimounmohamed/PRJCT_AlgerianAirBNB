/**
 * seedListings.js
 *
 * Populates the Listing collection with sample data covering all four
 * Explore filter categories (Riads, Sea view, Casbah, Desert), and seeds
 * a matching 90-day window of per-day Availability documents for each
 * listing (booked inside a sample blocked range, available outside it) —
 * so the Explore page, filters, and "next available" logic all have real
 * data to query against.
 *
 * Usage:
 *   node seedListings.js            // insert sample listings + availability
 *   node seedListings.js --clear    // wipe existing listings/availability first, then insert
 *
 * Requires in your .env:
 *   MONGODB_URI  — same connection string your backend already uses
 *   HOST_ID      — an existing User _id in your DB (every Listing needs a valid hostId)
 */

require('dotenv').config();

// Force Node's own DNS resolver to use Cloudflare directly. On some Windows
// setups (especially after a VPN client like Cloudflare WARP has been active),
// Node's internal resolver can fail SRV lookups (mongodb+srv://) even when the
// OS resolver works fine via nslookup. This sidesteps that mismatch.
const dns = require('dns');
dns.setServers(['1.1.1.1', '1.0.0.1']);

const mongoose = require('mongoose');
const Listing = require('./models/Listing'); // adjust path to match your project structure
const Availability = require('./models/Availability'); // adjust path to match your project structure

const MONGODB_URI = process.env.MONGODB_URI;
const FALLBACK_HOST_ID = process.env.HOST_ID; // must be a real User _id in your DB

if (!MONGODB_URI) {
  console.error('Missing MONGODB_URI in environment.');
  process.exit(1);
}
if (!FALLBACK_HOST_ID) {
  console.error('Missing HOST_ID in environment — set it to an existing User _id.');
  process.exit(1);
}

// Helper: build a blockedDates entry N..M days from now, so "next available"
// logic has something real to compute against instead of a hardcoded string.
function daysFromNow(n) {
  const d = new Date();
  d.setDate(d.getDate() + n);
  d.setHours(0, 0, 0, 0);
  return d;
}

const sampleListings = [
  {
    title: 'Dar El Menia',
    description:
      'A restored 19th-century riad in the heart of Constantine, built around a tiled courtyard with a working fountain. Traditional zellige work throughout, quiet despite the central location.',
    descriptionTitle: 'A Living Piece of Constantine',
    propertyType: 'Riad',
    styleType: 'Traditional Riad',
    categories: ['Riads', 'Casbah'],
    location: {
      wilaya: 'Constantine',
      city: 'Constantine',
      neighborhood: 'Old City',
      coordinates: { type: 'Point', coordinates: [6.6147, 36.365] },
    },
    price: { perNight: 9200, currency: 'DZD' },
    capacity: { guests: 4, bedrooms: 2, bathrooms: 1.5 },
    photos: [
      { url: 'https://images.unsplash.com/photo-1553603227-2358aabe821e', order: 0 },
      { url: 'https://images.unsplash.com/photo-1590490360182-c33d57733427', order: 1 },
    ],
    amenities: [
      { catalogKey: 'fiber_wifi', name: 'Fiber WiFi', category: 'Internet and office', iconName: 'wifi', description: 'Fast, reliable connection throughout the riad, including the courtyard.' },
      { catalogKey: 'breakfast_included', name: 'Breakfast included', category: 'Kitchen and dining', iconName: 'free_breakfast', description: 'Traditional Algerian breakfast served each morning in the courtyard.' },
      { catalogKey: 'courtyard', name: 'Courtyard', category: 'Outdoor', iconName: 'yard', description: 'Central tiled courtyard with a working fountain, shaded by orange trees.' },
      { catalogKey: 'air_conditioning', name: 'Air conditioning', category: 'Heating and cooling', iconName: 'ac_unit', description: 'Every bedroom is air conditioned for the Constantine summer heat.' },
      { catalogKey: 'traditional_cookware', name: 'Traditional clay cookware', category: 'Kitchen and dining', iconName: 'ramen_dining', description: 'Full set of traditional tagines and clay dishes available for guest use.' },
    ],
    bookingPreferences: { instantBook: true },
    // seed-only metadata, not a schema field — used below to generate real Availability docs
    _blockedRange: { from: daysFromNow(0), to: daysFromNow(11) },
    visibility: 'listed',
    status: 'active',
    publishedAt: new Date(),
    rating: { overall: 4.92, cleanliness: 4.9, communication: 5.0, checkIn: 4.9, location: 4.95, value: 4.8, totalReviews: 128 },
    isGuestFavorite: true,
  },
  {
    title: 'Tassili Nomadic Lodge',
    description:
      'Berber-style tents pitched at the edge of the dunes near Djanet, run by a local Tuareg family. Includes guided sunset walks and traditional dinners cooked over open fire.',
    descriptionTitle: 'Nights Under the Sahara Sky',
    propertyType: 'Desert House',
    styleType: 'Nomadic Camp',
    categories: ['Desert'],
    location: {
      wilaya: 'Djanet',
      city: 'Djanet',
      neighborhood: 'Tassili N\'Ajjer',
      coordinates: { type: 'Point', coordinates: [9.4844, 24.5541] },
    },
    price: { perNight: 15500, currency: 'DZD' },
    capacity: { guests: 2, bedrooms: 1, bathrooms: 1 },
    photos: [
      { url: 'https://images.unsplash.com/photo-1509316785289-025f5b846b35', order: 0 },
      { url: 'https://images.unsplash.com/photo-1518998053901-5348d3961a04', order: 1 },
    ],
    amenities: [
      { catalogKey: 'breakfast_included', name: 'Breakfast included', category: 'Kitchen and dining', iconName: 'free_breakfast', description: 'Traditional dinner and breakfast prepared over open fire by the host family.' },
      { catalogKey: 'fire_pit', name: 'Fire pit', category: 'Outdoor', iconName: 'local_fire_department', description: 'Communal fire pit for evening tea, music, and stargazing.' },
      { catalogKey: 'desert_view', name: 'Desert view', category: 'Scenic views', iconName: 'terrain', description: 'Direct views over the Tassili dunes from every tent.' },
      { catalogKey: 'host_greets_you', name: 'Host greets you', category: 'Other', iconName: 'waving_hand', description: 'The Tuareg family greets every guest personally on arrival.' },
    ],
    bookingPreferences: { instantBook: false, advanceNoticeHours: 48 },
    _blockedRange: { from: daysFromNow(19), to: daysFromNow(26) },
    visibility: 'listed',
    status: 'active',
    publishedAt: new Date(),
    rating: { overall: 5.0, cleanliness: 5.0, communication: 5.0, checkIn: 5.0, location: 5.0, value: 5.0, totalReviews: 42 },
    isGuestFavorite: true,
  },
  {
    title: 'Villa Turquoise',
    description:
      'Clifftop villa overlooking the Mediterranean, five minutes from central Algiers. Private terrace, direct sea view from every room, bougainvillea-lined entrance.',
    descriptionTitle: 'Where the Mediterranean Meets Home',
    propertyType: 'Villa',
    styleType: 'Coastal Villa',
    categories: ['Sea view'],
    location: {
      wilaya: 'Algiers',
      city: 'Algiers',
      neighborhood: 'Bordj El Kiffan',
      coordinates: { type: 'Point', coordinates: [3.1908, 36.7538] },
    },
    price: { perNight: 22000, currency: 'DZD' },
    capacity: { guests: 6, bedrooms: 3, bathrooms: 2 },
    photos: [
      { url: 'https://images.unsplash.com/photo-1499793983690-e29da59ef1c2', order: 0 },
      { url: 'https://images.unsplash.com/photo-1505142468610-359e7d316be0', order: 1 },
    ],
    amenities: [
      { catalogKey: 'sea_view', name: 'Sea view', category: 'Scenic views', iconName: 'waves', description: 'Uninterrupted Mediterranean views from the private terrace and every bedroom.' },
      { catalogKey: 'full_kitchen', name: 'Full kitchen', category: 'Kitchen and dining', iconName: 'kitchen', description: 'Fully equipped kitchen with everything needed for longer stays.' },
      { catalogKey: 'free_parking', name: 'Free parking on premises', category: 'Parking and facilities', iconName: 'local_parking', description: 'Private gated parking right outside the villa.' },
      { catalogKey: 'air_conditioning', name: 'Air conditioning', category: 'Heating and cooling', iconName: 'ac_unit', description: 'Central air conditioning throughout the villa.' },
      { catalogKey: 'in_unit_washer', name: 'In-unit washer', category: 'Bedroom and laundry', iconName: 'local_laundry_service', description: 'Washer available for longer coastal stays.' },
    ],
    bookingPreferences: { instantBook: true },
    _blockedRange: { from: daysFromNow(37), to: daysFromNow(42) },
    visibility: 'listed',
    status: 'active',
    publishedAt: new Date(),
    rating: { overall: 4.88, cleanliness: 4.85, communication: 4.9, checkIn: 4.85, location: 5.0, value: 4.7, totalReviews: 89 },
    isGuestFavorite: false,
  },
  {
    title: 'Kasbah Blue House',
    description:
      'A narrow, sky-blue townhouse tucked into the alleys of the Casbah, steps from Ketchaoua Mosque. Rooftop terrace looks out over the bay of Algiers.',
    descriptionTitle: 'A Blue Door in the Casbah',
    propertyType: 'Townhouse',
    styleType: 'Casbah Townhouse',
    categories: ['Casbah'],
    location: {
      wilaya: 'Algiers',
      city: 'Algiers',
      neighborhood: 'Casbah',
      coordinates: { type: 'Point', coordinates: [3.0608, 36.7855] },
    },
    price: { perNight: 8500, currency: 'DZD' },
    capacity: { guests: 3, bedrooms: 1, bathrooms: 1 },
    photos: [
      { url: 'https://images.unsplash.com/photo-1548013146-72479768bada', order: 0 },
      { url: 'https://images.unsplash.com/photo-1512917774080-9991f1c4c750', order: 1 },
    ],
    amenities: [
      { catalogKey: 'rooftop_terrace', name: 'Rooftop terrace', category: 'Outdoor', iconName: 'roofing', description: 'Private rooftop terrace looking out over the bay of Algiers.' },
      { catalogKey: 'fiber_wifi', name: 'Fiber WiFi', category: 'Internet and office', iconName: 'wifi', description: 'Reliable WiFi throughout the townhouse.' },
      { catalogKey: 'espresso_machine', name: 'Espresso machine', category: 'Kitchen and dining', iconName: 'coffee', description: 'Espresso machine in the kitchen, Algerian coffee included.' },
    ],
    bookingPreferences: { instantBook: false },
    _blockedRange: { from: daysFromNow(5), to: daysFromNow(9) },
    visibility: 'listed',
    status: 'active',
    publishedAt: new Date(),
    rating: { overall: 4.76, cleanliness: 4.7, communication: 4.8, checkIn: 4.75, location: 4.9, value: 4.8, totalReviews: 61 },
    isGuestFavorite: false,
  },
  {
    title: 'Riad Yasmine',
    description:
      'Family-run riad near the Roman ruins of Tipaza, five bedrooms around a citrus-tree courtyard. Popular for group stays and weekend getaways from Algiers.',
    descriptionTitle: 'Citrus, Courtyards, and Company',
    propertyType: 'Riad',
    styleType: 'Traditional Riad',
    categories: ['Riads', 'Sea view'],
    location: {
      wilaya: 'Tipaza',
      city: 'Tipaza',
      neighborhood: 'Centre Ville',
      coordinates: { type: 'Point', coordinates: [2.4483, 36.5891] },
    },
    price: { perNight: 13000, currency: 'DZD' },
    capacity: { guests: 8, bedrooms: 4, bathrooms: 3 },
    photos: [
      { url: 'https://images.unsplash.com/photo-1600585154340-be6161a56a0c', order: 0 },
      { url: 'https://images.unsplash.com/photo-1600607687939-ce8a6c25118c', order: 1 },
    ],
    amenities: [
      { catalogKey: 'courtyard', name: 'Courtyard', category: 'Outdoor', iconName: 'yard', description: 'Citrus-tree courtyard shared by all five bedrooms.' },
      { catalogKey: 'breakfast_included', name: 'Breakfast included', category: 'Kitchen and dining', iconName: 'free_breakfast', description: 'Family-style breakfast served daily, included for all guests.' },
      { catalogKey: 'free_parking', name: 'Free parking on premises', category: 'Parking and facilities', iconName: 'local_parking', description: 'Off-street parking right by the entrance.' },
      { catalogKey: 'full_kitchen', name: 'Full kitchen', category: 'Kitchen and dining', iconName: 'kitchen', description: 'Shared kitchen, well suited for group stays.' },
    ],
    bookingPreferences: { instantBook: true, minStayNights: 2 },
    _blockedRange: { from: daysFromNow(14), to: daysFromNow(21) },
    visibility: 'listed',
    status: 'active',
    publishedAt: new Date(),
    rating: { overall: 4.81, cleanliness: 4.8, communication: 4.85, checkIn: 4.8, location: 4.9, value: 4.75, totalReviews: 74 },
    isGuestFavorite: false,
  },
  {
    title: 'Erg Chebbi Dune Camp',
    description:
      'Camp set among the tallest dunes near Taghit, with camel trekking arranged on request and a communal fire pit for evening tea and music.',
    descriptionTitle: 'Camped Among the Dunes',
    propertyType: 'Desert House',
    styleType: 'Nomadic Camp',
    categories: ['Desert'],
    location: {
      wilaya: 'Béchar',
      city: 'Taghit',
      neighborhood: 'Grand Erg Occidental',
      coordinates: { type: 'Point', coordinates: [2.0086, 30.9111] },
    },
    price: { perNight: 11800, currency: 'DZD' },
    capacity: { guests: 4, bedrooms: 2, bathrooms: 1 },
    photos: [
      { url: 'https://images.unsplash.com/photo-1509023464722-18d996393ca8', order: 0 },
      { url: 'https://images.unsplash.com/photo-1547471080-7cc2caa01a7e', order: 1 },
    ],
    amenities: [
      { catalogKey: 'breakfast_included', name: 'Breakfast included', category: 'Kitchen and dining', iconName: 'free_breakfast', description: 'Traditional dinner cooked over open fire, included with every stay.' },
      { catalogKey: 'fire_pit', name: 'Fire pit', category: 'Outdoor', iconName: 'local_fire_department', description: 'Nightly fire pit gatherings with tea and music.' },
      { catalogKey: 'desert_view', name: 'Desert view', category: 'Scenic views', iconName: 'terrain', description: 'Camp sits right among the tallest dunes near Taghit.' },
    ],
    bookingPreferences: { instantBook: false, advanceNoticeHours: 48 },
    _blockedRange: { from: daysFromNow(9), to: daysFromNow(13) },
    visibility: 'listed',
    status: 'active',
    publishedAt: new Date(),
    rating: { overall: 4.94, cleanliness: 4.9, communication: 4.95, checkIn: 4.9, location: 5.0, value: 4.9, totalReviews: 37 },
    isGuestFavorite: true,
  },
  {
    title: 'Oran Bay Apartment',
    description:
      'Modern apartment on the Front de Mer with a private balcony facing the bay. Walking distance to Santa Cruz and the port promenade.',
    descriptionTitle: 'Front-Row Seat to the Bay',
    propertyType: 'Apartment',
    styleType: 'Modern Apartment',
    categories: ['Sea view'],
    location: {
      wilaya: 'Oran',
      city: 'Oran',
      neighborhood: 'Front de Mer',
      coordinates: { type: 'Point', coordinates: [-0.6331, 35.7089] },
    },
    price: { perNight: 10500, currency: 'DZD' },
    capacity: { guests: 4, bedrooms: 2, bathrooms: 1 },
    photos: [
      { url: 'https://images.unsplash.com/photo-1522708323590-d24dbb6b0267', order: 0 },
      { url: 'https://images.unsplash.com/photo-1502672260266-1c1ef2d93688', order: 1 },
    ],
    amenities: [
      { catalogKey: 'fiber_wifi', name: 'Fiber WiFi', category: 'Internet and office', iconName: 'wifi', description: 'Fast WiFi throughout the apartment, good for remote work.' },
      { catalogKey: 'air_conditioning', name: 'Air conditioning', category: 'Heating and cooling', iconName: 'ac_unit', description: 'Air conditioning in both bedrooms and the living room.' },
      { catalogKey: 'private_terrace', name: 'Private terrace', category: 'Outdoor', iconName: 'deck', description: 'Private balcony facing the bay, perfect for sunset.' },
      { catalogKey: 'elevator', name: 'Elevator', category: 'Parking and facilities', iconName: 'elevator', description: 'Building elevator, no stairs required.' },
    ],
    bookingPreferences: { instantBook: true },
    _blockedRange: { from: daysFromNow(2), to: daysFromNow(6) },
    visibility: 'listed',
    status: 'active',
    publishedAt: new Date(),
    rating: { overall: 4.7, cleanliness: 4.7, communication: 4.75, checkIn: 4.65, location: 4.85, value: 4.7, totalReviews: 53 },
    isGuestFavorite: false,
  },
  {
    title: 'Dar Sidi Bouhouria',
    description:
      'Restored merchant house in the Casbah of Dellys with sea glimpses from the top terrace. Original tilework preserved throughout.',
    descriptionTitle: 'An Old Town Merchant House Reborn',
    propertyType: 'Riad',
    styleType: 'Casbah Riad',
    categories: ['Casbah', 'Sea view'],
    location: {
      wilaya: 'Boumerdès',
      city: 'Dellys',
      neighborhood: 'Old Town',
      coordinates: { type: 'Point', coordinates: [3.9169, 36.9147] },
    },
    price: { perNight: 9800, currency: 'DZD' },
    capacity: { guests: 5, bedrooms: 2, bathrooms: 2 },
    photos: [
      { url: 'https://images.unsplash.com/photo-1512918728675-ed5a9ecdebfd', order: 0 },
      { url: 'https://images.unsplash.com/photo-1600566752355-35792bedcfea', order: 1 },
    ],
    amenities: [
      { catalogKey: 'rooftop_terrace', name: 'Rooftop terrace', category: 'Outdoor', iconName: 'roofing', description: 'Top terrace with sea glimpses over the old town of Dellys.' },
      { catalogKey: 'breakfast_included', name: 'Breakfast included', category: 'Kitchen and dining', iconName: 'free_breakfast', description: 'Breakfast served each morning, included in the stay.' },
      { catalogKey: 'fiber_wifi', name: 'Fiber WiFi', category: 'Internet and office', iconName: 'wifi', description: 'WiFi available throughout the house.' },
    ],
    bookingPreferences: { instantBook: false },
    _blockedRange: { from: daysFromNow(24), to: daysFromNow(29) },
    visibility: 'listed',
    status: 'active',
    publishedAt: new Date(),
    rating: { overall: 4.85, cleanliness: 4.8, communication: 4.9, checkIn: 4.8, location: 4.95, value: 4.85, totalReviews: 46 },
    isGuestFavorite: false,
  },
];

// Generates one Availability document per day for a 90-day window starting
// today. Days that fall inside blockedRange are marked 'booked'; everything
// else is 'available'. This is what the Explore page's "next available"
// query should read from — not anything embedded on Listing itself.
function buildAvailabilityDocs(listingId, blockedRange, windowDays = 90) {
  const docs = [];
  for (let i = 0; i < windowDays; i++) {
    const date = daysFromNow(i);
    const isBlocked = blockedRange && date >= blockedRange.from && date < blockedRange.to;
    docs.push({
      listingId,
      date,
      status: isBlocked ? 'booked' : 'available',
    });
  }
  return docs;
}

async function seed() {
  const args = process.argv.slice(2);
  const shouldClear = args.includes('--clear');

  await mongoose.connect(MONGODB_URI);
  console.log('Connected to MongoDB.');

  if (shouldClear) {
    const { deletedCount: listingsCleared } = await Listing.deleteMany({});
    const { deletedCount: availabilityCleared } = await Availability.deleteMany({});
    console.log(`Cleared ${listingsCleared} existing listing(s) and ${availabilityCleared} availability doc(s).`);
  }

  // Strip the seed-only _blockedRange field before inserting — it's not part
  // of the Listing schema, it's only used below to seed Availability.
  const docs = sampleListings.map(({ _blockedRange, ...listing }) => ({
    ...listing,
    hostId: FALLBACK_HOST_ID,
  }));

  const insertedListings = await Listing.insertMany(docs);
  console.log(`Inserted ${insertedListings.length} sample listing(s):`);
  insertedListings.forEach((doc) => {
    console.log(`  - ${doc.title} [${doc.categories.join(', ')}] (${doc._id})`);
  });

  // Build and insert matching Availability day-documents for each listing,
  // using the original sampleListings array (in the same order) to pull
  // each one's _blockedRange.
  const availabilityDocs = insertedListings.flatMap((listing, i) =>
    buildAvailabilityDocs(listing._id, sampleListings[i]._blockedRange)
  );
  const insertedAvailability = await Availability.insertMany(availabilityDocs);
  console.log(`Inserted ${insertedAvailability.length} availability day-document(s) (90-day window per listing).`);

  await mongoose.disconnect();
  console.log('Done.');
}

seed().catch((err) => {
  console.error('Seed failed:', err);
  process.exit(1);
});