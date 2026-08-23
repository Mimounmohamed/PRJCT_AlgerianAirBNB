/**
 * seedAmenityCatalog.js
 *
 * Populates the AmenityCatalog collection — the fixed, predefined list of
 * amenities hosts check off when creating a listing (~130 items across 11
 * categories). Custom amenities a host adds manually are NOT stored here —
 * they live only on that specific Listing document (see Listing.js).
 *
 * Usage:
 *   node seedAmenityCatalog.js            // insert catalog
 *   node seedAmenityCatalog.js --clear    // wipe existing catalog first
 *
 * Requires MONGODB_URI in your .env (same one your backend already uses).
 */

require('dotenv').config();
const dns = require('dns');
dns.setServers(['1.1.1.1', '1.0.0.1']);

const mongoose = require('mongoose');
const AmenityCatalog = require('./models/AmenityCatalog'); // adjust path to match your project structure

const MONGODB_URI = process.env.MONGODB_URI;
if (!MONGODB_URI) {
  console.error('Missing MONGODB_URI in environment.');
  process.exit(1);
}

// key, name, category, iconName (maps to a Flutter Icons.* name client-side)
const amenities = [
  // ── Scenic views ─────────────────────────────────────────
  ['sea_view', 'Sea view', 'Scenic views', 'waves'],
  ['city_skyline_view', 'City skyline view', 'Scenic views', 'location_city'],
  ['mountain_view', 'Mountain view', 'Scenic views', 'landscape'],
  ['garden_view', 'Garden view', 'Scenic views', 'grass'],
  ['courtyard_view', 'Courtyard view', 'Scenic views', 'yard'],
  ['desert_view', 'Desert view', 'Scenic views', 'terrain'],
  ['pool_view', 'Pool view', 'Scenic views', 'pool'],
  ['sunset_view', 'Sunset view', 'Scenic views', 'wb_twilight'],
  ['private_terrace_view', 'Private terrace with a view', 'Scenic views', 'deck'],

  // ── Bedroom and laundry ──────────────────────────────────
  ['essentials', 'Essentials (towels, sheets, soap)', 'Bedroom and laundry', 'checkroom'],
  ['hangers', 'Hangers', 'Bedroom and laundry', 'checkroom'],
  ['bed_linens', 'Bed linens', 'Bedroom and laundry', 'bed'],
  ['extra_pillows_blankets', 'Extra pillows and blankets', 'Bedroom and laundry', 'bed'],
  ['iron_steamer', 'Iron and steamer', 'Bedroom and laundry', 'iron'],
  ['in_unit_washer', 'In-unit washer', 'Bedroom and laundry', 'local_laundry_service'],
  ['dryer', 'Dryer', 'Bedroom and laundry', 'dry_cleaning'],
  ['closet_wardrobe', 'Closet / wardrobe', 'Bedroom and laundry', 'checkroom'],
  ['blackout_curtains', 'Blackout curtains', 'Bedroom and laundry', 'curtains'],
  ['drying_rack', 'Clothes drying rack', 'Bedroom and laundry', 'dry'],

  // ── Bathroom ─────────────────────────────────────────────
  ['hot_water', 'Hot water', 'Bathroom', 'water_drop'],
  ['hair_dryer', 'Hair dryer', 'Bathroom', 'air'],
  ['shampoo_conditioner', 'Shampoo and conditioner', 'Bathroom', 'soap'],
  ['body_soap', 'Body soap', 'Bathroom', 'soap'],
  ['bathtub', 'Bathtub', 'Bathroom', 'bathtub'],
  ['walk_in_shower', 'Walk-in shower', 'Bathroom', 'shower'],
  ['bidet', 'Bidet', 'Bathroom', 'wc'],
  ['private_bathroom', 'Private bathroom', 'Bathroom', 'wc'],
  ['outdoor_shower', 'Outdoor shower', 'Bathroom', 'shower'],

  // ── Internet and office ──────────────────────────────────
  ['fiber_wifi', 'Fiber WiFi', 'Internet and office', 'wifi'],
  ['dedicated_workspace', 'Dedicated workspace', 'Internet and office', 'work'],
  ['ethernet_connection', 'Ethernet connection', 'Internet and office', 'settings_ethernet'],
  ['printer', 'Printer', 'Internet and office', 'print'],
  ['desk_chair', 'Desk and chair', 'Internet and office', 'chair'],

  // ── Entertainment ────────────────────────────────────────
  ['smart_tv', 'Smart TV', 'Entertainment', 'tv'],
  ['satellite_channels', 'Satellite / cable channels', 'Entertainment', 'settings_input_antenna'],
  ['streaming_services', 'Streaming services (Netflix, etc.)', 'Entertainment', 'live_tv'],
  ['books_reading_material', 'Books and reading material', 'Entertainment', 'menu_book'],
  ['board_games', 'Board games', 'Entertainment', 'casino'],
  ['sound_system', 'Bluetooth sound system', 'Entertainment', 'speaker'],
  ['game_console', 'Game console', 'Entertainment', 'sports_esports'],
  ['record_player', 'Record player', 'Entertainment', 'album'],

  // ── Kitchen and dining ───────────────────────────────────
  ['full_kitchen', 'Full kitchen', 'Kitchen and dining', 'kitchen'],
  ['refrigerator', 'Refrigerator', 'Kitchen and dining', 'kitchen'],
  ['microwave', 'Microwave', 'Kitchen and dining', 'microwave'],
  ['stove', 'Stove', 'Kitchen and dining', 'local_fire_department'],
  ['oven', 'Oven', 'Kitchen and dining', 'countertops'],
  ['dishwasher', 'Dishwasher', 'Kitchen and dining', 'wash'],
  ['coffee_maker', 'Coffee maker', 'Kitchen and dining', 'coffee_maker'],
  ['espresso_machine', 'Espresso machine', 'Kitchen and dining', 'coffee'],
  ['kettle', 'Electric kettle', 'Kitchen and dining', 'coffee'],
  ['toaster', 'Toaster', 'Kitchen and dining', 'bakery_dining'],
  ['dining_table', 'Dining table', 'Kitchen and dining', 'table_restaurant'],
  ['traditional_cookware', 'Traditional clay cookware', 'Kitchen and dining', 'ramen_dining'],
  ['breakfast_included', 'Breakfast included', 'Kitchen and dining', 'free_breakfast'],
  ['bbq_grill', 'BBQ grill', 'Kitchen and dining', 'outdoor_grill'],
  ['wine_glasses', 'Wine glasses', 'Kitchen and dining', 'wine_bar'],

  // ── Heating and cooling ──────────────────────────────────
  ['air_conditioning', 'Air conditioning', 'Heating and cooling', 'ac_unit'],
  ['central_heating', 'Central heating', 'Heating and cooling', 'thermostat'],
  ['ceiling_fan', 'Ceiling fan', 'Heating and cooling', 'mode_fan_off'],
  ['fireplace', 'Indoor fireplace', 'Heating and cooling', 'fireplace'],
  ['portable_fans', 'Portable fans', 'Heating and cooling', 'air'],
  ['extra_heaters', 'Extra portable heaters', 'Heating and cooling', 'device_thermostat'],

  // ── Home safety ──────────────────────────────────────────
  ['security_cameras', '24/7 security', 'Home safety', 'shield'],
  ['smoke_alarm', 'Smoke alarm', 'Home safety', 'detector_smoke'],
  ['carbon_monoxide_alarm', 'Carbon monoxide alarm', 'Home safety', 'co2'],
  ['first_aid_kit', 'First aid kit', 'Home safety', 'medical_services'],
  ['fire_extinguisher', 'Fire extinguisher', 'Home safety', 'fire_extinguisher'],
  ['safe', 'In-room safe', 'Home safety', 'lock'],
  ['gated_property', 'Gated property', 'Home safety', 'fence'],
  ['exterior_lighting', 'Exterior lighting', 'Home safety', 'light'],

  // ── Outdoor ───────────────────────────────────────────────
  ['private_terrace', 'Private terrace', 'Outdoor', 'deck'],
  ['rooftop_terrace', 'Rooftop terrace', 'Outdoor', 'roofing'],
  ['courtyard', 'Courtyard', 'Outdoor', 'yard'],
  ['garden', 'Garden', 'Outdoor', 'grass'],
  ['private_pool', 'Private pool', 'Outdoor', 'pool'],
  ['shared_pool', 'Shared pool', 'Outdoor', 'pool'],
  ['outdoor_furniture', 'Outdoor furniture', 'Outdoor', 'deck'],
  ['fire_pit', 'Fire pit', 'Outdoor', 'local_fire_department'],
  ['hammock', 'Hammock', 'Outdoor', 'weekend'],
  ['sun_loungers', 'Sun loungers', 'Outdoor', 'beach_access'],

  // ── Parking and facilities ───────────────────────────────
  ['free_parking', 'Free parking on premises', 'Parking and facilities', 'local_parking'],
  ['paid_parking', 'Paid parking nearby', 'Parking and facilities', 'local_parking'],
  ['elevator', 'Elevator', 'Parking and facilities', 'elevator'],
  ['luggage_dropoff', 'Luggage drop-off allowed', 'Parking and facilities', 'luggage'],
  ['self_checkin', 'Self check-in', 'Parking and facilities', 'key'],
  ['keypad_entry', 'Keypad entry', 'Parking and facilities', 'pin'],
  ['gym_access', 'Gym access', 'Parking and facilities', 'fitness_center'],
  ['ev_charger', 'EV charger', 'Parking and facilities', 'ev_station'],

  // ── Accessibility ─────────────────────────────────────────
  ['step_free_entrance', 'Step-free entrance', 'Accessibility', 'accessible'],
  ['wide_doorways', 'Wide doorways', 'Accessibility', 'accessible'],
  ['accessible_bathroom', 'Accessible bathroom', 'Accessibility', 'accessible_forward'],
  ['ground_floor_access', 'Ground floor access', 'Accessibility', 'stairs'],
  ['grab_rails', 'Grab rails in bathroom', 'Accessibility', 'accessible'],

  // ── Other ─────────────────────────────────────────────────
  ['pets_allowed', 'Pets allowed', 'Other', 'pets'],
  ['smoking_allowed', 'Smoking allowed', 'Other', 'smoking_rooms'],
  ['long_term_stays', 'Long-term stays allowed', 'Other', 'calendar_month'],
  ['host_greets_you', 'Host greets you', 'Other', 'waving_hand'],
  ['cleaning_available', 'Cleaning available during stay', 'Other', 'cleaning_services'],
];

async function seed() {
  const args = process.argv.slice(2);
  const shouldClear = args.includes('--clear');

  await mongoose.connect(MONGODB_URI);
  console.log('Connected to MongoDB.');

  if (shouldClear) {
    const { deletedCount } = await AmenityCatalog.deleteMany({});
    console.log(`Cleared ${deletedCount} existing catalog entr(ies).`);
  }

  const docs = amenities.map(([key, name, category, iconName]) => ({
    key,
    name,
    category,
    iconName,
  }));

  const inserted = await AmenityCatalog.insertMany(docs, { ordered: false });
  console.log(`Inserted ${inserted.length} amenity catalog entries across ${
    new Set(docs.map((d) => d.category)).size
  } categories.`);

  await mongoose.disconnect();
  console.log('Done.');
}

seed().catch((err) => {
  console.error('Seed failed:', err);
  process.exit(1);
});