# Graph Report - PRJCT_AlgerianAirBNB  (2026-11-04)

## Corpus Check
- 248 files · ~146,549 words
- Verdict: corpus is large enough that graph structure adds value.
- Unclassified: 58 file(s) not represented in the graph (top: (none) 11, .xcconfig 8, .xml 7)

## Summary
- 2566 nodes · 3319 edges · 147 communities (118 shown, 29 thin omitted)
- Extraction: 98% EXTRACTED · 2% INFERRED · 0% AMBIGUOUS · INFERRED: 61 edges (avg confidence: 0.87)
- Token cost: 301,398 input · 0 output

## Community Hubs (Navigation)
- Edit Listing Details Page
- Chat Conversation Screen
- Listing Draft Model
- Listing Settings Page
- Create Listing Review Page
- Host Listing Detail Model
- OTP Code Input Widget
- Birthday Field & Calendar
- Amenities Page & Sheet
- App Bootstrap & Push Setup
- Listing Detail Model
- Guest Booking Page
- Create Listing Location Page
- House Rules Page
- Flutter Dependencies (pubspec)
- Backend Dependencies (npm)
- Manage Listing Page
- Profile & Settings Screen
- Manage Calendar Page
- iOS/macOS App Delegates
- Backend Auth Middleware & Routes
- Personal Info Screen
- Frontend Auth Service
- Booking Preferences Page
- Create Listing Amenities Page
- Privacy & Security Screen
- Update Password Screen
- Landing Page Tabs
- Conversation Model & Seeds
- Report Incident Screen
- Linux Runner (GTK)
- Sign-Up Step 2
- Message Center
- Sign-Up Step 1
- Wilaya Data & Help Center
- Host All Listings Page
- Two-Step Verification Screen
- Listing Detail Page
- OTP & Pending Signup Models
- Safety Guide Screen
- Login & Security Screen
- Sign-Up Step 3 (Photo)
- Bottom Nav Bar
- Notification Settings
- Host Dashboard Page
- Win32 Window Impl
- Host Stats & Progress Widgets
- User Session State
- Listing/Booking/Availability Models
- Create Listing Basics Page
- Email/Phone Login Screen
- Account OTP Verify Screen
- Complete Profile Dialog
- Socket.IO Client Service
- Windows Flutter Window
- Default Flutter Icons (Android/macOS/Web)
- Listing Image Carousel
- Win32 Geometry Types
- New Password Screen
- Location Map Preview
- Wilaya/Baladiya Selector
- Delete Account Screen
- Create Listing Confirmation
- Default Flutter Icons (iOS)
- Reset Password Method
- Verify Account Method
- Listing & Availability Services
- Navigation Handlers
- Safety & Trust Screen
- Desktop CMake Build
- Property Type Page
- Become Host Page
- Explore Filter Bar
- Onboarding Screens
- Host Booking Details Page
- Express Server Entry
- Host Tab Entry
- Windows Runner Entry
- OTP Method Selector
- Host Profile Page
- Explore Search Bar
- Listing Card Model
- How It Works Screen
- Hex Pattern Background
- Amenity Model
- Host Service API
- Privacy Policy Screen
- Terms of Service Screen
- Listing Card Widget
- Web PWA Manifest
- Amenity Catalog Backend
- Mar7aban Welcome Screen
- Akrili App Bar
- Reviews Page
- Host Listing Summary Model
- Win32 Message Handling
- Push Notifications & Message Routes
- Create Listing Intro Page
- Sign-In Progress Bar
- Host Section Widget
- Host Dashboard Model
- Amenity Catalog Service
- Firebase Phone Auth
- Custom Dashed Painters
- Splash Screen
- Courtyard Auth Entry
- Google Sign-In Screen
- Stateful Screen Classes
- Booking Bottom Bar
- Host Listing Row
- Dart Analyzer Config
- Maghrebi Heritage Imagery
- Project Docs & Web Entry
- Profile Dialog State
- Landing App Bar
- SMS Service
- Maghrebi Architecture Imagery
- Four-Point Star Brand
- iOS Launch Images
- API Base Config
- Android MainActivity
- Profile Illustration SVGs
- Hospitality Interior Images
- Notifications Screen State
- Shield Trust Icons
- Discover Landscape Images
- Location Page State
- Review Page State
- Edit Listing State
- Manage Calendar State
- Info Field State
- Personal Info State
- Decorative Orbit SVG
- Discover Compass SVG
- Experience House SVG
- Google G SVG
- Mosque Icon SVG
- Mountains Icon SVG
- Kasbah Icon SVG
- Default Avatar Image

## God Nodes (most connected - your core abstractions)
1. `mongoose` - 21 edges
2. `Win32Window` - 21 edges
3. `dependencies` - 17 edges
4. `Flutter Default App Icon (Flutter logo)` - 17 edges
5. `express` - 15 edges
6. `iOS AppIcon Set (default Flutter logo)` - 15 edges
7. `protect()` - 12 edges
8. `FlutterWindow` - 10 edges
9. `WindowClassRegistrar` - 9 edges
10. `_MyApplication` - 7 edges

