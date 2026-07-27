import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_zh.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
      : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('zh')
  ];

  /// No description provided for @newStampUnlocked.
  ///
  /// In en, this message translates to:
  /// **'🏆 New Stamp Unlocked!'**
  String get newStampUnlocked;

  /// No description provided for @gpsRequired.
  ///
  /// In en, this message translates to:
  /// **'Enable GPS to earn stamps at historical landmarks.'**
  String get gpsRequired;

  /// No description provided for @tooFarFromLandmark.
  ///
  /// In en, this message translates to:
  /// **'You must be within 500 m of this landmark to earn the stamp.'**
  String get tooFarFromLandmark;

  /// No description provided for @colosseumName.
  ///
  /// In en, this message translates to:
  /// **'Colosseum'**
  String get colosseumName;

  /// No description provided for @pyramidName.
  ///
  /// In en, this message translates to:
  /// **'Pyramid of Cestius'**
  String get pyramidName;

  /// No description provided for @pantheonName.
  ///
  /// In en, this message translates to:
  /// **'Pantheon'**
  String get pantheonName;

  /// No description provided for @feedEmpty.
  ///
  /// In en, this message translates to:
  /// **'Global knowledge base is syncing...\nOr tap + to contribute a place.'**
  String get feedEmpty;

  /// No description provided for @formatYearIntAD.
  ///
  /// In en, this message translates to:
  /// **'AD {y}'**
  String formatYearIntAD(int y);

  /// No description provided for @formatYearIntBC.
  ///
  /// In en, this message translates to:
  /// **'{y} BC'**
  String formatYearIntBC(int y);

  /// No description provided for @exploreRoutes.
  ///
  /// In en, this message translates to:
  /// **'Explore Historic Routes'**
  String get exploreRoutes;

  /// No description provided for @exploreRoutesSub.
  ///
  /// In en, this message translates to:
  /// **'Follow the footprints of time on a narrative journey.'**
  String get exploreRoutesSub;

  /// No description provided for @featuredRoutes.
  ///
  /// In en, this message translates to:
  /// **'Featured Routes'**
  String get featuredRoutes;

  /// No description provided for @communityRoutes.
  ///
  /// In en, this message translates to:
  /// **'Community Routes'**
  String get communityRoutes;

  /// No description provided for @createRoute.
  ///
  /// In en, this message translates to:
  /// **'Design & Publish a Route'**
  String get createRoute;

  /// No description provided for @createRouteSub.
  ///
  /// In en, this message translates to:
  /// **'Pin waypoints on the map and share your historic trail.'**
  String get createRouteSub;

  /// No description provided for @stopsCount.
  ///
  /// In en, this message translates to:
  /// **'{n} stops'**
  String stopsCount(int n);

  /// No description provided for @routeCreatorTitle.
  ///
  /// In en, this message translates to:
  /// **'Route Creator'**
  String get routeCreatorTitle;

  /// No description provided for @routeCreatorHint.
  ///
  /// In en, this message translates to:
  /// **'Tap on the map to add waypoints and connect them into a route.'**
  String get routeCreatorHint;

  /// No description provided for @waypointCountLabel.
  ///
  /// In en, this message translates to:
  /// **'Waypoints'**
  String get waypointCountLabel;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @nextPublish.
  ///
  /// In en, this message translates to:
  /// **'Next & Publish'**
  String get nextPublish;

  /// No description provided for @stopLabel.
  ///
  /// In en, this message translates to:
  /// **'Stop {n}: '**
  String stopLabel(int n);

  /// No description provided for @progressLabel.
  ///
  /// In en, this message translates to:
  /// **'Progress: {cur} / {total}'**
  String progressLabel(int cur, int total);

  /// No description provided for @prevStepLabel.
  ///
  /// In en, this message translates to:
  /// **'Previous'**
  String get prevStepLabel;

  /// No description provided for @nextStepLabel.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get nextStepLabel;

  /// No description provided for @addWaypointTitle.
  ///
  /// In en, this message translates to:
  /// **'Add Waypoint'**
  String get addWaypointTitle;

  /// No description provided for @waypointNameHint.
  ///
  /// In en, this message translates to:
  /// **'Waypoint Name (e.g. Acropolis)'**
  String get waypointNameHint;

  /// No description provided for @waypointDescHint.
  ///
  /// In en, this message translates to:
  /// **'Historical Description / Story'**
  String get waypointDescHint;

  /// No description provided for @waypointNameRequired.
  ///
  /// In en, this message translates to:
  /// **'Waypoint name is required.'**
  String get waypointNameRequired;

  /// No description provided for @add.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get add;

  /// No description provided for @publishRouteTitle.
  ///
  /// In en, this message translates to:
  /// **'Publish Route'**
  String get publishRouteTitle;

  /// No description provided for @routeNameHint.
  ///
  /// In en, this message translates to:
  /// **'Route Name (e.g. Silk Road)'**
  String get routeNameHint;

  /// No description provided for @routeDescHint.
  ///
  /// In en, this message translates to:
  /// **'Route Description'**
  String get routeDescHint;

  /// No description provided for @chooseColor.
  ///
  /// In en, this message translates to:
  /// **'Choose Route Color:'**
  String get chooseColor;

  /// No description provided for @routeNameRequired.
  ///
  /// In en, this message translates to:
  /// **'Route name is required.'**
  String get routeNameRequired;

  /// No description provided for @back.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get back;

  /// No description provided for @publishToCloud.
  ///
  /// In en, this message translates to:
  /// **'Publish to Cloud'**
  String get publishToCloud;

  /// No description provided for @publishSuccess.
  ///
  /// In en, this message translates to:
  /// **'🎉 Route published to the cloud!'**
  String get publishSuccess;

  /// No description provided for @publishFail.
  ///
  /// In en, this message translates to:
  /// **'Publish failed: {e}'**
  String publishFail(String e);

  /// No description provided for @passportTitle.
  ///
  /// In en, this message translates to:
  /// **'Cultural Passport'**
  String get passportTitle;

  /// No description provided for @passportSubtitle.
  ///
  /// In en, this message translates to:
  /// **'PASSPORT OF TIME & CULTURE'**
  String get passportSubtitle;

  /// No description provided for @stampsCollected.
  ///
  /// In en, this message translates to:
  /// **'Stamps Collected'**
  String get stampsCollected;

  /// No description provided for @navTurnLeft.
  ///
  /// In en, this message translates to:
  /// **'Turn left'**
  String get navTurnLeft;

  /// No description provided for @navTurnRight.
  ///
  /// In en, this message translates to:
  /// **'Turn right'**
  String get navTurnRight;

  /// No description provided for @navSlightLeft.
  ///
  /// In en, this message translates to:
  /// **'Slight left'**
  String get navSlightLeft;

  /// No description provided for @navSlightRight.
  ///
  /// In en, this message translates to:
  /// **'Slight right'**
  String get navSlightRight;

  /// No description provided for @navSharpLeft.
  ///
  /// In en, this message translates to:
  /// **'Sharp left'**
  String get navSharpLeft;

  /// No description provided for @navSharpRight.
  ///
  /// In en, this message translates to:
  /// **'Sharp right'**
  String get navSharpRight;

  /// No description provided for @navStart.
  ///
  /// In en, this message translates to:
  /// **'Start'**
  String get navStart;

  /// No description provided for @navArrive.
  ///
  /// In en, this message translates to:
  /// **'Arrive at destination'**
  String get navArrive;

  /// No description provided for @navContinue.
  ///
  /// In en, this message translates to:
  /// **'Continue straight'**
  String get navContinue;

  /// No description provided for @navRoundabout.
  ///
  /// In en, this message translates to:
  /// **'Enter roundabout'**
  String get navRoundabout;

  /// No description provided for @navRotary.
  ///
  /// In en, this message translates to:
  /// **'Enter rotary'**
  String get navRotary;

  /// No description provided for @navMerge.
  ///
  /// In en, this message translates to:
  /// **'Merge'**
  String get navMerge;

  /// No description provided for @navFork.
  ///
  /// In en, this message translates to:
  /// **'Take fork'**
  String get navFork;

  /// No description provided for @navContinueForward.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get navContinueForward;

  /// No description provided for @navWalking.
  ///
  /// In en, this message translates to:
  /// **'Walking'**
  String get navWalking;

  /// No description provided for @navCycling.
  ///
  /// In en, this message translates to:
  /// **'Cycling'**
  String get navCycling;

  /// No description provided for @navDriving.
  ///
  /// In en, this message translates to:
  /// **'Driving'**
  String get navDriving;

  /// No description provided for @navStarting.
  ///
  /// In en, this message translates to:
  /// **'Starting {mode} navigation to {dest}, distance {dist}, estimated time {time}'**
  String navStarting(String mode, String dest, String dist, String time);

  /// No description provided for @navArrived.
  ///
  /// In en, this message translates to:
  /// **'You have arrived at {dest}'**
  String navArrived(String dest);

  /// No description provided for @navInMeters.
  ///
  /// In en, this message translates to:
  /// **'In {meters} meters, {instruction}'**
  String navInMeters(int meters, String instruction);

  /// No description provided for @navDistance.
  ///
  /// In en, this message translates to:
  /// **'{instruction}, distance {dist}'**
  String navDistance(String instruction, String dist);

  /// No description provided for @navVoiceEnabled.
  ///
  /// In en, this message translates to:
  /// **'Voice guidance enabled'**
  String get navVoiceEnabled;

  /// No description provided for @navSwitchedMode.
  ///
  /// In en, this message translates to:
  /// **'Switched to {mode} mode'**
  String navSwitchedMode(String mode);

  /// No description provided for @navRemaining.
  ///
  /// In en, this message translates to:
  /// **'Remaining'**
  String get navRemaining;

  /// No description provided for @navEstimatedTime.
  ///
  /// In en, this message translates to:
  /// **'Estimated Time'**
  String get navEstimatedTime;

  /// No description provided for @eraRange.
  ///
  /// In en, this message translates to:
  /// **'Era Range'**
  String get eraRange;

  /// No description provided for @collectedStampsSection.
  ///
  /// In en, this message translates to:
  /// **'Collected Stamps'**
  String get collectedStampsSection;

  /// No description provided for @colosseumLabel.
  ///
  /// In en, this message translates to:
  /// **'Colosseum'**
  String get colosseumLabel;

  /// No description provided for @pyramidLabel.
  ///
  /// In en, this message translates to:
  /// **'Pyramid of Cestius'**
  String get pyramidLabel;

  /// No description provided for @pantheonLabel.
  ///
  /// In en, this message translates to:
  /// **'Pantheon'**
  String get pantheonLabel;

  /// No description provided for @letterFromPast.
  ///
  /// In en, this message translates to:
  /// **'Letter from the Past'**
  String get letterFromPast;

  /// No description provided for @chronicler.
  ///
  /// In en, this message translates to:
  /// **'Chronicler'**
  String get chronicler;

  /// No description provided for @profileTitle.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profileTitle;

  /// No description provided for @loginRegister.
  ///
  /// In en, this message translates to:
  /// **'Sign In / Register'**
  String get loginRegister;

  /// No description provided for @logout.
  ///
  /// In en, this message translates to:
  /// **'Log Out'**
  String get logout;

  /// No description provided for @guestExplorer.
  ///
  /// In en, this message translates to:
  /// **'Guest Explorer'**
  String get guestExplorer;

  /// No description provided for @exploreTab.
  ///
  /// In en, this message translates to:
  /// **'Explore'**
  String get exploreTab;

  /// No description provided for @mapTab.
  ///
  /// In en, this message translates to:
  /// **'Map'**
  String get mapTab;

  /// No description provided for @meTab.
  ///
  /// In en, this message translates to:
  /// **'Me'**
  String get meTab;

  /// No description provided for @communityLedger.
  ///
  /// In en, this message translates to:
  /// **'Community Database Ledger'**
  String get communityLedger;

  /// No description provided for @savedPlaces.
  ///
  /// In en, this message translates to:
  /// **'Saved Places'**
  String get savedPlaces;

  /// No description provided for @systemSettings.
  ///
  /// In en, this message translates to:
  /// **'System Settings'**
  String get systemSettings;

  /// No description provided for @switchLanguage.
  ///
  /// In en, this message translates to:
  /// **'Switch Language'**
  String get switchLanguage;

  /// No description provided for @mapTheme.
  ///
  /// In en, this message translates to:
  /// **'Map Theme'**
  String get mapTheme;

  /// No description provided for @explorerSignIn.
  ///
  /// In en, this message translates to:
  /// **'Explorer Sign In'**
  String get explorerSignIn;

  /// No description provided for @email.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get email;

  /// No description provided for @password.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get password;

  /// No description provided for @newExplorer.
  ///
  /// In en, this message translates to:
  /// **'New explorer? Create account'**
  String get newExplorer;

  /// No description provided for @createAccount.
  ///
  /// In en, this message translates to:
  /// **'Create Account'**
  String get createAccount;

  /// No description provided for @existingExplorer.
  ///
  /// In en, this message translates to:
  /// **'Already have an account? Sign In'**
  String get existingExplorer;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'zh'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'zh':
      return AppLocalizationsZh();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
