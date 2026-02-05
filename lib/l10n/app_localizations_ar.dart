// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Arabic (`ar`).
class AppLocalizationsAr extends AppLocalizations {
  AppLocalizationsAr([String locale = 'ar']) : super(locale);

  @override
  String get appTitle => 'مهتم';

  @override
  String get login => 'تسجيل الدخول';

  @override
  String get logout => 'تسجيل الخروج';

  @override
  String get welcome => 'مرحبا';

  @override
  String get noAnniversariesToday => 'لا توجد مناسبات محفوظة لهذا اليوم، \nيمكنك إضافة مناسبة جديدة';

  @override
  String get title => 'مهتم';

  @override
  String get mohtmMenu => 'قائمة مهتم';

  @override
  String get rateUs => 'قيمنا';

  @override
  String get settings => 'الإعدادات';

  @override
  String get shareApp => 'شارك التطبيق';

  @override
  String get changePassword => 'تغيير كلمة المرور';

  @override
  String typeLabel(Object type) {
    return 'النوع: $type';
  }

  @override
  String get startDate => 'تاريخ البدء';

  @override
  String get endDate => 'تاريخ الانتهاء';

  @override
  String get filter => 'تصفية';

  @override
  String get clearFilter => 'مسح التصفية';

  @override
  String get noAnniversariesFound => 'لا توجد مناسبات';

  @override
  String get profileUpdatedsuccessfully => 'تم تحديث الملف الشخصي بنجاح';

  @override
  String get profileUpdateFailed => 'فشل تحديث الملف الشخصي';

  @override
  String get profile => 'الملف الشخصي';

  @override
  String get firstName => 'الاسم الأول';

  @override
  String get lastName => 'الاسم الأخير';

  @override
  String get email => 'البريد الإلكتروني';

  @override
  String get phone => 'رقم الهاتف';

  @override
  String get birthdate => 'تاريخ الميلاد';

  @override
  String get gender => 'الجنس';

  @override
  String get forgetPassword => 'نسيت كلمة المرور';

  @override
  String get pleaseEntervalidEmail => 'الرجاء إدخال بريد إلكتروني صالح';

  @override
  String get restPassword => 'إعادة تعيين كلمة المرور';

  @override
  String get changePasswordSuccessMessage => 'تم تغيير كلمة المرور بنجاح';

  @override
  String get changePasswordErrorMessage => 'خطأ في تغيير كلمة المرور';

  @override
  String get changePasswordTitle => 'تغيير كلمة المرور';

  @override
  String get currentPassword => 'كلمة المرور الحالية';

  @override
  String get newPassword => 'كلمة المرور الجديدة';

  @override
  String get confirmNewPassword => 'تأكيد كلمة المرور الجديدة';

  @override
  String get entercurrentPassword => 'الرجاء إدخال كلمة المرور الحالية';

  @override
  String get enterNewPassword => 'الرجاء إدخال كلمة المرور الجديدة';

  @override
  String get passwordLengthValidation => 'يجب أن تكون كلمة المرور الجديدة على الأقل 6 أحرف';

  @override
  String get passwordMatchValidation => 'يجب أن تتطابق كلمة المرور الجديدة مع تأكيد كلمة المرور الجديدة';

  @override
  String get enterConfirmNewPassword => 'الرجاء إدخال تأكيد كلمة المرور الجديدة';

  @override
  String get passwordsDoNotMatch => 'كلمة المرور الجديدة وتأكيد كلمة المرور الجديدة لا تتطابقان';

  @override
  String get passwordChangedSuccessfully => 'تم تغيير كلمة المرور بنجاح';

  @override
  String get changePasswordButtonText => 'تغيير كلمة المرور';

  @override
  String get description => ' وصف المناسبه';

  @override
  String get date => 'التاريخ';

  @override
  String get type => 'النوع';

  @override
  String get relationship => 'العلاقة';

  @override
  String get priority => 'الأولوية';

  @override
  String get rememberBefore => 'تذكير قبل ';

  @override
  String get atTimeOfEvent => 'في وقت الحدث';

  @override
  String get anntitle => 'عنوان المناسبة';

  @override
  String get deleteAnniversary => 'حذف المناسبة';

  @override
  String get deleteAnniversaryConfirmation => 'هل أنت متأكد أنك تريد حذف هذه المناسبة؟';

  @override
  String get cancel => 'إلغاء';

  @override
  String get delete => 'حذف';

  @override
  String get addAnniversaryTitle => 'إضافة مناسبة جديدة';

  @override
  String get selectDateLabel => 'اختر التاريخ';

  @override
  String get anniversaryNameLabel => 'اسم المناسبة';