## Surprising Connections (you probably didn't know these)
- `wWinMain()` --calls--> `CreateAndAttachConsole()`  [INFERRED]
  front/windows/runner/main.cpp → front/windows/runner/utils.cpp
- `APPLY_STANDARD_SETTINGS (Linux)` --semantically_similar_to--> `APPLY_STANDARD_SETTINGS (Windows)`  [INFERRED] [semantically similar]
  front/linux/CMakeLists.txt → front/windows/CMakeLists.txt
- `flutter_assemble (Linux)` --semantically_similar_to--> `flutter_assemble (Windows)`  [INFERRED] [semantically similar]
  front/linux/flutter/CMakeLists.txt → front/windows/flutter/CMakeLists.txt
- `Windows Runner Executable (WIN32)` --implements--> `Windows aairbnb Binary`  [INFERRED]
  front/windows/runner/CMakeLists.txt → front/windows/CMakeLists.txt
- `confidence.svg - Shield with Checkmark (Trust)` --semantically_similar_to--> `security.svg - Shield with User (Account Security)`  [INFERRED] [semantically similar]
  front/assets/icons/confidence.svg → front/assets/icons/security.svg

## Import Cycles
- None detected.

## Hyperedges (group relationships)
- **Linux desktop Flutter build pipeline** — front_linux_cmakelists_aairbnb_binary, front_linux_runner_cmakelists_runner_executable, front_linux_flutter_cmakelists_flutter_library, front_linux_flutter_cmakelists_flutter_assemble, front_linux_cmakelists_install_bundle [EXTRACTED 1.00]
- **Windows desktop Flutter build pipeline** — front_windows_cmakelists_aairbnb_binary, front_windows_runner_cmakelists_runner_executable, front_windows_flutter_cmakelists_flutter_library, front_windows_flutter_cmakelists_flutter_wrapper_app, front_windows_flutter_cmakelists_flutter_assemble, front_windows_cmakelists_install_bundle [EXTRACTED 1.00]
- **Mar7aban welcome screen Algerian heritage icons (mosque, mountains, kasbah)** — front_assets_icons_icon__1__icon, front_assets_icons_icon__2__icon, front_assets_icons_icon__3__icon [INFERRED 0.95]
- **How-it-works settings page feature icons (discover, confidence, experience)** — front_assets_icons_discover_icon, front_assets_icons_confidence_icon, front_assets_icons_experience_icon [INFERRED 0.95]
- **Profile illustration composition (central avatar, orbit ring, floating badges)** — front_assets_icons_central_avatar_base_icon, front_assets_icons_decorative_orbit_icon, front_assets_icons_background_icon, front_assets_icons_floating_element_reprentingprofile_icon [INFERRED 0.75]
- **Onboarding carousel full-bleed backgrounds (discover, authentically, hospitality)** — front_assets_images_discover_image, front_assets_images_authentically_image, front_assets_images_hospitality_image [INFERRED 0.85]
- **Login / sign-up screen imagery (courtyard, google, default avatar)** — front_assets_images_courtyard_image, front_assets_images_google_image, front_assets_images_default_avatar_image [INFERRED 0.75]
- **How it works page imagery (discoverAlgeria, authentically)** — front_assets_images_discoveralgeria_image, front_assets_images_authentically_image, front_assets_images_authentically_traditional_architecture_concept [INFERRED 0.65]
- **Four-Point Star Brand Identity Assets** — front_assets_images_logo_image, front_assets_images_logo_for_main_image, front_assets_images_phonenumber_image, front_assets_images_brand_star_motif [INFERRED 0.85]
- **Maghrebi Riad Hospitality Imagery** — front_assets_images_marhaban_image, front_assets_images_w_image, front_assets_images_safehousing_image, front_assets_images_maghrebi_heritage_aesthetic [INFERRED 0.85]
- **Android launcher icon density variants** — front_android_app_src_main_res_mipmap_mdpi_ic_launcher_icon, front_android_app_src_main_res_mipmap_hdpi_ic_launcher_icon, front_android_app_src_main_res_mipmap_xhdpi_ic_launcher_icon, front_android_app_src_main_res_mipmap_xxhdpi_ic_launcher_icon, front_android_app_src_main_res_mipmap_xxxhdpi_ic_launcher_icon [EXTRACTED 1.00]
- **macOS AppIcon.appiconset size variants** — front_macos_runner_assets_xcassets_appicon_appiconset_app_icon_16_icon, front_macos_runner_assets_xcassets_appicon_appiconset_app_icon_32_icon, front_macos_runner_assets_xcassets_appicon_appiconset_app_icon_64_icon, front_macos_runner_assets_xcassets_appicon_appiconset_app_icon_128_icon, front_macos_runner_assets_xcassets_appicon_appiconset_app_icon_256_icon, front_macos_runner_assets_xcassets_appicon_appiconset_app_icon_512_icon, front_macos_runner_assets_xcassets_appicon_appiconset_app_icon_1024_icon [EXTRACTED 1.00]
- **Web favicon and PWA icon set** — front_web_favicon_icon, front_web_icons_icon_192_icon, front_web_icons_icon_512_icon, front_web_icons_icon_maskable_192_icon, front_web_icons_icon_maskable_512_icon [INFERRED 0.95]
- **iOS Launch Image resolution variants** — front_ios_runner_assets_xcassets_launchimage_imageset_launchimage, front_ios_runner_assets_xcassets_launchimage_imageset_launchimage_2x, front_ios_runner_assets_xcassets_launchimage_imageset_launchimage_3x [EXTRACTED 1.00]

