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

  static String m6(amount, email) =>
      "Payment successful: ${amount} from ${email}\\nEnrollments updated successfully";

  final messages = _notInlinedMessages(_notInlinedMessages);
  static Map<String, Function> _notInlinedMessages(_) => <String, Function>{
    "BrowseCourses": MessageLookupByLibrary.simpleMessage("Browse Courses"),
    "Cancelled": MessageLookupByLibrary.simpleMessage("Cancelled"),
    "Cart": MessageLookupByLibrary.simpleMessage("Cart"),
    "Categories": MessageLookupByLibrary.simpleMessage("Categories"),
    "Checkout": MessageLookupByLibrary.simpleMessage("Checkout"),
    "Completed": MessageLookupByLibrary.simpleMessage("Completed"),
    "Courseremoved": MessageLookupByLibrary.simpleMessage(
      "Course removed from wishlist",
    ),
    "Coursesyousavetoyourwishlistwillappearhere":
        MessageLookupByLibrary.simpleMessage(
          "Courses you save to your wishlist will appear here",
        ),
    "Email": MessageLookupByLibrary.simpleMessage("Email"),
    "Failed": MessageLookupByLibrary.simpleMessage("Failed"),
    "FeaturescoursesinWebDevelopment": MessageLookupByLibrary.simpleMessage(
      "Featured courses in Web Development",
    ),
    "Haveaccount": MessageLookupByLibrary.simpleMessage(
      "Don\'t have an account?",
    ),
    "Login": MessageLookupByLibrary.simpleMessage("Log in"),
    "Loginemail": MessageLookupByLibrary.simpleMessage("  Log in with email"),
    "Loginsuccessful": MessageLookupByLibrary.simpleMessage(
      "Login successful!",
    ),
    "MyCourses": MessageLookupByLibrary.simpleMessage("My Courses"),
    "NewCourses": MessageLookupByLibrary.simpleMessage("New Courses"),
    "NoMatchingcourses": MessageLookupByLibrary.simpleMessage(
      "No matching courses found",
    ),
    "Nocoursesfound": MessageLookupByLibrary.simpleMessage("No courses found"),
    "OrderSummary": MessageLookupByLibrary.simpleMessage("Order Summary"),
    "OriginalPrice": MessageLookupByLibrary.simpleMessage("Original Price:"),
    "Password": MessageLookupByLibrary.simpleMessage("Password"),
    "PayPal": MessageLookupByLibrary.simpleMessage("PayPal"),
    "PaymentMethod": MessageLookupByLibrary.simpleMessage("Payment Method"),
    "Paymentsuccessfulbutfailedtoupdateenrollments":
        MessageLookupByLibrary.simpleMessage(
          "Payment successful but failed to update enrollments",
        ),
    "Paymentwascancelledbyuser": MessageLookupByLibrary.simpleMessage(
      "Payment was cancelled by user",
    ),
    "Paymentwasnotcompleted": MessageLookupByLibrary.simpleMessage(
      "Payment was not completed",
    ),
    "PoweredbyPayPal": MessageLookupByLibrary.simpleMessage(
      "Powered by PayPal",
    ),
    "ProceedtoCheckout": MessageLookupByLibrary.simpleMessage(
      "Proceed to Checkout",
    ),
    "Remove": MessageLookupByLibrary.simpleMessage("Remove"),
    "SignUp": MessageLookupByLibrary.simpleMessage("Sign Up"),
    "Success": MessageLookupByLibrary.simpleMessage("Success"),
    "TopRatedCourses": MessageLookupByLibrary.simpleMessage(
      "Top Rated Courses",
    ),
    "Welcome": MessageLookupByLibrary.simpleMessage("Welcome"),
    "Wishlist": MessageLookupByLibrary.simpleMessage("Wishlist"),
    "Yourwishlistisempty": MessageLookupByLibrary.simpleMessage(
      "Your wishlist is empty",
    ),
    "account": MessageLookupByLibrary.simpleMessage("Account"),
    "all": MessageLookupByLibrary.simpleMessage("All"),
    "alreadyHaveAccount": MessageLookupByLibrary.simpleMessage(
      "Already have an account?",
    ),
    "archived": MessageLookupByLibrary.simpleMessage("Archived"),
    "bio": MessageLookupByLibrary.simpleMessage("Bio:"),
    "bioField": MessageLookupByLibrary.simpleMessage("Bio"),
    "cancel": MessageLookupByLibrary.simpleMessage("Cancel"),
    "cartEmpty": MessageLookupByLibrary.simpleMessage("Your Cart is empty!"),
    "changePassword": MessageLookupByLibrary.simpleMessage("Change Password"),
    "changeProfileImage": MessageLookupByLibrary.simpleMessage(
      "Change Profile Image",
    ),
    "confirmPassword": MessageLookupByLibrary.simpleMessage("Confirm Password"),
    "confirmcheckout": MessageLookupByLibrary.simpleMessage("Confirm Checkout"),
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
    "downloadMessage": MessageLookupByLibrary.simpleMessage(
      "When you download a course to take with you, you\'ll see them here!",
    ),
    "downloaded": MessageLookupByLibrary.simpleMessage("Downloaded"),
    "editProfile": MessageLookupByLibrary.simpleMessage("Edit Profile"),
    "errorDeletingAccount": m0,
    "errorFetchingProfile": m1,
    "errorFetchingProfilePicture": m2,
    "errorGeneric": m3,
    "errorSavingProfile": m4,
    "errorUpdatingPassword": m5,
    "facebook": MessageLookupByLibrary.simpleMessage("Facebook:"),
    "facebookUrl": MessageLookupByLibrary.simpleMessage("Facebook URL"),
    "favourited": MessageLookupByLibrary.simpleMessage("Favourited"),
    "feature": MessageLookupByLibrary.simpleMessage("Feature"),
    "firstName": MessageLookupByLibrary.simpleMessage("First Name"),
    "gender": MessageLookupByLibrary.simpleMessage("Gender"),
    "goShopping": MessageLookupByLibrary.simpleMessage("Go Shopping"),
    "home": MessageLookupByLibrary.simpleMessage("Home"),
    "instagram": MessageLookupByLibrary.simpleMessage("Instagram:"),
    "instagramUrl": MessageLookupByLibrary.simpleMessage("Instagram URL"),
    "lastName": MessageLookupByLibrary.simpleMessage("Last Name"),
    "learning": MessageLookupByLibrary.simpleMessage("Learning"),
    "linkedin": MessageLookupByLibrary.simpleMessage("LinkedIn:"),
    "linkedinUrl": MessageLookupByLibrary.simpleMessage("LinkedIn URL"),
    "logout": MessageLookupByLibrary.simpleMessage("Log out"),
    "newPassword": MessageLookupByLibrary.simpleMessage("New Password"),
    "noBioProvided": MessageLookupByLibrary.simpleMessage("No bio provided"),
    "nothingDownloaded": MessageLookupByLibrary.simpleMessage(
      "Nothing\'s downloaded yet",
    ),
    "options": MessageLookupByLibrary.simpleMessage(
      "_____ Other login options _____",
    ),
    "passwordMismatch": MessageLookupByLibrary.simpleMessage(
      "New password and confirm password do not match.",
    ),
    "passwordUpdated": MessageLookupByLibrary.simpleMessage(
      "Password updated successfully.",
    ),
    "paymentSuccess": m6,
    "pickImage": MessageLookupByLibrary.simpleMessage("Pick Image"),
    "profileImageUpdated": MessageLookupByLibrary.simpleMessage(
      "Profile image updated.",
    ),
    "profileSaved": MessageLookupByLibrary.simpleMessage(
      "Profile saved successfully.",
    ),
    "saveProfile": MessageLookupByLibrary.simpleMessage("Save Profile"),
    "search": MessageLookupByLibrary.simpleMessage("Search"),
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
    "whatToLearn": MessageLookupByLibrary.simpleMessage(
      "What will you learn first?",
    ),
    "wishlist": MessageLookupByLibrary.simpleMessage("Wishlist"),
    "yourCourses": MessageLookupByLibrary.simpleMessage(
      "Your courses will go here.",
    ),
    "youtube": MessageLookupByLibrary.simpleMessage("YouTube:"),
    "youtubeUrl": MessageLookupByLibrary.simpleMessage("YouTube URL"),
  };
}
