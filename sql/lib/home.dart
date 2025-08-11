import 'package:flutter/material.dart';
import 'database_helper.dart';
import 'screen.dart'; 

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Map<String, dynamic>> users = [];
  final _nameController = TextEditingController();
  final _ageController = TextEditingController();
  final _domainController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _refreshUsers();
  }

  void _refreshUsers() async {
    final data = await DatabaseHelper.instance.queryAllUsers();
    setState(() {
      users = data;
    });
  }

  void _showForm({Map<String, dynamic>? user}) {
    if (user != null) {
      _nameController.text = user['name'];
      _domainController.text = user['domain'];
      _ageController.text = user['age'].toString();
    } else {
      _nameController.clear();
      _ageController.clear();
      _domainController.clear();
    }

    showModalBottomSheet(
      context: context,
      builder: (_) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            left: 15,
            right: 15,
            top: 15,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 20),
              TextField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Name'),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: _ageController,
                decoration: const InputDecoration(labelText: 'Age'),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 20),
              TextField(
                controller: _domainController,
                decoration: const InputDecoration(labelText: 'Domain'),
                keyboardType: TextInputType.name,
              ),
              const SizedBox(height: 30),
              ElevatedButton(
                onPressed: () async {
                  final name = _nameController.text.trim();
                  final age = int.tryParse(_ageController.text.trim()) ?? 0;
                  final domain = _domainController.text.trim();

                  if (name.isEmpty || age <= 0) return;

                  if (user == null) {
                    await DatabaseHelper.instance.insertUser({
                      'name': name,
                      'age': age,
                      'domain': domain,
                    });
                  } else {
                    await DatabaseHelper.instance.updateUser({
                      'id': user['id'],
                      'name': name,
                      'age': age,
                      'domain': domain,
                    });
                  }
                  _refreshUsers();
                  Navigator.of(context).pop();
                },
                child: Text(user == null ? 'Add User' : 'Update User'),
              ),
              const SizedBox(height: 50),
            ],
          ),
        );
      },
      isScrollControlled: true,
    );
  }

  void _deleteUser(int id) async {
    await DatabaseHelper.instance.deleteUser(id);
    _refreshUsers();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('SQflite'),
        backgroundColor: Colors.red, 
      ),
      body: users.isEmpty
          ? const Center(child: Text('No users found.'))
          : ListView.builder(
              itemCount: users.length,
              itemBuilder: (context, index) {
                final user = users[index];
                return Card(
                  margin:
                      const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                  child: ListTile(
                    title: Text(user['name']),
                    subtitle: Text(
                        'Age: ${user['age']}, Domain: ${user['domain']}'),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              StudentDetailsScreen(student: user),
                        ),
                      );
                    },
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon:
                              const Icon(Icons.edit, color: Colors.blue),
                          onPressed: () => _showForm(user: user),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () => _deleteUser(user['id']),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showForm(),
        child: const Icon(Icons.add),
      ),
    );
  }
}