## Communities (147 total, 29 thin omitted)

### Community 0 - "Edit Listing Details Page"
Cohesion: 0.02
Nodes (86): accentColor, _addCustomAmenityChip, _addPhoto, _addPhotoTile, _amenities, _amenitiesSummaryTile, _amenityCatalog, _amenityCategorySection (+78 more)

### Community 1 - "Chat Conversation Screen"
Cohesion: 0.03
Nodes (59): _addButtonKey, _AvatarWithBadge, border, borderRadius, build, _C, cardBg, _ChatBubble (+51 more)

### Community 2 - "Listing Draft Model"
Cohesion: 0.04
Nodes (53): addCustomAmenity, additionalRules, addPhoto, adultOnly, advanceNoticeHours, amenities, bathrooms, bedrooms (+45 more)

### Community 3 - "Listing Settings Page"
Cohesion: 0.04
Nodes (50): _additionalRules, _adultOnly, _advanceNoticeHours, authToken, _border, build, _cancellationCard, _cancellationPolicy (+42 more)

### Community 4 - "Create Listing Review Page"
Cohesion: 0.04
Nodes (47): _addPhotosTile, _border, build, _cancellationCard, color, _cream, createState, _dark (+39 more)

### Community 5 - "Host Listing Detail Model"
Cohesion: 0.04
Nodes (48): additionalRules, adultOnly, advanceNoticeHours, amenities, cancellationPolicy, categories, checkInInstructions, checkInTimeFrom (+40 more)

### Community 6 - "OTP Code Input Widget"
Cohesion: 0.04
Nodes (41): build, _controllers, createState, dispose, errorText, fillColor, _focusNodes, length (+33 more)

### Community 7 - "Birthday Field & Calendar"
Cohesion: 0.05
Nodes (40): BirthdayField, build, errorText, _format, hint, label, onDateSelected, _pickDate (+32 more)

### Community 8 - "Amenities Page & Sheet"
Cohesion: 0.05
Nodes (38): amenities, AmenitiesPage, blurb, build, footerBlurb, _FooterCard, footerPhotoUrl, _groupByCategory (+30 more)

### Community 9 - "App Bootstrap & Push Setup"
Cohesion: 0.05
Nodes (25): build, initializeApp, initLocalNotifications, main, MyApp, android, DefaultFirebaseOptions, ios (+17 more)

### Community 10 - "Listing Detail Model"
Cohesion: 0.05
Nodes (40): amenities, bathrooms, bedrooms, categories, checkInTimeFrom, checkInTimeTo, checkOutTime, checkOutTimeFrom (+32 more)

### Community 11 - "Guest Booking Page"
Cohesion: 0.05
Nodes (37): BookingPage, _BookingPageState, build, checkInTimeFrom, checkInTimeTo, checkOutTime, checkOutTimeFrom, checkOutTimeTo (+29 more)

### Community 12 - "Create Listing Location Page"
Cohesion: 0.05
Nodes (31): _border, _center, _communes, createState, _dark, _debounce, _defaultCenter, dispose (+23 more)

### Community 13 - "House Rules Page"
Cohesion: 0.05
Nodes (37): additionalRules, adultOnly, authToken, _border, build, _cream, createState, curfew (+29 more)

### Community 14 - "Flutter Dependencies (pubspec)"
Cohesion: 0.05
Nodes (37): dependencies, cupertino_icons, dio, firebase_auth, firebase_core, firebase_messaging, flutter, flutter_local_notifications (+29 more)

### Community 15 - "Backend Dependencies (npm)"
Cohesion: 0.07
Nodes (35): author, dependencies, cors@^2.8.6, dotenv@^16.6.1, express@^4.22.2, express-validator@^7.1.0, firebase-admin@^14.3.0, mongoose@^8.24.1 (+27 more)

### Community 16 - "Manage Listing Page"
Cohesion: 0.06
Nodes (32): authToken, _border, color, _confirmAndRun, _cream, createState, _danger, _dark (+24 more)

### Community 17 - "Profile & Settings Screen"
Cohesion: 0.06
Nodes (27): appVersion, _bg, _cardFill, color, createState, _dark, _handleLogout, icon (+19 more)

