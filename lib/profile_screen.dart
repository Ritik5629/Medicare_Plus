import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:intl/intl.dart';
import 'auth_service.dart';
import 'models.dart';
import 'theme_provider.dart';

// --- PLACEHOLDER SCREENS (Replace with your actual files) ---

class HairDiagnosisScreen extends StatelessWidget {
  const HairDiagnosisScreen({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Hair Diagnosis')),
      body: const Center(child: Text('Hair Diagnosis Screen (Placeholder)')),
    );
  }
}

class DentalCheckScreen extends StatelessWidget {
  const DentalCheckScreen({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Dental Check')),
      body: const Center(child: Text('Dental Check Screen (Placeholder)')),
    );
  }
}

class SkinDiagnosisScreen extends StatelessWidget {
  const SkinDiagnosisScreen({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Skin Diagnosis')),
      body: const Center(child: Text('Skin Diagnosis Screen (Placeholder)')),
    );
  }
}

// -------------------------------------------------------------------

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> with TickerProviderStateMixin {
  final User? user = FirebaseAuth.instance.currentUser;
  UserProfile? userProfile;
  bool _isLoading = true;
  late AnimationController _animationController;
  late AnimationController _pulseController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _pulseAnimation;

  int _profileCompleteness = 0;
  List<Achievement> _achievements = [];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: true);

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.05).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _loadUserProfile();
    _initializeAchievements();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  void _initializeAchievements() {
    _achievements = [
      Achievement(
        title: 'Profile Master',
        description: 'Complete your profile 100%',
        icon: Icons.emoji_events,
        color: Colors.amber,
        isUnlocked: false,
      ),
      Achievement(
        title: 'Health Warrior',
        description: 'Log 30 health records',
        icon: Icons.fitness_center,
        color: Colors.green,
        isUnlocked: false,
      ),
      Achievement(
        title: 'Consistent User',
        description: 'Use app for 7 consecutive days',
        icon: Icons.calendar_today,
        color: Colors.blue,
        isUnlocked: false,
      ),
    ];
  }

  Future<void> _loadUserProfile() async {
    if (user != null) {
      try {
        UserProfile? profile = await AuthService().getUserProfile(user!.uid);
        setState(() {
          userProfile = profile;
          _isLoading = false;
          if (userProfile != null) {
            _calculateProfileCompleteness();
          }
        });
        _animationController.forward();
      } catch (e) {
        setState(() {
          _isLoading = false;
        });
        _showErrorSnackBar('Failed to load profile');
      }
    }
  }

  void _calculateProfileCompleteness() {
    int completed = 0;
    int total = 6;

    if (userProfile?.name.isNotEmpty == true) completed++;
    if (userProfile?.age != null && userProfile!.age > 0) completed++;
    if (userProfile?.gender.isNotEmpty == true) completed++;
    if (userProfile?.medicalHistory.isNotEmpty == true) completed++;
    if (userProfile?.allergies.isNotEmpty == true) completed++;
    if (userProfile?.profilePictureUrl != null) completed++;

    setState(() {
      _profileCompleteness = ((completed / total) * 100).round();
      if (_profileCompleteness == 100) {
        _achievements[0].isUnlocked = true;
      }
    });
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.red.shade600,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.green.shade600,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  Future<void> _showProfileOptions() async {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(25)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 50,
              height: 5,
              margin: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: Text(
                'Profile Options',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ),
            _buildBottomSheetOption(
              icon: Icons.edit,
              title: 'Edit Profile',
              subtitle: 'Update your personal information',
              color: Colors.blue,
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => EditProfileScreen(userProfile: userProfile),
                  ),
                ).then((_) => _loadUserProfile());
              },
            ),
            _buildBottomSheetOption(
              icon: Icons.lock_outline,
              title: 'Change Password',
              subtitle: 'Update your account password',
              color: Colors.orange,
              onTap: () {
                Navigator.pop(context);
                _showChangePasswordDialog();
              },
            ),
            _buildBottomSheetOption(
              icon: Icons.privacy_tip_outlined,
              title: 'Privacy Settings',
              subtitle: 'Manage your privacy preferences',
              color: Colors.purple,
              onTap: () {
                Navigator.pop(context);
                _showPrivacySettings();
              },
            ),
            _buildBottomSheetOption(
              icon: Icons.download_outlined,
              title: 'Export Data',
              subtitle: 'Download your profile data',
              color: Colors.teal,
              onTap: () {
                Navigator.pop(context);
                _exportUserData();
              },
            ),
            _buildBottomSheetOption(
              icon: Icons.delete_forever,
              title: 'Delete Account',
              subtitle: 'Permanently delete your account',
              color: Colors.red,
              onTap: () {
                Navigator.pop(context);
                _showDeleteAccountDialog();
              },
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomSheetOption({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: color),
      ),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
      subtitle: Text(subtitle, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
      trailing: Icon(Icons.chevron_right, color: Colors.grey[400]),
      onTap: onTap,
    );
  }

  Future<void> _exportUserData() async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: const [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Exporting your data...'),
          ],
        ),
      ),
    );

    await Future.delayed(const Duration(seconds: 2));
    Navigator.pop(context);
    _showSuccessSnackBar('Data exported successfully!');
  }

  Future<void> _showChangePasswordDialog() async {
    final currentPasswordController = TextEditingController();
    final newPasswordController = TextEditingController();
    final confirmPasswordController = TextEditingController();
    bool isLoading = false;
    bool obscureCurrentPassword = true;
    bool obscureNewPassword = true;
    bool obscureConfirmPassword = true;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.orange.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.lock_outline, color: Colors.orange),
              ),
              const SizedBox(width: 12),
              const Text('Change Password'),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: currentPasswordController,
                  obscureText: obscureCurrentPassword,
                  decoration: InputDecoration(
                    labelText: 'Current Password',
                    prefixIcon: const Icon(Icons.lock_outline),
                    suffixIcon: IconButton(
                      icon: Icon(obscureCurrentPassword ? Icons.visibility_outlined : Icons.visibility_off_outlined),
                      onPressed: () => setDialogState(() => obscureCurrentPassword = !obscureCurrentPassword),
                    ),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    filled: true,
                    fillColor: Colors.grey.shade50,
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: newPasswordController,
                  obscureText: obscureNewPassword,
                  decoration: InputDecoration(
                    labelText: 'New Password',
                    prefixIcon: const Icon(Icons.lock),
                    suffixIcon: IconButton(
                      icon: Icon(obscureNewPassword ? Icons.visibility_outlined : Icons.visibility_off_outlined),
                      onPressed: () => setDialogState(() => obscureNewPassword = !obscureNewPassword),
                    ),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    filled: true,
                    fillColor: Colors.grey.shade50,
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: confirmPasswordController,
                  obscureText: obscureConfirmPassword,
                  decoration: InputDecoration(
                    labelText: 'Confirm Password',
                    prefixIcon: const Icon(Icons.lock_clock),
                    suffixIcon: IconButton(
                      icon: Icon(obscureConfirmPassword ? Icons.visibility_outlined : Icons.visibility_off_outlined),
                      onPressed: () => setDialogState(() => obscureConfirmPassword = !obscureConfirmPassword),
                    ),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    filled: true,
                    fillColor: Colors.grey.shade50,
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: isLoading ? null : () => Navigator.pop(context),
              child: Text('Cancel', style: TextStyle(color: Colors.grey[600])),
            ),
            ElevatedButton(
              onPressed: isLoading ? null : () async {
                if (newPasswordController.text != confirmPasswordController.text) {
                  _showErrorSnackBar('Passwords do not match');
                  return;
                }
                if (newPasswordController.text.length < 6) {
                  _showErrorSnackBar('Password must be at least 6 characters');
                  return;
                }

                setDialogState(() => isLoading = true);

                try {
                  final credential = EmailAuthProvider.credential(
                    email: user!.email!,
                    password: currentPasswordController.text,
                  );
                  await user!.reauthenticateWithCredential(credential);
                  await user!.updatePassword(newPasswordController.text);

                  Navigator.pop(context);
                  _showSuccessSnackBar('Password updated successfully!');
                } catch (e) {
                  _showErrorSnackBar('Failed to update password. Check your current password.');
                }

                setDialogState(() => isLoading = false);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
              child: isLoading
                  ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                  : const Text('Update'),
            ),
          ],
        ),
      ),
    );
  }

  void _showPrivacySettings() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const PrivacySettingsScreen()),
    );
  }

  void _showDeleteAccountDialog() {
    final passwordController = TextEditingController();
    bool obscurePassword = true;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.warning_amber_rounded, color: Colors.red),
              ),
              const SizedBox(width: 12),
              const Text('Delete Account'),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'This action is permanent and cannot be undone!',
                style: TextStyle(fontWeight: FontWeight.bold, color: Colors.red),
              ),
              const SizedBox(height: 16),
              const Text(
                'All your data will be permanently removed:',
                style: TextStyle(fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 8),
              _buildDeleteWarningItem('Profile information'),
              _buildDeleteWarningItem('Medical records'),
              _buildDeleteWarningItem('Appointment history'),
              _buildDeleteWarningItem('All saved data'),
              const SizedBox(height: 16),
              const Text(
                'Enter your password to confirm:',
                style: TextStyle(fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: passwordController,
                obscureText: obscurePassword,
                decoration: InputDecoration(
                  labelText: 'Password',
                  prefixIcon: const Icon(Icons.lock_outline),
                  suffixIcon: IconButton(
                    icon: Icon(obscurePassword ? Icons.visibility_outlined : Icons.visibility_off_outlined),
                    onPressed: () => setDialogState(() => obscurePassword = !obscurePassword),
                  ),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  filled: true,
                  fillColor: Colors.grey.shade50,
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              onPressed: () async {
                if (passwordController.text.isEmpty) {
                  _showErrorSnackBar('Please enter your password');
                  return;
                }

                try {
                  final credential = EmailAuthProvider.credential(
                    email: user!.email!,
                    password: passwordController.text,
                  );
                  await user!.reauthenticateWithCredential(credential);
                  await user!.delete();

                  Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
                } catch (e) {
                  Navigator.pop(context);
                  _showErrorSnackBar('Failed to delete account. Please check your password.');
                }
              },
              child: const Text('Delete Forever'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDeleteWarningItem(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(Icons.close, size: 16, color: Colors.red[300]),
          const SizedBox(width: 8),
          Text(text, style: TextStyle(color: Colors.grey[700])),
        ],
      ),
    );
  }

  void _showQRCode() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('My Profile QR Code', textAlign: TextAlign.center),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(15),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Icon(Icons.qr_code_2, size: 150, color: Colors.grey[800]),
                  const SizedBox(height: 12),
                  Text(
                    user?.email ?? 'User',
                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Share this code with healthcare providers',
              style: TextStyle(fontSize: 12, color: Colors.grey),
              textAlign: TextAlign.center,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
          ElevatedButton.icon(
            onPressed: () {
              _showSuccessSnackBar('QR Code saved to gallery!');
              Navigator.pop(context);
            },
            icon: const Icon(Icons.download, size: 18),
            label: const Text('Save'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final theme = Theme.of(context);

    return Scaffold(
      body: _isLoading
          ? Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: 16),
            Text('Loading your profile...', style: TextStyle(color: Colors.grey[600])),
          ],
        ),
      )
          : userProfile == null
          ? _buildErrorState()
          : FadeTransition(
        opacity: _fadeAnimation,
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            _buildSliverAppBar(theme),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(8.0), // Reduced padding
                child: Column(
                  children: [
                    _buildProfileHeader(),
                    const SizedBox(height: 8), // Reduced height
                    _buildProfileCompletenessCard(),
                    const SizedBox(height: 8), // Reduced height
                    _buildQuickStats(),
                    const SizedBox(height: 8), // Reduced height

                    // --- DIAGNOSIS QUICK LINKS SECTION ---
                    _buildDiagnosisQuickLinks(),
                    const SizedBox(height: 8),
                    // -------------------------------------

                    _buildAchievementsCard(),
                    const SizedBox(height: 8), // Reduced height
                    _buildMedicalInfoCard(),
                    const SizedBox(height: 8), // Reduced height
                    _buildActivityTimeline(),
                    const SizedBox(height: 8), // Reduced height
                    _buildAppSettingsCard(themeProvider),
                    const SizedBox(height: 8), // Reduced height
                    _buildActionButtons(),
                    const SizedBox(height: 16), // Reduced height
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 80, color: Colors.grey[300]),
          const SizedBox(height: 16),
          Text(
            'Oops! Something went wrong',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.grey[700]),
          ),
          const SizedBox(height: 8),
          Text(
            'Unable to load your profile data',
            style: TextStyle(fontSize: 14, color: Colors.grey[500]),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: _loadUserProfile,
            icon: const Icon(Icons.refresh),
            label: const Text('Try Again'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSliverAppBar(ThemeData theme) {
    return SliverAppBar(
      expandedHeight: 80, // Reduced height
      floating: false,
      pinned: true,
      backgroundColor: theme.primaryColor,
      flexibleSpace: FlexibleSpaceBar(
        title: const Text('My Profile', style: TextStyle(fontWeight: FontWeight.w600)),
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [theme.primaryColor, theme.primaryColor.withOpacity(0.7)],
            ),
          ),
        ),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.qr_code_rounded),
          tooltip: 'My QR Code',
          onPressed: () => _showQRCode(),
        ),
        IconButton(
          icon: const Icon(Icons.more_vert),
          onPressed: _showProfileOptions,
        ),
      ],
    );
  }

  Widget _buildProfileHeader() {
    return Container(
      padding: const EdgeInsets.all(12), // Reduced padding
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Colors.blue.shade400, Colors.purple.shade400],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.purple.withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Stack(
            children: [
              Hero(
                tag: 'profile_avatar',
                child: ScaleTransition(
                  scale: _pulseAnimation,
                  child: Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 3),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 15,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: CircleAvatar(
                      radius: 35, // Reduced radius
                      backgroundColor: Colors.white,
                      backgroundImage: userProfile?.profilePictureUrl != null
                          ? NetworkImage(userProfile!.profilePictureUrl!)
                          : null,
                      child: userProfile?.profilePictureUrl == null
                          ? const Icon(Icons.person, size: 35, color: Colors.blue) // Reduced size
                          : null,
                    ),
                  ),
                ),
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.all(4), // Reduced padding
                  decoration: BoxDecoration(
                    color: Colors.green,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                  child: const Icon(Icons.verified, color: Colors.white, size: 16), // Reduced size
                ),
              ),
            ],
          ),
          const SizedBox(height: 12), // Reduced height
          Text(
            userProfile?.name ?? user?.email?.split('@')[0] ?? 'User', // Use email prefix if name is not available
            style: const TextStyle(
              fontSize: 18, // Reduced font size
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 8), // Reduced height
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6), // Reduced padding
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.white.withOpacity(0.3), width: 1),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.cake_outlined, color: Colors.white, size: 14), // Reduced size
                const SizedBox(width: 4), // Reduced width
                Text(
                  '${userProfile?.age ?? 0} years',
                  style: const TextStyle(
                    fontSize: 12, // Reduced font size
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(width: 8), // Reduced width
                Container(
                  width: 3, // Reduced size
                  height: 3,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 8), // Reduced width
                Icon(
                  userProfile?.gender == 'Male' ? Icons.male :
                  userProfile?.gender == 'Female' ? Icons.female : Icons.transgender,
                  color: Colors.white,
                  size: 14, // Reduced size
                ),
                const SizedBox(width: 4), // Reduced width
                Text(
                  userProfile?.gender ?? 'Not specified',
                  style: const TextStyle(
                    fontSize: 12, // Reduced font size
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8), // Reduced height
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.email_outlined, color: Colors.white70, size: 12), // Reduced size
              const SizedBox(width: 4), // Reduced width
              Expanded(
                child: Text(
                  user?.email ?? '',
                  style: const TextStyle(
                    fontSize: 11, // Reduced font size
                    color: Colors.white70,
                    fontWeight: FontWeight.w500,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildProfileCompletenessCard() {
    return Container(
      padding: const EdgeInsets.all(12), // Reduced padding
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Colors.orange.shade50, Colors.orange.shade100],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.orange.withOpacity(0.2),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Profile Completeness',
                style: TextStyle(
                  fontSize: 14, // Reduced font size
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3), // Reduced padding
                decoration: BoxDecoration(
                  color: Colors.orange,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  '$_profileCompleteness%',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 12, // Reduced font size
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8), // Reduced height
          LinearProgressIndicator(
            value: _profileCompleteness / 100,
            backgroundColor: Colors.orange.shade200,
            valueColor: AlwaysStoppedAnimation<Color>(Colors.orange.shade700),
            minHeight: 6, // Reduced height
            borderRadius: BorderRadius.circular(8),
          ),
          const SizedBox(height: 8), // Reduced height
          const Text(
            'Complete your profile to get better healthcare recommendations',
            style: TextStyle(
              fontSize: 11, // Reduced font size
              color: Colors.black54,
            ),
          ),
          const SizedBox(height: 8), // Reduced height
          ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => EditProfileScreen(userProfile: userProfile),
                ),
              ).then((_) => _loadUserProfile());
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8), // Reduced padding
            ),
            child: const Text('Complete Profile', style: TextStyle(fontSize: 12)), // Reduced font size
          ),
        ],
      ),
    );
  }

  Widget _buildQuickStats() {
    return Container(
      padding: const EdgeInsets.all(12), // Reduced padding
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Health Stats',
            style: TextStyle(
              fontSize: 14, // Reduced font size
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12), // Reduced height
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStatCard(
                icon: Icons.calendar_today,
                title: 'Appointments',
                value: '12',
                color: Colors.blue,
              ),
              _buildStatCard(
                icon: Icons.medication,
                title: 'Medications',
                value: '5',
                color: Colors.green,
              ),
              _buildStatCard(
                icon: Icons.monitor_heart,
                title: 'Health Records',
                value: '24',
                color: Colors.red,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDiagnosisQuickLinks() {
    return Container(
      padding: const EdgeInsets.all(12), // Reduced padding
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Quick Diagnosis Tools',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildDiagnosisButton(
                icon: Icons.content_cut,
                label: 'Hair',
                screen: const HairDiagnosisScreen(),
                color: Colors.brown.shade400,
              ),
              _buildDiagnosisButton(
                // Corrected icon
                icon: Icons.badge,
                label: 'Dental',
                screen: const DentalCheckScreen(),
                color: Colors.blue.shade400,
              ),
              _buildDiagnosisButton(
                // Corrected icon
                icon: Icons.person_pin,
                label: 'Skin',
                screen: const SkinDiagnosisScreen(),
                color: Colors.pink.shade400,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDiagnosisButton({
    required IconData icon,
    required String label,
    required Widget screen,
    required Color color,
  }) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => screen),
        );
      },
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: color.withOpacity(0.3), width: 1),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: Colors.grey[800],
              ),
            ),
          ],
        ),
      ),
    );
  }


  Widget _buildStatCard({
    required IconData icon,
    required String title,
    required String value,
    required Color color,
  }) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(8), // Reduced padding
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: color, size: 20), // Reduced size
        ),
        const SizedBox(height: 4), // Reduced height
        Text(
          value,
          style: TextStyle(
            fontSize: 16, // Reduced font size
            fontWeight: FontWeight.bold,
            color: Colors.grey[800],
          ),
        ),
        const SizedBox(height: 2), // Reduced height
        Text(
          title,
          style: TextStyle(
            fontSize: 10, // Reduced font size
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  Widget _buildAchievementsCard() {
    return Container(
      padding: const EdgeInsets.all(8), // Reduced padding
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Achievements',
                style: TextStyle(
                  fontSize: 14, // Reduced font size
                  fontWeight: FontWeight.bold,
                ),
              ),
              TextButton(
                onPressed: () {
                  // Navigate to achievements screen
                },
                child: Text(
                  'View All',
                  style: TextStyle(
                    color: Colors.blue.shade600,
                    fontWeight: FontWeight.w500,
                    fontSize: 12, // Reduced font size
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6), // Reduced height
          SizedBox(
            height: 70, // Reduced height
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _achievements.length,
              itemBuilder: (context, index) {
                final achievement = _achievements[index];
                return Container(
                  width: 110, // Reduced width
                  margin: const EdgeInsets.only(right: 6), // Reduced margin
                  padding: const EdgeInsets.all(6), // Reduced padding
                  decoration: BoxDecoration(
                    color: achievement.isUnlocked
                        ? achievement.color.withOpacity(0.1)
                        : Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: achievement.isUnlocked
                          ? achievement.color.withOpacity(0.3)
                          : Colors.grey.shade300,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        achievement.icon,
                        color: achievement.isUnlocked
                            ? achievement.color
                            : Colors.grey.shade400,
                        size: 18, // Reduced size
                      ),
                      const SizedBox(height: 3), // Reduced height
                      Text(
                        achievement.title,
                        style: TextStyle(
                          fontSize: 10, // Reduced font size
                          fontWeight: FontWeight.bold,
                          color: achievement.isUnlocked
                              ? Colors.black87
                              : Colors.grey.shade500,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 1), // Reduced height
                      Expanded(
                        child: Text(
                          achievement.description,
                          style: TextStyle(
                            fontSize: 7, // Reduced font size
                            color: achievement.isUnlocked
                                ? Colors.black54
                                : Colors.grey.shade400,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMedicalInfoCard() {
    return Container(
      padding: const EdgeInsets.all(8), // Reduced padding
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Medical Information',
            style: TextStyle(
              fontSize: 14, // Reduced font size
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 6), // Reduced height
          if (userProfile?.medicalHistory?.isNotEmpty == true)
            _buildMedicalInfoItem(
              icon: Icons.history,
              title: 'Medical History',
              content: userProfile!.medicalHistory!,
              color: Colors.blue,
            ),
          if (userProfile?.allergies?.isNotEmpty == true)
            _buildMedicalInfoItem(
              icon: Icons.warning_amber,
              title: 'Allergies',
              content: userProfile!.allergies!.join(', '),
              color: Colors.red,
            ),
          if ((userProfile?.medicalHistory?.isEmpty ?? true) &&
              (userProfile?.allergies?.isEmpty ?? true))
            Container(
              padding: const EdgeInsets.all(6), // Reduced padding
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.blue.shade200),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline, color: Colors.blue.shade700, size: 14), // Reduced size
                  const SizedBox(width: 6), // Reduced width
                  const Expanded(
                    child: Text(
                      'No medical information added yet. Update your profile to add medical history and allergies.',
                      style: TextStyle(fontSize: 9), // Reduced font size
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildMedicalInfoItem({
    required IconData icon,
    required String title,
    required String content,
    required Color color,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 6), // Reduced margin
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(3), // Reduced padding
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 14), // Reduced size
          ),
          const SizedBox(width: 6), // Reduced width
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 11, // Reduced font size
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 1), // Reduced height
                Text(
                  content,
                  style: TextStyle(
                    fontSize: 9, // Reduced font size
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActivityTimeline() {
    return Container(
      padding: const EdgeInsets.all(8), // Reduced padding
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Recent Activity',
                style: TextStyle(
                  fontSize: 14, // Reduced font size
                  fontWeight: FontWeight.bold,
                ),
              ),
              TextButton(
                onPressed: () {
                  // Navigate to activity screen
                },
                child: Text(
                  'View All',
                  style: TextStyle(
                    color: Colors.blue.shade600,
                    fontWeight: FontWeight.w500,
                    fontSize: 12, // Reduced font size
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6), // Reduced height
          _buildActivityItem(
            icon: Icons.edit_document,
            title: 'Updated Profile',
            subtitle: 'Changed profile picture',
            time: '2 hours ago',
            color: Colors.blue,
          ),
          _buildActivityItem(
            icon: Icons.medication,
            title: 'Added Medication',
            subtitle: 'Vitamin D supplements',
            time: '1 day ago',
            color: Colors.green,
          ),
          _buildActivityItem(
            icon: Icons.calendar_today,
            title: 'Booked Appointment',
            subtitle: 'Dr. Smith - General Checkup',
            time: '3 days ago',
            color: Colors.purple,
          ),
        ],
      ),
    );
  }

  Widget _buildActivityItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required String time,
    required Color color,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6), // Reduced padding
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(3), // Reduced padding
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 14), // Reduced size
          ),
          const SizedBox(width: 6), // Reduced width
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 11, // Reduced font size
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 1), // Reduced height
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 9, // Reduced font size
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          Text(
            time,
            style: TextStyle(
              fontSize: 8, // Reduced font size
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppSettingsCard(ThemeProvider themeProvider) {
    return Container(
      padding: const EdgeInsets.all(8), // Reduced padding
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'App Settings',
            style: TextStyle(
              fontSize: 14, // Reduced font size
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 6), // Reduced height
          SwitchListTile(
            secondary: Container(
              padding: const EdgeInsets.all(3), // Reduced padding
              decoration: BoxDecoration(
                color: themeProvider.isDarkMode
                    ? Colors.indigo.withOpacity(0.1)
                    : Colors.amber.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                themeProvider.isDarkMode ? Icons.dark_mode : Icons.light_mode,
                color: themeProvider.isDarkMode ? Colors.indigo : Colors.amber,
                size: 14, // Reduced size
              ),
            ),
            title: const Text('Dark Mode', style: TextStyle(fontSize: 11)), // Reduced font size
            subtitle: const Text('Switch between light and dark themes', style: TextStyle(fontSize: 9)), // Reduced font size
            value: themeProvider.isDarkMode,
            onChanged: (value) {
              themeProvider.toggleTheme();
            },
            activeColor: Colors.blue,
          ),
          const SizedBox(height: 2), // Reduced height
          ListTile(
            leading: Container(
              padding: const EdgeInsets.all(3), // Reduced padding
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.notifications, color: Colors.blue, size: 14), // Reduced size
            ),
            title: const Text('Notification Settings', style: TextStyle(fontSize: 11)), // Reduced font size
            subtitle: const Text('Manage app notifications', style: TextStyle(fontSize: 9)), // Reduced font size
            trailing: const Icon(Icons.chevron_right, size: 14), // Reduced size
            onTap: () {
              // Navigate to notification settings
            },
          ),
          const SizedBox(height: 2), // Reduced height
          ListTile(
            leading: Container(
              padding: const EdgeInsets.all(3), // Reduced padding
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.language, color: Colors.green, size: 14), // Reduced size
            ),
            title: const Text('Language', style: TextStyle(fontSize: 11)), // Reduced font size
            subtitle: const Text('English', style: TextStyle(fontSize: 9)), // Reduced font size
            trailing: const Icon(Icons.chevron_right, size: 14), // Reduced size
            onTap: () {
              // Navigate to language settings
            },
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: () async {
              showDialog(
                context: context,
                barrierDismissible: false,
                builder: (context) => AlertDialog(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: const [
                      CircularProgressIndicator(),
                      SizedBox(height: 16),
                      Text('Signing out...'),
                    ],
                  ),
                ),
              );

              await Future.delayed(const Duration(seconds: 1));

              try {
                await AuthService().signOut();
                Navigator.pushNamedAndRemoveUntil(
                  context,
                  '/login',
                      (route) => false,
                );
              } catch (e) {
                Navigator.pop(context);
                _showErrorSnackBar('Failed to sign out. Please try again.');
              }
            },
            icon: const Icon(Icons.logout_rounded, size: 16), // Reduced size
            label: const Text(
              'Sign Out',
              style: TextStyle(
                fontSize: 12, // Reduced font size
                fontWeight: FontWeight.w600,
              ),
            ),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 10), // Reduced padding
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              backgroundColor: Colors.red.shade500,
              foregroundColor: Colors.white,
              elevation: 3,
              shadowColor: Colors.red.withOpacity(0.3),
            ),
          ),
        ),
        const SizedBox(height: 6), // Reduced height
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextButton.icon(
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                    title: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: Colors.blue.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(Icons.help_outline, color: Colors.blue),
                        ),
                        const SizedBox(width: 10),
                        const Text('Help & Support'),
                      ],
                    ),
                    content: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        ListTile(
                          leading: const Icon(Icons.email, color: Colors.blue),
                          title: const Text('Email Support'),
                          subtitle: const Text('support@health.com'),
                          onTap: () {
                            Navigator.pop(context);
                            _showSuccessSnackBar('Opening email client...');
                          },
                        ),
                        ListTile(
                          leading: const Icon(Icons.phone, color: Colors.green),
                          title: const Text('Call Us'),
                          subtitle: const Text('+1 (555) 123-4567'),
                          onTap: () {
                            Navigator.pop(context);
                            _showSuccessSnackBar('Calling support...');
                          },
                        ),
                        ListTile(
                          leading: const Icon(Icons.chat, color: Colors.purple),
                          title: const Text('Live Chat'),
                          subtitle: const Text('Chat with our team'),
                          onTap: () {
                            Navigator.pop(context);
                            _showSuccessSnackBar('Starting live chat...');
                          },
                        ),
                      ],
                    ),
                  ),
                );
              },
              icon: const Icon(Icons.help_outline, size: 14), // Reduced size
              label: const Text(
                'Need Help?',
                style: TextStyle(
                  decoration: TextDecoration.underline,
                  fontWeight: FontWeight.w500,
                  fontSize: 10, // Reduced font size
                ),
              ),
            ),
            const SizedBox(width: 6), // Reduced width
            TextButton.icon(
              onPressed: () {
                showAboutDialog(
                  context: context,
                  applicationName: 'Health App',
                  applicationVersion: '2.0.0',
                  applicationIcon: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Colors.blue.shade400, Colors.purple.shade400],
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.favorite, color: Colors.white, size: 24),
                  ),
                  children: const [
                    SizedBox(height: 12),
                    Text(
                      'Your personal health companion\n\nMade with love for better healthcare',
                      textAlign: TextAlign.center,
                    ),
                  ],
                );
              },
              icon: const Icon(Icons.info_outline, size: 14), // Reduced size
              label: const Text(
                'About',
                style: TextStyle(
                  decoration: TextDecoration.underline,
                  fontWeight: FontWeight.w500,
                  fontSize: 10, // Reduced font size
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 4), // Reduced height
        Text(
          'Version 2.0.0 • Built with Flutter',
          style: TextStyle(
            fontSize: 8, // Reduced font size
            color: Colors.grey[500],
            fontStyle: FontStyle.italic,
          ),
        ),
      ],
    );
  }
}

