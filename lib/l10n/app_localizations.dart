import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_en.dart';

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
  AppLocalizations(String locale) : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();

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
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates = <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('ar'),
    Locale('en')
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'Mohtm'**
  String get appTitle;

  /// No description provided for @login.
  ///
  /// In en, this message translates to:
  /// **'Login'**
  String get login;

  /// No description provided for @logout.
  ///
  /// In en, this message translates to:
  /// **'Logout'**
  String get logout;

  /// No description provided for @welcome.
  ///
  /// In en, this message translates to:
  /// **'Welcome'**
  String get welcome;

  /// No description provided for @noAnniversariesToday.
  ///
  /// In en, this message translates to:
  /// **'No saved occasions for today ,\n  you can add a new one'**
  String get noAnniversariesToday;

  /// No description provided for @title.
  ///
  /// In en, this message translates to:
  /// **'mohtm'**
  String get title;

  /// No description provided for @mohtmMenu.
  ///
  /// In en, this message translates to:
  /// **'Mohtm Menu'**
  String get mohtmMenu;

  /// No description provided for @rateUs.
  ///
  /// In en, this message translates to:
  /// **'Rate us'**
  String get rateUs;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @shareApp.
  ///
  /// In en, this message translates to:
  /// **'Share app'**
  String get shareApp;

  /// No description provided for @changePassword.
  ///
  /// In en, this message translates to:
  /// **'Change password'**
  String get changePassword;

  /// No description provided for @typeLabel.
  ///
  /// In en, this message translates to:
  /// **'Type: {type}'**
  String typeLabel(Object type);

  /// No description provided for @startDate.
  ///
  /// In en, this message translates to:
  /// **'Start Date'**
  String get startDate;

  /// No description provided for @endDate.
  ///
  /// In en, this message translates to:
  /// **'End Date'**
  String get endDate;

  /// No description provided for @filter.
  ///
  /// In en, this message translates to:
  /// **'Filter'**
  String get filter;

  /// No description provided for @clearFilter.
  ///
  /// In en, this message translates to:
  /// **'Clear filter'**
  String get clearFilter;

  /// No description provided for @noAnniversariesFound.
  ///
  /// In en, this message translates to:
  /// **'No occasions found'**
  String get noAnniversariesFound;

  /// No description provided for @profileUpdatedsuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Profile updated successfully'**
  String get profileUpdatedsuccessfully;

  /// No description provided for @profileUpdateFailed.
  ///
  /// In en, this message translates to:
  /// **'Profile update failed'**
  String get profileUpdateFailed;

  /// No description provided for @profile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profile;

  /// No description provided for @firstName.
  ///
  /// In en, this message translates to:
  /// **'First name'**
  String get firstName;

  /// No description provided for @lastName.
  ///
  /// In en, this message translates to:
  /// **'Last name'**
  String get lastName;

  /// No description provided for @email.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get email;

  /// No description provided for @phone.
  ///
  /// In en, this message translates to:
  /// **'Phone Number'**
  String get phone;

  /// No description provided for @birthdate.
  ///
  /// In en, this message translates to:
  /// **'Birthdate'**
  String get birthdate;

  /// No description provided for @gender.
  ///
  /// In en, this message translates to:
  /// **'gender'**
  String get gender;

  /// No description provided for @forgetPassword.
  ///
  /// In en, this message translates to:
  /// **'Forget password'**
  String get forgetPassword;

  /// No description provided for @pleaseEntervalidEmail.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid email'**
  String get pleaseEntervalidEmail;

  /// No description provided for @restPassword.
  ///
  /// In en, this message translates to:
  /// **'Reset password'**
  String get restPassword;

  /// No description provided for @changePasswordSuccessMessage.
  ///
  /// In en, this message translates to:
  /// **'Password changed successfully'**
  String get changePasswordSuccessMessage;

  /// No description provided for @changePasswordErrorMessage.
  ///
  /// In en, this message translates to:
  /// **'Error changing password'**
  String get changePasswordErrorMessage;

  /// No description provided for @changePasswordTitle.
  ///
  /// In en, this message translates to:
  /// **'Change password'**
  String get changePasswordTitle;

  /// No description provided for @currentPassword.
  ///
  /// In en, this message translates to:
  /// **'Current password'**
  String get currentPassword;

  /// No description provided for @newPassword.
  ///
  /// In en, this message translates to:
  /// **'New password'**
  String get newPassword;

  /// No description provided for @confirmNewPassword.
  ///
  /// In en, this message translates to:
  /// **'Confirm new password'**
  String get confirmNewPassword;

  /// No description provided for @entercurrentPassword.
  ///
  /// In en, this message translates to:
  /// **'Please enter current password'**
  String get entercurrentPassword;

  /// No description provided for @enterNewPassword.
  ///
  /// In en, this message translates to:
  /// **'Please enter new password'**
  String get enterNewPassword;

  /// No description provided for @passwordLengthValidation.
  ///
  /// In en, this message translates to:
  /// **'New password must be at least 6 characters'**
  String get passwordLengthValidation;

  /// No description provided for @passwordMatchValidation.
  ///
  /// In en, this message translates to:
  /// **'New password and confirm new password must match'**
  String get passwordMatchValidation;

  /// No description provided for @enterConfirmNewPassword.
  ///
  /// In en, this message translates to:
  /// **'Please enter confirm new password'**
  String get enterConfirmNewPassword;

  /// No description provided for @passwordsDoNotMatch.
  ///
  /// In en, this message translates to:
  /// **'New password and confirm new password do not match'**
  String get passwordsDoNotMatch;

  /// No description provided for @passwordChangedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Password changed successfully'**
  String get passwordChangedSuccessfully;

  /// No description provided for @changePasswordButtonText.
  ///
  /// In en, this message translates to:
  /// **'Change password'**
  String get changePasswordButtonText;

  /// No description provided for @description.
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get description;

  /// No description provided for @date.
  ///
  /// In en, this message translates to:
  /// **'Date'**
  String get date;

  /// No description provided for @type.
  ///
  /// In en, this message translates to:
  /// **'Type'**
  String get type;

  /// No description provided for @relationship.
  ///
  /// In en, this message translates to:
  /// **'Relationship'**
  String get relationship;

  /// No description provided for @priority.
  ///
  /// In en, this message translates to:
  /// **'Priority'**
  String get priority;

  /// No description provided for @rememberBefore.
  ///
  /// In en, this message translates to:
  /// **'Remember before '**
  String get rememberBefore;

  /// No description provided for @atTimeOfEvent.
  ///
  /// In en, this message translates to:
  /// **'At time of event'**
  String get atTimeOfEvent;

  /// No description provided for @anntitle.
  ///
  /// In en, this message translates to:
  /// **'occasion title'**
  String get anntitle;

  /// No description provided for @deleteAnniversary.
  ///
  /// In en, this message translates to:
  /// **'Delete occasion'**
  String get deleteAnniversary;

  /// No description provided for @deleteAnniversaryConfirmation.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this occasion?'**
  String get deleteAnniversaryConfirmation;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @addAnniversaryTitle.
  ///
  /// In en, this message translates to:
  /// **'Add new occasion'**
  String get addAnniversaryTitle;

  /// No description provided for @selectDateLabel.
  ///
  /// In en, this message translates to:
  /// **'date of occasion ,ex:birthday 01-04-1990'**
  String get selectDateLabel;

  /// No description provided for @anniversaryNameLabel.
  ///
  /// In en, this message translates to:
  /// **'occasion name'**
  String get anniversaryNameLabel;

  /// No description provided for @anniversaryNameHint.
  ///
  /// In en, this message translates to:
  /// **'Enter occasion name'**
  String get anniversaryNameHint;

  /// No description provided for @anniversaryNameValidation.
  ///
  /// In en, this message translates to:
  /// **'Please enter occasion name'**
  String get anniversaryNameValidation;

  /// No description provided for @anniversaryDescriptionLabel.
  ///
  /// In en, this message translates to:
  /// **'occasion description'**
  String get anniversaryDescriptionLabel;

  /// No description provided for @anniversaryDescriptionHint.
  ///
  /// In en, this message translates to:
  /// **'Enter occasion description'**
  String get anniversaryDescriptionHint;

  /// No description provided for @anniversarytypeValidation.
  ///
  /// In en, this message translates to:
  /// **'Please select occasion type'**
  String get anniversarytypeValidation;

  /// No description provided for @specifyType.
  ///
  /// In en, this message translates to:
  /// **'Specify type'**
  String get specifyType;

  /// No description provided for @anniversaryOtherTypeValidation.
  ///
  /// In en, this message translates to:
  /// **'Please specify occasion type'**
  String get anniversaryOtherTypeValidation;

  /// No description provided for @relationshipHint.
  ///
  /// In en, this message translates to:
  /// **'Enter relationship'**
  String get relationshipHint;

  /// No description provided for @priorityValidation.
  ///
  /// In en, this message translates to:
  /// **'Please select priority'**
  String get priorityValidation;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @loginToMohtm.
  ///
  /// In en, this message translates to:
  /// **'MOHTM'**
  String get loginToMohtm;

  /// No description provided for @password.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get password;

  /// No description provided for @forgetPasswordquestion.
  ///
  /// In en, this message translates to:
  /// **'Forgot your password?'**
  String get forgetPasswordquestion;

  /// No description provided for @donthaveAnAccount.
  ///
  /// In en, this message translates to:
  /// **'Don\'t have an account?'**
  String get donthaveAnAccount;

  /// No description provided for @userNotFound.
  ///
  /// In en, this message translates to:
  /// **'email or password is incorrect'**
  String get userNotFound;

  /// No description provided for @errorOccurred.
  ///
  /// In en, this message translates to:
  /// **'An error occurred'**
  String get errorOccurred;

  /// No description provided for @register.
  ///
  /// In en, this message translates to:
  /// **'Register'**
  String get register;

  /// No description provided for @registerTitle.
  ///
  /// In en, this message translates to:
  /// **'Register'**
  String get registerTitle;

  /// No description provided for @firstNamevalidation.
  ///
  /// In en, this message translates to:
  /// **'Please enter first name'**
  String get firstNamevalidation;

  /// No description provided for @lastNamevalidation.
  ///
  /// In en, this message translates to:
  /// **'Please enter last name'**
  String get lastNamevalidation;

  /// No description provided for @emailValidation.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid email'**
  String get emailValidation;

  /// No description provided for @phoneValidation.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid phone number'**
  String get phoneValidation;

  /// No description provided for @passwordValidation.
  ///
  /// In en, this message translates to:
  /// **'Please enter a password'**
  String get passwordValidation;

  /// No description provided for @confirmPassword.
  ///
  /// In en, this message translates to:
  /// **'Confirm password'**
  String get confirmPassword;

  /// No description provided for @pleaseConfirmPassword.
  ///
  /// In en, this message translates to:
  /// **'Please confirm your password'**
  String get pleaseConfirmPassword;

  /// No description provided for @registerSuccessMessage.
  ///
  /// In en, this message translates to:
  /// **'Registration successful'**
  String get registerSuccessMessage;

  /// No description provided for @registerErrorMessage.
  ///
  /// In en, this message translates to:
  /// **'Registration failed'**
  String get registerErrorMessage;

  /// No description provided for @registerSuccessMessageWithVerification.
  ///
  /// In en, this message translates to:
  /// **'Registration successful! Please check your email (and Spam / Junk Folder) to verify your account before logging in.'**
  String get registerSuccessMessageWithVerification;

  /// No description provided for @emailNotVerifiedMessage.
  ///
  /// In en, this message translates to:
  /// **'Your email is not verified. Please check your inbox (and Spam / Junk Folder) and verify your email before logging in.'**
  String get emailNotVerifiedMessage;

  /// No description provided for @soticalUseNotFound.
  ///
  /// In en, this message translates to:
  /// **' user not found, please register first'**
  String get soticalUseNotFound;

  /// No description provided for @signinwithGoogle.
  ///
  /// In en, this message translates to:
  /// **'Sign in with Google'**
  String get signinwithGoogle;

  /// No description provided for @signinwithFacebook.
  ///
  /// In en, this message translates to:
  /// **'Sign in with Facebook'**
  String get signinwithFacebook;

  /// No description provided for @sigupWithGoogle.
  ///
  /// In en, this message translates to:
  /// **'Sign up with Google'**
  String get sigupWithGoogle;

  /// No description provided for @sigupWithFacebook.
  ///
  /// In en, this message translates to:
  /// **'Sign up with Facebook'**
  String get sigupWithFacebook;

  /// No description provided for @rememberme.
  ///
  /// In en, this message translates to:
  /// **'Remember me'**
  String get rememberme;

  /// No description provided for @feedbackrequiredFields.
  ///
  /// In en, this message translates to:
  /// **'title and comment are required.'**
  String get feedbackrequiredFields;

  /// No description provided for @commentTooLong.
  ///
  /// In en, this message translates to:
  /// **'Comment is too long. Please shorten it to 1000 characters or less.'**
  String get commentTooLong;

  /// No description provided for @feedbackSent.
  ///
  /// In en, this message translates to:
  /// **'Feedback sent successfully'**
  String get feedbackSent;

  /// No description provided for @feedbackError.
  ///
  /// In en, this message translates to:
  /// **'Error sending feedback'**
  String get feedbackError;

  /// No description provided for @feedbackTitle.
  ///
  /// In en, this message translates to:
  /// **'Contact Us'**
  String get feedbackTitle;

  /// No description provided for @subject.
  ///
  /// In en, this message translates to:
  /// **'Subject'**
  String get subject;

  /// No description provided for @body.
  ///
  /// In en, this message translates to:
  /// **'Body'**
  String get body;

  /// No description provided for @send.
  ///
  /// In en, this message translates to:
  /// **'Send'**
  String get send;

  /// No description provided for @contactUs.
  ///
  /// In en, this message translates to:
  /// **'Contact Us'**
  String get contactUs;

  /// No description provided for @passwordResetSent.
  ///
  /// In en, this message translates to:
  /// **'Password reset email sent to {email}. Please check your inbox (and Spam / Junk Folder).'**
  String passwordResetSent(Object email);

  /// No description provided for @emailNotFound.
  ///
  /// In en, this message translates to:
  /// **'Email not found'**
  String get emailNotFound;

  /// No description provided for @errorSendRestmail.
  ///
  /// In en, this message translates to:
  /// **'Error sending reset email: {errorMessage}'**
  String errorSendRestmail(Object errorMessage);

  /// No description provided for @unexpectedErrorOccurred.
  ///
  /// In en, this message translates to:
  /// **'An unexpected error occurred.'**
  String get unexpectedErrorOccurred;

  /// No description provided for @pleaseInterValidInputs.
  ///
  /// In en, this message translates to:
  /// **'Please enter valid inputs.'**
  String get pleaseInterValidInputs;

  /// No description provided for @userNotLogin.
  ///
  /// In en, this message translates to:
  /// **'User not logged in'**
  String get userNotLogin;

  /// No description provided for @annAddSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'occasion added successfully'**
  String get annAddSuccessfully;

  /// No description provided for @failtoAddAnniversary.
  ///
  /// In en, this message translates to:
  /// **'Failed to add occasion, please try again later'**
  String get failtoAddAnniversary;

  /// No description provided for @dateValidation.
  ///
  /// In en, this message translates to:
  /// **'Please select a date.'**
  String get dateValidation;

  /// No description provided for @annUpdateSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'occasion updated successfully'**
  String get annUpdateSuccessfully;

  /// No description provided for @failtoUpdateAnniversary.
  ///
  /// In en, this message translates to:
  /// **'Failed to update occasion, please try again later'**
  String get failtoUpdateAnniversary;

  /// No description provided for @oldPasswordIncorrect.
  ///
  /// In en, this message translates to:
  /// **'Old password is incorrect. Please try again.'**
  String get oldPasswordIncorrect;

  /// No description provided for @occasionDetails.
  ///
  /// In en, this message translates to:
  /// **'occasion Details'**
  String get occasionDetails;

  /// No description provided for @reminders.
  ///
  /// In en, this message translates to:
  /// **'Reminders'**
  String get reminders;

  /// No description provided for @exactAlarmPermissionTitle.
  ///
  /// In en, this message translates to:
  /// **'Exact Alarm Permission Needed'**
  String get exactAlarmPermissionTitle;

  /// No description provided for @exactAlarmPermissionMessage.
  ///
  /// In en, this message translates to:
  /// **'To ensure reminders work reliably, make sure to  allow \"Schedule exact alarms\" permission in system settings.'**
  String get exactAlarmPermissionMessage;

  /// No description provided for @open_sertings.
  ///
  /// In en, this message translates to:
  /// **'Open Settings'**
  String get open_sertings;

  /// No description provided for @noReminders.
  ///
  /// In en, this message translates to:
  /// **'No reminders found.'**
  String get noReminders;

  /// No description provided for @repeat.
  ///
  /// In en, this message translates to:
  /// **'Repeat'**
  String get repeat;

  /// No description provided for @addReminder.
  ///
  /// In en, this message translates to:
  /// **'Add Reminder'**
  String get addReminder;

  /// No description provided for @fixNotificationsPermission.
  ///
  /// In en, this message translates to:
  /// **'Fix Notification Permission'**
  String get fixNotificationsPermission;

  /// No description provided for @reminderTitle.
  ///
  /// In en, this message translates to:
  /// **' Reminder Title'**
  String get reminderTitle;

  /// No description provided for @reminderTitleRequired.
  ///
  /// In en, this message translates to:
  /// **'Reminder title is required'**
  String get reminderTitleRequired;

  /// No description provided for @reminderTitleTooLong.
  ///
  /// In en, this message translates to:
  /// **'Reminder title must be at most 100 characters'**
  String get reminderTitleTooLong;

  /// No description provided for @selecydatetime.
  ///
  /// In en, this message translates to:
  /// **'Select date & time'**
  String get selecydatetime;

  /// No description provided for @saveReminder.
  ///
  /// In en, this message translates to:
  /// **'Save Reminder'**
  String get saveReminder;

  /// No description provided for @duration.
  ///
  /// In en, this message translates to:
  /// **'Duration'**
  String get duration;

  /// No description provided for @forever.
  ///
  /// In en, this message translates to:
  /// **'Forever'**
  String get forever;

  /// No description provided for @count.
  ///
  /// In en, this message translates to:
  /// **'Specific number of times'**
  String get count;

  /// No description provided for @untilDate.
  ///
  /// In en, this message translates to:
  /// **'Until a date'**
  String get untilDate;

  /// No description provided for @repeatCount.
  ///
  /// In en, this message translates to:
  /// **'Number of times'**
  String get repeatCount;

  /// No description provided for @repeatCountRequired.
  ///
  /// In en, this message translates to:
  /// **'Number of times is required'**
  String get repeatCountRequired;

  /// No description provided for @repeatCountvalidation.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid number'**
  String get repeatCountvalidation;

  /// No description provided for @untilDate2.
  ///
  /// In en, this message translates to:
  /// **'Until date'**
  String get untilDate2;

  /// No description provided for @notSet.
  ///
  /// In en, this message translates to:
  /// **'Not set'**
  String get notSet;

  /// No description provided for @unit_minute.
  ///
  /// In en, this message translates to:
  /// **'minute'**
  String get unit_minute;

  /// No description provided for @unit_hour.
  ///
  /// In en, this message translates to:
  /// **'hour'**
  String get unit_hour;

  /// No description provided for @unit_day.
  ///
  /// In en, this message translates to:
  /// **'day'**
  String get unit_day;

  /// No description provided for @unit_week.
  ///
  /// In en, this message translates to:
  /// **'week'**
  String get unit_week;

  /// No description provided for @unit_month.
  ///
  /// In en, this message translates to:
  /// **'month'**
  String get unit_month;

  /// No description provided for @unit_year.
  ///
  /// In en, this message translates to:
  /// **'year'**
  String get unit_year;

  /// No description provided for @dontrepeat.
  ///
  /// In en, this message translates to:
  /// **'Don\'t repeat'**
  String get dontrepeat;

  /// No description provided for @every.
  ///
  /// In en, this message translates to:
  /// **'Every'**
  String get every;

  /// No description provided for @confirm.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get confirm;

  /// No description provided for @reminderDelete.
  ///
  /// In en, this message translates to:
  /// **'Delete Reminder'**
  String get reminderDelete;

  /// No description provided for @reminderDeleteConfirmation.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this Reminder?'**
  String get reminderDeleteConfirmation;

  /// No description provided for @tasks.
  ///
  /// In en, this message translates to:
  /// **'Tasks'**
  String get tasks;

  /// No description provided for @category.
  ///
  /// In en, this message translates to:
  /// **'Category'**
  String get category;

  /// No description provided for @allCategories.
  ///
  /// In en, this message translates to:
  /// **'All Categories'**
  String get allCategories;

  /// No description provided for @addNewCategory.
  ///
  /// In en, this message translates to:
  /// **'Add new category...'**
  String get addNewCategory;

  /// No description provided for @manageCategories.
  ///
  /// In en, this message translates to:
  /// **'Manage categories...'**
  String get manageCategories;

  /// No description provided for @status.
  ///
  /// In en, this message translates to:
  /// **'Status'**
  String get status;

  /// No description provided for @allTasks.
  ///
  /// In en, this message translates to:
  /// **'All Tasks'**
  String get allTasks;

  /// No description provided for @open.
  ///
  /// In en, this message translates to:
  /// **'Open'**
  String get open;

  /// No description provided for @done.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get done;

  /// No description provided for @noTasksFound.
  ///
  /// In en, this message translates to:
  /// **'No tasks found'**
  String get noTasksFound;

  /// No description provided for @addYourFirstTaskToGetStarted.
  ///
  /// In en, this message translates to:
  /// **'Add your first task to get started!'**
  String get addYourFirstTaskToGetStarted;

  /// No description provided for @addCategory.
  ///
  /// In en, this message translates to:
  /// **'Add Category'**
  String get addCategory;

  /// No description provided for @categoryName.
  ///
  /// In en, this message translates to:
  /// **'Category name'**
  String get categoryName;

  /// No description provided for @add.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get add;

  /// No description provided for @namecategoryRequired.
  ///
  /// In en, this message translates to:
  /// **'Name is required'**
  String get namecategoryRequired;

  /// No description provided for @manageCategories2.
  ///
  /// In en, this message translates to:
  /// **'Manage Categories'**
  String get manageCategories2;

  /// No description provided for @removeCategory.
  ///
  /// In en, this message translates to:
  /// **'Remove Category'**
  String get removeCategory;

  /// No description provided for @removing.
  ///
  /// In en, this message translates to:
  /// **'Removing \''**
  String get removing;

  /// No description provided for @removingcatmessage.
  ///
  /// In en, this message translates to:
  /// **' will PERMANENTLY delete all tasks under this category. This action cannot be undone. Are you sure?'**
  String get removingcatmessage;

  /// No description provided for @categoryanditstasksremoved.
  ///
  /// In en, this message translates to:
  /// **'Category and its tasks removed'**
  String get categoryanditstasksremoved;

  /// No description provided for @errorremovingcategory.
  ///
  /// In en, this message translates to:
  /// **'Error removing category: '**
  String get errorremovingcategory;

  /// No description provided for @errorupdatingtask.
  ///
  /// In en, this message translates to:
  /// **'Error updating task: '**
  String get errorupdatingtask;

  /// No description provided for @due.
  ///
  /// In en, this message translates to:
  /// **'Due: {dueDate}'**
  String due(Object dueDate);

  /// No description provided for @erroraddingcategory.
  ///
  /// In en, this message translates to:
  /// **'Error adding category: '**
  String get erroraddingcategory;

  /// No description provided for @defaultcategorycannotberemoved.
  ///
  /// In en, this message translates to:
  /// **'Default category cannot be removed.'**
  String get defaultcategorycannotberemoved;

  /// No description provided for @errorloadingcategories.
  ///
  /// In en, this message translates to:
  /// **'Error loading categories: '**
  String get errorloadingcategories;

  /// No description provided for @selectDueDate.
  ///
  /// In en, this message translates to:
  /// **'Select Due Date'**
  String get selectDueDate;

  /// No description provided for @pleasefillinallrequiredfields.
  ///
  /// In en, this message translates to:
  /// **'Please fill in all required fields'**
  String get pleasefillinallrequiredfields;

  /// No description provided for @pleaseselectacategory.
  ///
  /// In en, this message translates to:
  /// **'Please select a category'**
  String get pleaseselectacategory;

  /// No description provided for @usernotauthenticated.
  ///
  /// In en, this message translates to:
  /// **'User not authenticated'**
  String get usernotauthenticated;

  /// No description provided for @errorsavingtask.
  ///
  /// In en, this message translates to:
  /// **'Error saving task: '**
  String get errorsavingtask;

  /// No description provided for @addTask.
  ///
  /// In en, this message translates to:
  /// **'Add Task'**
  String get addTask;

  /// No description provided for @taskName.
  ///
  /// In en, this message translates to:
  /// **'Task Name *'**
  String get taskName;

  /// No description provided for @enterTaskName.
  ///
  /// In en, this message translates to:
  /// **'Enter task name'**
  String get enterTaskName;

  /// No description provided for @tasknameisrequired.
  ///
  /// In en, this message translates to:
  /// **'Task name is required'**
  String get tasknameisrequired;

  /// No description provided for @tasknamemustbe100charactersorless.
  ///
  /// In en, this message translates to:
  /// **'Task name must be 100 characters or less'**
  String get tasknamemustbe100charactersorless;

  /// No description provided for @dueDate.
  ///
  /// In en, this message translates to:
  /// **'Due Date'**
  String get dueDate;

  /// No description provided for @nonotificationifdatenotset.
  ///
  /// In en, this message translates to:
  /// **'No notification if date not set'**
  String get nonotificationifdatenotset;

  /// No description provided for @category1.
  ///
  /// In en, this message translates to:
  /// **'Category *'**
  String get category1;

  /// No description provided for @selectcategory.
  ///
  /// In en, this message translates to:
  /// **'Select category'**
  String get selectcategory;

  /// No description provided for @nocategoryfound.
  ///
  /// In en, this message translates to:
  /// **'No categories found. Please create a category first.'**
  String get nocategoryfound;

  /// No description provided for @saveTask.
  ///
  /// In en, this message translates to:
  /// **'Save Task'**
  String get saveTask;

  /// No description provided for @todaysOccasions.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get todaysOccasions;

  /// No description provided for @notifiedOccasions.
  ///
  /// In en, this message translates to:
  /// **'Coming..'**
  String get notifiedOccasions;

  /// No description provided for @occasions.
  ///
  /// In en, this message translates to:
  /// **'Occasions'**
  String get occasions;

  /// No description provided for @noNotifiedOccasions.
  ///
  /// In en, this message translates to:
  /// **'No notified occasions'**
  String get noNotifiedOccasions;

  /// No description provided for @importantOccasions.
  ///
  /// In en, this message translates to:
  /// **'Important Occasions'**
  String get importantOccasions;

  /// No description provided for @noImportantOccasions.
  ///
  /// In en, this message translates to:
  /// **'No important occasions found'**
  String get noImportantOccasions;

  /// No description provided for @noImportantOccasionsMessage.
  ///
  /// In en, this message translates to:
  /// **'You don\'t have any high priority occasions yet. Add some occasions and mark them as high priority to see them here.'**
  String get noImportantOccasionsMessage;

  /// No description provided for @feedback.
  ///
  /// In en, this message translates to:
  /// **'Feedback'**
  String get feedback;

  /// No description provided for @addYourFirstRemnederToGetStarted.
  ///
  /// In en, this message translates to:
  /// **'Add your first reminder to get started!'**
  String get addYourFirstRemnederToGetStarted;

  /// No description provided for @permissionRequired.
  ///
  /// In en, this message translates to:
  /// **'Notification Permission Needed'**
  String get permissionRequired;

  /// No description provided for @taskNotFound.
  ///
  /// In en, this message translates to:
  /// **'Task not found'**
  String get taskNotFound;

  /// No description provided for @taskUpdated.
  ///
  /// In en, this message translates to:
  /// **'Task updated successfully'**
  String get taskUpdated;

  /// No description provided for @errorUpdating.
  ///
  /// In en, this message translates to:
  /// **'Error updating: '**
  String get errorUpdating;

  /// No description provided for @removeTask.
  ///
  /// In en, this message translates to:
  /// **'Remove Task'**
  String get removeTask;

  /// No description provided for @areYouSureYouWantToRemoveThisTask.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to remove this task?'**
  String get areYouSureYouWantToRemoveThisTask;

  /// No description provided for @yes.
  ///
  /// In en, this message translates to:
  /// **'Yes'**
  String get yes;

  /// No description provided for @no.
  ///
  /// In en, this message translates to:
  /// **'No'**
  String get no;

  /// No description provided for @taskRemoved.
  ///
  /// In en, this message translates to:
  /// **'Task removed Successfully'**
  String get taskRemoved;

  /// No description provided for @errorRemovingTask.
  ///
  /// In en, this message translates to:
  /// **'Error removing task: '**
  String get errorRemovingTask;

  /// No description provided for @taskDetails.
  ///
  /// In en, this message translates to:
  /// **'Task Details'**
  String get taskDetails;

  /// No description provided for @statusTask.
  ///
  /// In en, this message translates to:
  /// **'Status *'**
  String get statusTask;

  /// No description provided for @modify.
  ///
  /// In en, this message translates to:
  /// **'Modify'**
  String get modify;

  /// No description provided for @overdue.
  ///
  /// In en, this message translates to:
  /// **'Overdue'**
  String get overdue;

  /// No description provided for @updateReminder.
  ///
  /// In en, this message translates to:
  /// **'Update Reminder'**
  String get updateReminder;

  /// No description provided for @validNumberbetween.
  ///
  /// In en, this message translates to:
  /// **'Please enter a number between 1 and 99.'**
  String get validNumberbetween;

  /// No description provided for @pleaseselectAtLeastOneWeekday.
  ///
  /// In en, this message translates to:
  /// **'Please select at least one weekday'**
  String get pleaseselectAtLeastOneWeekday;

  /// No description provided for @pleaseselecydatetime.
  ///
  /// In en, this message translates to:
  /// **'Please select date & time'**
  String get pleaseselecydatetime;

  /// No description provided for @pleaseselectanuntildate.
  ///
  /// In en, this message translates to:
  /// **'Please select an until date'**
  String get pleaseselectanuntildate;

  /// No description provided for @reminderUpdatedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Reminder updated successfully'**
  String get reminderUpdatedSuccessfully;

  /// No description provided for @errorUpdatingReminder.
  ///
  /// In en, this message translates to:
  /// **'Error updating reminder: '**
  String get errorUpdatingReminder;

  /// No description provided for @reminderDeletedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Reminder deleted successfully'**
  String get reminderDeletedSuccessfully;

  /// No description provided for @errorDeletingReminder.
  ///
  /// In en, this message translates to:
  /// **'Error deleting reminder: '**
  String get errorDeletingReminder;

  /// No description provided for @timeOfReminder.
  ///
  /// In en, this message translates to:
  /// **'Time of Reminder'**
  String get timeOfReminder;

  /// No description provided for @selectfuturedatetime.
  ///
  /// In en, this message translates to:
  /// **'Please select a future date & time'**
  String get selectfuturedatetime;

  /// No description provided for @error.
  ///
  /// In en, this message translates to:
  /// **'Error'**
  String get error;

  /// No description provided for @tasksavedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Task added successfully'**
  String get tasksavedSuccessfully;

  /// No description provided for @dailyDeed.
  ///
  /// In en, this message translates to:
  /// **'Daily Deeds'**
  String get dailyDeed;

  /// No description provided for @religiousDeed.
  ///
  /// In en, this message translates to:
  /// **'Religious Daily Deeds'**
  String get religiousDeed;

  /// No description provided for @statisticsreligiousDeed.
  ///
  /// In en, this message translates to:
  /// **'Religious Deed Statistics'**
  String get statisticsreligiousDeed;

  /// No description provided for @followUs.
  ///
  /// In en, this message translates to:
  /// **'Follow Us'**
  String get followUs;

  /// No description provided for @deedName.
  ///
  /// In en, this message translates to:
  /// **'Deed Name'**
  String get deedName;

  /// No description provided for @enterDeedName.
  ///
  /// In en, this message translates to:
  /// **'Please enter deed name'**
  String get enterDeedName;

  /// No description provided for @prayers.
  ///
  /// In en, this message translates to:
  /// **'Prayers'**
  String get prayers;

  /// No description provided for @fajr.
  ///
  /// In en, this message translates to:
  /// **'Fajr'**
  String get fajr;

  /// No description provided for @dhur.
  ///
  /// In en, this message translates to:
  /// **'Dhur'**
  String get dhur;

  /// No description provided for @asr.
  ///
  /// In en, this message translates to:
  /// **'Asr'**
  String get asr;

  /// No description provided for @maghrib.
  ///
  /// In en, this message translates to:
  /// **'Maghrib'**
  String get maghrib;

  /// No description provided for @isa.
  ///
  /// In en, this message translates to:
  /// **'Isha'**
  String get isa;

  /// No description provided for @tahajjud.
  ///
  /// In en, this message translates to:
  /// **'Tahajjud'**
  String get tahajjud;

  /// No description provided for @witr.
  ///
  /// In en, this message translates to:
  /// **'Witr'**
  String get witr;

  /// No description provided for @taraweeh.
  ///
  /// In en, this message translates to:
  /// **'Taraweeh'**
  String get taraweeh;

  /// No description provided for @learning.
  ///
  /// In en, this message translates to:
  /// **'Learning'**
  String get learning;

  /// No description provided for @readQuran.
  ///
  /// In en, this message translates to:
  /// **'Read Quran'**
  String get readQuran;

  /// No description provided for @fasting.
  ///
  /// In en, this message translates to:
  /// **'Fasting'**
  String get fasting;

  /// No description provided for @ramadanFasting.
  ///
  /// In en, this message translates to:
  /// **'Fasting'**
  String get ramadanFasting;

  /// No description provided for @notPrayed.
  ///
  /// In en, this message translates to:
  /// **'Not Prayed'**
  String get notPrayed;

  /// No description provided for @late.
  ///
  /// In en, this message translates to:
  /// **'Late'**
  String get late;

  /// No description provided for @onTime.
  ///
  /// In en, this message translates to:
  /// **'On Time'**
  String get onTime;

  /// No description provided for @inJamaah.
  ///
  /// In en, this message translates to:
  /// **'In Jamaah'**
  String get inJamaah;

  /// No description provided for @missed.
  ///
  /// In en, this message translates to:
  /// **'Missed'**
  String get missed;

  /// No description provided for @completed.
  ///
  /// In en, this message translates to:
  /// **'Completed'**
  String get completed;

  /// No description provided for @chapters.
  ///
  /// In en, this message translates to:
  /// **'Chapters'**
  String get chapters;

  /// No description provided for @selectChapters.
  ///
  /// In en, this message translates to:
  /// **'Select chapters'**
  String get selectChapters;

  /// No description provided for @retry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;

  /// No description provided for @sunnahPrayers.
  ///
  /// In en, this message translates to:
  /// **'Sunnah'**
  String get sunnahPrayers;

  /// No description provided for @sunnah.
  ///
  /// In en, this message translates to:
  /// **'Sunnah'**
  String get sunnah;

  /// No description provided for @fajrSunnah.
  ///
  /// In en, this message translates to:
  /// **'Fajr Sunnah'**
  String get fajrSunnah;

  /// No description provided for @doha.
  ///
  /// In en, this message translates to:
  /// **'Doha'**
  String get doha;

  /// No description provided for @dhurSunnah.
  ///
  /// In en, this message translates to:
  /// **'Dhur Sunnah'**
  String get dhurSunnah;

  /// No description provided for @maghribSunnah.
  ///
  /// In en, this message translates to:
  /// **'Maghrib Sunnah'**
  String get maghribSunnah;

  /// No description provided for @isaSunnah.
  ///
  /// In en, this message translates to:
  /// **'Isha Sunnah'**
  String get isaSunnah;

  /// No description provided for @morningSupplications.
  ///
  /// In en, this message translates to:
  /// **'Morning Supplications'**
  String get morningSupplications;

  /// No description provided for @eveningSupplications.
  ///
  /// In en, this message translates to:
  /// **'Evening Supplications'**
  String get eveningSupplications;

  /// No description provided for @supplications.
  ///
  /// In en, this message translates to:
  /// **'Supplications'**
  String get supplications;

  /// No description provided for @surahAlKahf.
  ///
  /// In en, this message translates to:
  /// **'Surah Al-Kahf'**
  String get surahAlKahf;

  /// No description provided for @connectionIssue.
  ///
  /// In en, this message translates to:
  /// **'Connection Issue'**
  String get connectionIssue;

  /// No description provided for @choose.
  ///
  /// In en, this message translates to:
  /// **'Choose'**
  String get choose;

  /// No description provided for @totalChaptersRead.
  ///
  /// In en, this message translates to:
  /// **'Total chapters read'**
  String get totalChaptersRead;

  /// No description provided for @daysWithReading.
  ///
  /// In en, this message translates to:
  /// **'Days with reading'**
  String get daysWithReading;

  /// No description provided for @distribution.
  ///
  /// In en, this message translates to:
  /// **'Distribution'**
  String get distribution;

  /// No description provided for @parts.
  ///
  /// In en, this message translates to:
  /// **'parts'**
  String get parts;

  /// No description provided for @statistics.
  ///
  /// In en, this message translates to:
  /// **'Statistics'**
  String get statistics;

  /// No description provided for @selectMonth.
  ///
  /// In en, this message translates to:
  /// **'Select Month'**
  String get selectMonth;

  /// No description provided for @currentMonth.
  ///
  /// In en, this message translates to:
  /// **'Current Month'**
  String get currentMonth;

  /// No description provided for @nextMonth.
  ///
  /// In en, this message translates to:
  /// **'Next Month'**
  String get nextMonth;

  /// No description provided for @notSelected.
  ///
  /// In en, this message translates to:
  /// **'Not Selected'**
  String get notSelected;

  /// No description provided for @prayerStatistics.
  ///
  /// In en, this message translates to:
  /// **'Prayer Statistics'**
  String get prayerStatistics;

  /// No description provided for @naflPrayers.
  ///
  /// In en, this message translates to:
  /// **'Nafl Prayers'**
  String get naflPrayers;

  /// No description provided for @sunnahStatistics.
  ///
  /// In en, this message translates to:
  /// **'Sunnah Statistics'**
  String get sunnahStatistics;

  /// No description provided for @learningStatistics.
  ///
  /// In en, this message translates to:
  /// **'Learning Statistics'**
  String get learningStatistics;

  /// No description provided for @fastingStatistics.
  ///
  /// In en, this message translates to:
  /// **'Fasting Statistics'**
  String get fastingStatistics;

  /// No description provided for @customDailyDeeds.
  ///
  /// In en, this message translates to:
  /// **'Custom Daily Deeds'**
  String get customDailyDeeds;

  /// No description provided for @addCustomDeed.
  ///
  /// In en, this message translates to:
  /// **'Add Custom Deed'**
  String get addCustomDeed;

  /// No description provided for @editCustomDeed.
  ///
  /// In en, this message translates to:
  /// **'Edit Custom Deed'**
  String get editCustomDeed;

  /// No description provided for @selectStartDate.
  ///
  /// In en, this message translates to:
  /// **'Select Start Date'**
  String get selectStartDate;

  /// No description provided for @selectEndDate.
  ///
  /// In en, this message translates to:
  /// **'Select End Date'**
  String get selectEndDate;

  /// No description provided for @deleteDeed.
  ///
  /// In en, this message translates to:
  /// **'Delete Deed'**
  String get deleteDeed;

  /// No description provided for @deleteDeedConfirm.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this deed?'**
  String get deleteDeedConfirm;

  /// No description provided for @noCustomDeeds.
  ///
  /// In en, this message translates to:
  /// **'No custom deeds yet'**
  String get noCustomDeeds;

  /// No description provided for @tapToAddDeed.
  ///
  /// In en, this message translates to:
  /// **'Tap + to add your first custom deed'**
  String get tapToAddDeed;

  /// No description provided for @monthStatistics.
  ///
  /// In en, this message translates to:
  /// **'{month} Statistics'**
  String monthStatistics(Object month);

  /// No description provided for @totalDays.
  ///
  /// In en, this message translates to:
  /// **'Total Days'**
  String get totalDays;

  /// No description provided for @daysInMonth.
  ///
  /// In en, this message translates to:
  /// **'Days in Month'**
  String get daysInMonth;

  /// No description provided for @statValueCount.
  ///
  /// In en, this message translates to:
  /// **'{count} {value}'**
  String statValueCount(Object count, Object value);

  /// No description provided for @percentage.
  ///
  /// In en, this message translates to:
  /// **'{percentage}%'**
  String percentage(Object percentage);

  /// No description provided for @graph.
  ///
  /// In en, this message translates to:
  /// **'Graph'**
  String get graph;

  /// No description provided for @eidPrayer.
  ///
  /// In en, this message translates to:
  /// **'Eid Prayer'**
  String get eidPrayer;

  /// No description provided for @health.
  ///
  /// In en, this message translates to:
  /// **'Health'**
  String get health;

  /// No description provided for @bloodPressure.
  ///
  /// In en, this message translates to:
  /// **'Blood Pressure'**
  String get bloodPressure;

  /// No description provided for @bloodSugar.
  ///
  /// In en, this message translates to:
  /// **'Blood Sugar'**
  String get bloodSugar;

  /// No description provided for @unit.
  ///
  /// In en, this message translates to:
  /// **'Unit'**
  String get unit;

  /// No description provided for @bloodSugarValue.
  ///
  /// In en, this message translates to:
  /// **'Blood Sugar Value'**
  String get bloodSugarValue;

  /// No description provided for @enterBloodSugarValue.
  ///
  /// In en, this message translates to:
  /// **'Enter blood sugar value'**
  String get enterBloodSugarValue;

  /// No description provided for @invalidBloodSugarValue.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid blood sugar value'**
  String get invalidBloodSugarValue;

  /// No description provided for @lowBloodSugar.
  ///
  /// In en, this message translates to:
  /// **'Low'**
  String get lowBloodSugar;

  /// No description provided for @normalBloodSugar.
  ///
  /// In en, this message translates to:
  /// **'Normal'**
  String get normalBloodSugar;

  /// No description provided for @preDiabetesBloodSugar.
  ///
  /// In en, this message translates to:
  /// **'Pre-Diabetes'**
  String get preDiabetesBloodSugar;

  /// No description provided for @diabetesBloodSugar.
  ///
  /// In en, this message translates to:
  /// **'Diabetes'**
  String get diabetesBloodSugar;

  /// No description provided for @beforeMeal.
  ///
  /// In en, this message translates to:
  /// **'Before a Meal'**
  String get beforeMeal;

  /// No description provided for @afterMeal1h.
  ///
  /// In en, this message translates to:
  /// **'After a Meal (1h)'**
  String get afterMeal1h;

  /// No description provided for @afterMeal2h.
  ///
  /// In en, this message translates to:
  /// **'After a Meal (2h)'**
  String get afterMeal2h;

  /// No description provided for @sleep.
  ///
  /// In en, this message translates to:
  /// **'Sleep'**
  String get sleep;

  /// No description provided for @beforeExercise.
  ///
  /// In en, this message translates to:
  /// **'Before Exercise'**
  String get beforeExercise;

  /// No description provided for @afterExercise.
  ///
  /// In en, this message translates to:
  /// **'After Exercise'**
  String get afterExercise;

  /// No description provided for @defaultCondition.
  ///
  /// In en, this message translates to:
  /// **'Default'**
  String get defaultCondition;

  /// No description provided for @export.
  ///
  /// In en, this message translates to:
  /// **'Export'**
  String get export;

  /// No description provided for @noDataToExport.
  ///
  /// In en, this message translates to:
  /// **'No data to export'**
  String get noDataToExport;

  /// No description provided for @noDataToShare.
  ///
  /// In en, this message translates to:
  /// **'No data to share'**
  String get noDataToShare;

  /// No description provided for @shareError.
  ///
  /// In en, this message translates to:
  /// **'Error sharing data'**
  String get shareError;

  /// No description provided for @healthInfo.
  ///
  /// In en, this message translates to:
  /// **'Health Info'**
  String get healthInfo;

  /// No description provided for @track.
  ///
  /// In en, this message translates to:
  /// **'Track'**
  String get track;

  /// No description provided for @history.
  ///
  /// In en, this message translates to:
  /// **'History'**
  String get history;

  /// No description provided for @addMeasurement.
  ///
  /// In en, this message translates to:
  /// **'Add Measurement'**
  String get addMeasurement;

  /// No description provided for @editMeasurement.
  ///
  /// In en, this message translates to:
  /// **'Edit Measurement'**
  String get editMeasurement;

  /// No description provided for @measurementName.
  ///
  /// In en, this message translates to:
  /// **'Measurement Name'**
  String get measurementName;

  /// No description provided for @enterMeasurementName.
  ///
  /// In en, this message translates to:
  /// **'Enter measurement name'**
  String get enterMeasurementName;

  /// No description provided for @measurementNameRequired.
  ///
  /// In en, this message translates to:
  /// **'Measurement name is required'**
  String get measurementNameRequired;

  /// No description provided for @enterDescription.
  ///
  /// In en, this message translates to:
  /// **'Enter description (optional)'**
  String get enterDescription;

  /// No description provided for @selectDate.
  ///
  /// In en, this message translates to:
  /// **'Select date'**
  String get selectDate;

  /// No description provided for @systolic.
  ///
  /// In en, this message translates to:
  /// **'Systolic'**
  String get systolic;

  /// No description provided for @diastolic.
  ///
  /// In en, this message translates to:
  /// **'Diastolic'**
  String get diastolic;

  /// No description provided for @pulse.
  ///
  /// In en, this message translates to:
  /// **'Pulse'**
  String get pulse;

  /// No description provided for @enterSystolic.
  ///
  /// In en, this message translates to:
  /// **'Enter systolic value'**
  String get enterSystolic;

  /// No description provided for @enterDiastolic.
  ///
  /// In en, this message translates to:
  /// **'Enter diastolic value'**
  String get enterDiastolic;

  /// No description provided for @enterPulse.
  ///
  /// In en, this message translates to:
  /// **'Enter pulse value'**
  String get enterPulse;

  /// No description provided for @mmHg.
  ///
  /// In en, this message translates to:
  /// **'mmHg'**
  String get mmHg;

  /// No description provided for @bpm.
  ///
  /// In en, this message translates to:
  /// **'bpm'**
  String get bpm;

  /// No description provided for @arm.
  ///
  /// In en, this message translates to:
  /// **'Arm'**
  String get arm;

  /// No description provided for @leftArm.
  ///
  /// In en, this message translates to:
  /// **'Left Arm'**
  String get leftArm;

  /// No description provided for @rightArm.
  ///
  /// In en, this message translates to:
  /// **'Right Arm'**
  String get rightArm;

  /// No description provided for @position.
  ///
  /// In en, this message translates to:
  /// **'Position'**
  String get position;

  /// No description provided for @sitting.
  ///
  /// In en, this message translates to:
  /// **'Sitting'**
  String get sitting;

  /// No description provided for @standing.
  ///
  /// In en, this message translates to:
  /// **'Standing'**
  String get standing;

  /// No description provided for @lyingDown.
  ///
  /// In en, this message translates to:
  /// **'Lying Down'**
  String get lyingDown;

  /// No description provided for @condition.
  ///
  /// In en, this message translates to:
  /// **'Condition'**
  String get condition;

  /// No description provided for @atRest.
  ///
  /// In en, this message translates to:
  /// **'At Rest'**
  String get atRest;

  /// No description provided for @afterMeal.
  ///
  /// In en, this message translates to:
  /// **'After Meal'**
  String get afterMeal;

  /// No description provided for @stressed.
  ///
  /// In en, this message translates to:
  /// **'Stressed'**
  String get stressed;

  /// No description provided for @update.
  ///
  /// In en, this message translates to:
  /// **'Update'**
  String get update;

  /// No description provided for @noMeasurementsToday.
  ///
  /// In en, this message translates to:
  /// **'No measurements today'**
  String get noMeasurementsToday;

  /// No description provided for @tapToAddMeasurement.
  ///
  /// In en, this message translates to:
  /// **'Tap + to add your first measurement'**
  String get tapToAddMeasurement;

  /// No description provided for @todayMeasurements.
  ///
  /// In en, this message translates to:
  /// **'Today\'s Measurements'**
  String get todayMeasurements;

  /// No description provided for @dailyBloodSugarStatistics.
  ///
  /// In en, this message translates to:
  /// **'Daily Blood Sugar Statistics'**
  String get dailyBloodSugarStatistics;

  /// No description provided for @dailyBloodPressureStatistics.
  ///
  /// In en, this message translates to:
  /// **'Daily Blood Pressure Statistics'**
  String get dailyBloodPressureStatistics;

  /// No description provided for @average.
  ///
  /// In en, this message translates to:
  /// **'Average'**
  String get average;

  /// No description provided for @min.
  ///
  /// In en, this message translates to:
  /// **'Min'**
  String get min;

  /// No description provided for @max.
  ///
  /// In en, this message translates to:
  /// **'Max'**
  String get max;

  /// No description provided for @totalMeasurements.
  ///
  /// In en, this message translates to:
  /// **'Total Measurements'**
  String get totalMeasurements;

  /// No description provided for @normal.
  ///
  /// In en, this message translates to:
  /// **'Normal'**
  String get normal;

  /// No description provided for @elevated.
  ///
  /// In en, this message translates to:
  /// **'Elevated'**
  String get elevated;

  /// No description provided for @highStage1.
  ///
  /// In en, this message translates to:
  /// **'High (Stage 1)'**
  String get highStage1;

  /// No description provided for @highStage2.
  ///
  /// In en, this message translates to:
  /// **'High (Stage 2)'**
  String get highStage2;

  /// No description provided for @hypertensiveCrisis.
  ///
  /// In en, this message translates to:
  /// **'Hypertensive Crisis'**
  String get hypertensiveCrisis;

  /// No description provided for @week.
  ///
  /// In en, this message translates to:
  /// **'Week'**
  String get week;

  /// No description provided for @month.
  ///
  /// In en, this message translates to:
  /// **'Month'**
  String get month;

  /// No description provided for @year.
  ///
  /// In en, this message translates to:
  /// **'Year'**
  String get year;

  /// No description provided for @noHistoryData.
  ///
  /// In en, this message translates to:
  /// **'No history data available'**
  String get noHistoryData;

  /// No description provided for @exportData.
  ///
  /// In en, this message translates to:
  /// **'Export Data'**
  String get exportData;

  /// No description provided for @exportAsCsv.
  ///
  /// In en, this message translates to:
  /// **'Export as CSV'**
  String get exportAsCsv;

  /// No description provided for @exportAsPdf.
  ///
  /// In en, this message translates to:
  /// **'Export as PDF'**
  String get exportAsPdf;

  /// No description provided for @download.
  ///
  /// In en, this message translates to:
  /// **'Download'**
  String get download;

  /// No description provided for @share.
  ///
  /// In en, this message translates to:
  /// **'Share'**
  String get share;

  /// No description provided for @sharePdf.
  ///
  /// In en, this message translates to:
  /// **'Share PDF'**
  String get sharePdf;

  /// No description provided for @shareCsv.
  ///
  /// In en, this message translates to:
  /// **'Share CSV'**
  String get shareCsv;

  /// No description provided for @downloadPdf.
  ///
  /// In en, this message translates to:
  /// **'Save as PDF'**
  String get downloadPdf;

  /// No description provided for @downloadCsv.
  ///
  /// In en, this message translates to:
  /// **'Download CSV'**
  String get downloadCsv;

  /// No description provided for @exportSuccess.
  ///
  /// In en, this message translates to:
  /// **'Data exported successfully'**
  String get exportSuccess;

  /// No description provided for @exportError.
  ///
  /// In en, this message translates to:
  /// **'Error exporting data'**
  String get exportError;

  /// No description provided for @measurementAdded.
  ///
  /// In en, this message translates to:
  /// **'Measurement added successfully'**
  String get measurementAdded;

  /// No description provided for @measurementUpdated.
  ///
  /// In en, this message translates to:
  /// **'Measurement updated successfully'**
  String get measurementUpdated;

  /// No description provided for @measurementDeleted.
  ///
  /// In en, this message translates to:
  /// **'Measurement deleted successfully'**
  String get measurementDeleted;

  /// No description provided for @errorAddingMeasurement.
  ///
  /// In en, this message translates to:
  /// **'Error adding measurement'**
  String get errorAddingMeasurement;

  /// No description provided for @errorUpdatingMeasurement.
  ///
  /// In en, this message translates to:
  /// **'Error updating measurement'**
  String get errorUpdatingMeasurement;

  /// No description provided for @errorDeletingMeasurement.
  ///
  /// In en, this message translates to:
  /// **'Error deleting measurement'**
  String get errorDeletingMeasurement;

  /// No description provided for @deleteMeasurementConfirm.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this measurement?'**
  String get deleteMeasurementConfirm;

  /// No description provided for @measurementDetails.
  ///
  /// In en, this message translates to:
  /// **'Measurement Details'**
  String get measurementDetails;

  /// No description provided for @today.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get today;

  /// No description provided for @yesterday.
  ///
  /// In en, this message translates to:
  /// **'Yesterday'**
  String get yesterday;

  /// No description provided for @targetRanges.
  ///
  /// In en, this message translates to:
  /// **'Target Ranges'**
  String get targetRanges;

  /// No description provided for @editTargetRanges.
  ///
  /// In en, this message translates to:
  /// **'Edit Target Ranges'**
  String get editTargetRanges;

  /// No description provided for @customRangesActive.
  ///
  /// In en, this message translates to:
  /// **'Custom ranges are active'**
  String get customRangesActive;

  /// No description provided for @defaultRangesInfo.
  ///
  /// In en, this message translates to:
  /// **'Using default medical ranges'**
  String get defaultRangesInfo;

  /// No description provided for @editRanges.
  ///
  /// In en, this message translates to:
  /// **'Edit Ranges'**
  String get editRanges;

  /// No description provided for @resetToDefault.
  ///
  /// In en, this message translates to:
  /// **'Reset to Default'**
  String get resetToDefault;

  /// No description provided for @low.
  ///
  /// In en, this message translates to:
  /// **'Low'**
  String get low;

  /// No description provided for @preDiabetes.
  ///
  /// In en, this message translates to:
  /// **'Pre-Diabetes'**
  String get preDiabetes;

  /// No description provided for @diabetes.
  ///
  /// In en, this message translates to:
  /// **'Diabetes'**
  String get diabetes;

  /// No description provided for @saveRanges.
  ///
  /// In en, this message translates to:
  /// **'Save Ranges'**
  String get saveRanges;

  /// No description provided for @rangesSaved.
  ///
  /// In en, this message translates to:
  /// **'Ranges saved successfully'**
  String get rangesSaved;

  /// No description provided for @greaterThan.
  ///
  /// In en, this message translates to:
  /// **'Greater than'**
  String get greaterThan;

  /// No description provided for @lessThan.
  ///
  /// In en, this message translates to:
  /// **'Less than'**
  String get lessThan;

  /// No description provided for @lowRange.
  ///
  /// In en, this message translates to:
  /// **'Low Range'**
  String get lowRange;

  /// No description provided for @normalRange.
  ///
  /// In en, this message translates to:
  /// **'Normal Range'**
  String get normalRange;

  /// No description provided for @preDiabetesRange.
  ///
  /// In en, this message translates to:
  /// **'Pre-Diabetes Range'**
  String get preDiabetesRange;

  /// No description provided for @diabetesRange.
  ///
  /// In en, this message translates to:
  /// **'Diabetes Range'**
  String get diabetesRange;

  /// No description provided for @and.
  ///
  /// In en, this message translates to:
  /// **'and'**
  String get and;

  /// No description provided for @bloodPressureRanges.
  ///
  /// In en, this message translates to:
  /// **'Blood Pressure Ranges'**
  String get bloodPressureRanges;

  /// No description provided for @editBloodPressureRanges.
  ///
  /// In en, this message translates to:
  /// **'Edit Blood Pressure Ranges'**
  String get editBloodPressureRanges;

  /// No description provided for @systolicMin.
  ///
  /// In en, this message translates to:
  /// **'Systolic Min'**
  String get systolicMin;

  /// No description provided for @systolicMax.
  ///
  /// In en, this message translates to:
  /// **'Systolic Max'**
  String get systolicMax;

  /// No description provided for @diastolicMin.
  ///
  /// In en, this message translates to:
  /// **'Diastolic Min'**
  String get diastolicMin;

  /// No description provided for @diastolicMax.
  ///
  /// In en, this message translates to:
  /// **'Diastolic Max'**
  String get diastolicMax;

  /// No description provided for @normalBP.
  ///
  /// In en, this message translates to:
  /// **'Normal'**
  String get normalBP;

  /// No description provided for @elevatedBP.
  ///
  /// In en, this message translates to:
  /// **'Elevated'**
  String get elevatedBP;

  /// No description provided for @highStage1BP.
  ///
  /// In en, this message translates to:
  /// **'High (Stage 1)'**
  String get highStage1BP;

  /// No description provided for @highStage2BP.
  ///
  /// In en, this message translates to:
  /// **'High (Stage 2)'**
  String get highStage2BP;

  /// No description provided for @crisisBP.
  ///
  /// In en, this message translates to:
  /// **'Crisis'**
  String get crisisBP;

  /// No description provided for @rangesSettingsNote.
  ///
  /// In en, this message translates to:
  /// **'Customize target ranges based on doctor recommendations'**
  String get rangesSettingsNote;

  /// No description provided for @basicInfo.
  ///
  /// In en, this message translates to:
  /// **'Basic Info'**
  String get basicInfo;

  /// No description provided for @addBasicInfo.
  ///
  /// In en, this message translates to:
  /// **'Add Basic Info'**
  String get addBasicInfo;

  /// No description provided for @fullName.
  ///
  /// In en, this message translates to:
  /// **'Full Name'**
  String get fullName;

  /// No description provided for @enterFullName.
  ///
  /// In en, this message translates to:
  /// **'Enter your full name'**
  String get enterFullName;

  /// No description provided for @bloodType.
  ///
  /// In en, this message translates to:
  /// **'Blood Type'**
  String get bloodType;

  /// No description provided for @selectBloodType.
  ///
  /// In en, this message translates to:
  /// **'Select blood type'**
  String get selectBloodType;

  /// No description provided for @dateOfBirth.
  ///
  /// In en, this message translates to:
  /// **'Date of Birth'**
  String get dateOfBirth;

  /// No description provided for @height.
  ///
  /// In en, this message translates to:
  /// **'Height'**
  String get height;

  /// No description provided for @enterHeight.
  ///
  /// In en, this message translates to:
  /// **'Enter height'**
  String get enterHeight;

  /// No description provided for @weight.
  ///
  /// In en, this message translates to:
  /// **'Weight'**
  String get weight;

  /// No description provided for @enterWeight.
  ///
  /// In en, this message translates to:
  /// **'Enter weight'**
  String get enterWeight;

  /// No description provided for @allergies.
  ///
  /// In en, this message translates to:
  /// **'Allergies'**
  String get allergies;

  /// No description provided for @addMedicationAllergy.
  ///
  /// In en, this message translates to:
  /// **'Add Medication Allergy'**
  String get addMedicationAllergy;

  /// No description provided for @addFoodAllergy.
  ///
  /// In en, this message translates to:
  /// **'Add Food Allergy'**
  String get addFoodAllergy;

  /// No description provided for @noAllergies.
  ///
  /// In en, this message translates to:
  /// **'No allergies recorded'**
  String get noAllergies;

  /// No description provided for @addAllergyHint.
  ///
  /// In en, this message translates to:
  /// **'Tap + to add an allergy'**
  String get addAllergyHint;

  /// No description provided for @addCustom.
  ///
  /// In en, this message translates to:
  /// **'Add Custom'**
  String get addCustom;

  /// No description provided for @enterCustomAllergy.
  ///
  /// In en, this message translates to:
  /// **'Enter custom allergy'**
  String get enterCustomAllergy;

  /// No description provided for @selectFromList.
  ///
  /// In en, this message translates to:
  /// **'Select from list'**
  String get selectFromList;

  /// No description provided for @saveSelected.
  ///
  /// In en, this message translates to:
  /// **'Save Selected'**
  String get saveSelected;

  /// No description provided for @custom.
  ///
  /// In en, this message translates to:
  /// **'Custom'**
  String get custom;

  /// No description provided for @medications.
  ///
  /// In en, this message translates to:
  /// **'Medications'**
  String get medications;

  /// No description provided for @food.
  ///
  /// In en, this message translates to:
  /// **'Food'**
  String get food;

  /// No description provided for @active.
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get active;

  /// No description provided for @noData.
  ///
  /// In en, this message translates to:
  /// **'No data'**
  String get noData;

  /// No description provided for @chronicDiseases.
  ///
  /// In en, this message translates to:
  /// **'Chronic Diseases'**
  String get chronicDiseases;

  /// No description provided for @addChronicDisease.
  ///
  /// In en, this message translates to:
  /// **'Add Chronic Disease'**
  String get addChronicDisease;

  /// No description provided for @noChronicDiseases.
  ///
  /// In en, this message translates to:
  /// **'No chronic diseases recorded'**
  String get noChronicDiseases;

  /// No description provided for @addDiseaseHint.
  ///
  /// In en, this message translates to:
  /// **'Tap + to add a disease'**
  String get addDiseaseHint;

  /// No description provided for @enterCustomDisease.
  ///
  /// In en, this message translates to:
  /// **'Enter custom disease'**
  String get enterCustomDisease;

  /// No description provided for @medicationName.
  ///
  /// In en, this message translates to:
  /// **'Medication Name'**
  String get medicationName;

  /// No description provided for @enterMedicationName.
  ///
  /// In en, this message translates to:
  /// **'Enter medication name'**
  String get enterMedicationName;

  /// No description provided for @dosage.
  ///
  /// In en, this message translates to:
  /// **'Dosage'**
  String get dosage;

  /// No description provided for @enterDosage.
  ///
  /// In en, this message translates to:
  /// **'Enter dosage'**
  String get enterDosage;

  /// No description provided for @frequency.
  ///
  /// In en, this message translates to:
  /// **'Frequency'**
  String get frequency;

  /// No description provided for @enterValidNumber.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid number'**
  String get enterValidNumber;

  /// No description provided for @reminderTimes.
  ///
  /// In en, this message translates to:
  /// **'Reminder Times'**
  String get reminderTimes;

  /// No description provided for @addTime.
  ///
  /// In en, this message translates to:
  /// **'Add Time'**
  String get addTime;

  /// No description provided for @noMedications.
  ///
  /// In en, this message translates to:
  /// **'No medications recorded'**
  String get noMedications;

  /// No description provided for @addMedicationHint.
  ///
  /// In en, this message translates to:
  /// **'Tap + to add a medication'**
  String get addMedicationHint;

  /// No description provided for @editMedication.
  ///
  /// In en, this message translates to:
  /// **'Edit Medication'**
  String get editMedication;

  /// No description provided for @addMedication.
  ///
  /// In en, this message translates to:
  /// **'Add Medication'**
  String get addMedication;

  /// No description provided for @emergencyInfo.
  ///
  /// In en, this message translates to:
  /// **'Emergency Info'**
  String get emergencyInfo;

  /// No description provided for @noEmergencyContacts.
  ///
  /// In en, this message translates to:
  /// **'No emergency contacts'**
  String get noEmergencyContacts;

  /// No description provided for @addEmergencyContactHint.
  ///
  /// In en, this message translates to:
  /// **'Tap + to add an emergency contact'**
  String get addEmergencyContactHint;

  /// No description provided for @addContact.
  ///
  /// In en, this message translates to:
  /// **'Add Contact'**
  String get addContact;

  /// No description provided for @editContact.
  ///
  /// In en, this message translates to:
  /// **'Edit Contact'**
  String get editContact;

  /// No description provided for @enterContactName.
  ///
  /// In en, this message translates to:
  /// **'Enter contact name'**
  String get enterContactName;

  /// No description provided for @phoneNumber.
  ///
  /// In en, this message translates to:
  /// **'Phone Number'**
  String get phoneNumber;

  /// No description provided for @enterPhoneNumber.
  ///
  /// In en, this message translates to:
  /// **'Enter phone number'**
  String get enterPhoneNumber;

  /// No description provided for @relationshipOptional.
  ///
  /// In en, this message translates to:
  /// **'Relationship (Optional)'**
  String get relationshipOptional;

  /// No description provided for @enterRelationship.
  ///
  /// In en, this message translates to:
  /// **'e.g., Spouse, Parent'**
  String get enterRelationship;

  /// No description provided for @call.
  ///
  /// In en, this message translates to:
  /// **'Call'**
  String get call;

  /// No description provided for @medicalNotes.
  ///
  /// In en, this message translates to:
  /// **'Medical Notes'**
  String get medicalNotes;

  /// No description provided for @noMedicalNotes.
  ///
  /// In en, this message translates to:
  /// **'No medical notes'**
  String get noMedicalNotes;

  /// No description provided for @addMedicalNoteHint.
  ///
  /// In en, this message translates to:
  /// **'Tap + to add a note'**
  String get addMedicalNoteHint;

  /// No description provided for @addMedicalNote.
  ///
  /// In en, this message translates to:
  /// **'Add Medical Note'**
  String get addMedicalNote;

  /// No description provided for @editMedicalNote.
  ///
  /// In en, this message translates to:
  /// **'Edit Medical Note'**
  String get editMedicalNote;

  /// No description provided for @noteContent.
  ///
  /// In en, this message translates to:
  /// **'Note Content'**
  String get noteContent;

  /// No description provided for @enterNoteContent.
  ///
  /// In en, this message translates to:
  /// **'Enter your note here...'**
  String get enterNoteContent;

  /// No description provided for @dateAndTime.
  ///
  /// In en, this message translates to:
  /// **'Date & Time'**
  String get dateAndTime;

  /// No description provided for @confirmDelete.
  ///
  /// In en, this message translates to:
  /// **'Confirm Delete'**
  String get confirmDelete;

  /// No description provided for @deleteAllergyConfirm.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this allergy?'**
  String get deleteAllergyConfirm;

  /// No description provided for @deleteDiseaseConfirm.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this disease?'**
  String get deleteDiseaseConfirm;

  /// No description provided for @deleteMedicationConfirm.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this medication?'**
  String get deleteMedicationConfirm;

  /// No description provided for @deleteContactConfirm.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this contact?'**
  String get deleteContactConfirm;

  /// No description provided for @deleteNoteConfirm.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this note?'**
  String get deleteNoteConfirm;

  /// No description provided for @savedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Saved successfully'**
  String get savedSuccessfully;

  /// No description provided for @errorSaving.
  ///
  /// In en, this message translates to:
  /// **'Error saving data'**
  String get errorSaving;

  /// No description provided for @pleaseEnterValue.
  ///
  /// In en, this message translates to:
  /// **'Please enter a value'**
  String get pleaseEnterValue;

  /// No description provided for @edit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get edit;

  /// No description provided for @goodMorning.
  ///
  /// In en, this message translates to:
  /// **'Good Morning'**
  String get goodMorning;

  /// No description provided for @goodAfternoon.
  ///
  /// In en, this message translates to:
  /// **'Good Afternoon'**
  String get goodAfternoon;

  /// No description provided for @goodEvening.
  ///
  /// In en, this message translates to:
  /// **'Good Evening'**
  String get goodEvening;

  /// No description provided for @todayOverview.
  ///
  /// In en, this message translates to:
  /// **'Today Overview'**
  String get todayOverview;

  /// No description provided for @occasionsToday.
  ///
  /// In en, this message translates to:
  /// **'Occasions Today'**
  String get occasionsToday;

  /// No description provided for @upcomingOccasions.
  ///
  /// In en, this message translates to:
  /// **'Upcoming'**
  String get upcomingOccasions;

  /// No description provided for @tasksToday.
  ///
  /// In en, this message translates to:
  /// **'Tasks Today'**
  String get tasksToday;

  /// No description provided for @remindersToday.
  ///
  /// In en, this message translates to:
  /// **'Reminders Today'**
  String get remindersToday;

  /// No description provided for @noTasksToday.
  ///
  /// In en, this message translates to:
  /// **'No tasks for today'**
  String get noTasksToday;

  /// No description provided for @noRemindersToday.
  ///
  /// In en, this message translates to:
  /// **'No reminders for today'**
  String get noRemindersToday;

  /// No description provided for @lastReading.
  ///
  /// In en, this message translates to:
  /// **'Last: {value}'**
  String lastReading(Object value);

  /// No description provided for @addReading.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get addReading;

  /// No description provided for @dailyDeeds.
  ///
  /// In en, this message translates to:
  /// **'Daily Deeds'**
  String get dailyDeeds;

  /// No description provided for @generalDeeds.
  ///
  /// In en, this message translates to:
  /// **'General Deeds'**
  String get generalDeeds;

  /// No description provided for @religiousDeeds.
  ///
  /// In en, this message translates to:
  /// **'Religious Deeds'**
  String get religiousDeeds;

  /// No description provided for @progressToday.
  ///
  /// In en, this message translates to:
  /// **'Today\'s Progress'**
  String get progressToday;

  /// No description provided for @quickActions.
  ///
  /// In en, this message translates to:
  /// **'Quick Actions'**
  String get quickActions;

  /// No description provided for @addOccasion.
  ///
  /// In en, this message translates to:
  /// **'Add Occasion'**
  String get addOccasion;

  /// No description provided for @viewAll.
  ///
  /// In en, this message translates to:
  /// **'View All'**
  String get viewAll;

  /// No description provided for @noOccasionsToday.
  ///
  /// In en, this message translates to:
  /// **'No occasions today'**
  String get noOccasionsToday;

  /// No description provided for @insightBloodPressure.
  ///
  /// In en, this message translates to:
  /// **'You haven\'t logged blood pressure today'**
  String get insightBloodPressure;

  /// No description provided for @insightBloodSugar.
  ///
  /// In en, this message translates to:
  /// **'You haven\'t logged blood sugar today'**
  String get insightBloodSugar;

  /// No description provided for @insightUpcomingOccasion.
  ///
  /// In en, this message translates to:
  /// **'You have an occasion coming up tomorrow'**
  String get insightUpcomingOccasion;

  /// No description provided for @viewMore.
  ///
  /// In en, this message translates to:
  /// **'View more'**
  String get viewMore;
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>['ar', 'en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {


  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar': return AppLocalizationsAr();
    case 'en': return AppLocalizationsEn();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.'
  );
}