### Community 18 - "Manage Calendar Page"
Cohesion: 0.06
Nodes (33): _applyUpdate, authToken, basePricePerNight, _blockedBg, _bookedBg, _border, _byDate, _changeMonth (+25 more)

### Community 19 - "iOS/macOS App Delegates"
Cohesion: 0.07
Nodes (11): Cocoa, Flutter, FlutterMacOS, AppDelegate, SceneDelegate, RunnerTests, AppDelegate, MainFlutterWindow (+3 more)

### Community 20 - "Backend Auth Middleware & Routes"
Cohesion: 0.09
Nodes (24): generateToken(), jwt, optionalAuth(), protect(), requireHost(), express, router, express (+16 more)

### Community 21 - "Personal Info Screen"
Cohesion: 0.06
Nodes (31): actionLabel, _address, badge, build, _controller, createState, _deactivateAccount, didUpdateWidget (+23 more)

### Community 22 - "Frontend Auth Service"
Cohesion: 0.06
Nodes (32): AuthService, completeProfile, deactivateAccount, deleteAccountPermanently, disconnectGoogle, getConversations, getMe, getMessages (+24 more)

### Community 23 - "Booking Preferences Page"
Cohesion: 0.06
Nodes (31): advanceNoticeHours, authToken, BookingPreferencesPage, _BookingPreferencesPageState, BookingPreferencesResult, _border, build, checkInTimeFrom (+23 more)

### Community 24 - "Create Listing Amenities Page"
Cohesion: 0.07
Nodes (26): _addCustomChip, _amenityChip, _border, _catalog, _categorySection, CreateListingAmenitiesPage, _CreateListingAmenitiesPageState, createState (+18 more)

### Community 25 - "Privacy & Security Screen"
Cohesion: 0.09
Nodes (28): appbarIcon, authBannerBg, badgeBg, bodyText, border, build, _C, captionText (+20 more)

### Community 26 - "Update Password Screen"
Cohesion: 0.07
Nodes (29): build, _confirmController, controller, createState, _currentController, dispose, _FieldLabel, _handleUpdate (+21 more)

### Community 27 - "Landing Page Tabs"
Cohesion: 0.07
Nodes (17): build, _buildExploreTab, _buildHostTab, _buildTabBody, _checkUnread, createState, _currentIndex, dispose (+9 more)

### Community 28 - "Conversation Model & Seeds"
Cohesion: 0.08
Nodes (17): mongoose, mongoose, conversationSchema, mongoose, incidentSchema, mongoose, listingViewSchema, mongoose (+9 more)

### Community 29 - "Report Incident Screen"
Cohesion: 0.08
Nodes (26): _AttachBox, _bodyStyle, build, color, content, createState, _descController, dispose (+18 more)

### Community 30 - "Linux Runner (GTK)"
Cohesion: 0.10
Nodes (13): main(), first_frame_cb(), my_application_activate(), my_application_class_init(), my_application_dispose(), my_application_init(), my_application_local_command_line(), my_application_new() (+5 more)

### Community 31 - "Sign-Up Step 2"
Cohesion: 0.08
Nodes (22): _baladiya, _birthday, _birthdayError, build, createState, dispose, email, _fullAddressController (+14 more)

### Community 32 - "Message Center"
Cohesion: 0.08
Nodes (23): conversationId, _conversations, _ConversationTile, createState, dispose, _error, _formatTime, hasUnread (+15 more)

### Community 33 - "Sign-Up Step 1"
Cohesion: 0.08
Nodes (21): build, createState, dispose, _emailController, _emailError, _fullNameController, _fullNameError, _generalError (+13 more)

### Community 34 - "Wilaya Data & Help Center"
Cohesion: 0.08
Nodes (21): algeriaWilayas, baladiyas, code, name, toString, WilayaData, answer, build (+13 more)

### Community 35 - "Host All Listings Page"
Cohesion: 0.09
Nodes (24): AllListingsPage, _AllListingsPageState, authToken, _border, build, Extension on _StatusFilter, _cream, createState (+16 more)

### Community 36 - "Two-Step Verification Screen"
Cohesion: 0.08
Nodes (24): build, child, color, createState, _DashedBorderContainer, _emailEnabled, icon, initState (+16 more)

### Community 37 - "Listing Detail Page"
Cohesion: 0.09
Nodes (11): createState, _descriptionExpanded, _future, initState, ListingDetailPage, _ListingDetailPageState, listingId, _openChat (+3 more)

### Community 38 - "OTP & Pending Signup Models"
Cohesion: 0.09
Nodes (15): bcryptjs@^2.4.3, bcrypt, mongoose, otpVerificationSchema, mongoose, pendingSignupSchema, bcrypt, mongoose (+7 more)

### Community 39 - "Safety Guide Screen"
Cohesion: 0.09
Nodes (20): build, _DarkGuideItem, description, _GuideItem, icon, iconColor, label, _RuleChip (+12 more)

