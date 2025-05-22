// GENERATED CODE - DO NOT MODIFY BY HAND
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'intl/messages_all.dart';

// **************************************************************************
// Generator: Flutter Intl IDE plugin
// Made by Localizely
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, lines_longer_than_80_chars
// ignore_for_file: join_return_with_assignment, prefer_final_in_for_each
// ignore_for_file: avoid_redundant_argument_values, avoid_escaping_inner_quotes

class S {
  S();

  static S? _current;

  static S get current {
    assert(
      _current != null,
      'No instance of S was loaded. Try to initialize the S delegate before accessing S.current.',
    );
    return _current!;
  }

  static const AppLocalizationDelegate delegate = AppLocalizationDelegate();

  static Future<S> load(Locale locale) {
    final name = (locale.countryCode?.isEmpty ?? false)
        ? locale.languageCode
        : locale.toString();
    final localeName = Intl.canonicalizedLocale(name);
    return initializeMessages(localeName).then((_) {
      Intl.defaultLocale = localeName;
      final instance = S();
      S._current = instance;

      return instance;
    });
  }

  static S of(BuildContext context) {
    final instance = S.maybeOf(context);
    assert(
      instance != null,
      'No instance of S present in the widget tree. Did you add S.delegate in localizationsDelegates?',
    );
    return instance!;
  }

  static S? maybeOf(BuildContext context) {
    return Localizations.of<S>(context, S);
  }

  /// `Log in to continue your learning \n journey`
  String get titlelogin {
    return Intl.message(
      'Log in to continue your learning \n journey',
      name: 'titlelogin',
      desc: '',
      args: [],
    );
  }

  /// `Email`
  String get Email {
    return Intl.message('Email', name: 'Email', desc: '', args: []);
  }

  /// `Password`
  String get Password {
    return Intl.message('Password', name: 'Password', desc: '', args: []);
  }

  /// `  Log in with email`
  String get Loginemail {
    return Intl.message(
      '  Log in with email',
      name: 'Loginemail',
      desc: '',
      args: [],
    );
  }

  /// `Sign Up`
  String get SignUp {
    return Intl.message('Sign Up', name: 'SignUp', desc: '', args: []);
  }

  /// `Log in`
  String get Login {
    return Intl.message('Log in', name: 'Login', desc: '', args: []);
  }

  /// `Don't have an account?`
  String get Haveaccount {
    return Intl.message(
      'Don\'t have an account?',
      name: 'Haveaccount',
      desc: '',
      args: [],
    );
  }

  /// `_____ Other login options _____`
  String get options {
    return Intl.message(
      '_____ Other login options _____',
      name: 'options',
      desc: '',
      args: [],
    );
  }

  /// `Login successful!`
  String get Loginsuccessful {
    return Intl.message(
      'Login successful!',
      name: 'Loginsuccessful',
      desc: '',
      args: [],
    );
  }

  /// `Sign In`
  String get signin {
    return Intl.message('Sign In', name: 'signin', desc: '', args: []);
  }

  /// `A world of learning`
  String get splash1 {
    return Intl.message(
      'A world of learning',
      name: 'splash1',
      desc: '',
      args: [],
    );
  }

  /// `From cooking to coding\nand everything in between`
  String get splash1_subtitle {
    return Intl.message(
      'From cooking to coding\nand everything in between',
      name: 'splash1_subtitle',
      desc: '',
      args: [],
    );
  }

  /// `Learn from the Best`
  String get splash2 {
    return Intl.message(
      'Learn from the Best',
      name: 'splash2',
      desc: '',
      args: [],
    );
  }

  /// `Approachable expert-instructors,\n vetted by more than 50 million learners`
  String get splash2_subtitle {
    return Intl.message(
      'Approachable expert-instructors,\n vetted by more than 50 million learners',
      name: 'splash2_subtitle',
      desc: '',
      args: [],
    );
  }

  /// `Go at Your Own Pace`
  String get splash3 {
    return Intl.message(
      'Go at Your Own Pace',
      name: 'splash3',
      desc: '',
      args: [],
    );
  }

  /// `Lifetime access to purchased courses,\n anytime, anywhere`
  String get splash3_subtitle {
    return Intl.message(
      'Lifetime access to purchased courses,\n anytime, anywhere',
      name: 'splash3_subtitle',
      desc: '',
      args: [],
    );
  }

  /// `Sign up with email`
  String get signupWithEmail {
    return Intl.message(
      'Sign up with email',
      name: 'signupWithEmail',
      desc: '',
      args: [],
    );
  }

  /// `We'll email you a code for secure signup`
  String get signupSubtitle {
    return Intl.message(
      'We\'ll email you a code for secure signup',
      name: 'signupSubtitle',
      desc: '',
      args: [],
    );
  }

