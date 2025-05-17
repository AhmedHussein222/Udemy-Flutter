import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:udemyflutter/Screens/login/login.dart';
import 'package:udemyflutter/Screens/splash/splash_screen.dart';

class AccountScreen extends StatefulWidget {
  const AccountScreen({Key? key}) : super(key: key);

  @override
  _AccountScreenState createState() => _AccountScreenState();
}

class _AccountScreenState extends State<AccountScreen> {
  final user = FirebaseAuth.instance.currentUser;
  Map<String, dynamic>? userData;
  String selectedSection = 'home';
  bool isLoading = true;

  // Form controllers
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _bioController = TextEditingController();
  String _selectedGender = 'Male';
  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _imageUrlController = TextEditingController();

  List<String> genderOptions = ['Male', 'Female'];

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  Future<void> _fetchUserData() async {
    if (user == null) {
      setState(() => isLoading = false);
      return;
    }

    setState(() => isLoading = true);
    try {
      final doc = await FirebaseFirestore.instance
          .collection('Users')
          .doc(user!.uid)
          .get();
      if (doc.exists) {
        final data = doc.data();
        if (data != null) {
          userData = data;
          setState(() {
            _firstNameController.text = (userData?['first_name'] as String?) ?? '';
            _lastNameController.text = (userData?['last_name'] as String?) ?? '';
            _bioController.text = (userData?['bio'] as String?) ?? '';
            final gender = userData?['gender'] as String?;
            _selectedGender = gender != null && genderOptions.contains(gender)
                ? gender
                : genderOptions.first;
            _imageUrlController.text = (userData?['profile_picture'] as String?) ?? '';
            isLoading = false;
          });
        } else {
          print('Firestore document exists but data is null');
          setState(() {
            _firstNameController.text = '';
            _lastNameController.text = '';
            _bioController.text = '';
            _selectedGender = genderOptions.first;
            _imageUrlController.text = '';
            isLoading = false;
          });
        }
      } else {
        print('Firestore document does not exist for user: ${user!.uid}');
        setState(() => isLoading = false);
      }
    } catch (e) {
      print('Error fetching user data: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error fetching profile: $e'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.only(top: 20, left: 20, right: 20),
          elevation: 6,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      );
      setState(() => isLoading = false);
    }
  }