### Community 40 - "Login & Security Screen"
Cohesion: 0.09
Nodes (20): confirmController, createState, icon, iconColor, initState, _isGoogleLinked, isLoading, _loadProfile (+12 more)

### Community 41 - "Sign-Up Step 3 (Photo)"
Cohesion: 0.09
Nodes (17): build, createState, email, _isLoading, _maskEmail, _maskPhone, _onBack, _onCompleteProfile (+9 more)

### Community 42 - "Bottom Nav Bar"
Cohesion: 0.09
Nodes (22): _active, activeIcon, AkriliNavBar, build, _cornerRadius, createState, _currentIndex, hasUnreadMessages (+14 more)

### Community 43 - "Notification Settings"
Cohesion: 0.09
Nodes (21): build, createState, _CustomToggle, icon, initState, _loadFromSession, _messagesEmail, _messagesPush (+13 more)

### Community 44 - "Host Dashboard Page"
Cohesion: 0.10
Nodes (16): authToken, build, createState, _dark, _dashboard, _error, _fetchAll, HostDashboardPage (+8 more)

### Community 45 - "Win32 Window Impl"
Cohesion: 0.13
Nodes (8): EnableNonClientDpiScaling, Scale(), Win32Window::Win32Window(), WindowClassRegistrar, class_registered_, WindowClassRegistrar::GetWindowClass(), instance_, WindowClassRegistrar::UnregisterWindowClass()

### Community 46 - "Host Stats & Progress Widgets"
Cohesion: 0.10
Nodes (14): build, CreateListingProgressDots, currentStep, totalSteps, activeListings, avgRating, build, formattedEarnings (+6 more)

### Community 47 - "User Session State"
Cohesion: 0.10
Nodes (15): AppUser, clear, copyWith, _currentUser, email, fromJson, id, instance (+7 more)

### Community 48 - "Listing/Booking/Availability Models"
Cohesion: 0.12
Nodes (15): availabilitySchema, mongoose, bookingSchema, mongoose, listingSchema, mongoose, photoSchema, express (+7 more)

### Community 49 - "Create Listing Basics Page"
Cohesion: 0.11
Nodes (17): _bathrooms, _bedrooms, _border, _counterRow, CreateListingBasicsPage, _CreateListingBasicsPageState, createState, _dark (+9 more)

### Community 50 - "Email/Phone Login Screen"
Cohesion: 0.11
Nodes (17): build, createState, dispose, _generalError, _identifierController, _identifierError, _isLoading, _labeledField (+9 more)

### Community 51 - "Account OTP Verify Screen"
Cohesion: 0.11
Nodes (18): build, _code, createState, _handleResend, _isEmail, _isLoading, _markAllRed, maskedContact (+10 more)

### Community 52 - "Complete Profile Dialog"
Cohesion: 0.11
Nodes (15): _browseApp, build, _buildBadge, _buildIllustration, _circle, _continueProfile, _controller, createState (+7 more)

### Community 53 - "Socket.IO Client Service"
Cohesion: 0.11
Nodes (13): _baseUrl, connect, disconnect, instance, isConnected, joinConversation, leaveConversation, offConversationUpdated (+5 more)

### Community 54 - "Windows Flutter Window"
Cohesion: 0.11
Nodes (4): FlutterWindow, flutter_controller_, FlutterWindow::FlutterWindow(), project_

### Community 55 - "Default Flutter Icons (Android/macOS/Web)"
Cohesion: 0.11
Nodes (18): Flutter Default App Icon (Flutter logo), Android launcher icon (hdpi), Android launcher icon (mdpi), Android launcher icon (xhdpi), Android launcher icon (xxhdpi), Android launcher icon (xxxhdpi), macOS app icon 1024, macOS app icon 128 (+10 more)

### Community 56 - "Listing Image Carousel"
Cohesion: 0.12
Nodes (16): build, _circleButton, _controller, createState, _currentPage, DetailImageCarousel, _DetailImageCarouselState, dispose (+8 more)

### Community 57 - "Win32 Geometry Types"
Cohesion: 0.13
Nodes (10): Point, x, y, Size, height, width, Win32Window, child_content_ (+2 more)

### Community 58 - "New Password Screen"
Cohesion: 0.12
Nodes (15): build, _confirmPasswordController, createState, dispose, email, _errorText, _isLoading, _newPasswordController (+7 more)

### Community 59 - "Location Map Preview"
Cohesion: 0.12
Nodes (13): _border, build, _dark, latitude, locationLabel, LocationMapPreview, longitude, _mapButton (+5 more)

### Community 60 - "Wilaya/Baladiya Selector"
Cohesion: 0.12
Nodes (14): baladiyaLabel, build, errorText, label, onBaladiyaChanged, onWilayaChanged, _openPicker, _pickerField (+6 more)

