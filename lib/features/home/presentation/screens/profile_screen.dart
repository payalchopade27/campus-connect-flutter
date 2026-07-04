import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final supabase = Supabase.instance.client;

  bool loading = true;
  bool editing = false;

  // profile fields
  String fullName = '';
  String branch = '';
  String year = '';
  String bio = '';
  bool lookingForTeam = false;
  List<String> skills = [];
  List<String> techStack = [];

  // controllers
  final nameCtrl = TextEditingController();
  final branchCtrl = TextEditingController();
  final yearCtrl = TextEditingController();
  final bioCtrl = TextEditingController();
  final skillsCtrl = TextEditingController();
  final techCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    final userId = supabase.auth.currentUser!.id;

    final data = await supabase
        .from('profiles')
        .select()
        .eq('user_id', userId)
        .maybeSingle();

    if (data != null) {
      fullName = data['full_name'] ?? '';
      branch = data['branch'] ?? '';
      year = data['year'] ?? '';
      bio = data['bio'] ?? '';
      lookingForTeam = data['looking_for_team'] ?? false;
      skills = List<String>.from(data['skills'] ?? []);
      techStack = List<String>.from(data['tech_stack'] ?? []);
    }

    nameCtrl.text = fullName;
    branchCtrl.text = branch;
    yearCtrl.text = year;
    bioCtrl.text = bio;
    skillsCtrl.text = skills.join(', ');
    techCtrl.text = techStack.join(', ');

    setState(() => loading = false);
  }

  Future<void> _saveProfile() async {
    final userId = supabase.auth.currentUser!.id;

    await supabase.from('profiles').upsert({
      'user_id': userId,
      'full_name': nameCtrl.text.trim(),
      'branch': branchCtrl.text.trim(),
      'year': yearCtrl.text.trim(),
      'bio': bioCtrl.text.trim(),
      'skills': skillsCtrl.text.split(',').map((e) => e.trim()).toList(),
      'tech_stack': techCtrl.text.split(',').map((e) => e.trim()).toList(),
      'looking_for_team': lookingForTeam,
    });

    editing = false;
    _loadProfile();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F3F7),

      appBar: AppBar(
        title: const Text("My Profile"),
        actions: [
          IconButton(
            icon: Icon(editing ? Icons.close : Icons.edit),
            onPressed: () => setState(() => editing = !editing),
          )
        ],
      ),

      body: loading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _headerCard(),
          const SizedBox(height: 24),
          editing ? _editSection() : _viewSection(),
          if (editing) _saveButton(),
        ],
      ),
    );
  }

  /// 🔷 HEADER
  Widget _headerCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF4F46E5), Color(0xFF7C3AED)],
        ),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(fullName.isEmpty ? "Your Name" : fullName,
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.bold)),
          const SizedBox(height: 6),
          Text(
            "$branch • $year",
            style: const TextStyle(color: Colors.white70),
          ),
          const SizedBox(height: 12),
          if (lookingForTeam)
            _badge("Looking for Team"),
        ],
      ),
    );
  }

  /// 👁 VIEW MODE
  Widget _viewSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _section("Bio", bio.isEmpty ? "No bio added" : bio),
        _chipsSection("Skills", skills),
        _chipsSection("Tech Stack", techStack),
      ],
    );
  }

  /// ✏️ EDIT MODE
  Widget _editSection() {
    return Column(
      children: [
        _field("Full Name", nameCtrl),
        _field("Branch", branchCtrl),
        _field("Year", yearCtrl),
        _field("Bio", bioCtrl, max: 3),
        _field("Skills (comma separated)", skillsCtrl),
        _field("Tech Stack (comma separated)", techCtrl),
        SwitchListTile(
          value: lookingForTeam,
          onChanged: (v) => setState(() => lookingForTeam = v),
          title: const Text("Looking for Team"),
        ),
      ],
    );
  }

  Widget _saveButton() {
    return Padding(
      padding: const EdgeInsets.only(top: 24),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF4F46E5),
            padding: const EdgeInsets.all(14),
            shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          ),
          onPressed: _saveProfile,
          child: const Text("Save Profile",
              style: TextStyle(fontWeight: FontWeight.w600)),
        ),
      ),
    );
  }

  /// helpers
  Widget _section(String title, String text) => Padding(
    padding: const EdgeInsets.only(bottom: 20),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title,
            style:
            const TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
        const SizedBox(height: 6),
        Text(text, style: const TextStyle(color: Colors.black54)),
      ],
    ),
  );

  Widget _chipsSection(String title, List<String> items) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(title,
          style:
          const TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
      const SizedBox(height: 8),
      Wrap(
        spacing: 8,
        runSpacing: 8,
        children: items
            .map((e) => Chip(
          label: Text(e),
          backgroundColor: const Color(0xFFEDEBFF),
          labelStyle:
          const TextStyle(color: Color(0xFF4F46E5)),
        ))
            .toList(),
      ),
      const SizedBox(height: 20),
    ],
  );

  Widget _field(String label, TextEditingController c, {int max = 1}) =>
      Padding(
        padding: const EdgeInsets.only(bottom: 14),
        child: TextField(
          controller: c,
          maxLines: max,
          decoration: InputDecoration(
            labelText: label,
            border:
            OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
          ),
        ),
      );

  Widget _badge(String text) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(20),
    ),
    child: Text(text,
        style: const TextStyle(
            color: Color(0xFF4F46E5),
            fontWeight: FontWeight.w600)),
  );
}