  @override
  String get anniversaryNameHint => 'أدخل اسم المناسبة';

  @override
  String get anniversaryNameValidation => 'الرجاء إدخال اسم المناسبة';

  @override
  String get anniversaryDescriptionLabel => 'وصف المناسبة';

  @override
  String get anniversaryDescriptionHint => 'أدخل وصف المناسبة';

  @override
  String get anniversarytypeValidation => 'الرجاء اختيار نوع المناسبة';

  @override
  String get specifyType => 'نوع محدد';

  @override
  String get anniversaryOtherTypeValidation => 'الرجاء تحديد نوع المناسبة';

  @override
  String get relationshipHint => 'أدخل العلاقة';

  @override
  String get priorityValidation => 'الرجاء اختيار أولوية';

  @override
  String get save => 'حفظ';

  @override
  String get loginToMohtm => 'MOHTM';

  @override
  String get password => 'كلمة المرور';

  @override
  String get forgetPasswordquestion => 'هل نسيت كلمة المرور؟';

  @override
  String get donthaveAnAccount => 'ليس لديك حساب؟';

  @override
  String get userNotFound => 'البريد الإلكتروني أو كلمة المرور غير صحيحة';

  @override
  String get errorOccurred => 'حدث خطأ';

  @override
  String get register => 'تسجيل';

  @override
  String get registerTitle => 'إنشاء حساب جديد';

  @override
  String get firstNamevalidation => 'الرجاء إدخال الاسم الأول';

  @override
  String get lastNamevalidation => 'الرجاء إدخال الاسم الأخير';

  @override
  String get emailValidation => 'الرجاء إدخال بريد إلكتروني صالح';

  @override
  String get phoneValidation => 'الرجاء إدخال رقم هاتف صالح';

  @override
  String get passwordValidation => 'الرجاء إدخال كلمة المرور';

  @override
  String get confirmPassword => 'تأكيد كلمة المرور';

  @override
  String get pleaseConfirmPassword => 'الرجاء تأكيد كلمة المرور';

  @override
  String get registerSuccessMessage => 'تم التسجيل بنجاح';

  @override
  String get registerErrorMessage => 'خطأ في التسجيل';

  @override
  String get registerSuccessMessageWithVerification => 'تم التسجيل بنجاح! يرجى التحقق من بريدك الإلكتروني (و المزعج(Spam /Junk Folder))  لتفعيل الحساب قبل تسجيل الدخول.';

  @override
  String get emailNotVerifiedMessage => 'بريدك الإلكتروني غير مفعل. يرجى التحقق من بريدك (و المزعج(Spam /Junk Folder)) وتفعيل الحساب قبل تسجيل الدخول.';

  @override
  String get soticalUseNotFound => ' المستخدم غير موجود، يرجى التسجيل أولاً';

  @override
  String get signinwithGoogle => 'تسجيل الدخول باستخدام جوجل';

  @override
  String get signinwithFacebook => 'تسجيل الدخول باستخدام فيسبوك';

  @override
  String get sigupWithGoogle => 'إنشاء حساب باستخدام جوجل';

  @override
  String get sigupWithFacebook => 'إنشاء حساب باستخدام فيسبوك';

  @override
  String get rememberme => 'ذكرني';

  @override
  String get feedbackrequiredFields => 'العنوان والتعليق مطلوبان.';

  @override
  String get commentTooLong => 'التعليق طويل جدًا. يرجى تقصيره إلى 1000 حرف أو أقل.';

  @override
  String get feedbackSent => 'تم إرسال الملاحظات بنجاح';

  @override
  String get feedbackError => 'خطأ في إرسال الملاحظات';

  @override
  String get feedbackTitle => 'تواصل معنا';

  @override
  String get subject => 'الموضوع';

  @override
  String get body => 'المحتوى';

  @override
  String get send => 'إرسال';

  @override
  String get contactUs => 'تواصل معنا';

  @override
  String passwordResetSent(Object email) {
    return 'تم إرسال رسالة إعادة تعيين كلمة المرور إلى $email. يرجى التحقق من بريدك الوارد (و المزعج(Spam /Junk Folder)).';
  }

  @override
  String get emailNotFound => 'البريد الإلكتروني غير موجودً';

  @override
  String errorSendRestmail(Object errorMessage) {
    return 'خطأ في إرسال رسالة إعادة تعيين كلمة المرور: $errorMessage';
  }

  @override
  String get unexpectedErrorOccurred => 'حدث خطأ غير متوقع.';

  @override
  String get pleaseInterValidInputs => 'الرجاء إدخال بيانات صحيحة';

  @override
  String get userNotLogin => 'المستخدم غير مسجل الدخول';