// Achievement Model
class Achievement {
  final String title;
  final String description;
  final IconData icon;
  final Color color;
  bool isUnlocked;

  Achievement({
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
    this.isUnlocked = false,
  });
}

// Edit Profile Screen
class EditProfileScreen extends StatefulWidget {
  final UserProfile? userProfile;

  const EditProfileScreen({Key? key, this.userProfile}) : super(key: key);

  @override
  _EditProfileScreenState createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _ageController = TextEditingController();
  final _medicalHistoryController = TextEditingController();
  final _allergiesController = TextEditingController();

  String _selectedGender = 'Male';
  bool _isLoading = false;
  File? _selectedImage;
  final ImagePicker _picker = ImagePicker();

  final List<String> _genders = ['Male', 'Female', 'Other'];

  @override
  void initState() {
    super.initState();
    if (widget.userProfile != null) {
      _nameController.text = widget.userProfile!.name;
      _ageController.text = widget.userProfile!.age.toString();
      _selectedGender = widget.userProfile!.gender;
      _medicalHistoryController.text = widget.userProfile!.medicalHistory;
      _allergiesController.text = widget.userProfile!.allergies.join(', ');
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _ageController.dispose();
    _medicalHistoryController.dispose();
    _allergiesController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(25)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 50,
              height: 5,
              margin: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: Text(
                'Select Image Source',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.camera_alt, color: Colors.blue),
              ),
              title: const Text('Take Photo'),
              subtitle: const Text('Use camera to take a new photo'),
              onTap: () async {
                Navigator.pop(context);
                final XFile? image = await _picker.pickImage(
                  source: ImageSource.camera,
                  maxWidth: 800,
                  maxHeight: 800,
                  imageQuality: 85,
                );
                if (image != null) {
                  setState(() => _selectedImage = File(image.path));
                }
              },
            ),
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.purple.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.photo_library, color: Colors.purple),
              ),
              title: const Text('Choose from Gallery'),
              subtitle: const Text('Select from your photos'),
              onTap: () async {
                Navigator.pop(context);
                final XFile? image = await _picker.pickImage(
                  source: ImageSource.gallery,
                  maxWidth: 800,
                  maxHeight: 800,
                  imageQuality: 85,
                );
                if (image != null) {
                  setState(() => _selectedImage = File(image.path));
                }
              },
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Future<void> _saveProfile() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);

      try {
        List<String> allergies = [];
        if (_allergiesController.text.trim().isNotEmpty) {
          allergies = _allergiesController.text
              .split(',')
              .map((e) => e.trim())
              .where((e) => e.isNotEmpty)
              .toList();
        }

        UserProfile updatedProfile = UserProfile(
          name: _nameController.text.trim(),
          age: int.parse(_ageController.text.trim()),
          gender: _selectedGender,
          medicalHistory: _medicalHistoryController.text.trim(),
          allergies: allergies,
          profilePictureUrl: widget.userProfile?.profilePictureUrl,
        );

        bool success = await AuthService().updateUserProfile(
          FirebaseAuth.instance.currentUser!.uid,
          updatedProfile,
        );

        if (success) {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: const [
                  Icon(Icons.check_circle, color: Colors.white),
                  SizedBox(width: 12),
                  Text('Profile updated successfully!'),
                ],
              ),
              backgroundColor: Colors.green.shade600,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              margin: const EdgeInsets.all(16),
            ),
          );
        } else {
          throw Exception('Update failed');
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: const [
                Icon(Icons.error_outline, color: Colors.white),
                SizedBox(width: 12),
                Expanded(child: Text('Failed to update profile. Please try again.')),
              ],
            ),
            backgroundColor: Colors.red.shade600,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            margin: const EdgeInsets.all(16),
          ),
        );
      } finally {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Profile', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.blue.shade400, Colors.purple.shade400],
            ),
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: TextButton.icon(
              onPressed: _isLoading ? null : _saveProfile,
              icon: _isLoading
                  ? const SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
                  : const Icon(Icons.check, color: Colors.white),
              label: const Text(
                'Save',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              style: TextButton.styleFrom(
                backgroundColor: Colors.white.withOpacity(0.2),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(8.0), // Reduced padding
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              _buildProfileImagePicker(),
              const SizedBox(height: 16), // Reduced height
              _buildFormField(
                controller: _nameController,
                label: 'Full Name',
                icon: Icons.person,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 8), // Reduced height
              Row(
                children: [
                  Expanded(
                    child: _buildFormField(
                      controller: _ageController,
                      label: 'Age',
                      icon: Icons.cake,
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Enter age';
                        }
                        if (int.tryParse(value) == null || int.parse(value) <= 0) {
                          return 'Invalid age';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 8), // Reduced width
                  Expanded(
                    child: _buildGenderDropdown(),
                  ),
                ],
              ),
              const SizedBox(height: 8), // Reduced height
              _buildFormField(
                controller: _medicalHistoryController,
                label: 'Medical History',
                icon: Icons.history,
                maxLines: 3, // Reduced lines
                hintText: 'Enter your medical history...',
              ),
              const SizedBox(height: 8), // Reduced height
              _buildFormField(
                controller: _allergiesController,
                label: 'Allergies (comma separated)',
                icon: Icons.warning_amber,
                hintText: 'e.g., Peanuts, Dust, Pollen',
                maxLines: 2,
              ),
              const SizedBox(height: 16), // Reduced height
              Container(
                padding: const EdgeInsets.all(8), // Reduced padding
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.blue.shade200),
                ),
                child: Row(
                  children: [
                    Icon(Icons.info_outline, color: Colors.blue.shade700, size: 14), // Reduced size
                    const SizedBox(width: 6), // Reduced width
                    const Expanded(
                      child: Text(
                        'Keep your profile updated for better healthcare services',
                        style: TextStyle(fontSize: 9), // Reduced font size
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16), // Reduced height
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileImagePicker() {
    return Center(
      child: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [Colors.blue.shade300, Colors.purple.shade300],
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.purple.withOpacity(0.3),
                  blurRadius: 15,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            padding: const EdgeInsets.all(2), // Reduced padding
            child: Container(
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white,
              ),
              padding: const EdgeInsets.all(2), // Reduced padding
              child: CircleAvatar(
                radius: 40, // Reduced radius
                backgroundColor: Colors.grey.shade200,
                backgroundImage: _selectedImage != null
                    ? FileImage(_selectedImage!) as ImageProvider
                    : (widget.userProfile?.profilePictureUrl != null
                    ? NetworkImage(widget.userProfile!.profilePictureUrl!)
                    : null),
                child: _selectedImage == null && widget.userProfile?.profilePictureUrl == null
                    ? Icon(Icons.person, size: 40, color: Colors.grey[400]) // Reduced size
                    : null,
              ),
            ),
          ),
          Positioned(
            bottom: 0,
            right: 0,
            child: GestureDetector(
              onTap: _pickImage,
              child: Container(
                padding: const EdgeInsets.all(6), // Reduced padding
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.blue.shade400, Colors.purple.shade400],
                  ),
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.blue.withOpacity(0.4),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.camera_alt,
                  color: Colors.white,
                  size: 16, // Reduced size
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFormField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    String? hintText,
    int maxLines = 1,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: keyboardType,
      validator: validator,
      style: const TextStyle(fontSize: 12), // Reduced font size
      decoration: InputDecoration(
        labelText: label,
        hintText: hintText,
        prefixIcon: Container(
          margin: const EdgeInsets.all(3), // Reduced margin
          padding: const EdgeInsets.all(3), // Reduced padding
          decoration: BoxDecoration(
            color: Colors.blue.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: Colors.blue, size: 14), // Reduced size
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8), // Reduced radius
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8), // Reduced radius
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8), // Reduced radius
          borderSide: const BorderSide(color: Colors.blue, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8), // Reduced radius
          borderSide: const BorderSide(color: Colors.red, width: 2),
        ),
        filled: true,
        fillColor: Colors.grey.shade50,
        contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8), // Reduced padding
      ),
    );
  }

  Widget _buildGenderDropdown() {
    return DropdownButtonFormField<String>(
      value: _selectedGender,
      decoration: InputDecoration(
        labelText: 'Gender',
        prefixIcon: Container(
          margin: const EdgeInsets.all(3), // Reduced margin
          padding: const EdgeInsets.all(3), // Reduced padding
          decoration: BoxDecoration(
            color: Colors.blue.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Icon(Icons.person_outline, color: Colors.blue, size: 14), // Reduced size
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8), // Reduced radius
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8), // Reduced radius
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8), // Reduced radius
          borderSide: const BorderSide(color: Colors.blue, width: 2),
        ),
        filled: true,
        fillColor: Colors.grey.shade50,
      ),
      items: _genders.map((String gender) {
        return DropdownMenuItem<String>(
          value: gender,
          child: Row(
            children: [
              Icon(
                gender == 'Male' ? Icons.male :
                gender == 'Female' ? Icons.female : Icons.transgender,
                size: 12, // Reduced size
                color: Colors.grey[700],
              ),
              const SizedBox(width: 4), // Reduced width
              Text(gender, style: const TextStyle(fontSize: 12)), // Reduced font size
            ],
          ),
        );
      }).toList(),
      onChanged: (String? newValue) {
        if (newValue != null) {
          setState(() => _selectedGender = newValue);
        }
      },
    );
  }
}

