// DO NOT EDIT. This is code generated via package:intl/generate_localized.dart
// This is a library that provides messages for a en locale. All the
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
  String get localeName => 'en';

  static String m0(error) => "Error deleting account: ${error}";

  static String m1(error) => "Error fetching profile: ${error}";

  static String m2(error) => "Error fetching profile picture: ${error}";

  static String m3(error) => "Error: ${error}";

  static String m4(error) => "Error saving profile: ${error}";

  static String m5(error) => "Error updating password: ${error}";

  final messages = _notInlinedMessages(_notInlinedMessages);
  static Map<String, Function> _notInlinedMessages(_) => <String, Function>{
    "Email": MessageLookupByLibrary.simpleMessage("Email"),
    "Haveaccount": MessageLookupByLibrary.simpleMessage(
      "Don\'t have an account?",
    ),
    "Login": MessageLookupByLibrary.simpleMessage("Log in"),
    "Loginemail": MessageLookupByLibrary.simpleMessage("  Log in with email"),
    "Loginsuccessful": MessageLookupByLibrary.simpleMessage(
      "Login successful!",
    ),
    "Password": MessageLookupByLibrary.simpleMessage("Password"),
    "SignUp": MessageLookupByLibrary.simpleMessage("Sign Up"),
    "alreadyHaveAccount": MessageLookupByLibrary.simpleMessage(
      "Already have an account?",
    ),
    "bio": MessageLookupByLibrary.simpleMessage("Bio:"),
    "bioField": MessageLookupByLibrary.simpleMessage("Bio"),
    "cancel": MessageLookupByLibrary.simpleMessage("Cancel"),
    "changePassword": MessageLookupByLibrary.simpleMessage("Change Password"),
    "changeProfileImage": MessageLookupByLibrary.simpleMessage(
      "Change Profile Image",
    ),
    "confirmPassword": MessageLookupByLibrary.simpleMessage("Confirm Password"),
    "continueText": MessageLookupByLibrary.simpleMessage("Continue"),
    "currentPassword": MessageLookupByLibrary.simpleMessage("Current Password"),
    "delete": MessageLookupByLibrary.simpleMessage("Delete"),
    "deleteAccount": MessageLookupByLibrary.simpleMessage("Delete Account"),
    "deleteAccountConfirm": MessageLookupByLibrary.simpleMessage(
      "Permanently delete your account?",
    ),
    "deleteAccountDialogContent": MessageLookupByLibrary.simpleMessage(
      "Are you sure you want to delete your account? This action cannot be undone.",
    ),
    "deleteAccountDialogTitle": MessageLookupByLibrary.simpleMessage(
      "Delete Account",
    ),
    "editProfile": MessageLookupByLibrary.simpleMessage("Edit Profile"),
    "errorDeletingAccount": m0,
    "errorFetchingProfile": m1,
    "errorFetchingProfilePicture": m2,
    "errorGeneric": m3,
    "errorSavingProfile": m4,
    "errorUpdatingPassword": m5,
    "facebook": MessageLookupByLibrary.simpleMessage("Facebook:"),
    "facebookUrl": MessageLookupByLibrary.simpleMessage("Facebook URL"),
    "firstName": MessageLookupByLibrary.simpleMessage("First Name"),
    "gender": MessageLookupByLibrary.simpleMessage("Gender"),
    "home": MessageLookupByLibrary.simpleMessage("Home"),
    "instagram": MessageLookupByLibrary.simpleMessage("Instagram:"),
    "instagramUrl": MessageLookupByLibrary.simpleMessage("Instagram URL"),
    "lastName": MessageLookupByLibrary.simpleMessage("Last Name"),
    "linkedin": MessageLookupByLibrary.simpleMessage("LinkedIn:"),
    "linkedinUrl": MessageLookupByLibrary.simpleMessage("LinkedIn URL"),
    "logout": MessageLookupByLibrary.simpleMessage("Log out"),
    "newPassword": MessageLookupByLibrary.simpleMessage("New Password"),
    "noBioProvided": MessageLookupByLibrary.simpleMessage("No bio provided"),
    "options": MessageLookupByLibrary.simpleMessage(
      "_____ Other login options _____",
    ),
    "passwordMismatch": MessageLookupByLibrary.simpleMessage(
      "New password and confirm password do not match.",
    ),
    "passwordUpdated": MessageLookupByLibrary.simpleMessage(
      "Password updated successfully.",
    ),
    "pickImage": MessageLookupByLibrary.simpleMessage("Pick Image"),
    "profileImageUpdated": MessageLookupByLibrary.simpleMessage(
      "Profile image updated.",
    ),
    "profileSaved": MessageLookupByLibrary.simpleMessage(
      "Profile saved successfully.",
    ),
    "saveProfile": MessageLookupByLibrary.simpleMessage("Save Profile"),
    "selectImage": MessageLookupByLibrary.simpleMessage(
      "Select an image from your gallery.",
    ),
    "selectImageFirst": MessageLookupByLibrary.simpleMessage(
      "Please select an image first.",
    ),
    "signin": MessageLookupByLibrary.simpleMessage("Sign In"),
    "signupSubtitle": MessageLookupByLibrary.simpleMessage(
      "We\'ll email you a code for secure signup",
    ),
    "signupWithEmail": MessageLookupByLibrary.simpleMessage(
      "Sign up with email",
    ),
    "splash1": MessageLookupByLibrary.simpleMessage("A world of learning"),
    "splash1_subtitle": MessageLookupByLibrary.simpleMessage(
      "From cooking to coding\nand everything in between",
    ),
    "splash2": MessageLookupByLibrary.simpleMessage("Learn from the Best"),
    "splash2_subtitle": MessageLookupByLibrary.simpleMessage(
      "Approachable expert-instructors,\n vetted by more than 50 million learners",
    ),
    "splash3": MessageLookupByLibrary.simpleMessage("Go at Your Own Pace"),
    "splash3_subtitle": MessageLookupByLibrary.simpleMessage(
      "Lifetime access to purchased courses,\n anytime, anywhere",
    ),
    "switchLanguage": MessageLookupByLibrary.simpleMessage("Switch Language"),
    "titlelogin": MessageLookupByLibrary.simpleMessage(
      "Log in to continue your learning \n journey",
    ),
    "upload": MessageLookupByLibrary.simpleMessage("Upload"),
    "uploadFailed": MessageLookupByLibrary.simpleMessage(
      "Upload failed. Please try again.",
    ),
    "userNotLoggedIn": MessageLookupByLibrary.simpleMessage(
      "User not logged in.",
    ),
    "youtube": MessageLookupByLibrary.simpleMessage("YouTube:"),
    "youtubeUrl": MessageLookupByLibrary.simpleMessage("YouTube URL"),
  };
}