  @override
  String get annAddSuccessfully => 'تمت إضافة المناسبة بنجاح';

  @override
  String get failtoAddAnniversary => 'فشل في إضافة المناسبة، يرجى المحاولة مرة أخرى لاحقًا';

  @override
  String get dateValidation => 'يرجى اختيار التاريخ.';

  @override
  String get annUpdateSuccessfully => 'تم تحديث المناسبة بنجاح';

  @override
  String get failtoUpdateAnniversary => 'فشل في تحديث المناسبة، يرجى المحاولة مرة أخرى لاحقًا';

  @override
  String get oldPasswordIncorrect => 'كلمة المرور القديمة غير صحيحة. يرجى المحاولة مرة أخرى.';

  @override
  String get occasionDetails => 'تفاصيل المناسبة';

  @override
  String get reminders => 'التذكيرات';

  @override
  String get exactAlarmPermissionTitle => 'مطلوب إذن التنبيهات الدقيقة';

  @override
  String get exactAlarmPermissionMessage => 'لضمان عمل التذكيرات بشكل موثوق، تأكد من السماح بإذن \"جدولة التنبيهات الدقيقة\" في إعدادات النظام.';

  @override
  String get open_sertings => 'فتح الإعدادات';

  @override
  String get noReminders => 'لا توجد تذكيرات.';

  @override
  String get repeat => 'تكرار';

  @override
  String get addReminder => 'إضافة تذكير';

  @override
  String get fixNotificationsPermission => 'إصلاح إذن الإشعارات';

  @override
  String get reminderTitle => ' عنوان التذكير';

  @override
  String get reminderTitleRequired => 'عنوان التذكير مطلوب';

  @override
  String get reminderTitleTooLong => 'عنوان التذكير  يجب أن يكون بحد أقصى 100 حرف';

  @override
  String get selecydatetime => 'اختر التاريخ والوقت';

  @override
  String get saveReminder => 'حفظ التذكير';

  @override
  String get duration => 'المدة';

  @override
  String get forever => 'إلى الأبد';

  @override
  String get count => 'عدد محدد من المرات';

  @override
  String get untilDate => 'حتى تاريخ معين';

  @override
  String get repeatCount => 'عدد المرات';

  @override
  String get repeatCountRequired => 'عدد المرات مطلوب';

  @override
  String get repeatCountvalidation => 'الرجاء إدخال رقم صحيح أكبر من 0';

  @override
  String get untilDate2 => 'حتى تاريخ';

  @override
  String get notSet => 'غير محدد';

  @override
  String get unit_minute => 'دقيقة';

  @override
  String get unit_hour => 'ساعة';

  @override
  String get unit_day => 'يوم';

  @override
  String get unit_week => 'أسبوع';

  @override
  String get unit_month => 'شهر';

  @override
  String get unit_year => 'سنة';

  @override
  String get dontrepeat => 'لا تكرر';

  @override
  String get every => 'كل';

  @override
  String get confirm => 'تأكيد';

  @override
  String get reminderDelete => 'حذف التذكير';

  @override
  String get reminderDeleteConfirmation => 'هل أنت متأكد أنك تريد حذف هذا التذكير؟';

  @override
  String get tasks => 'المهام';

  @override
  String get category => 'الفئة';

  @override
  String get allCategories => 'جميع الفئات';

  @override
  String get addNewCategory => 'إضافة فئة جديدة...';

  @override
  String get manageCategories => 'إدارة الفئات...';

  @override
  String get status => 'الحالة';

  @override
  String get allTasks => 'جميع المهام';

  @override
  String get open => 'مفتوح';

  @override
  String get done => 'انجزت';

  @override
  String get noTasksFound => 'لا توجد مهام';

  @override
  String get addYourFirstTaskToGetStarted => 'إضافة مهمة جديدة للبدء!';

  @override
  String get addCategory => 'إضافة فئة';

  @override
  String get categoryName => 'اسم الفئة';

  @override
  String get add => 'إضافة';

  @override
  String get namecategoryRequired => 'اسم الفئة مطلوب';

  @override
  String get manageCategories2 => 'إدارة القائمات';

  @override
  String get removeCategory => 'حذف الفئة';

  @override
  String get removing => 'حذف \'';

  @override
  String get removingcatmessage => ' سيتم حذف جميع المهام تحت هذه الفئة. لا يمكن التراجع عن هذا الإجراء. هل أنت متأكد؟';

  @override
  String get categoryanditstasksremoved => 'تم حذف الفئة وجميع المهام تحتها';

  @override
  String get errorremovingcategory => 'خطأ في حذف الفئة: ';

