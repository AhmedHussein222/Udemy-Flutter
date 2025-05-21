import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:udemyflutter/Screens/login/login.dart';
import 'package:udemyflutter/Screens/splash/splash_screen.dart';
import 'package:image_picker/image_picker.dart';


class AccountScreen extends StatefulWidget {
  const AccountScreen({super.key});

  @override
  _AccountScreenState createState() => _AccountScreenState();
}

class _AccountScreenState extends State<AccountScreen> {
  final user = FirebaseAuth.instance.currentUser;
  Map<String, dynamic>? userData;
  String selectedSection = 'home';


  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _bioController = TextEditingController();
  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _imageUrlController = TextEditingController();
  final _facebookController = TextEditingController();
  final _linkedinController = TextEditingController();
  final _youtubeController = TextEditingController();
  final _instagramController = TextEditingController();
  //  File? _selectedImage;
  bool isLoading = false;
  final User = FirebaseAuth.instance.currentUser;

  // Future<void> _pickImage() async {
  //   final picker = ImagePicker();
  //   final picked = await picker.pickImage(source: ImageSource.gallery);
  //   if (picked != null) {
  //     setState(() {
  //       _selectedImage = File(picked.path);
  //     });
  //   }
  // }

  List<String> genderOptions = ['male', 'female'];
  String _selectedGender = 'male';
  XFile? _selectedImage;
  // bool isLoading = false;
  String? _profilePictureUrl; // لتخزين رابط صورة الملف الشخصي من Firestore
  // final user = FirebaseAuth.instance.currentUser;