  /// `First Name`
  String get firstName {
    return Intl.message('First Name', name: 'firstName', desc: '', args: []);
  }

  /// `Last Name`
  String get lastName {
    return Intl.message('Last Name', name: 'lastName', desc: '', args: []);
  }

  /// `Continue`
  String get continueText {
    return Intl.message('Continue', name: 'continueText', desc: '', args: []);
  }

  /// `Already have an account?`
  String get alreadyHaveAccount {
    return Intl.message(
      'Already have an account?',
      name: 'alreadyHaveAccount',
      desc: '',
      args: [],
    );
  }

  /// `Home`
  String get home {
    return Intl.message('Home', name: 'home', desc: '', args: []);
  }

  /// `Edit Profile`
  String get editProfile {
    return Intl.message(
      'Edit Profile',
      name: 'editProfile',
      desc: '',
      args: [],
    );
  }

  /// `Change Password`
  String get changePassword {
    return Intl.message(
      'Change Password',
      name: 'changePassword',
      desc: '',
      args: [],
    );
  }

  /// `Change Profile Image`
  String get changeProfileImage {
    return Intl.message(
      'Change Profile Image',
      name: 'changeProfileImage',
      desc: '',
      args: [],
    );
  }

  /// `Delete Account`
  String get deleteAccount {
    return Intl.message(
      'Delete Account',
      name: 'deleteAccount',
      desc: '',
      args: [],
    );
  }

  /// `Log out`
  String get logout {
    return Intl.message('Log out', name: 'logout', desc: '', args: []);
  }

  /// `Select an image from your gallery.`
  String get selectImage {
    return Intl.message(
      'Select an image from your gallery.',
      name: 'selectImage',
      desc: '',
      args: [],
    );
  }

  /// `Bio:`
  String get bio {
    return Intl.message('Bio:', name: 'bio', desc: '', args: []);
  }

  /// `No bio provided`
  String get noBioProvided {
    return Intl.message(
      'No bio provided',
      name: 'noBioProvided',
      desc: '',
      args: [],
    );
  }

  /// `Facebook:`
  String get facebook {
    return Intl.message('Facebook:', name: 'facebook', desc: '', args: []);
  }

  /// `LinkedIn:`
  String get linkedin {
    return Intl.message('LinkedIn:', name: 'linkedin', desc: '', args: []);
  }

  /// `YouTube:`
  String get youtube {
    return Intl.message('YouTube:', name: 'youtube', desc: '', args: []);
  }

  /// `Instagram:`
  String get instagram {
    return Intl.message('Instagram:', name: 'instagram', desc: '', args: []);
  }

  /// `Gender`
  String get gender {
    return Intl.message('Gender', name: 'gender', desc: '', args: []);
  }

  /// `Bio`
  String get bioField {
    return Intl.message('Bio', name: 'bioField', desc: '', args: []);
  }

  /// `Facebook URL`
  String get facebookUrl {
    return Intl.message(
      'Facebook URL',
      name: 'facebookUrl',
      desc: '',
      args: [],
    );
  }

  /// `LinkedIn URL`
  String get linkedinUrl {
    return Intl.message(
      'LinkedIn URL',
      name: 'linkedinUrl',
      desc: '',
      args: [],
    );
  }

  /// `YouTube URL`
  String get youtubeUrl {
    return Intl.message('YouTube URL', name: 'youtubeUrl', desc: '', args: []);
  }

  /// `Instagram URL`
  String get instagramUrl {
    return Intl.message(
      'Instagram URL',
      name: 'instagramUrl',
      desc: '',
      args: [],
    );
  }

  /// `Save Profile`
  String get saveProfile {
    return Intl.message(
      'Save Profile',
      name: 'saveProfile',
      desc: '',
      args: [],
    );
  }

  /// `Current Password`
  String get currentPassword {
    return Intl.message(
      'Current Password',
      name: 'currentPassword',
      desc: '',
      args: [],
    );
  }

  /// `New Password`
  String get newPassword {
    return Intl.message(
      'New Password',
      name: 'newPassword',
      desc: '',
      args: [],
    );
  }

  /// `Confirm Password`
  String get confirmPassword {
    return Intl.message(
      'Confirm Password',
      name: 'confirmPassword',
      desc: '',
      args: [],
    );
  }

  /// `Permanently delete your account?`
  String get deleteAccountConfirm {
    return Intl.message(
      'Permanently delete your account?',
      name: 'deleteAccountConfirm',
      desc: '',
      args: [],
    );
  }