  @override
  String get errorupdatingtask => 'خطأ في تحديث المهمة: ';

  @override
  String due(Object dueDate) {
    return ' ينتهى فى: $dueDate';
  }

  @override
  String get erroraddingcategory => 'خطأ في إضافة الفئة: ';

  @override
  String get defaultcategorycannotberemoved => 'الفئة الافتراضية لا يمكن حذفها.';

  @override
  String get errorloadingcategories => 'خطأ في تحميل القائمات: ';

  @override
  String get selectDueDate => 'اختر تاريخ الانتهاء';

  @override
  String get pleasefillinallrequiredfields => 'الرجاء إدخال جميع الحقول المطلوبة';

  @override
  String get pleaseselectacategory => 'الرجاء اختيار الفئة';

  @override
  String get usernotauthenticated => 'المستخدم غير مصرح له';

  @override
  String get errorsavingtask => 'خطأ في حفظ المهمة: ';

  @override
  String get addTask => 'إضافة مهمة';

  @override
  String get taskName => 'اسم المهمة *';

  @override
  String get enterTaskName => 'أدخل اسم المهمة';

  @override
  String get tasknameisrequired => 'اسم المهمة مطلوب';

  @override
  String get tasknamemustbe100charactersorless => 'اسم المهمة يجب أن يكون على الأكثر 100 حرف';

  @override
  String get dueDate => 'تاريخ الانتهاء';

  @override
  String get nonotificationifdatenotset => 'لا توجد إشعارات إذا لم يتم تعيين التاريخ';

  @override
  String get category1 => ' * الفئة';

  @override
  String get selectcategory => 'اختر الفئة';

  @override
  String get nocategoryfound => 'لم يتم العثور على فئات. يُرجى إنشاء فئة أولاً.';

  @override
  String get saveTask => 'حفظ المهمة';

  @override
  String get todaysOccasions => 'اليوم';

  @override
  String get notifiedOccasions => 'القادمه .. ';

  @override
  String get noNotifiedOccasions => 'لا توجد مناسبات مذكرة';

  @override
  String get importantOccasions => 'المناسبات المهمة';

  @override
  String get noImportantOccasions => 'لا توجد مناسبات مهمة';

  @override
  String get noImportantOccasionsMessage => 'ليس لديك أي مناسبات ذات أولوية عالية بعد. أضف بعض المناسبات وحددها كأولوية عالية لتراها هنا.';

  @override
  String get addYourFirstRemnederToGetStarted => 'أضف تذكيرك الأول للبدء!';

  @override
  String get permissionRequired => 'مطلوب إذن الإشعارات';

  @override
  String get taskNotFound => 'المهمة غير موجودة';

  @override
  String get taskUpdated => 'تم تحديث المهمة بنجاح';

  @override
  String get errorUpdating => 'خطأ في التحديث: ';

  @override
  String get removeTask => 'حذف المهمة';

  @override
  String get areYouSureYouWantToRemoveThisTask => 'هل أنت متأكد أنك تريد حذف هذه المهمة؟';

  @override
  String get yes => 'نعم';

  @override
  String get no => 'لا';

  @override
  String get taskRemoved => 'تم حذف المهمة بنجاح';

  @override
  String get errorRemovingTask => 'خطأ في حذف المهمة: ';

  @override
  String get taskDetails => 'تفاصيل المهمة';

  @override
  String get statusTask => 'الحالة *';

  @override
  String get modify => 'تعديل';

  @override
  String get overdue => 'متأخرة';

  @override
  String get updateReminder => 'تعدبل تذكير';

  @override
  String get validNumberbetween => 'الرجاء إدخال رقم بين 1 و 99.';

  @override
  String get pleaseselectAtLeastOneWeekday => 'الرجاء اختيار يوم عمل واحد على الأقل';

  @override
  String get pleaseselecydatetime => 'الرجاء اختيار التاريخ والوقت';

  @override
  String get pleaseselectanuntildate => 'الرجاء اختيار تاريخ النهايه';

  @override
  String get reminderUpdatedSuccessfully => 'تم تحديث التذكير بنجاح';

  @override
  String get errorUpdatingReminder => 'خطأ في تحديث التذكير: ';

  @override
  String get reminderDeletedSuccessfully => 'تم حذف التذكير بنجاح';

  @override
  String get errorDeletingReminder => 'خطأ في حذف التذكير: ';

  @override
  String get timeOfReminder => 'وقت التذكير';

  @override
  String get selectfuturedatetime => 'الرجاء اختيار تاريخ ووقت في المستقبل';

  @override
  String get error => 'خطأ';

  @override
  String get tasksavedSuccessfully => 'تم حفظ المهمة بنجاح';
}