  Future<void> _saveProfile() async {
    setState(() => isLoading = true);
    try {
      await FirebaseFirestore.instance.collection('Users').doc(user!.uid).set({
        'first_name': _firstNameController.text.trim(),
        'last_name': _lastNameController.text.trim(),
        'bio': _bioController.text.trim(),
        'gender': _selectedGender,
      }, SetOptions(merge: true));
      await _fetchUserData();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Profile saved successfully.'),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
          margin: EdgeInsets.only(top: 20, left: 20, right: 20),
          elevation: 6,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(8))),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error saving profile: $e'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          margin: EdgeInsets.only(top: 20, left: 20, right: 20),
          elevation: 6,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(8))),
        ),
      );
    }
    setState(() => isLoading = false);
  }

  Future<void> _changePassword() async {
    if (_newPasswordController.text != _confirmPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('New password and confirm password do not match.'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          margin: EdgeInsets.only(top: 20, left: 20, right: 20),
          elevation: 6,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(8))),
        ),
      );
      return;
    }

    final cred = EmailAuthProvider.credential(
      email: user!.email!,
      password: _currentPasswordController.text,
    );

    try {
      await user!.reauthenticateWithCredential(cred);
      await user!.updatePassword(_newPasswordController.text);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Password updated successfully.'),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
          margin: EdgeInsets.only(top: 20, left: 20, right: 20),
          elevation: 6,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(8))),
        ),
      );
      _currentPasswordController.clear();
      _newPasswordController.clear();
      _confirmPasswordController.clear();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error updating password: $e'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          margin: EdgeInsets.only(top: 20, left: 20, right: 20),
          elevation: 6,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      );
    }
  }

  Future<void> _saveImageProfile() async {
    setState(() => isLoading = true);
    try {
      await FirebaseFirestore.instance.collection('Users').doc(user!.uid).set({
        'profile_picture': _imageUrlController.text.trim(),
      }, SetOptions(merge: true));
      await _fetchUserData();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Profile image updated.'),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
          margin: EdgeInsets.only(top: 20, left: 20, right: 20),
          elevation: 6,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(8))),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error updating image: $e'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          margin: EdgeInsets.only(top: 20, left: 20, right: 20),
          elevation: 6,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      );
    }
    setState(() => isLoading = false);
  }

  Future<void> _deleteAccount() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Delete Account'),
        content: const Text(
            'Are you sure you want to delete your account? This action cannot be undone.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel')),
          TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Delete', style: TextStyle(color: Colors.red))),
        ],
      ),
    );
    if (!(confirm ?? false)) return;

    try {
      await FirebaseFirestore.instance.collection('Users').doc(user!.uid).delete();
      await user!.delete();
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => LoginScreen()),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error deleting account: $e'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.only(top: 20, left: 20, right: 20),
          elevation: 6,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      );
    }
  }

  Widget buildSectionContent() {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator(color: Colors.white));
    }
    switch (selectedSection) {
      case 'home':
        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: CircleAvatar(
                  radius: 70,
                  backgroundImage: (_imageUrlController.text.isNotEmpty)
                      ? NetworkImage(_imageUrlController.text)
                      : const AssetImage('assets/default_avatar.png')
                          as ImageProvider,
                  onBackgroundImageError: (error, stackTrace) {
                    print('Image load error: $error');
                  },
                ),
              ),
              const SizedBox(height: 16),
              Center(
                child: Text(
                  '${_firstNameController.text} ${_lastNameController.text}',
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 8),
              Center(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.email, color: Colors.white70, size: 18),
                    const SizedBox(width: 8),
                    Text(
                      user?.email ?? '',
                      style: const TextStyle(color: Colors.white70, fontSize: 16),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Gender: $_selectedGender',
                style: const TextStyle(color: Colors.white),
              ),
              const SizedBox(height: 8),
              const Text(
                'Bio:',
                style: TextStyle(color: Colors.white),
              ),
              Text(
                _bioController.text,
                style: const TextStyle(color: Colors.white70),
              ),
            ],
          ),
        );

      case 'profile':
        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                controller: _firstNameController,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.grey[900],
                  labelText: 'First Name',
                  labelStyle: TextStyle(color: Colors.grey[400]),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _lastNameController,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.grey[900],
                  labelText: 'Last Name',
                  labelStyle: TextStyle(color: Colors.grey[400]),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: _selectedGender,
                dropdownColor: Colors.grey[900],
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.grey[900],
                  labelText: 'Gender',
                  labelStyle: TextStyle(color: Colors.grey[400]),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
                items: genderOptions
                    .map((g) => DropdownMenuItem(
                          value: g,
                          child: Text(g, style: const TextStyle(color: Colors.white)),
                        ))
                    .toList(),
                onChanged: (v) => setState(() => _selectedGender = v!),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _bioController,
                style: const TextStyle(color: Colors.white),
                maxLines: 3,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.grey[900],
                  labelText: 'Bio',
                  labelStyle: TextStyle(color: Colors.grey[400]),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Center(
                child: ElevatedButton(
                  onPressed: _saveProfile,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueAccent,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  ),
                  child: const Text('Save Profile', style: TextStyle(fontSize: 16)),
                ),
              ),
            ],
          ),
        );

      case 'change_password':
        return Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              TextField(
                controller: _currentPasswordController,
                style: const TextStyle(color: Colors.white),
                obscureText: true,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.grey[900],
                  labelText: 'Current Password',
                  labelStyle: TextStyle(color: Colors.grey[400]),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _newPasswordController,
                style: const TextStyle(color: Colors.white),
                obscureText: true,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.grey[900],
                  labelText: 'New Password',
                  labelStyle: TextStyle(color: Colors.grey[400]),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _confirmPasswordController,
                style: const TextStyle(color: Colors.white),
                obscureText: true,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.grey[900],
                  labelText: 'Confirm Password',
                  labelStyle: TextStyle(color: Colors.grey[400]),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Center(
                child: ElevatedButton(
                  onPressed: _changePassword,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueAccent,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  ),
                  child: const Text('Change Password', style: TextStyle(fontSize: 16)),
                ),
              ),
            ],
          ),
        );

      case 'image_profile':
        return Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              CircleAvatar(
                radius: 50,
                backgroundImage: (_imageUrlController.text.isNotEmpty)
                    ? NetworkImage(_imageUrlController.text)
                    : const AssetImage('assets/default_avatar.png')
                        as ImageProvider,
                onBackgroundImageError: (error, stackTrace) {
                  print('Image load error: $error');
                },
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _imageUrlController,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.grey[900],
                  labelText: 'Profile Picture URL',
                  labelStyle: TextStyle(color: Colors.grey[400]),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Center(
                child: ElevatedButton(
                  onPressed: _saveImageProfile,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueAccent,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  ),
                  child: const Text('Save Image', style: TextStyle(fontSize: 16)),
                ),
              ),
            ],
          ),
        );

      case 'delete_account':
        return Center(
          child: ElevatedButton(
            onPressed: _deleteAccount,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
            child: const Text('Delete Account', style: TextStyle(fontSize: 16)),
          ),
        );

      default:
        return const SizedBox.shrink();
    }
  }

  Widget buildDrawer() {
    return Drawer(
      backgroundColor: Colors.black,
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          UserAccountsDrawerHeader(
            decoration: const BoxDecoration(color: Colors.black),
            currentAccountPicture: CircleAvatar(
              backgroundImage: (_imageUrlController.text.isNotEmpty)
                  ? NetworkImage(_imageUrlController.text)
                  : const AssetImage('assets/default_avatar.png')
                      as ImageProvider,
              onBackgroundImageError: (error, stackTrace) {
                print('Image load error: $error');
              },
            ),
            accountName: Text(
              '${_firstNameController.text} ${_lastNameController.text}',
              style: const TextStyle(
                  color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold),
            ),
            accountEmail: Text(
              user?.email ?? '',
              style: const TextStyle(color: Colors.white70),
            ),
          ),
          buildDrawerTile(Icons.home, 'Home', 'home'),
          buildDrawerTile(Icons.person, 'Edit Profile', 'profile'),
          buildDrawerTile(Icons.lock, 'Change Password', 'change_password'),
          buildDrawerTile(Icons.image, 'Change Profile Image', 'image_profile'),
          buildDrawerTile(Icons.delete_forever, 'Delete Account', 'delete_account',
              color: Colors.red),
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: const Text('Log out', style: TextStyle(color: Colors.red)),
            hoverColor: Colors.transparent,
            splashColor: Colors.transparent,
            onTap: () async {
              Navigator.pop(context);
              await FirebaseAuth.instance.signOut();
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => SplashScreen()),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget buildDrawerTile(IconData icon, String title, String section,
      {Color? color}) {
    return ListTile(
      leading: Icon(icon, color: color ?? Colors.white),
      title: Text(title, style: TextStyle(color: color ?? Colors.white)),
      splashColor: Colors.transparent,
      onTap: () {
        Navigator.pop(context);
        setState(() => selectedSection = section);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      drawer: buildDrawer(),
      appBar: AppBar(
        backgroundColor: Colors.black,
        automaticallyImplyLeading: true,
        // title: const Text('Account', style: TextStyle(color: Colors.white)),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: buildSectionContent(),
    );
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _bioController.dispose();
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    _imageUrlController.dispose();
    super.dispose();
  }
}