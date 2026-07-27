// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get newStampUnlocked => '🏆 New Stamp Unlocked!';

  @override
  String get gpsRequired =>
      'Enable GPS to earn stamps at historical landmarks.';

  @override
  String get tooFarFromLandmark =>
      'You must be within 500 m of this landmark to earn the stamp.';

  @override
  String get colosseumName => 'Colosseum';

  @override
  String get pyramidName => 'Pyramid of Cestius';

  @override
  String get pantheonName => 'Pantheon';

  @override
  String get feedEmpty =>
      'Global knowledge base is syncing...\nOr tap + to contribute a place.';

  @override
  String formatYearIntAD(int y) {
    return 'AD $y';
  }

  @override
  String formatYearIntBC(int y) {
    return '$y BC';
  }

  @override
  String get exploreRoutes => 'Explore Historic Routes';

  @override
  String get exploreRoutesSub =>
      'Follow the footprints of time on a narrative journey.';

  @override
  String get featuredRoutes => 'Featured Routes';

  @override
  String get communityRoutes => 'Community Routes';

  @override
  String get createRoute => 'Design & Publish a Route';

  @override
  String get createRouteSub =>
      'Pin waypoints on the map and share your historic trail.';

  @override
  String stopsCount(int n) {
    return '$n stops';
  }

  @override
  String get routeCreatorTitle => 'Route Creator';

  @override
  String get routeCreatorHint =>
      'Tap on the map to add waypoints and connect them into a route.';

  @override
  String get waypointCountLabel => 'Waypoints';

  @override
  String get cancel => 'Cancel';

  @override
  String get nextPublish => 'Next & Publish';

  @override
  String stopLabel(int n) {
    return 'Stop $n: ';
  }

  @override
  String progressLabel(int cur, int total) {
    return 'Progress: $cur / $total';
  }

  @override
  String get prevStepLabel => 'Previous';

  @override
  String get nextStepLabel => 'Next';

  @override
  String get addWaypointTitle => 'Add Waypoint';

  @override
  String get waypointNameHint => 'Waypoint Name (e.g. Acropolis)';

  @override
  String get waypointDescHint => 'Historical Description / Story';

  @override
  String get waypointNameRequired => 'Waypoint name is required.';

  @override
  String get add => 'Add';

  @override
  String get publishRouteTitle => 'Publish Route';

  @override
  String get routeNameHint => 'Route Name (e.g. Silk Road)';

  @override
  String get routeDescHint => 'Route Description';

  @override
  String get chooseColor => 'Choose Route Color:';

  @override
  String get routeNameRequired => 'Route name is required.';

  @override
  String get back => 'Back';

  @override
  String get publishToCloud => 'Publish to Cloud';

  @override
  String get publishSuccess => '🎉 Route published to the cloud!';

  @override
  String publishFail(String e) {
    return 'Publish failed: $e';
  }

  @override
  String get passportTitle => 'Cultural Passport';

  @override
  String get passportSubtitle => 'PASSPORT OF TIME & CULTURE';

  @override
  String get stampsCollected => 'Stamps Collected';

  @override
  String get navTurnLeft => 'Turn left';

  @override
  String get navTurnRight => 'Turn right';

  @override
  String get navSlightLeft => 'Slight left';

  @override
  String get navSlightRight => 'Slight right';

  @override
  String get navSharpLeft => 'Sharp left';

  @override
  String get navSharpRight => 'Sharp right';

  @override
  String get navStart => 'Start';

  @override
  String get navArrive => 'Arrive at destination';

  @override
  String get navContinue => 'Continue straight';

  @override
  String get navRoundabout => 'Enter roundabout';

  @override
  String get navRotary => 'Enter rotary';

  @override
  String get navMerge => 'Merge';

  @override
  String get navFork => 'Take fork';

  @override
  String get navContinueForward => 'Continue';

  @override
  String get navWalking => 'Walking';

  @override
  String get navCycling => 'Cycling';

  @override
  String get navDriving => 'Driving';

  @override
  String navStarting(String mode, String dest, String dist, String time) {
    return 'Starting $mode navigation to $dest, distance $dist, estimated time $time';
  }

  @override
  String navArrived(String dest) {
    return 'You have arrived at $dest';
  }

  @override
  String navInMeters(int meters, String instruction) {
    return 'In $meters meters, $instruction';
  }

  @override
  String navDistance(String instruction, String dist) {
    return '$instruction, distance $dist';
  }

  @override
  String get navVoiceEnabled => 'Voice guidance enabled';

  @override
  String navSwitchedMode(String mode) {
    return 'Switched to $mode mode';
  }

  @override
  String get navRemaining => 'Remaining';

  @override
  String get navEstimatedTime => 'Estimated Time';

  @override
  String get eraRange => 'Era Range';

  @override
  String get collectedStampsSection => 'Collected Stamps';

  @override
  String get colosseumLabel => 'Colosseum';

  @override
  String get pyramidLabel => 'Pyramid of Cestius';

  @override
  String get pantheonLabel => 'Pantheon';

  @override
  String get letterFromPast => 'Letter from the Past';

  @override
  String get chronicler => 'Chronicler';

  @override
  String get profileTitle => 'Profile';

  @override
  String get loginRegister => 'Sign In / Register';

  @override
  String get logout => 'Log Out';

  @override
  String get guestExplorer => 'Guest Explorer';

  @override
  String get exploreTab => 'Explore';

  @override
  String get mapTab => 'Map';

  @override
  String get meTab => 'Me';

  @override
  String get communityLedger => 'Community Database Ledger';

  @override
  String get savedPlaces => 'Saved Places';

  @override
  String get systemSettings => 'System Settings';

  @override
  String get switchLanguage => 'Switch Language';

  @override
  String get mapTheme => 'Map Theme';

  @override
  String get explorerSignIn => 'Explorer Sign In';

  @override
  String get email => 'Email';

  @override
  String get password => 'Password';

  @override
  String get newExplorer => 'New explorer? Create account';

  @override
  String get createAccount => 'Create Account';

  @override
  String get existingExplorer => 'Already have an account? Sign In';
}
