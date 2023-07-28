import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:toolbox/profiles/profile.dart';
import 'package:http/http.dart' as http;
import 'package:intl/date_symbol_data_local.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  ProfileScreenState createState() => ProfileScreenState();
}

class ProfileScreenState extends State<ProfileScreen> {
  late Future<UserProfile> _userProfileFuture;

  void _copyToClipboard(String value) {
    Clipboard.setData(ClipboardData(text: value));
  }

  @override
  void initState() {
    super.initState();
    _userProfileFuture = fetchUserProfile();
  }

  Future<UserProfile> fetchUserProfile() async {
    final response = await http.get(Uri.parse('https://randomuser.me/api/?nat=fr&password=upper,special,upper,number,lower,8-16'));
    if (response.statusCode == 200) {
      final jsonResult = json.decode(response.body);
      final user = jsonResult['results'][0];
      return UserProfile(
        gender: user['gender'],
        title: user['name']['title'],
        firstName: user['name']['first'],
        lastName: user['name']['last'],
        streetName: user['location']['street']['name'],
        city: user['location']['city'],
        state: user['location']['state'],
        country: user['location']['country'],
        email: user['email'],
        username: user['login']['username'],
        dob: user['dob']['date'],
        phone: user['phone'],
        picture: user['picture']['large'],
        password: user['login']['password'],
      );
    } else {
      throw Exception('Failed to load user profile');
    }
  }

  void _refreshProfile() {
    setState(() {
      _userProfileFuture = fetchUserProfile();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: null,
      body: FutureBuilder<UserProfile>(
        future: _userProfileFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else {
            final userProfile = snapshot.data;
            return userProfile != null ? _buildProfileCard(userProfile) : const Center(child: Text('No data'));
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _refreshProfile,
        child: const Icon(Icons.refresh),
      ),
    );
  }

  Widget _buildProfileCard(UserProfile userProfile) {
    return Card(
      margin: const EdgeInsets.all(16.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 60,
              backgroundImage: NetworkImage(userProfile.picture),
            ),
            const SizedBox(height: 16),
            Text(
              '${userProfile.firstName} ${userProfile.lastName}',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              userProfile.gender,
              style: const TextStyle(fontSize: 16, color: Colors.grey),
            ),
            const SizedBox(height: 24),
            _buildPersonalInfoSection(userProfile),
            const SizedBox(height: 16),
            _buildLoginInfoSection(userProfile),
          ],
        ),
      ),
    );
  }

  Widget _buildPersonalInfoSection(UserProfile userProfile) {
    return Column(
      children: [
        ListTile(
          leading: const Icon(Icons.email),
          title: InkWell(
            child: Text(userProfile.email),
            onTap: () => _copyToClipboard(userProfile.email),
          ),
        ),
        ListTile(
          leading: const Icon(Icons.location_on),
          title: InkWell(
            child: Text('${userProfile.streetName}, ${userProfile.city}, ${userProfile.state}, ${userProfile.country}'),
            onTap: () => _copyToClipboard('${userProfile.streetName}, ${userProfile.city}, ${userProfile.state}, ${userProfile.country}'),
          ),
        ),
        ListTile(
          leading: const Icon(Icons.phone),
          title: InkWell(
            child: Text(formatFrenchNumber(userProfile.phone)),
            onTap: () => _copyToClipboard(formatFrenchNumber(userProfile.phone)),
          ),
        ),
        ListTile(
          leading: const Icon(Icons.calendar_today),
          title: InkWell(
            child: Text(formatBirthday(userProfile.dob)),
            onTap: () => _copyToClipboard(formatBirthday(userProfile.dob)),
          ),
        ),
      ],
    );
  }

  Widget _buildLoginInfoSection(UserProfile userProfile) {
    return Column(
      children: [
        ListTile(
          leading: const Icon(Icons.person),
          title: InkWell(
            child: Text(userProfile.username),
            onTap: () => _copyToClipboard(userProfile.username),
          ),
        ),
        ListTile(
          leading: const Icon(Icons.lock),
          title: InkWell(
            child: Text(userProfile.password),
            onTap: () => _copyToClipboard(userProfile.password),
          ),
        ),
      ],
    );
  }

  String formatFrenchNumber(String number) {
    return number.replaceAll('-', ' ');
  }

  String formatBirthday(String birthday) {
    initializeDateFormatting('fr_FR');
    DateTime date = DateTime.parse(birthday);
    String formattedDate = DateFormat('dd MMMM yyyy à HH:mm', 'fr_FR').format(date);
    return formattedDate;
  }
}

void main() {
  runApp(const MaterialApp(
    home: ProfileScreen(),
  ));
}