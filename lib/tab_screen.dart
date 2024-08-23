import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
// Main entry point
void main() {
  runApp(MyApp());
}

// Main Application Widget
class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SMK Negeri 4 - Student Portal',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        colorScheme: ColorScheme.fromSwatch(primarySwatch: Colors.blue).copyWith(
          secondary: Colors.lightBlueAccent, // Use colorScheme for secondary color
        ),
      ),
      home: TabScreen(),
    );
  }
}

// TabScreen with three tabs
class TabScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3, // Number of tabs
      child: Scaffold(
        appBar: AppBar(
          title: Text('SMK Negeri 4 - Siswa'),
          bottom: TabBar(
            tabs: [
              Tab(icon: Icon(Icons.dashboard), text: 'Dashboard'),
              Tab(icon: Icon(Icons.group), text: 'Students'),
              Tab(icon: Icon(Icons.account_circle), text: 'Profile'),
            ],
            labelColor: Color.fromARGB(255, 24, 24, 49),
            unselectedLabelColor: Colors.grey,
            indicatorColor: const Color.fromARGB(255, 0, 0, 0),
          ),
        ),
        body: TabBarView(
          children: [
            DashboardTab(),
            StudentsTab(),
            ProfileTab(),
            
          ],
        ),
      ),
    );
  }
}


