// DO NOT EDIT. This is code generated via package:intl/generate_localized.dart
// This is a library that provides messages for a ar locale. All the
// messages from the main program should be duplicated here with the same
// function name.

// Ignore issues from commonly used lints in this file.
// ignore_for_file:unnecessary_brace_in_string_interps, unnecessary_new
// ignore_for_file:prefer_single_quotes,comment_references, directives_ordering
// ignore_for_file:annotate_overrides,prefer_generic_function_type_aliases
// ignore_for_file:unused_import, file_names, avoid_escaping_inner_quotes
// ignore_for_file:unnecessary_string_interpolations, unnecessary_string_escapes

import 'package:intl/intl.dart';
import 'package:intl/message_lookup_by_library.dart';

final messages = new MessageLookup();

typedef String MessageIfAbsent(String messageStr, List<dynamic> args);

class MessageLookup extends MessageLookupByLibrary {
  String get localeName => 'ar';

  static String m0(error) => "خطأ في حذف الحساب: ${error}";

  static String m1(error) => "خطأ في جلب الملف الشخصي: ${error}";

  static String m2(error) => "خطأ في جلب صورة الملف الشخصي: ${error}";

  static String m3(error) => "خطأ: ${error}";

  static String m4(error) => "خطأ في حفظ الملف الشخصي: ${error}";

  static String m5(error) => "خطأ في تحديث كلمة المرور: ${error}";