  @override
  void initState() {
    super.initState();
    _fetchUserData();
    _fetchProfilePicture();
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
          final links = userData?['links'] as Map<String, dynamic>? ?? {};
          setState(() {
            _firstNameController.text = (userData?['first_name'] as String?) ?? '';
            _lastNameController.text = (userData?['last_name'] as String?) ?? '';
            _bioController.text = (userData?['bio'] as String?) ?? '';
            _facebookController.text = (links['facebook'] as String?) ?? '';
            _linkedinController.text = (links['linkedin'] as String?) ?? '';
            _youtubeController.text = (links['youtube'] as String?) ?? '';
            _instagramController.text = (links['instagram'] as String?) ?? '';
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
            _facebookController.text = '';
            _linkedinController.text = '';
            _youtubeController.text = '';
            _instagramController.text = '';
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
      _showSnackBar('Error fetching profile: $e', Colors.red);
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
        'links': {
          'facebook': _facebookController.text.trim(),
          'linkedin': _linkedinController.text.trim(),
          'youtube': _youtubeController.text.trim(),
          'instagram': _instagramController.text.trim(),
        },
      }, SetOptions(merge: true));
      await _fetchUserData();
      _showSnackBar('Profile saved successfully.', Colors.green);
    } catch (e) {
      _showSnackBar('Error saving profile: $e', Colors.red);
    }
    setState(() => isLoading = false);
  }

  Future<void> _changePassword() async {
    if (_newPasswordController.text != _confirmPasswordController.text) {
      _showSnackBar('New password and confirm password do not match.', Colors.red);
      return;
    }

    final cred = EmailAuthProvider.credential(
      email: user!.email!,
      password: _currentPasswordController.text,
    );

    try {
      await user!.reauthenticateWithCredential(cred);
      await user!.updatePassword(_newPasswordController.text);
      _showSnackBar('Password updated successfully.', Colors.green);
      _currentPasswordController.clear();
      _newPasswordController.clear();
      _confirmPasswordController.clear();
    } catch (e) {
      _showSnackBar('Error updating password: $e', Colors.red);
    }
  }

  Future<void> _fetchProfilePicture() async {
    if (user != null) {
      try {
        final doc = await FirebaseFirestore.instance.collection('Users').doc(user!.uid).get();
        if (doc.exists && doc.data() != null) {
          setState(() {
            _profilePictureUrl = doc.data()!['profile_picture'] as String?;
          });
        }
      } catch (e) {
        _showSnackBar('Error fetching profile picture: $e', Colors.red);
      }
    }
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() {
        _selectedImage = picked;
      });
    }
  }

  Future<void> _saveImageProfile() async {
    if (_selectedImage == null) {
      _showSnackBar('Please select an image first.', Colors.red);
      return;
    }

    if (user == null) {
      _showSnackBar('User not logged in.', Colors.red);
      return;
    }

    setState(() => isLoading = true);

    try {
      final cloudName = 'dimwxding';
      final uploadPreset = 'flutter_upload';

      final url = Uri.parse('https://api.cloudinary.com/v1_1/$cloudName/image/upload');
      FormData formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(_selectedImage!.path),
        'upload_preset': uploadPreset,
      });

      Dio dio = Dio();
      dio.options.connectTimeout = Duration(seconds: 10);
      dio.options.receiveTimeout = Duration(seconds: 15);

      final response = await dio.post(url.toString(), data: formData);

      if (response.statusCode == 200 && response.data['secure_url'] != null) {
        final imageUrl = response.data['secure_url'];

        await FirebaseFirestore.instance.collection('Users').doc(user!.uid).set({
          'profile_picture': imageUrl,
        }, SetOptions(merge: true));

        setState(() {
          _profilePictureUrl = imageUrl; 
        });

        _showSnackBar('Profile image updated.', Colors.green);
      } else {
        _showSnackBar('Upload failed. Please try again.', Colors.red);
      }
    } catch (e) {
      _showSnackBar('Error: $e', Colors.red);
    }

    setState(() => isLoading = false);
  }

  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: color),
    );
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
      _showSnackBar('Error deleting account: $e', Colors.red);
    }
  }

  // void _showSnackBar(String message, Color color) {
  //   ScaffoldMessenger.of(context).showSnackBar(
  //     SnackBar(
  //       content: Text(message),
  //       backgroundColor: color,
  //       behavior: SnackBarBehavior.floating,
  //       margin: const EdgeInsets.only(top: 20, left: 20, right: 20),
  //       elevation: 6,
  //       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
  //     ),
  //   );
  // }

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
  key: ValueKey(_imageUrlController.text), 
  radius: 50,
  backgroundImage: _imageUrlController.text.isNotEmpty
      ? NetworkImage(_imageUrlController.text)
      : const AssetImage('assets/default_avatar.png') as ImageProvider,
  onBackgroundImageError: (_, __) {
    print('Image load error');
  },
  child: _imageUrlController.text.isNotEmpty
      ? null
      : const Icon(Icons.person, size: 50, color: Colors.grey),
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
                'Gender: ${_selectedGender[0].toUpperCase()}${_selectedGender.substring(1)}',
                style: const TextStyle(color: Colors.white),
              ),
              const SizedBox(height: 8),
              const Text(
                'Bio:',
                style: TextStyle(color: Colors.white),
              ),
              Text(
                _bioController.text.isEmpty ? 'No bio provided' : _bioController.text,
                style: const TextStyle(color: Colors.white70),
              ),
              const SizedBox(height: 8),
              if (_facebookController.text.isNotEmpty) ...[
                const Text(
                  'Facebook:',
                  style: TextStyle(color: Colors.white),
                ),
                Text(
                  _facebookController.text,
                  style: const TextStyle(color: Colors.white70),
                ),
                const SizedBox(height: 8),
              ],
              if (_linkedinController.text.isNotEmpty) ...[
                const Text(
                  'LinkedIn:',
                  style: TextStyle(color: Colors.white),
                ),
                Text(
                  _linkedinController.text,
                  style: const TextStyle(color: Colors.white70),
                ),
                const SizedBox(height: 8),
              ],
              if (_youtubeController.text.isNotEmpty) ...[
                const Text(
                  'YouTube:',
                  style: TextStyle(color: Colors.white),
                ),
                Text(
                  _youtubeController.text,
                  style: const TextStyle(color: Colors.white70),
                ),
                const SizedBox(height: 8),
              ],
              if (_instagramController.text.isNotEmpty) ...[
                const Text(
                  'Instagram:',
                  style: TextStyle(color: Colors.white),
                ),
                Text(
                  _instagramController.text,
                  style: const TextStyle(color: Colors.white70),
                ),
              ],
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
                          child: Text(g[0].toUpperCase() + g.substring(1),
                              style: const TextStyle(color: Colors.white)),
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
              const SizedBox(height: 12),
              TextField(
                controller: _facebookController,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.grey[900],
                  labelText: 'Facebook URL',
                  labelStyle: TextStyle(color: Colors.grey[400]),
                  prefixIcon: const Icon(Icons.facebook, color: Colors.grey),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
                keyboardType: TextInputType.url,
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _linkedinController,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.grey[900],
                  labelText: 'LinkedIn URL',
                  labelStyle: TextStyle(color: Colors.grey[400]),
                  prefixIcon: const Icon(Icons.link, color: Colors.grey),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
                keyboardType: TextInputType.url,
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _youtubeController,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.grey[900],
                  labelText: 'YouTube URL',
                  labelStyle: TextStyle(color: Colors.grey[400]),
                  prefixIcon: const Icon(Icons.videocam, color: Colors.grey),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
                keyboardType: TextInputType.url,
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _instagramController,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.grey[900],
                  labelText: 'Instagram URL',
                  labelStyle: TextStyle(color: Colors.grey[400]),
                  prefixIcon: const Icon(Icons.camera_alt, color: Colors.grey),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
                keyboardType: TextInputType.url,
              ),
              const SizedBox(height: 16),
              Center(
                child: ElevatedButton(
                  onPressed: _saveProfile,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromARGB(255, 137, 52, 216),
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
                    backgroundColor: const Color.fromARGB(255, 137, 52, 216),
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
        return Column(
  mainAxisAlignment: MainAxisAlignment.center,
  crossAxisAlignment: CrossAxisAlignment.center,
  children: [
  
    const Text(
      'Select an image from your gallery.',
      style: TextStyle(color: Colors.white70),
    ),
    const SizedBox(height: 16),
    _selectedImage != null
        ? FutureBuilder<Uint8List>(
            future: _selectedImage!.readAsBytes(),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                return Image.memory(
                  snapshot.data!,
                  height: 150,
                  fit: BoxFit.cover,
                );
              } else if (snapshot.hasError) {
                return const Text(
                  'Error loading image.',
                  style: TextStyle(color: Colors.white),
                );
              }
              return const CircularProgressIndicator();
            },
          )
        : _profilePictureUrl != null
            ? Image.network(
                _profilePictureUrl!,
                height: 150,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Image.asset(
                  'assets/Images/defaultt.png',
                  height: 150,
                  fit: BoxFit.cover,
                ),
              )
            : Image.asset(
                'assets/Images/defaultt.png',
                height: 150,
                fit: BoxFit.cover,
              ),
    const SizedBox(height: 16), 
    Padding(
      padding: const EdgeInsets.only(top: 16),
      child: ElevatedButton(
        onPressed: _pickImage,
        style: ElevatedButton.styleFrom(
          backgroundColor:  const Color.fromARGB(255, 98, 22, 190) ,
          foregroundColor: Colors.white, 
        ),
        child: const Text(
          'Pick Image',
          style: TextStyle(fontSize: 16, color: Colors.white),
        ),
      ),
    ),
    const SizedBox(height: 8), 
    ElevatedButton(
      onPressed: _selectedImage != null && !isLoading ? _saveImageProfile : null,
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color.fromARGB(255, 98, 22, 190), 
        foregroundColor: Colors.white,
      ),
      child: isLoading
          ? const CircularProgressIndicator(color: Colors.white)
          : const Text(
              'Upload',
              style: TextStyle(fontSize: 16, color: Colors.white),
            ),
    ),
  ],
);
      case 'delete_account':
        return Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Permanently delete your account?',
                style: TextStyle(color: Colors.white, fontSize: 18),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
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
            ],
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
              backgroundImage: _imageUrlController.text.isNotEmpty
                  ? NetworkImage(_imageUrlController.text)
                  : const AssetImage('assets/default_avatar.png')
                      as ImageProvider,
              onBackgroundImageError: (_, __) {
                print('Image load error');
              },
              child: _imageUrlController.text.isNotEmpty
                  ? null
                  : const Icon(Icons.person, size: 50, color: Colors.grey),
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
    _facebookController.dispose();
    _linkedinController.dispose();
    _youtubeController.dispose();
    _instagramController.dispose();
    super.dispose();
  }
}