### Community 61 - "Delete Account Screen"
Cohesion: 0.13
Nodes (14): build, _controller, createState, _deleteAccount, DeleteAccountScreen, _DeleteAccountScreenState, dispose, initState (+6 more)

### Community 62 - "Create Listing Confirmation"
Cohesion: 0.12
Nodes (14): _border, build, city, coverPhotoUrl, _cream, CreateListingConfirmationPage, _dark, listingId (+6 more)

### Community 63 - "Default Flutter Icons (iOS)"
Cohesion: 0.12
Nodes (16): Flutter Logo App Icon 1024x1024@1x, Flutter Logo App Icon 20x20@1x, Flutter Logo App Icon 20x20@2x, Flutter Logo App Icon 20x20@3x, Flutter Logo App Icon 29x29@1x, Flutter Logo App Icon 29x29@2x, Flutter Logo App Icon 29x29@3x, Flutter Logo App Icon 40x40@1x (+8 more)

### Community 64 - "Reset Password Method"
Cohesion: 0.13
Nodes (12): build, createState, _goToVerifyCodeScreen, _isLoading, maskedEmail, maskedPhone, _onBack, _onSendCode (+4 more)

### Community 65 - "Verify Account Method"
Cohesion: 0.13
Nodes (13): build, createState, _goToVerifyCodeScreen, _isLoading, maskedEmail, maskedPhone, _onBack, _onSendCode (+5 more)

### Community 66 - "Listing & Availability Services"
Cohesion: 0.15
Nodes (7): AvailabilityService, fetchMonth, updateDates, createListing, fetchListingById, fetchListings, ListingService

### Community 67 - "Navigation Handlers"
Cohesion: 0.13
Nodes (14): _onContinue, _onContinue, _goToVerify, _openFullscreen, build, _buildListingsBody, build, build (+6 more)

### Community 68 - "Safety & Trust Screen"
Cohesion: 0.14
Nodes (12): build, createState, dispose, icon, iconColor, _issueController, onTap, _SafetyGuideItem (+4 more)

### Community 69 - "Desktop CMake Build"
Cohesion: 0.21
Nodes (15): Linux aairbnb Binary (com.example.aairbnb), APPLY_STANDARD_SETTINGS (Linux), Linux Install Bundle Step, flutter_assemble (Linux), flutter INTERFACE library (Linux GTK), list_prepend, Linux Runner Executable, Windows aairbnb Binary (+7 more)

### Community 70 - "Property Type Page"
Cohesion: 0.15
Nodes (11): build, CreateListingPropertyTypePage, _CreateListingPropertyTypePageState, createState, _dark, icon, label, _options (+3 more)

### Community 71 - "Become Host Page"
Cohesion: 0.15
Nodes (12): authToken, BecomeHostPage, _BecomeHostPageState, _benefitRow, build, createState, _dark, _error (+4 more)

### Community 72 - "Explore Filter Bar"
Cohesion: 0.15
Nodes (12): build, createState, ExploreFilterBar, _ExploreFilterBarState, ExploreFilterItem, icon, _items, label (+4 more)

### Community 73 - "Onboarding Screens"
Cohesion: 0.18
Nodes (6): AuthenticallyAlgerianScreen, build, build, OnboardingScreen, build, HostHospitalityScreen

### Community 74 - "Host Booking Details Page"
Cohesion: 0.15
Nodes (10): BookingDetailsPage, _border, build, _cream, _dark, date, listingId, _muted (+2 more)

### Community 75 - "Express Server Entry"
Cohesion: 0.15
Nodes (11): jsonwebtoken@^9.0.3, app, cors, dns, express, http, io, jwt (+3 more)

### Community 76 - "Host Tab Entry"
Cohesion: 0.17
Nodes (9): authToken, build, createState, _future, hostFirstName, HostTabEntry, _HostTabEntryState, initState (+1 more)

### Community 77 - "Windows Runner Entry"
Cohesion: 0.19
Nodes (4): wWinMain(), CreateAndAttachConsole(), GetCommandLineArguments(), Utf8FromUtf16()

### Community 78 - "OTP Method Selector"
Cohesion: 0.17
Nodes (12): build, createState, initialMethod, maskedEmail, maskedPhone, _methodCard, onSendCode, OtpMethod (+4 more)

### Community 79 - "Host Profile Page"
Cohesion: 0.15
Nodes (12): build, child, hostName, HostProfilePage, hostProfilePhotoUrl, hostSinceLabel, lines, _PlaceholderBlock (+4 more)

### Community 80 - "Explore Search Bar"
Cohesion: 0.17
Nodes (11): build, _controller, createState, dispose, ExploreSearchBar, _ExploreSearchBarState, initialLocation, initState (+3 more)

### Community 81 - "Listing Card Model"
Cohesion: 0.15
Nodes (12): city, coverPhotoUrl, currency, fromJson, id, isGuestFavorite, ListingModel, pricePerNight (+4 more)

