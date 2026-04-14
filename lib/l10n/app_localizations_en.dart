// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Mohtm';

  @override
  String get login => 'Login';

  @override
  String get logout => 'Logout';

  @override
  String get welcome => 'Welcome';

  @override
  String get noAnniversariesToday =>
      'No saved occasions for today ,\n  you can add a new one';

  @override
  String get title => 'mohtm';

  @override
  String get mohtmMenu => 'Mohtm Menu';

  @override
  String get rateUs => 'Rate us';

  @override
  String get settings => 'Settings';

  @override
  String get shareApp => 'Share app';

  @override
  String get changePassword => 'Change password';

  @override
  String typeLabel(Object type) {
    return 'Type: $type';
  }

  @override
  String get startDate => 'Start Date';

  @override
  String get endDate => 'End Date';

  @override
  String get filter => 'Filter';

  @override
  String get clearFilter => 'Clear filter';

  @override
  String get noAnniversariesFound => 'No occasions found';

  @override
  String get profileUpdatedsuccessfully => 'Profile updated successfully';

  @override
  String get profileUpdateFailed => 'Profile update failed';

  @override
  String get profile => 'Profile';

  @override
  String get firstName => 'First name';

  @override
  String get lastName => 'Last name';

  @override
  String get email => 'Email';

  @override
  String get phone => 'Phone Number';

  @override
  String get birthdate => 'Birthdate';

  @override
  String get gender => 'gender';

  @override
  String get forgetPassword => 'Forget password';

  @override
  String get pleaseEntervalidEmail => 'Please enter a valid email';

  @override
  String get restPassword => 'Reset password';

  @override
  String get changePasswordSuccessMessage => 'Password changed successfully';

  @override
  String get changePasswordErrorMessage => 'Error changing password';

  @override
  String get changePasswordTitle => 'Change password';

  @override
  String get currentPassword => 'Current password';

  @override
  String get newPassword => 'New password';

  @override
  String get confirmNewPassword => 'Confirm new password';

  @override
  String get entercurrentPassword => 'Please enter current password';

  @override
  String get enterNewPassword => 'Please enter new password';

  @override
  String get passwordLengthValidation =>
      'New password must be at least 6 characters';

  @override
  String get passwordMatchValidation =>
      'New password and confirm new password must match';

  @override
  String get enterConfirmNewPassword => 'Please enter confirm new password';

  @override
  String get passwordsDoNotMatch =>
      'New password and confirm new password do not match';

  @override
  String get passwordChangedSuccessfully => 'Password changed successfully';

  @override
  String get changePasswordButtonText => 'Change password';

  @override
  String get description => 'Description';

  @override
  String get date => 'Date';

  @override
  String get type => 'Type';

  @override
  String get relationship => 'Relationship';

  @override
  String get priority => 'Priority';

  @override
  String get rememberBefore => 'Remember before ';

  @override
  String get atTimeOfEvent => 'At time of event';

  @override
  String get anntitle => 'occasion title';

  @override
  String get deleteAnniversary => 'Delete occasion';

  @override
  String get deleteAnniversaryConfirmation =>
      'Are you sure you want to delete this occasion?';

  @override
  String get cancel => 'Cancel';

  @override
  String get delete => 'Delete';

  @override
  String get addAnniversaryTitle => 'Add new occasion';

  @override
  String get selectDateLabel => 'date of occasion ,ex:birthday 01-04-1990';

  @override
  String get anniversaryNameLabel => 'occasion name';

  @override
  String get anniversaryNameHint => 'Enter occasion name';

  @override
  String get anniversaryNameValidation => 'Please enter occasion name';

  @override
  String get anniversaryDescriptionLabel => 'occasion description';

  @override
  String get anniversaryDescriptionHint => 'Enter occasion description';

  @override
  String get anniversarytypeValidation => 'Please select occasion type';

  @override
  String get specifyType => 'Specify type';

  @override
  String get anniversaryOtherTypeValidation => 'Please specify occasion type';

  @override
  String get relationshipHint => 'Enter relationship';

  @override
  String get priorityValidation => 'Please select priority';

  @override
  String get save => 'Save';

  @override
  String get loginToMohtm => 'MOHTM';

  @override
  String get password => 'Password';

  @override
  String get forgetPasswordquestion => 'Forgot your password?';

  @override
  String get donthaveAnAccount => 'Don\'t have an account?';

  @override
  String get userNotFound => 'email or password is incorrect';

  @override
  String get errorOccurred => 'An error occurred';

  @override
  String get register => 'Register';

  @override
  String get registerTitle => 'Register';

  @override
  String get firstNamevalidation => 'Please enter first name';

  @override
  String get lastNamevalidation => 'Please enter last name';

  @override
  String get emailValidation => 'Please enter a valid email';

  @override
  String get phoneValidation => 'Please enter a valid phone number';

  @override
  String get passwordValidation => 'Please enter a password';

  @override
  String get confirmPassword => 'Confirm password';

  @override
  String get pleaseConfirmPassword => 'Please confirm your password';

  @override
  String get registerSuccessMessage => 'Registration successful';

  @override
  String get registerErrorMessage => 'Registration failed';

  @override
  String get registerSuccessMessageWithVerification =>
      'Registration successful! Please check your email (and Spam / Junk Folder) to verify your account before logging in.';

  @override
  String get emailNotVerifiedMessage =>
      'Your email is not verified. Please check your inbox (and Spam / Junk Folder) and verify your email before logging in.';

  @override
  String get soticalUseNotFound => ' user not found, please register first';

  @override
  String get signinwithGoogle => 'Sign in with Google';

  @override
  String get signinwithFacebook => 'Sign in with Facebook';

  @override
  String get sigupWithGoogle => 'Sign up with Google';

  @override
  String get sigupWithFacebook => 'Sign up with Facebook';

  @override
  String get rememberme => 'Remember me';

  @override
  String get feedbackrequiredFields => 'title and comment are required.';

  @override
  String get commentTooLong =>
      'Comment is too long. Please shorten it to 1000 characters or less.';

  @override
  String get feedbackSent => 'Feedback sent successfully';

  @override
  String get feedbackError => 'Error sending feedback';

  @override
  String get feedbackTitle => 'Contact Us';

  @override
  String get subject => 'Subject';

  @override
  String get body => 'Body';

  @override
  String get send => 'Send';

  @override
  String get contactUs => 'Contact Us';

  @override
  String passwordResetSent(Object email) {
    return 'Password reset email sent to $email. Please check your inbox (and Spam / Junk Folder).';
  }

  @override
  String get emailNotFound => 'Email not found';

  @override
  String errorSendRestmail(Object errorMessage) {
    return 'Error sending reset email: $errorMessage';
  }

  @override
  String get unexpectedErrorOccurred => 'An unexpected error occurred.';

  @override
  String get pleaseInterValidInputs => 'Please enter valid inputs.';

  @override
  String get userNotLogin => 'User not logged in';

  @override
  String get annAddSuccessfully => 'occasion added successfully';

  @override
  String get failtoAddAnniversary =>
      'Failed to add occasion, please try again later';

  @override
  String get dateValidation => 'Please select a date.';

  @override
  String get annUpdateSuccessfully => 'occasion updated successfully';

  @override
  String get failtoUpdateAnniversary =>
      'Failed to update occasion, please try again later';

  @override
  String get oldPasswordIncorrect =>
      'Old password is incorrect. Please try again.';

  @override
  String get occasionDetails => 'occasion Details';

  @override
  String get reminders => 'Reminders';

  @override
  String get exactAlarmPermissionTitle => 'Exact Alarm Permission Needed';

  @override
  String get exactAlarmPermissionMessage =>
      'To ensure reminders work reliably, make sure to  allow \"Schedule exact alarms\" permission in system settings.';

  @override
  String get open_sertings => 'Open Settings';

  @override
  String get noReminders => 'No reminders found.';

  @override
  String get repeat => 'Repeat';

  @override
  String get addReminder => 'Add Reminder';

  @override
  String get fixNotificationsPermission => 'Fix Notification Permission';

  @override
  String get reminderTitle => ' Reminder Title';

  @override
  String get reminderTitleRequired => 'Reminder title is required';

  @override
  String get reminderTitleTooLong =>
      'Reminder title must be at most 100 characters';

  @override
  String get selecydatetime => 'Select date & time';

  @override
  String get saveReminder => 'Save Reminder';

  @override
  String get duration => 'Duration';

  @override
  String get forever => 'Forever';

  @override
  String get count => 'Specific number of times';

  @override
  String get untilDate => 'Until a date';

  @override
  String get repeatCount => 'Number of times';

  @override
  String get repeatCountRequired => 'Number of times is required';

  @override
  String get repeatCountvalidation => 'Enter a valid number';

  @override
  String get untilDate2 => 'Until date';

  @override
  String get notSet => 'Not set';

  @override
  String get unit_minute => 'minute';

  @override
  String get unit_hour => 'hour';

  @override
  String get unit_day => 'day';

  @override
  String get unit_week => 'week';

  @override
  String get unit_month => 'month';

  @override
  String get unit_year => 'year';

  @override
  String get dontrepeat => 'Don\'t repeat';

  @override
  String get every => 'Every';

  @override
  String get confirm => 'Confirm';

  @override
  String get reminderDelete => 'Delete Reminder';

  @override
  String get reminderDeleteConfirmation =>
      'Are you sure you want to delete this Reminder?';

  @override
  String get tasks => 'Tasks';

  @override
  String get category => 'Category';

  @override
  String get allCategories => 'All Categories';

  @override
  String get addNewCategory => 'Add new category...';

  @override
  String get manageCategories => 'Manage categories...';

  @override
  String get status => 'Status';

  @override
  String get allTasks => 'All Tasks';

  @override
  String get open => 'Open';

  @override
  String get done => 'Done';

  @override
  String get noTasksFound => 'No tasks found';

  @override
  String get addYourFirstTaskToGetStarted =>
      'Add your first task to get started!';

  @override
  String get addCategory => 'Add Category';

  @override
  String get categoryName => 'Category name';

  @override
  String get add => 'Add';

  @override
  String get namecategoryRequired => 'Name is required';

  @override
  String get manageCategories2 => 'Manage Categories';

  @override
  String get removeCategory => 'Remove Category';

  @override
  String get removing => 'Removing \'';

  @override
  String get removingcatmessage =>
      ' will PERMANENTLY delete all tasks under this category. This action cannot be undone. Are you sure?';

  @override
  String get categoryanditstasksremoved => 'Category and its tasks removed';

  @override
  String get errorremovingcategory => 'Error removing category: ';

  @override
  String get errorupdatingtask => 'Error updating task: ';

  @override
  String due(Object dueDate) {
    return 'Due: $dueDate';
  }

  @override
  String get erroraddingcategory => 'Error adding category: ';

  @override
  String get defaultcategorycannotberemoved =>
      'Default category cannot be removed.';

  @override
  String get errorloadingcategories => 'Error loading categories: ';

  @override
  String get selectDueDate => 'Select Due Date';

  @override
  String get pleasefillinallrequiredfields =>
      'Please fill in all required fields';

  @override
  String get pleaseselectacategory => 'Please select a category';

  @override
  String get usernotauthenticated => 'User not authenticated';

  @override
  String get errorsavingtask => 'Error saving task: ';

  @override
  String get addTask => 'Add Task';

  @override
  String get taskName => 'Task Name *';

  @override
  String get enterTaskName => 'Enter task name';

  @override
  String get tasknameisrequired => 'Task name is required';

  @override
  String get tasknamemustbe100charactersorless =>
      'Task name must be 100 characters or less';

  @override
  String get dueDate => 'Due Date';

  @override
  String get nonotificationifdatenotset => 'No notification if date not set';

  @override
  String get category1 => 'Category *';

  @override
  String get selectcategory => 'Select category';

  @override
  String get nocategoryfound =>
      'No categories found. Please create a category first.';

  @override
  String get saveTask => 'Save Task';

  @override
  String get todaysOccasions => 'Today';

  @override
  String get notifiedOccasions => 'Coming..';

  @override
  String get occasions => 'Occasions';

  @override
  String get noNotifiedOccasions => 'No notified occasions';

  @override
  String get importantOccasions => 'Important Occasions';

  @override
  String get noImportantOccasions => 'No important occasions found';

  @override
  String get noImportantOccasionsMessage =>
      'You don\'t have any high priority occasions yet. Add some occasions and mark them as high priority to see them here.';

  @override
  String get feedback => 'Feedback';

  @override
  String get addYourFirstRemnederToGetStarted =>
      'Add your first reminder to get started!';

  @override
  String get permissionRequired => 'Notification Permission Needed';

  @override
  String get taskNotFound => 'Task not found';

  @override
  String get taskUpdated => 'Task updated successfully';

  @override
  String get errorUpdating => 'Error updating: ';

  @override
  String get removeTask => 'Remove Task';

  @override
  String get areYouSureYouWantToRemoveThisTask =>
      'Are you sure you want to remove this task?';

  @override
  String get yes => 'Yes';

  @override
  String get no => 'No';

  @override
  String get taskRemoved => 'Task removed Successfully';

  @override
  String get errorRemovingTask => 'Error removing task: ';

  @override
  String get taskDetails => 'Task Details';

  @override
  String get statusTask => 'Status *';

  @override
  String get modify => 'Modify';

  @override
  String get overdue => 'Overdue';

  @override
  String get updateReminder => 'Update Reminder';

  @override
  String get validNumberbetween => 'Please enter a number between 1 and 99.';

  @override
  String get pleaseselectAtLeastOneWeekday =>
      'Please select at least one weekday';

  @override
  String get pleaseselecydatetime => 'Please select date & time';

  @override
  String get pleaseselectanuntildate => 'Please select an until date';

  @override
  String get reminderUpdatedSuccessfully => 'Reminder updated successfully';

  @override
  String get errorUpdatingReminder => 'Error updating reminder: ';

  @override
  String get reminderDeletedSuccessfully => 'Reminder deleted successfully';

  @override
  String get errorDeletingReminder => 'Error deleting reminder: ';

  @override
  String get timeOfReminder => 'Time of Reminder';

  @override
  String get selectfuturedatetime => 'Please select a future date & time';

  @override
  String get error => 'Error';

  @override
  String get tasksavedSuccessfully => 'Task added successfully';

  @override
  String get dailyDeed => 'Daily Deeds';

  @override
  String get religiousDeed => 'Religious Daily Deeds';

  @override
  String get statisticsreligiousDeed => 'Religious Deed Statistics';

  @override
  String get followUs => 'Follow Us';

  @override
  String get deedName => 'Deed Name';

  @override
  String get enterDeedName => 'Please enter deed name';

  @override
  String get prayers => 'Prayers';

  @override
  String get fajr => 'Fajr';

  @override
  String get dhur => 'Dhur';

  @override
  String get asr => 'Asr';

  @override
  String get maghrib => 'Maghrib';

  @override
  String get isa => 'Isha';

  @override
  String get tahajjud => 'Tahajjud';

  @override
  String get witr => 'Witr';

  @override
  String get taraweeh => 'Taraweeh';

  @override
  String get learning => 'Learning';

  @override
  String get readQuran => 'Read Quran';

  @override
  String get fasting => 'Fasting';

  @override
  String get ramadanFasting => 'Fasting';

  @override
  String get notPrayed => 'Not Prayed';

  @override
  String get late => 'Late';

  @override
  String get onTime => 'On Time';

  @override
  String get inJamaah => 'In Jamaah';

  @override
  String get missed => 'Missed';

  @override
  String get completed => 'Completed';

  @override
  String get chapters => 'Chapters';

  @override
  String get selectChapters => 'Select chapters';

  @override
  String get retry => 'Retry';

  @override
  String get sunnahPrayers => 'Sunnah';

  @override
  String get sunnah => 'Sunnah';

  @override
  String get fajrSunnah => 'Fajr Sunnah';

  @override
  String get doha => 'Doha';

  @override
  String get dhurSunnah => 'Dhur Sunnah';

  @override
  String get maghribSunnah => 'Maghrib Sunnah';

  @override
  String get isaSunnah => 'Isha Sunnah';

  @override
  String get morningSupplications => 'Morning Supplications';

  @override
  String get eveningSupplications => 'Evening Supplications';

  @override
  String get supplications => 'Supplications';

  @override
  String get surahAlKahf => 'Surah Al-Kahf';

  @override
  String get connectionIssue => 'Connection Issue';

  @override
  String get choose => 'Choose';

  @override
  String get totalChaptersRead => 'Total chapters read';

  @override
  String get daysWithReading => 'Days with reading';

  @override
  String get distribution => 'Distribution';

  @override
  String get parts => 'parts';

  @override
  String get statistics => 'Statistics';

  @override
  String get selectMonth => 'Select Month';

  @override
  String get currentMonth => 'Current Month';

  @override
  String get nextMonth => 'Next Month';

  @override
  String get notSelected => 'Not Selected';

  @override
  String get prayerStatistics => 'Prayer Statistics';

  @override
  String get naflPrayers => 'Nafl Prayers';

  @override
  String get sunnahStatistics => 'Sunnah Statistics';

  @override
  String get learningStatistics => 'Learning Statistics';

  @override
  String get fastingStatistics => 'Fasting Statistics';

  @override
  String get customDailyDeeds => 'Custom Daily Deeds';

  @override
  String get addCustomDeed => 'Add Custom Deed';

  @override
  String get editCustomDeed => 'Edit Custom Deed';

  @override
  String get selectStartDate => 'Select Start Date';

  @override
  String get selectEndDate => 'Select End Date';

  @override
  String get deleteDeed => 'Delete Deed';

  @override
  String get deleteDeedConfirm => 'Are you sure you want to delete this deed?';

  @override
  String get noCustomDeeds => 'No custom deeds yet';

  @override
  String get tapToAddDeed => 'Tap + to add your first custom deed';

  @override
  String monthStatistics(Object month) {
    return '$month Statistics';
  }

  @override
  String get totalDays => 'Total Days';

  @override
  String get daysInMonth => 'Days in Month';

  @override
  String statValueCount(Object count, Object value) {
    return '$count $value';
  }

  @override
  String percentage(Object percentage) {
    return '$percentage%';
  }

  @override
  String get graph => 'Graph';

  @override
  String get eidPrayer => 'Eid Prayer';

  @override
  String get health => 'Health';

  @override
  String get bloodPressure => 'Blood Pressure';

  @override
  String get bloodSugar => 'Blood Sugar';

  @override
  String get unit => 'Unit';

  @override
  String get bloodSugarValue => 'Blood Sugar Value';

  @override
  String get enterBloodSugarValue => 'Enter blood sugar value';

  @override
  String get invalidBloodSugarValue => 'Please enter a valid blood sugar value';

  @override
  String get lowBloodSugar => 'Low';

  @override
  String get normalBloodSugar => 'Normal';

  @override
  String get preDiabetesBloodSugar => 'Pre-Diabetes';

  @override
  String get diabetesBloodSugar => 'Diabetes';

  @override
  String get beforeMeal => 'Before a Meal';

  @override
  String get afterMeal1h => 'After a Meal (1h)';

  @override
  String get afterMeal2h => 'After a Meal (2h)';

  @override
  String get sleep => 'Sleep';

  @override
  String get beforeExercise => 'Before Exercise';

  @override
  String get afterExercise => 'After Exercise';

  @override
  String get defaultCondition => 'Default';

  @override
  String get export => 'Export';

  @override
  String get noDataToExport => 'No data to export';

  @override
  String get noDataToShare => 'No data to share';

  @override
  String get shareError => 'Error sharing data';

  @override
  String get healthInfo => 'Health Info';

  @override
  String get track => 'Track';

  @override
  String get history => 'History';

  @override
  String get addMeasurement => 'Add Measurement';

  @override
  String get editMeasurement => 'Edit Measurement';

  @override
  String get measurementName => 'Measurement Name';

  @override
  String get enterMeasurementName => 'Enter measurement name';

  @override
  String get measurementNameRequired => 'Measurement name is required';

  @override
  String get enterDescription => 'Enter description (optional)';

  @override
  String get selectDate => 'Select date';

  @override
  String get systolic => 'Systolic';

  @override
  String get diastolic => 'Diastolic';

  @override
  String get pulse => 'Pulse';

  @override
  String get enterSystolic => 'Enter systolic value';

  @override
  String get enterDiastolic => 'Enter diastolic value';

  @override
  String get enterPulse => 'Enter pulse value';

  @override
  String get mmHg => 'mmHg';

  @override
  String get bpm => 'bpm';

  @override
  String get arm => 'Arm';

  @override
  String get leftArm => 'Left Arm';

  @override
  String get rightArm => 'Right Arm';

  @override
  String get position => 'Position';

  @override
  String get sitting => 'Sitting';

  @override
  String get standing => 'Standing';

  @override
  String get lyingDown => 'Lying Down';

  @override
  String get condition => 'Condition';

  @override
  String get atRest => 'At Rest';

  @override
  String get afterMeal => 'After Meal';

  @override
  String get stressed => 'Stressed';

  @override
  String get update => 'Update';

  @override
  String get noMeasurementsToday => 'No measurements today';

  @override
  String get tapToAddMeasurement => 'Tap + to add your first measurement';

  @override
  String get todayMeasurements => 'Today\'s Measurements';

  @override
  String get dailyBloodSugarStatistics => 'Daily Blood Sugar Statistics';

  @override
  String get dailyBloodPressureStatistics => 'Daily Blood Pressure Statistics';

  @override
  String get average => 'Average';

  @override
  String get min => 'Min';

  @override
  String get max => 'Max';

  @override
  String get totalMeasurements => 'Total Measurements';

  @override
  String get normal => 'Normal';

  @override
  String get elevated => 'Elevated';

  @override
  String get highStage1 => 'High (Stage 1)';

  @override
  String get highStage2 => 'High (Stage 2)';

  @override
  String get hypertensiveCrisis => 'Hypertensive Crisis';

  @override
  String get week => 'Week';

  @override
  String get month => 'Month';

  @override
  String get year => 'Year';

  @override
  String get noHistoryData => 'No history data available';

  @override
  String get exportData => 'Export Data';

  @override
  String get exportAsCsv => 'Export as CSV';

  @override
  String get exportAsPdf => 'Export as PDF';

  @override
  String get download => 'Download';

  @override
  String get share => 'Share';

  @override
  String get sharePdf => 'Share PDF';

  @override
  String get shareCsv => 'Share CSV';

  @override
  String get downloadPdf => 'Save as PDF';

  @override
  String get downloadCsv => 'Download CSV';

  @override
  String get exportSuccess => 'Data exported successfully';

  @override
  String get exportError => 'Error exporting data';

  @override
  String get measurementAdded => 'Measurement added successfully';

  @override
  String get measurementUpdated => 'Measurement updated successfully';

  @override
  String get measurementDeleted => 'Measurement deleted successfully';

  @override
  String get errorAddingMeasurement => 'Error adding measurement';

  @override
  String get errorUpdatingMeasurement => 'Error updating measurement';

  @override
  String get errorDeletingMeasurement => 'Error deleting measurement';

  @override
  String get deleteMeasurementConfirm =>
      'Are you sure you want to delete this measurement?';

  @override
  String get measurementDetails => 'Measurement Details';

  @override
  String get today => 'Today';

  @override
  String get yesterday => 'Yesterday';

  @override
  String get targetRanges => 'Target Ranges';

  @override
  String get editTargetRanges => 'Edit Target Ranges';

  @override
  String get customRangesActive => 'Custom ranges are active';

  @override
  String get defaultRangesInfo => 'Using default medical ranges';

  @override
  String get editRanges => 'Edit Ranges';

  @override
  String get resetToDefault => 'Reset to Default';

  @override
  String get low => 'Low';

  @override
  String get preDiabetes => 'Pre-Diabetes';

  @override
  String get diabetes => 'Diabetes';

  @override
  String get saveRanges => 'Save Ranges';

  @override
  String get rangesSaved => 'Ranges saved successfully';

  @override
  String get greaterThan => 'Greater than';

  @override
  String get lessThan => 'Less than';

  @override
  String get lowRange => 'Low Range';

  @override
  String get normalRange => 'Normal Range';

  @override
  String get preDiabetesRange => 'Pre-Diabetes Range';

  @override
  String get diabetesRange => 'Diabetes Range';

  @override
  String get and => 'and';

  @override
  String get bloodPressureRanges => 'Blood Pressure Ranges';

  @override
  String get editBloodPressureRanges => 'Edit Blood Pressure Ranges';

  @override
  String get systolicMin => 'Systolic Min';

  @override
  String get systolicMax => 'Systolic Max';

  @override
  String get diastolicMin => 'Diastolic Min';

  @override
  String get diastolicMax => 'Diastolic Max';

  @override
  String get normalBP => 'Normal';

  @override
  String get elevatedBP => 'Elevated';

  @override
  String get highStage1BP => 'High (Stage 1)';

  @override
  String get highStage2BP => 'High (Stage 2)';

  @override
  String get crisisBP => 'Crisis';

  @override
  String get rangesSettingsNote =>
      'Customize target ranges based on doctor recommendations';

  @override
  String get basicInfo => 'Basic Info';

  @override
  String get addBasicInfo => 'Add Basic Info';

  @override
  String get fullName => 'Full Name';

  @override
  String get enterFullName => 'Enter your full name';

  @override
  String get bloodType => 'Blood Type';

  @override
  String get selectBloodType => 'Select blood type';

  @override
  String get dateOfBirth => 'Date of Birth';

  @override
  String get height => 'Height';

  @override
  String get enterHeight => 'Enter height';

  @override
  String get weight => 'Weight';

  @override
  String get enterWeight => 'Enter weight';

  @override
  String get allergies => 'Allergies';

  @override
  String get addMedicationAllergy => 'Add Medication Allergy';

  @override
  String get addFoodAllergy => 'Add Food Allergy';

  @override
  String get noAllergies => 'No allergies recorded';

  @override
  String get addAllergyHint => 'Tap + to add an allergy';

  @override
  String get addCustom => 'Add Custom';

  @override
  String get enterCustomAllergy => 'Enter custom allergy';

  @override
  String get selectFromList => 'Select from list';

  @override
  String get saveSelected => 'Save Selected';

  @override
  String get custom => 'Custom';

  @override
  String get medications => 'Medications';

  @override
  String get food => 'Food';

  @override
  String get active => 'Active';

  @override
  String get noData => 'No data';

  @override
  String get chronicDiseases => 'Chronic Diseases';

  @override
  String get addChronicDisease => 'Add Chronic Disease';

  @override
  String get noChronicDiseases => 'No chronic diseases recorded';

  @override
  String get addDiseaseHint => 'Tap + to add a disease';

  @override
  String get enterCustomDisease => 'Enter custom disease';

  @override
  String get medicationName => 'Medication Name';

  @override
  String get enterMedicationName => 'Enter medication name';

  @override
  String get dosage => 'Dosage';

  @override
  String get enterDosage => 'Enter dosage';

  @override
  String get frequency => 'Frequency';

  @override
  String get enterValidNumber => 'Enter a valid number';

  @override
  String get reminderTimes => 'Reminder Times';

  @override
  String get addTime => 'Add Time';

  @override
  String get noMedications => 'No medications recorded';

  @override
  String get addMedicationHint => 'Tap + to add a medication';

  @override
  String get editMedication => 'Edit Medication';

  @override
  String get addMedication => 'Add Medication';

  @override
  String get emergencyInfo => 'Emergency Info';

  @override
  String get noEmergencyContacts => 'No emergency contacts';

  @override
  String get addEmergencyContactHint => 'Tap + to add an emergency contact';

  @override
  String get addContact => 'Add Contact';

  @override
  String get editContact => 'Edit Contact';

  @override
  String get enterContactName => 'Enter contact name';

  @override
  String get phoneNumber => 'Phone Number';

  @override
  String get enterPhoneNumber => 'Enter phone number';

  @override
  String get relationshipOptional => 'Relationship (Optional)';

  @override
  String get enterRelationship => 'e.g., Spouse, Parent';

  @override
  String get call => 'Call';

  @override
  String get medicalNotes => 'Medical Notes';

  @override
  String get noMedicalNotes => 'No medical notes';

  @override
  String get addMedicalNoteHint => 'Tap + to add a note';

  @override
  String get addMedicalNote => 'Add Medical Note';

  @override
  String get editMedicalNote => 'Edit Medical Note';

  @override
  String get noteContent => 'Note Content';

  @override
  String get enterNoteContent => 'Enter your note here...';

  @override
  String get dateAndTime => 'Date & Time';

  @override
  String get confirmDelete => 'Confirm Delete';

  @override
  String get deleteAllergyConfirm =>
      'Are you sure you want to delete this allergy?';

  @override
  String get deleteDiseaseConfirm =>
      'Are you sure you want to delete this disease?';

  @override
  String get deleteMedicationConfirm =>
      'Are you sure you want to delete this medication?';

  @override
  String get deleteContactConfirm =>
      'Are you sure you want to delete this contact?';

  @override
  String get deleteNoteConfirm => 'Are you sure you want to delete this note?';

  @override
  String get savedSuccessfully => 'Saved successfully';

  @override
  String get errorSaving => 'Error saving data';

  @override
  String get pleaseEnterValue => 'Please enter a value';

  @override
  String get edit => 'Edit';
}