class DashboardTab extends StatelessWidget {
  final List<Map<String, dynamic>> menuItems = [
    {'icon': Icons.menu_book, 'label': 'Subjects', 'color': Colors.red},
    {'icon': Icons.check_circle_outline, 'label': 'Attendance', 'color': Colors.green},
    {'icon': Icons.bar_chart, 'label': 'Performance', 'color': Colors.blue},
    {'icon': Icons.announcement, 'label': 'Notices', 'color': Colors.orange},
    {'icon': Icons.calendar_today, 'label': 'Schedule', 'color': Colors.purple},
    {'icon': Icons.mail_outline, 'label': 'Inbox', 'color': Colors.teal},
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [const Color.fromARGB(255, 58, 60, 61), const Color.fromARGB(255, 252, 252, 252)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(10.0),
        child: GridView.builder(
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            mainAxisSpacing: 10.0,
            crossAxisSpacing: 10.0,
            childAspectRatio: 1.2,
          ),
          itemCount: menuItems.length,
          itemBuilder: (context, index) {
            final item = menuItems[index];
            return GestureDetector(
              onTap: () {
                print('${item['label']} tapped');
              },
              child: Card(
                elevation: 8.0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.0),
                ),
                shadowColor: Colors.black.withOpacity(0.3), // Shadow color
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12.0),
                    gradient: LinearGradient(
                      colors: [item['color'].withOpacity(0.2), Colors.white],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: EdgeInsets.all(10.0),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.2),
                              blurRadius: 8.0,
                              offset: Offset(2, 2), // Shadow position
                            ),
                          ],
                        ),
                        child: Icon(
                          item['icon'],
                          size: 60.0,
                          color: item['color'],
                        ),
                      ),
                      SizedBox(height: 10.0),
                      Text(
                        item['label'],
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 16.0,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

// Layout for Students Tab
class StudentsTab extends StatefulWidget {
  @override
  _StudentsTabState createState() => _StudentsTabState();
}

class _StudentsTabState extends State<StudentsTab> {
  List<User> _students = [];
  List<User> _filteredStudents = [];

  @override
  void initState() {
    super.initState();
    fetchStudents().then((students) {
      setState(() {
        _students = students;
        _filteredStudents = students;
      });
    });
  }

  Future<List<User>> fetchStudents() async {
    final response = await http.get(Uri.parse('https://reqres.in/api/users?page=2'));
    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body)['data'];
      return data.map((user) => User.fromJson(user)).toList();
    } else {
      throw Exception('Failed to load students');
    }
  }

  void _filterStudents(String query) {
    final filtered = _students.where((student) {
      final studentName = student.firstName.toLowerCase();
      final input = query.toLowerCase();
      return studentName.contains(input);
    }).toList();

    setState(() {
      _filteredStudents = filtered;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.blue.shade100, Color.fromARGB(255, 255, 255, 255)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            // Search bar for searching students
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 10.0),
              child: TextField(
                decoration: InputDecoration(
                  prefixIcon: Icon(Icons.search, color: const Color.fromARGB(255, 2, 2, 2)),
                  hintText: 'Cari Siswa',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                ),
                onChanged: (value) {
                  _filterStudents(value);
                },
              ),
            ),
            Expanded(
              child: _filteredStudents.isEmpty
                  ? Center(child: Text('Tidak ada siswa ditemukan', style: TextStyle(color: Colors.white70)))
                  : ListView.builder(
                      itemCount: _filteredStudents.length,
                      itemBuilder: (context, index) {
                        final user = _filteredStudents[index];
                        return Card(
                          margin: EdgeInsets.symmetric(vertical: 8.0, horizontal: 5.0),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12.0),
                          ),
                          elevation: 5.0,
                          color: Colors.white,
                          child: ListTile(
                            leading: CircleAvatar(
                              radius: 30,
                              backgroundImage: NetworkImage(user.avatar),
                              backgroundColor: Colors.blueAccent, // Default background color
                              child: user.avatar.isEmpty
                                  ? Text(
                                      user.firstName[0],
                                      style: TextStyle(color: Colors.white, fontSize: 20),
                                    )
                                  : null,
                            ),
                            title: Text(
                              user.firstName,
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            subtitle: Text(user.email),
                            trailing: Icon(Icons.arrow_forward_ios, color: const Color.fromARGB(255, 0, 0, 0)),
                            onTap: () {
                              // Handle onTap, e.g., navigate to a detailed profile page
                            },
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

//tab profile
class ProfileTab extends StatefulWidget {
  @override
  _ProfileTabState createState() => _ProfileTabState();
}

class _ProfileTabState extends State<ProfileTab> {
  String _name = 'Zankikarin';
  String _email = 'email@example.com';
  String _birthdate = '2000-01-01'; // Format: YYYY-MM-DD

  void _updateProfile(String name, String email, String birthdate) {
    setState(() {
      _name = name;
      _email = email;
      _birthdate = birthdate;
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(000), Color(0xFFB0E0E6)], // Gradien biru langit
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 20),
                Center(
                  child: CircleAvatar(
                    radius: 60,
                    backgroundColor: Colors.white,
                    child: CircleAvatar(
                      radius: 55,
                      backgroundImage: AssetImage('https://wallpapers.com/images/hd/anime-profile-picture-tebfn1alembbzoqw.jpg'), // Perbarui path gambar
                    ),
                  ),
                ),
                SizedBox(height: 20),
                Center(
                  child: Text(
                    _name,  // Gunakan nama terbaru
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: const Color.fromARGB(255, 0, 0, 0),
                    ),
                  ),
                ),
                SizedBox(height: 10),
                Center(
                  child: Text(
                    _email,  // Gunakan email terbaru
                    style: TextStyle(
                      fontSize: 16,
                      color: const Color.fromARGB(179, 0, 0, 0),
                    ),
                  ),
                ),
                SizedBox(height: 30),
                Card(
                  color: Colors.white,
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Informasi Profil',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.blueAccent,
                          ),
                        ),
                        Divider(),
                        ListTile(
                          leading: Icon(Icons.person, color: Colors.blueAccent),
                          title: Text('Nama Lengkap'),
                          subtitle: Text(_name),  // Gunakan nama terbaru
                        ),
                        ListTile(
                          leading: Icon(Icons.cake, color: Colors.blueAccent),
                          title: Text('Tanggal Lahir'),
                          subtitle: Text(_birthdate),  // Gunakan tanggal lahir terbaru
                        ),
                        ListTile(
                          leading: Icon(Icons.phone, color: Colors.blueAccent),
                          title: Text('Nomor Kontak'),
                          subtitle: Text('+62 123 456 7890'),
                        ),
                        ListTile(
                          leading: Icon(Icons.location_on, color: Colors.blueAccent),
                          title: Text('Alamat'),
                          subtitle: Text('Jl. Contoh No. 123, Jakarta'),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton.icon(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => EditProfileScreen(
                              name: _name,
                              email: _email,
                              birthdate: _birthdate,
                              onProfileUpdated: _updateProfile,
                            ),
                          ),
                        );
                      },
                      icon: Icon(Icons.edit),
                      label: Text('Edit Profil'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blueAccent,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                    ElevatedButton.icon(
                      onPressed: () {
                        // Tangani aksi logout
                      },
                      icon: Icon(Icons.logout),
                      label: Text('Logout'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.redAccent,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}


// Layar Edit Profil
class EditProfileScreen extends StatefulWidget {
  final String name;
  final String email;
  final String birthdate;
  final Function(String, String, String) onProfileUpdated;

  EditProfileScreen({
    required this.name,
    required this.email,
    required this.birthdate,
    required this.onProfileUpdated,
  });

  @override
  _EditProfileScreenState createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late String _name;
  late String _email;
  late String _birthdate;

  @override
  void initState() {
    super.initState();
    _name = widget.name;
    _email = widget.email;
    _birthdate = widget.birthdate;
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.parse(_birthdate),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != DateTime.parse(_birthdate)) {
      setState(() {
        _birthdate = picked.toIso8601String().split('T')[0];
      });
    }
  }

  Future<void> _saveChanges() async {
    if (_formKey.currentState!.validate()) {
      widget.onProfileUpdated(_name, _email, _birthdate);
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Profil'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                initialValue: _name,
                decoration: InputDecoration(labelText: 'Nama Lengkap'),
                onChanged: (value) => setState(() => _name = value),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Mohon masukkan nama lengkap';
                  }
                  return null;
                },
              ),
              TextFormField(
                initialValue: _email,
                decoration: InputDecoration(labelText: 'Alamat Email'),
                onChanged: (value) => setState(() => _email = value),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Mohon masukkan alamat email';
                  }
                  if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                    return 'Mohon masukkan alamat email yang valid';
                  }
                  return null;
                },
              ),
              SizedBox(height: 20),
              Text('Tanggal Lahir:'),
              InkWell(
                onTap: () => _selectDate(context),
                child: Container(
                  padding: EdgeInsets.symmetric(vertical: 8.0),
                  decoration: BoxDecoration(
                    border: Border(bottom: BorderSide(color: Colors.grey)),
                  ),
                  child: Text(
                    _birthdate,
                    style: TextStyle(fontSize: 16.0),
                  ),
                ),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _saveChanges,
                child: Text('Simpan Perubahan'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}


// User model
class User {
  final String firstName;
  final String email;
  final String avatar; // URL avatar

  User({required this.firstName, required this.email, required this.avatar});

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      firstName: json['first_name'],
      email: json['email'],
      avatar: json['avatar'], // Mengambil URL avatar
    );
  }
}