### Community 82 - "How It Works Screen"
Cohesion: 0.15
Nodes (11): build, description, HowItWorksScreen, icon, iconColor, image, showWatchFilm, stepNumber (+3 more)

### Community 83 - "Hex Pattern Background"
Cohesion: 0.17
Nodes (8): build, child, CreateListingPatternBackground, _drawHexagon, _hexSize, _lineColor, paint, shouldRepaint

### Community 84 - "Amenity Model"
Cohesion: 0.17
Nodes (10): AmenityModel, catalogKey, category, description, fromJson, icon, iconFor, iconName (+2 more)

### Community 85 - "Host Service API"
Cohesion: 0.17
Nodes (9): becomeHost, deleteListing, fetchDashboard, fetchHostListings, fetchListingDetail, HostService, pauseListing, resumeListing (+1 more)

### Community 86 - "Privacy Policy Screen"
Cohesion: 0.17
Nodes (11): build, _CheckItem, _DataItem, description, icon, iconColor, PrivacyPolicyScreen, _RightItem (+3 more)

### Community 88 - "Terms of Service Screen"
Cohesion: 0.18
Nodes (8): _bodyStyle, build, _CheckItem, number, _SectionTitle, TermsOfServiceScreen, text, title

### Community 89 - "Listing Card Widget"
Cohesion: 0.20
Nodes (9): build, createState, initState, _isFavorite, listing, ListingCard, _ListingCardState, onFavoriteToggle (+1 more)

### Community 90 - "Web PWA Manifest"
Cohesion: 0.18
Nodes (10): background_color, description, display, icons, name, orientation, prefer_related_applications, short_name (+2 more)

### Community 91 - "Amenity Catalog Backend"
Cohesion: 0.20
Nodes (6): AMENITY_CATEGORIES, amenityCatalogSchema, mongoose, amenities, dns, mongoose

### Community 92 - "Mar7aban Welcome Screen"
Cohesion: 0.20
Nodes (8): build, _buildHeritageSection, _buildHero, _categoryCard, _onStartExploring, token, userName, WelcomeHomeScreen

### Community 93 - "Akrili App Bar"
Cohesion: 0.20
Nodes (6): AkriliAppBar, build, onBack, preferredSize, showBackButton, title

### Community 94 - "Reviews Page"
Cohesion: 0.20
Nodes (9): _bar, build, label, listingTitle, _PlaceholderBreakdownRow, _PlaceholderReviewCard, ratingOverall, reviewCount (+1 more)

### Community 95 - "Host Listing Summary Model"
Cohesion: 0.20
Nodes (9): city, coverPhotoUrl, currency, fromJson, id, pricePerNight, propertyType, status (+1 more)

### Community 97 - "Push Notifications & Message Routes"
Cohesion: 0.25
Nodes (5): { getApps }, { getMessaging }, sendPushNotification(), express, router

### Community 98 - "Create Listing Intro Page"
Cohesion: 0.22
Nodes (6): _accent, build, CreateListingIntroPage, _dark, _stepRow, _teal

### Community 99 - "Sign-In Progress Bar"
Cohesion: 0.22
Nodes (8): activeSegmentWidth, build, currentStep, inactiveSegmentWidth, segmentHeight, segmentSpacing, StepProgressIndicator, totalSteps

### Community 100 - "Host Section Widget"
Cohesion: 0.22
Nodes (8): build, hostName, hostProfilePhotoUrl, HostSection, hostSinceLabel, isChatLoading, onHostTap, onMessageTap

### Community 101 - "Host Dashboard Model"
Cohesion: 0.22
Nodes (8): activeListings, avgRating, fromJson, HostDashboardModel, totalBookings, totalEarnings, totalListings, totalViews

### Community 102 - "Amenity Catalog Service"
Cohesion: 0.22
Nodes (8): AmenityCatalogItem, AmenityCatalogService, amenityCategoryOrder, fetchCatalog, fromJson, iconName, key, name

### Community 103 - "Firebase Phone Auth"
Cohesion: 0.22
Nodes (5): _auth, FirebasePhoneAuthService, sendCode, _verificationId, verifyCode

### Community 104 - "Custom Dashed Painters"
Cohesion: 0.25
Nodes (7): _DashedPathPainter, _DashedRectPainter, _DashedRectPainter, _DashedRectPainter, _HexPatternPainter, _DashedBorderPainter, _DashedRRectPainter

### Community 105 - "Splash Screen"
Cohesion: 0.29
Nodes (5): build, createState, initState, SplashScreen, _SplashScreenState

### Community 107 - "Google Sign-In Screen"
Cohesion: 0.25
Nodes (3): build, GoogleSignInScreen, _onContinueWithGoogle

### Community 108 - "Stateful Screen Classes"
Cohesion: 0.25
Nodes (7): ChatScreen, _ChatScreenState, _FullscreenVideo, _FullscreenVideoState, _VideoThumbnail, _VideoThumbnailState, NotificationsScreen