  final messages = _notInlinedMessages(_notInlinedMessages);
  static Map<String, Function> _notInlinedMessages(_) => <String, Function>{
    "Email": MessageLookupByLibrary.simpleMessage("البريد الإلكتروني"),
    "Haveaccount": MessageLookupByLibrary.simpleMessage("ليس لديك حساب؟"),
    "Login": MessageLookupByLibrary.simpleMessage("تسجيل الدخول"),
    "Loginemail": MessageLookupByLibrary.simpleMessage(
      "  التسجيل بالبريد الإلكتروني",
    ),
    "Loginsuccessful": MessageLookupByLibrary.simpleMessage(
      "تم تسجيل الدخول بنجاح!",
    ),
    "Password": MessageLookupByLibrary.simpleMessage("كلمة المرور"),
    "SignUp": MessageLookupByLibrary.simpleMessage("إنشاء حساب"),
    "alreadyHaveAccount": MessageLookupByLibrary.simpleMessage(
      "هل لديك حساب بالفعل؟",
    ),
    "bio": MessageLookupByLibrary.simpleMessage("السيرة الذاتية:"),
    "bioField": MessageLookupByLibrary.simpleMessage("السيرة الذاتية"),
    "cancel": MessageLookupByLibrary.simpleMessage("إلغاء"),
    "changePassword": MessageLookupByLibrary.simpleMessage("تغيير كلمة المرور"),
    "changeProfileImage": MessageLookupByLibrary.simpleMessage(
      "تغيير صورة الملف الشخصي",
    ),
    "confirmPassword": MessageLookupByLibrary.simpleMessage(
      "تأكيد كلمة المرور",
    ),
    "continueText": MessageLookupByLibrary.simpleMessage("متابعة"),
    "currentPassword": MessageLookupByLibrary.simpleMessage(
      "كلمة المرور الحالية",
    ),
    "delete": MessageLookupByLibrary.simpleMessage("حذف"),
    "deleteAccount": MessageLookupByLibrary.simpleMessage("حذف الحساب"),
    "deleteAccountConfirm": MessageLookupByLibrary.simpleMessage(
      "هل تريد حذف حسابك نهائيًا؟",
    ),
    "deleteAccountDialogContent": MessageLookupByLibrary.simpleMessage(
      "هل أنت متأكد من حذف حسابك؟ لا يمكن التراجع عن هذا الإجراء.",
    ),
    "deleteAccountDialogTitle": MessageLookupByLibrary.simpleMessage(
      "حذف الحساب",
    ),
    "editProfile": MessageLookupByLibrary.simpleMessage("تعديل الملف الشخصي"),
    "errorDeletingAccount": m0,
    "errorFetchingProfile": m1,
    "errorFetchingProfilePicture": m2,
    "errorGeneric": m3,
    "errorSavingProfile": m4,
    "errorUpdatingPassword": m5,
    "facebook": MessageLookupByLibrary.simpleMessage("فيسبوك:"),
    "facebookUrl": MessageLookupByLibrary.simpleMessage("رابط فيسبوك"),
    "firstName": MessageLookupByLibrary.simpleMessage("الاسم الأول"),
    "gender": MessageLookupByLibrary.simpleMessage("الجنس"),
    "home": MessageLookupByLibrary.simpleMessage("الرئيسية"),
    "instagram": MessageLookupByLibrary.simpleMessage("إنستغرام:"),
    "instagramUrl": MessageLookupByLibrary.simpleMessage("رابط إنستغرام"),
    "lastName": MessageLookupByLibrary.simpleMessage("اسم العائلة"),
    "linkedin": MessageLookupByLibrary.simpleMessage("لينكدإن:"),
    "linkedinUrl": MessageLookupByLibrary.simpleMessage("رابط لينكدإن"),
    "logout": MessageLookupByLibrary.simpleMessage("تسجيل الخروج"),
    "newPassword": MessageLookupByLibrary.simpleMessage("كلمة المرور الجديدة"),
    "noBioProvided": MessageLookupByLibrary.simpleMessage(
      "لم يتم تقديم سيرة ذاتية",
    ),
    "options": MessageLookupByLibrary.simpleMessage(
      "_____ خيارات تسجيل دخول أخرى _____",
    ),
    "passwordMismatch": MessageLookupByLibrary.simpleMessage(
      "كلمة المرور الجديدة وتأكيد كلمة المرور غير متطابقتين.",
    ),
    "passwordUpdated": MessageLookupByLibrary.simpleMessage(
      "تم تحديث كلمة المرور بنجاح.",
    ),
    "pickImage": MessageLookupByLibrary.simpleMessage("اختر صورة"),
    "profileImageUpdated": MessageLookupByLibrary.simpleMessage(
      "تم تحديث صورة الملف الشخصي.",
    ),
    "profileSaved": MessageLookupByLibrary.simpleMessage(
      "تم حفظ الملف الشخصي بنجاح.",
    ),
    "saveProfile": MessageLookupByLibrary.simpleMessage("حفظ الملف الشخصي"),
    "selectImage": MessageLookupByLibrary.simpleMessage("اختر صورة من المعرض."),
    "selectImageFirst": MessageLookupByLibrary.simpleMessage(
      "يرجى اختيار صورة أولاً.",
    ),
    "signin": MessageLookupByLibrary.simpleMessage("تسجيل الدخول"),
    "signupSubtitle": MessageLookupByLibrary.simpleMessage(
      "سنرسل لك رمزًا عبر البريد الإلكتروني لتسجيل آمن",
    ),
    "signupWithEmail": MessageLookupByLibrary.simpleMessage(
      "أنشئ حسابًا باستخدام البريد الإلكتروني",
    ),
    "splash1": MessageLookupByLibrary.simpleMessage("عالم من التعلم"),
    "splash1_subtitle": MessageLookupByLibrary.simpleMessage(
      "من الطهي إلى البرمجة\nوكل شيء بينهما",
    ),
    "splash2": MessageLookupByLibrary.simpleMessage("تعلم من الأفضل"),
    "splash2_subtitle": MessageLookupByLibrary.simpleMessage(
      "مدربون محترفون وسهلون،\n موثوق بهم من قبل أكثر من 50 مليون متعلم",
    ),
    "splash3": MessageLookupByLibrary.simpleMessage(
      "تعلم بالوتيرة التي تناسبك",
    ),
    "splash3_subtitle": MessageLookupByLibrary.simpleMessage(
      "وصول مدى الحياة للدورات التي اشتريتها،\n في أي وقت ومن أي مكان",
    ),
    "switchLanguage": MessageLookupByLibrary.simpleMessage("تغيير اللغة"),
    "titlelogin": MessageLookupByLibrary.simpleMessage(
      "تسجيل الدخول لمتابعة رحلة \n  تعلمك ",
    ),
    "upload": MessageLookupByLibrary.simpleMessage("تحميل"),
    "uploadFailed": MessageLookupByLibrary.simpleMessage(
      "فشل التحميل. يرجى المحاولة مرة أخرى.",
    ),
    "userNotLoggedIn": MessageLookupByLibrary.simpleMessage(
      "المستخدم غير مسجل الدخول.",
    ),
    "youtube": MessageLookupByLibrary.simpleMessage("يوتيوب:"),
    "youtubeUrl": MessageLookupByLibrary.simpleMessage("رابط يوتيوب"),
  };
}