// Privacy Settings Screen
class PrivacySettingsScreen extends StatefulWidget {
  const PrivacySettingsScreen({Key? key}) : super(key: key);

  @override
  _PrivacySettingsScreenState createState() => _PrivacySettingsScreenState();
}

class _PrivacySettingsScreenState extends State<PrivacySettingsScreen> {
  bool _profileVisibility = true;
  bool _shareHealthData = false;
  bool _allowNotifications = true;
  bool _dataAnalytics = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Privacy Settings', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.purple.shade400, Colors.pink.shade400],
            ),
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(8), // Reduced padding
        children: [
          Container(
            padding: const EdgeInsets.all(8), // Reduced padding
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.purple.shade50, Colors.pink.shade50],
              ),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.purple.shade200),
            ),
            child: Row(
              children: [
                Icon(Icons.security, color: Colors.purple.shade700, size: 20), // Reduced size
                const SizedBox(width: 8), // Reduced width
                const Expanded(
                  child: Text(
                    'Control your privacy and data sharing preferences',
                    style: TextStyle(fontSize: 10, fontWeight: FontWeight.w500), // Reduced size
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12), // Reduced height
          _buildPrivacySection(
            title: 'Profile Settings',
            children: [
              _buildPrivacyToggle(
                icon: Icons.visibility,
                title: 'Profile Visibility',
                subtitle: 'Allow others to view your profile',
                value: _profileVisibility,
                onChanged: (val) => setState(() => _profileVisibility = val),
              ),
              _buildPrivacyToggle(
                icon: Icons.health_and_safety,
                title: 'Share Health Data',
                subtitle: 'Share anonymous health data for research',
                value: _shareHealthData,
                onChanged: (val) => setState(() => _shareHealthData = val),
              ),
            ],
          ),
          const SizedBox(height: 6), // Reduced height
          _buildPrivacySection(
            title: 'Communication',
            children: [
              _buildPrivacyToggle(
                icon: Icons.notifications,
                title: 'Push Notifications',
                subtitle: 'Receive app notifications',
                value: _allowNotifications,
                onChanged: (val) => setState(() => _allowNotifications = val),
              ),
            ],
          ),
          const SizedBox(height: 6), // Reduced height
          _buildPrivacySection(
            title: 'Data Usage',
            children: [
              _buildPrivacyToggle(
                icon: Icons.analytics,
                title: 'Analytics',
                subtitle: 'Help improve the app with usage data',
                value: _dataAnalytics,
                onChanged: (val) => setState(() => _dataAnalytics = val),
              ),
            ],
          ),
          const SizedBox(height: 16), // Reduced height
          ElevatedButton.icon(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Row(
                    children: const [
                      Icon(Icons.check_circle, color: Colors.white),
                      SizedBox(width: 12),
                      Text('Privacy settings saved!'),
                    ],
                  ),
                  backgroundColor: Colors.green.shade600,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  margin: const EdgeInsets.all(16),
                ),
              );
            },
            icon: const Icon(Icons.save, size: 14), // Reduced size
            label: const Text('Save Privacy Settings', style: TextStyle(fontSize: 11)), // Reduced font size
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 10), // Reduced padding
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              backgroundColor: Colors.purple,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPrivacySection({
    required String title,
    required List<Widget> children,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(8), // Reduced padding
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 12, // Reduced font size
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const Divider(height: 1),
          ...children,
        ],
      ),
    );
  }

  Widget _buildPrivacyToggle({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required Function(bool) onChanged,
  }) {
    return SwitchListTile(
      secondary: Container(
        padding: const EdgeInsets.all(3), // Reduced padding
        decoration: BoxDecoration(
          color: value ? Colors.purple.withOpacity(0.1) : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          icon,
          color: value ? Colors.purple : Colors.grey,
          size: 14, // Reduced size
        ),
      ),
      title: Text(
        title,
        style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 11), // Reduced font size
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(fontSize: 9, color: Colors.grey[600]), // Reduced font size
      ),
      value: value,
      onChanged: onChanged,
      activeColor: Colors.purple,
    );
  }
}