### Community 109 - "Booking Bottom Bar"
Cohesion: 0.25
Nodes (6): BookingBottomBar, build, dateRangeLabel, formattedPrice, onBookNowTap, _teal

### Community 110 - "Host Listing Row"
Cohesion: 0.29
Nodes (5): build, HostListingRow, listing, onTap, HostListingSummaryModel

### Community 111 - "Dart Analyzer Config"
Cohesion: 0.33
Nodes (5): analyzer, exclude, include, linter, rules

### Community 112 - "Maghrebi Heritage Imagery"
Cohesion: 0.40
Nodes (6): incident.png - Safety First Banner, khayt.png - Stitched Leather Texture, Maghrebi Heritage Visual Aesthetic, marhaban.png - Moorish Courtyard Welcome Art, safehousing.png - Cozy Traditional Salon, w.png - Riad Doorway Through Shutters

### Community 113 - "Project Docs & Web Entry"
Cohesion: 0.40
Nodes (5): iOS Launch Screen Assets, aairbnb Flutter Project README, Flutter Framework, flutter_bootstrap.js loader, Flutter Web Entry Page (index.html)

### Community 114 - "Profile Dialog State"
Cohesion: 0.40
Nodes (4): CompleteProfileDialog, _CompleteProfileDialogState, _SavedPopupContent, _SavedPopupContentState

### Community 115 - "Landing App Bar"
Cohesion: 0.40
Nodes (3): build, LandingAppBar, profilePhotoUrl

### Community 117 - "Maghrebi Architecture Imagery"
Cohesion: 0.67
Nodes (4): authentically.png - Courtyard orange tree with zellige tiles (onboarding + How it works), Traditional Maghrebi architecture visual identity (arches, zellige, courtyards), courtyard.png - Ornate arched wooden door between orange trees (login courtyard screen), google.png - Ornate arched doorway background (Google sign-in screen)

### Community 118 - "Four-Point Star Brand"
Cohesion: 0.67
Nodes (4): Four-Point Star Brand Motif (gold/teal/brown), logo for main.png - Splash Logo (Four-Point Star), logo.png - App Icon Logo, phonenumber.png - Cream Background with Star Watermark

### Community 119 - "iOS Launch Images"
Cohesion: 0.50
Nodes (4): Blank Launch Image 1x, Blank Launch Image 2x, Blank Launch Image 3x, iOS Launch Image (blank placeholder)

### Community 122 - "Profile Illustration SVGs"
Cohesion: 0.67
Nodes (3): Background.svg - Home/Buildings Icon in Beige Circle Badge, Central_avatar+base.svg - Person Avatar in Peach Circle, floating_element_reprentingProfile.svg - ID Badge on Cyan Circle

### Community 123 - "Hospitality Interior Images"
Cohesion: 1.00
Nodes (3): authentic_stays.png - Traditional salon seating with tea set (used in create_listing_basics_page.dart), Authentic Algerian hospitality / traditional interiors, hospitality.png - Warm vaulted sitting room with arched window (onboarding hospitality screen)

## Knowledge Gaps
- **1585 isolated node(s):** `_identifierController`, `_passwordController`, `_obscurePassword`, `_isLoading`, `_identifierError` (+1580 more)
  These have ≤1 connection - possible missing edges or undocumented components. (Counts symbols only; 1912 node(s) total have ≤1 connection when file, concept and rationale nodes are included.)
- **29 thin communities (<3 nodes) omitted from report** — run `graphify query` to explore isolated nodes.

## Suggested Questions
_Questions this graph is uniquely positioned to answer:_

- **Why does `HostDashboardModel` connect `Host Dashboard Model` to `Host Dashboard Page`?**
  _High betweenness centrality (0.011) - this node is a cross-community bridge._
- **What connects `_identifierController`, `_passwordController`, `_obscurePassword` to the rest of the system?**
  _1585 weakly-connected nodes found - possible documentation gaps or missing edges._
- **Should `Edit Listing Details Page` be split into smaller, more focused modules?**
  _Cohesion score 0.02247191011235955 - nodes in this community are weakly interconnected._
- **Why does `ListingDraft` connect `Create Listing Basics Page` to `Create Listing Amenities Page`, `Listing Draft Model`, `Create Listing Location Page`, `Create Listing Review Page`?**
  _High betweenness centrality (0.006) - this node is a cross-community bridge._
- **Should `Chat Conversation Screen` be split into smaller, more focused modules?**
  _Cohesion score 0.030303030303030304 - nodes in this community are weakly interconnected._
- **Why does `HostListingDetailModel` connect `Manage Listing Page` to `Edit Listing Details Page`, `Listing Settings Page`, `Host Listing Detail Model`?**
  _High betweenness centrality (0.004) - this node is a cross-community bridge._
- **Should `Listing Draft Model` be split into smaller, more focused modules?**
  _Cohesion score 0.03636363636363636 - nodes in this community are weakly interconnected._