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
  /// **'start Date'**
  String get startDate;

  /// No description provided for @endDate.
  ///
  /// In en, this message translates to:
  /// **'end Date'**
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
  /// **'Select date'**
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
  /// **'Comming..'**
  String get notifiedOccasions;

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