  /// `Delete Account`
  String get deleteAccountDialogTitle {
    return Intl.message(
      'Delete Account',
      name: 'deleteAccountDialogTitle',
      desc: '',
      args: [],
    );
  }

  /// `Are you sure you want to delete your account? This action cannot be undone.`
  String get deleteAccountDialogContent {
    return Intl.message(
      'Are you sure you want to delete your account? This action cannot be undone.',
      name: 'deleteAccountDialogContent',
      desc: '',
      args: [],
    );
  }

  /// `Cancel`
  String get cancel {
    return Intl.message('Cancel', name: 'cancel', desc: '', args: []);
  }

  /// `Delete`
  String get delete {
    return Intl.message('Delete', name: 'delete', desc: '', args: []);
  }

  /// `Profile saved successfully.`
  String get profileSaved {
    return Intl.message(
      'Profile saved successfully.',
      name: 'profileSaved',
      desc: '',
      args: [],
    );
  }

  /// `Password updated successfully.`
  String get passwordUpdated {
    return Intl.message(
      'Password updated successfully.',
      name: 'passwordUpdated',
      desc: '',
      args: [],
    );
  }

  /// `New password and confirm password do not match.`
  String get passwordMismatch {
    return Intl.message(
      'New password and confirm password do not match.',
      name: 'passwordMismatch',
      desc: '',
      args: [],
    );
  }

  /// `Error fetching profile: {error}`
  String errorFetchingProfile(Object error) {
    return Intl.message(
      'Error fetching profile: $error',
      name: 'errorFetchingProfile',
      desc: '',
      args: [error],
    );
  }

  /// `Error saving profile: {error}`
  String errorSavingProfile(Object error) {
    return Intl.message(
      'Error saving profile: $error',
      name: 'errorSavingProfile',
      desc: '',
      args: [error],
    );
  }

  /// `Error updating password: {error}`
  String errorUpdatingPassword(Object error) {
    return Intl.message(
      'Error updating password: $error',
      name: 'errorUpdatingPassword',
      desc: '',
      args: [error],
    );
  }

  /// `Error fetching profile picture: {error}`
  String errorFetchingProfilePicture(Object error) {
    return Intl.message(
      'Error fetching profile picture: $error',
      name: 'errorFetchingProfilePicture',
      desc: '',
      args: [error],
    );
  }

  /// `Please select an image first.`
  String get selectImageFirst {
    return Intl.message(
      'Please select an image first.',
      name: 'selectImageFirst',
      desc: '',
      args: [],
    );
  }

  /// `User not logged in.`
  String get userNotLoggedIn {
    return Intl.message(
      'User not logged in.',
      name: 'userNotLoggedIn',
      desc: '',
      args: [],
    );
  }

  /// `Upload failed. Please try again.`
  String get uploadFailed {
    return Intl.message(
      'Upload failed. Please try again.',
      name: 'uploadFailed',
      desc: '',
      args: [],
    );
  }

  /// `Profile image updated.`
  String get profileImageUpdated {
    return Intl.message(
      'Profile image updated.',
      name: 'profileImageUpdated',
      desc: '',
      args: [],
    );
  }

  /// `Error: {error}`
  String errorGeneric(Object error) {
    return Intl.message(
      'Error: $error',
      name: 'errorGeneric',
      desc: '',
      args: [error],
    );
  }

  /// `Pick Image`
  String get pickImage {
    return Intl.message('Pick Image', name: 'pickImage', desc: '', args: []);
  }

  /// `Upload`
  String get upload {
    return Intl.message('Upload', name: 'upload', desc: '', args: []);
  }

  /// `Switch Language`
  String get switchLanguage {
    return Intl.message(
      'Switch Language',
      name: 'switchLanguage',
      desc: '',
      args: [],
    );
  }

  /// `Error deleting account: {error}`
  String errorDeletingAccount(Object error) {
    return Intl.message(
      'Error deleting account: $error',
      name: 'errorDeletingAccount',
      desc: '',
      args: [error],
    );
  }
}

class AppLocalizationDelegate extends LocalizationsDelegate<S> {
  const AppLocalizationDelegate();

  List<Locale> get supportedLocales {
    return const <Locale>[
      Locale.fromSubtags(languageCode: 'en'),
      Locale.fromSubtags(languageCode: 'ar'),
    ];
  }

  @override
  bool isSupported(Locale locale) => _isSupported(locale);
  @override
  Future<S> load(Locale locale) => S.load(locale);
  @override
  bool shouldReload(AppLocalizationDelegate old) => false;

  bool _isSupported(Locale locale) {
    for (var supportedLocale in supportedLocales) {
      if (supportedLocale.languageCode == locale.languageCode) {
        return true;
      }
    }
    return false;
  }
}
