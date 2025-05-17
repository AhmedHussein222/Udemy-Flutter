import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:udemyflutter/Screens/login/login.dart';

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
  String _selectedGender = '';
  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  final _imageUrlController = TextEditingController();

  List<String> genderOptions = [
    'Male',
    'Female',
  ];

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  Future<void> _fetchUserData() async {
    if (user != null) {
      final doc = await FirebaseFirestore.instance
          .collection('Users')
          .doc(user!.uid)
          .get();
      if (doc.exists) {
        userData = doc.data();
        _firstNameController.text = userData?['first_name'] ?? '';
        _lastNameController.text = userData?['last_name'] ?? '';
        _bioController.text = userData?['bio'] ?? '';
        _selectedGender = userData?['gender'] ?? genderOptions.first;
        _imageUrlController.text = userData?['profile_picture'] ?? '';
        setState(() => isLoading = false);
      }
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
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile saved successfully.')));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving profile: $e')));
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
        margin: const EdgeInsets.only(top: 20, left: 20, right: 20),
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
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile image updated.')));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error updating image: $e')));
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
    if (confirm != true) return;

    try {
      await FirebaseFirestore.instance.collection('Users').doc(user!.uid).delete();
      await user!.delete();
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => LoginScreen()),
      );
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Error deleting account: $e')));
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
                      : const AssetImage('assets/default_avatar.png') as ImageProvider,
                ),
              ),
              const SizedBox(height: 16),
              Center(
                child: Text(
                  '${_firstNameController.text} ${_lastNameController.text}',
                  style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
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
              // const Divider(height: 32, color: Colors.white24),
              Text('$_selectedGender', style: const TextStyle(color: Colors.white)),
              const SizedBox(height: 8),
              Text('Bio:', style: const TextStyle(color: Colors.white)),
              Text(_bioController.text, style: const TextStyle(color: Colors.white70)),
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
                decoration: const InputDecoration(labelText: 'First Name'),
                style: const TextStyle(color: Colors.white),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _lastNameController,
                decoration: const InputDecoration(labelText: 'Last Name'),
                style: const TextStyle(color: Colors.white),
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                dropdownColor: Colors.black,
                value: _selectedGender,
                decoration: const InputDecoration(labelText: 'Gender'),
                items: genderOptions
                    .map((g) => DropdownMenuItem(
                        value: g, child: Text(g, style: const TextStyle(color: Colors.white))))
                    .toList(),
                onChanged: (v) => setState(() => _selectedGender = v!),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _bioController,
                decoration: const InputDecoration(labelText: 'Bio'),
                maxLines: 3,
                style: const TextStyle(color: Colors.white),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _saveProfile,
                style: ElevatedButton.styleFrom(backgroundColor: Colors.deepPurple),
                child: const Text('Save', style: TextStyle(color: Colors.white)),
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
    decoration: const InputDecoration(labelText: 'Current Password'),
    obscureText: true,
    style: const TextStyle(color: Colors.white),
  ),
  const SizedBox(height: 8),
  TextField(
    controller: _newPasswordController,
    decoration: const InputDecoration(labelText: 'New Password'),
    obscureText: true,
    style: const TextStyle(color: Colors.white),
  ),
  const SizedBox(height: 8),
  TextField(
    controller: _confirmPasswordController,
    decoration: const InputDecoration(labelText: 'Confirm Password'),
    obscureText: true,
    style: const TextStyle(color: Colors.white),
  ),
  const SizedBox(height: 16),
  ElevatedButton(
    onPressed: _changePassword,
    style: ElevatedButton.styleFrom(backgroundColor: Colors.deepPurple),
    child: const Text('Change Password', style: TextStyle(color: Colors.white)),
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
                    : const AssetImage('assets/default_avatar.png') as ImageProvider,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _imageUrlController,
                decoration: const InputDecoration(labelText: 'Image URL'),
                style: const TextStyle(color: Colors.white),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _saveImageProfile,
                style: ElevatedButton.styleFrom(backgroundColor: Colors.deepPurple),
                child: const Text('Save Image', style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
        );

      case 'delete_account':
        return Center(
          child: ElevatedButton(
            onPressed: _deleteAccount,
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete Account', style: TextStyle(color: Colors.white)),
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
                : const AssetImage('assets/default_avatar.png') as ImageProvider,
          ),
          accountName: Text(
            '${_firstNameController.text} ${_lastNameController.text}',
            style: const TextStyle(color: Colors.white,fontSize: 15,fontWeight: FontWeight.bold),
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
        buildDrawerTile(Icons.delete_forever, 'Delete Account', 'delete_account', color: Colors.red),
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
              MaterialPageRoute(builder: (context) => LoginScreen()),
            );
          },
        ),
      ],
    ),
  );
}

Widget buildDrawerTile(IconData icon, String title, String section, {Color? color}) {
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
),

      body: buildSectionContent(),
    );
  }
}